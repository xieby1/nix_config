import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const { PI_ROOT, VOICEKIT_DIR, VOICEKIT_MODEL, VOICEKIT_SETTINGS } = process.env;
assert(PI_ROOT && VOICEKIT_DIR && VOICEKIT_MODEL && VOICEKIT_SETTINGS, "Run through check.nix or provide the four package paths");
const home = os.homedir();
assert.equal(home, process.env.VOICEKIT_TEST_HOME, "Use a disposable HOME");
const agent = path.join(home, ".pi/agent");
const cwd = path.join(home, "project");
fs.mkdirSync(agent, { recursive: true });
fs.mkdirSync(cwd, { recursive: true });
fs.copyFileSync(VOICEKIT_SETTINGS, path.join(agent, "settings.json"));
process.env.PI_CODING_AGENT_DIR = agent;
const settings = JSON.parse(fs.readFileSync(VOICEKIT_SETTINGS, "utf8"));
const modelId = settings.voice.ttsLocalModel;
fs.mkdirSync(path.join(home, ".pi/models/tts"), { recursive: true });
fs.symlinkSync(VOICEKIT_MODEL, path.join(home, ".pi/models/tts", modelId));

const { discoverAndLoadExtensions } = await import(pathToFileURL(path.join(PI_ROOT, "dist/core/extensions/loader.js")));
const loaded = await discoverAndLoadExtensions([VOICEKIT_DIR], cwd, agent);
assert.deepEqual(loaded.errors, []);
assert.equal(loaded.extensions.length, 1);
const extension = loaded.extensions[0];
assert(extension.commands.has("voice-speak"));
assert(extension.commands.has("voice-speak-stop"));
const notices = [];
const ctx = {
  cwd, hasUI: false,
  ui: { notify: (text) => notices.push(text), setStatus() {}, setWidget() {} },
  sessionManager: { getBranch: () => [] },
  waitForIdle: async () => {},
};
for (const handler of extension.handlers.get("session_start") ?? []) await handler({ reason: "startup" }, ctx);
assert.deepEqual(notices, []);
await extension.commands.get("voice-speak").handler("", ctx);
assert(notices.some((text) => text.includes("No assistant reply")));

const { createJiti } = await import(pathToFileURL(path.join(PI_ROOT, "node_modules/jiti/lib/jiti.mjs")));
const jiti = createJiti(import.meta.url);
const engine = await jiti.import(path.join(VOICEKIT_DIR, "extensions/voice/tts-engine.ts"));
const started = performance.now();
const audio = await engine.synthesizeById({
  text: "你好，语音已经准备好了。The server manager drinks water. 检查 tokenizer 和 phonemizer。",
  modelId, modelDir: VOICEKIT_MODEL, language: "zh", sid: settings.voice.ttsLocalVoiceId, speed: 1,
});
assert.equal(audio.sampleRate, 24000);
assert(audio.samples.length > 24000);
assert(audio.samples.every(Number.isFinite));
assert(audio.samples.some((sample) => Math.abs(sample) > 0.01));
console.log(JSON.stringify({ loaded: true, modelId, speaker: settings.voice.ttsLocalVoiceId, sampleRate: audio.sampleRate, audioSeconds: audio.samples.length / audio.sampleRate, wallSeconds: (performance.now() - started) / 1000 }));
engine.clearTtsCache();
for (const handler of extension.handlers.get("session_shutdown") ?? []) await handler({ reason: "quit" }, ctx);
