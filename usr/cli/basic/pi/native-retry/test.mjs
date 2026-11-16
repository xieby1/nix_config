import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

const root = process.env.PI_ROOT;
assert.ok(root, "PI_ROOT must point to the built pi-monorepo package");
const { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager, defineTool } =
  await import(pathToFileURL(join(root, "dist/index.js")));
const { fauxProvider, fauxAssistantMessage, fauxToolCall } =
  await import(pathToFileURL(join(root, "node_modules/@earendil-works/pi-ai/dist/providers/faux.js")));
const { isRetryableAssistantError, retryDelayMs } =
  await import(pathToFileURL(join(root, "node_modules/@earendil-works/pi-ai/dist/utils/retry.js")));
const { Type } = await import(pathToFileURL(join(root, "node_modules/typebox/build/index.mjs")));

const basispoints = "basispoints_protocol_error: basispoints tool transport correction changed an operation; no tool was executed";
const policyBlock = 'jw2-openai API error (429): {"code":"prompt_repetition_policy","message":"重复提交相同请求，已限流，约 55 分钟后自动恢复 / rate limited, retry in ~55 min","type":"permission_error"}';
const failure = (errorMessage = basispoints) => fauxAssistantMessage([], { stopReason: "error", errorMessage });

async function harness(t, responses, retry = {}, customTools = []) {
  const cwd = mkdtempSync(join(tmpdir(), "pi-native-retry-"));
  t.after(() => rmSync(cwd, { recursive: true, force: true }));
  const faux = fauxProvider({
    provider: "native-retry-test", api: "native-retry-test-api",
    models: [{ id: "test", name: "Test", reasoning: false }], tokenSize: { min: 1, max: 1 },
  });
  const requests = [];
  faux.setResponses(responses.map(response => context => {
    requests.push({ at: performance.now(), messages: structuredClone(context.messages) });
    return response;
  }));
  const modelRuntime = await ModelRuntime.create({
    authPath: join(cwd, "auth.json"), modelsPath: null, refreshOnCreate: false,
  });
  modelRuntime.registerNativeProvider(faux.provider);
  await modelRuntime.refresh({ allowNetwork: false });
  const settingsManager = SettingsManager.inMemory({
    retry: { enabled: true, maxRetries: 10, baseDelayMs: 10, maxAgentDelayMs: 100, ...retry },
    compaction: { enabled: false }, cacheWarming: "off",
  });
  const loader = new DefaultResourceLoader({
    cwd, agentDir: cwd, settingsManager, noExtensions: true, noSkills: true,
    noPromptTemplates: true, noThemes: true, noContextFiles: true,
  });
  await loader.reload();
  const { session } = await createAgentSession({
    cwd, agentDir: cwd, modelRuntime, model: modelRuntime.getModel("native-retry-test", "test"),
    thinkingLevel: "off", settingsManager, resourceLoader: loader,
    sessionManager: SessionManager.inMemory(cwd), tools: customTools.map(tool => tool.name), customTools,
  });
  t.after(async () => { await session.abort(); session.dispose(); });
  await session.bindExtensions({ mode: "rpc" });
  const scheduled = [];
  const finished = [];
  session.subscribe(event => {
    if (event.type === "auto_retry_start") scheduled.push({ ...event, at: performance.now() });
    if (event.type === "auto_retry_end") finished.push(event);
  });
  return { session, faux, requests, scheduled, finished };
}

function assertCleanRetries(h) {
  assert.equal(h.session.sessionManager.getEntries().filter(e => e.type === "custom_message").length, 0);
  for (const request of h.requests.slice(1)) {
    assert.ok(!request.messages.some(m => m.role === "assistant" && m.stopReason === "error"));
    assert.ok(!request.messages.some(m => m.role === "user" && JSON.stringify(m.content).includes("Retry the previous request.")));
  }
}

