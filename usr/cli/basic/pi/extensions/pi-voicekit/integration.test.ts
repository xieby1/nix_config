import { afterAll, beforeEach, expect, mock, test } from "bun:test";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { EventEmitter } from "node:events";

// Run from upstream's tests directory; native audio is covered separately by the Nix smoke test.
const home = os.homedir();
if (!process.env.VOICEKIT_TEST_HOME || home !== process.env.VOICEKIT_TEST_HOME) {
  throw new Error("Run with HOME and VOICEKIT_TEST_HOME pointing to the same disposable directory.");
}
process.env.PI_CODING_AGENT_DIR = path.join(home, ".pi/agent");
const modelId = "kokoro-multi-lang-v1_1";
const modelDir = path.join(home, ".pi/models/tts", modelId);
fs.mkdirSync(modelDir, { recursive: true });
for (const name of ["model.onnx", "tokens.txt", "voices.bin", "lexicon-us-en.txt", "lexicon-zh.txt", "lexicon-gb-en.txt", "number-zh.fst", "date-zh.fst", "phone-zh.fst"]) {
  fs.writeFileSync(path.join(modelDir, name), "");
}
fs.mkdirSync(process.env.PI_CODING_AGENT_DIR, { recursive: true });
fs.writeFileSync(path.join(process.env.PI_CODING_AGENT_DIR, "settings.json"), JSON.stringify({
  voice: { enabled: false, punctuationEnabled: false, previewEnabled: false, ttsEnabled: true, ttsAutoSpeak: false, ttsLocalModel: modelId, ttsLocalVoiceId: 0, ttsSpeed: 1 },
}));
let nativeConfig: any;
mock.module("../extensions/voice/sherpa-loader", () => ({
  loadSherpa: async () => true,
  getSherpaError: () => null,
  isSherpaAvailable: () => true,
  getSherpaModule: () => ({ OfflineTts: { createAsync: async (config: any) => { nativeConfig = config; return { sampleRate: 24000, numSpeakers: 103 }; } } }),
}));
let spoken: any[] = [];
let speakImpl = async (_opts: any) => {};
mock.module("../extensions/voice/speak", () => ({ speak: async (opts: any) => { spoken.push(opts); await speakImpl(opts); } }));
const { default: extension } = await import("../extensions/voice");
const { TTS_LOCAL_MODELS } = await import("../extensions/voice/tts-local-models");
const { warmupTts, clearTtsCache } = await import("../extensions/voice/tts-engine");

beforeEach(() => { spoken = []; speakImpl = async () => {}; clearTtsCache(); });
afterAll(() => clearTtsCache());

async function harness(entries: any[] = [], hasUI = false) {
  const commands = new Map<string, any>();
  const handlers = new Map<string, any[]>();
  const notices: string[] = [];
  let idleWaits = 0;
  let inputHooks = 0;
  extension({
    on: (name: string, fn: any) => handlers.set(name, [...(handlers.get(name) ?? []), fn]),
    registerCommand: (name: string, cmd: any) => commands.set(name, cmd),
    registerShortcut() {},
    appendEntry() {},
    events: new EventEmitter(),
  } as any);
  const ctx: any = {
    cwd: home, hasUI,
    waitForIdle: async () => { idleWaits++; },
    sessionManager: { getBranch: () => entries },
    ui: { notify: (message: string) => notices.push(message), setStatus() {}, setWidget() {}, onTerminalInput: () => { inputHooks++; return () => {}; } },
  };
  for (const fn of handlers.get("session_start") ?? []) await fn({ reason: "startup" }, ctx);
  return { commands, handlers, notices, ctx, idleWaits: () => idleWaits, inputHooks: () => inputHooks };
}

test("catalogue exposes the exact auditioned model and af_maple speaker", () => {
  const model = TTS_LOCAL_MODELS.find((m: any) => m.id === modelId);
  expect(model).toBeDefined();
  expect(model!.languages).toEqual(["zh", "en"]);
  expect(model!.voices.find((v: any) => v.sid === 0)?.name).toContain("af_maple");
  expect(model!.archiveSha256).toBe("b78e1ac42b852e839cceaafbe88f66806bf5860992d1d7b9a3f2ad1198427aed");
});

test("native Kokoro configuration uses four CPU threads and both lexicons", async () => {
  const model = TTS_LOCAL_MODELS.find((m: any) => m.id === modelId)!;
  expect(await warmupTts(model, modelDir)).toBe(true);
  expect(nativeConfig.model.numThreads).toBe(4);
  expect(nativeConfig.model.provider).toBe("cpu");
  expect(nativeConfig.model.kokoro.model).toBe(path.join(modelDir, "model.onnx"));
  expect(nativeConfig.model.kokoro.lexicon.split(",").sort()).toEqual([path.join(modelDir, "lexicon-us-en.txt"), path.join(modelDir, "lexicon-zh.txt")]);
  expect(nativeConfig.ruleFsts).toBe(["number-zh.fst", "date-zh.fst", "phone-zh.fst"].map((name) => path.join(modelDir, name)).join(","));
});

test("disabled dictation does not prompt for an STT model or hook terminal input", async () => {
  const h = await harness([], true);
  expect(h.notices).toEqual([]);
  expect(h.inputHooks()).toBe(0);
});

test("no-argument speech reads the latest branch answer after idle and strips code", async () => {
  const h = await harness([
    { type: "message", message: { role: "assistant", content: [{ type: "text", text: "Older answer" }] } },
    { type: "message", message: { role: "assistant", content: [
      { type: "thinking", thinking: "private thought" },
      { type: "text", text: "你好。**Tests passed.**\n```sh\nsecret-command\n```\nSee [details](https://example.test)." },
      { type: "toolCall", name: "bash", arguments: { command: "do-not-speak" } },
    ] } },
    { type: "message", message: { role: "toolResult", content: [{ type: "text", text: "tool output" }] } },
  ]);
  await h.commands.get("voice-speak").handler("", h.ctx);
  expect(h.idleWaits()).toBe(1);
  expect(spoken).toHaveLength(1);
  expect(spoken[0].text).toContain("你好。Tests passed.");
  for (const omitted of ["Older answer", "private thought", "secret-command", "do-not-speak", "tool output", "https://"]) expect(spoken[0].text).not.toContain(omitted);
  expect(spoken[0].config.ttsLocalVoiceId).toBe(0);
});

test("empty conversation reports no answer without starting speech", async () => {
  const h = await harness();
  await h.commands.get("voice-speak").handler("", h.ctx);
  expect(spoken).toHaveLength(0);
  expect(h.notices.join(" " )).toContain("No assistant reply");
});

test("explicit text still works and stop cancels the existing speech pipeline", async () => {
  const h = await harness();
  speakImpl = (opts: any) => new Promise<void>((resolve) => opts.signal.addEventListener("abort", () => resolve(), { once: true }));
  const active = h.commands.get("voice-speak").handler("Hello 你好", h.ctx);
  for (let i = 0; i < 100 && spoken.length === 0; i++) await Bun.sleep(5);
  expect(spoken).toHaveLength(1);
  expect(spoken[0].text).toBe("Hello 你好");
  await h.commands.get("voice-speak-stop").handler("", h.ctx);
  await active;
  expect(spoken[0].signal.aborted).toBe(true);
});