test("classification is narrow and prompt policy errors use generic 429 matching", () => {
  assert.equal(isRetryableAssistantError(failure()), true);
  assert.equal(isRetryableAssistantError(failure(policyBlock)), true);
  for (const error of [
    "basispoints_protocol_error: invalid operation",
    "another_protocol_error: no tool was executed",
    "permission_error: forbidden",
    "401 invalid API key", "400 invalid request", "429 insufficient_quota", "403 quota exceeded",
  ]) assert.equal(isRetryableAssistantError(failure(error)), false, error);
  for (const error of ["429 too many requests", "500 internal server error", "connection refused"]) {
    assert.equal(isRetryableAssistantError(failure(error)), true, error);
  }
  assert.equal(isRetryableAssistantError(fauxAssistantMessage(basispoints)), false);
  assert.equal(isRetryableAssistantError({ ...failure(), stopReason: "aborted" }), false);
  assert.deepEqual(Array.from({ length: 10 }, (_, i) => retryDelayMs({ baseDelayMs: 1000, maxAgentDelayMs: 10000 }, i + 1)),
    [1000, 2000, 4000, 8000, 10000, 10000, 10000, 10000, 10000, 10000]);
});

for (const [name, errorMessage] of [["basispoints", basispoints], ["prompt repetition policy", policyBlock]]) {
  test(`consecutive ${name} failures grow backoff and stop at ten retries`, { timeout: 10000 }, async t => {
    const h = await harness(t, Array.from({ length: 12 }, () => failure(errorMessage)));
    await h.session.prompt("Do the task");
    assert.equal(h.faux.state.callCount, 11);
    assert.deepEqual(h.scheduled.map(e => e.attempt), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    assert.deepEqual(h.scheduled.map(e => e.delayMs), [10, 20, 40, 80, 100, 100, 100, 100, 100, 100]);
    h.scheduled.forEach((e, i) => assert.ok(h.requests[i + 1].at - e.at >= e.delayMs - 2));
    assert.equal(h.finished.at(-1).success, false);
    assert.equal(h.finished.at(-1).attempt, 10);
    assert.equal(h.session.messages.at(-1).errorMessage, errorMessage);
    assertCleanRetries(h);
  });
}

test("cancelling backoff prevents the next request", { timeout: 10000 }, async t => {
  const h = await harness(t, [failure(), fauxAssistantMessage("must not be requested")], { baseDelayMs: 1000, maxAgentDelayMs: 1000 });
  // The TUI Escape key invokes this same native cancellation method.
  h.session.subscribe(event => { if (event.type === "auto_retry_start") queueMicrotask(() => h.session.abortRetry()); });
  await h.session.prompt("Do the task");
  assert.equal(h.scheduled.length, 1);
  assert.equal(h.faux.state.callCount, 1);
  assert.equal(h.session.isRetrying, false);
  assert.equal(h.finished.at(-1).success, false);
});

test("tool progress resets the failure streak without losing valid tool context", { timeout: 10000 }, async t => {
  let toolCalls = 0;
  const tool = defineTool({
    name: "probe", label: "Probe", description: "Return a deterministic result", parameters: Type.Object({}),
    execute: async () => { toolCalls++; return { content: [{ type: "text", text: "valid tool result" }], details: {} }; },
  });
  const h = await harness(t, [
    failure(), failure(),
    fauxAssistantMessage([fauxToolCall("probe", {}, { id: "valid-call" })], { stopReason: "toolUse" }),
    failure(), fauxAssistantMessage("done"),
  ], {}, [tool]);
  await h.session.prompt("Do the task");
  assert.equal(h.faux.state.callCount, 5);
  assert.equal(toolCalls, 1);
  assert.deepEqual(h.scheduled.map(e => [e.attempt, e.delayMs]), [[1, 10], [2, 20], [1, 10]]);
  assert.equal(h.session.getLastAssistantText(), "done");
  const lastContext = h.requests.at(-1).messages;
  assert.ok(lastContext.some(m => m.role === "assistant" && m.content.some(c => c.type === "toolCall" && c.id === "valid-call")));
  assert.ok(lastContext.some(m => m.role === "toolResult" && m.toolCallId === "valid-call"));
  assert.equal(h.session.sessionManager.getEntries().filter(e => e.type === "message" && e.message.stopReason === "error").length, 3);
  assertCleanRetries(h);
});
