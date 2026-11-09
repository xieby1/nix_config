import assert from 'node:assert/strict';
import { test } from 'node:test';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
const root = process.env.READ_ALOUD_PACKAGE ?? new URL('.', import.meta.url).pathname;
const { latestReply, speechText, speechChunks } = await import(pathToFileURL(join(root, 'text.mjs')).href);
const message = (id, content, stopReason = 'stop') => ({ id, type: 'message', message: { role: 'assistant', stopReason, content } });

test('select only completed assistant prose from the current branch', () => {
  const entry = message('answer', [{ type: 'thinking', thinking: 'private reasoning' }, { type: 'text', text: '你好，**world**。' }, { type: 'toolCall', name: 'bash', arguments: { command: 'secret' } }]);
  const entries = [entry, message('aborted', [{ type: 'text', text: 'partial' }], 'aborted'), message('error', [{ type: 'text', text: 'failed' }], 'error'), { type: 'message', message: { role: 'toolResult', content: [{ type: 'text', text: 'tool output' }] } }];
  assert.deepEqual(latestReply(entries), { id: 'answer', text: '你好，world。' });
});

test('identical text in different replies keeps the newest session entry identity', () => {
  assert.deepEqual(latestReply([message('one', [{ type: 'text', text: 'Same.' }]), message('two', [{ type: 'text', text: 'Same.' }])]), { id: 'two', text: 'Same.' });
});

test('empty, thinking-only and code-only branches have no speakable reply', () => {
  assert.equal(latestReply([]), undefined);
  assert.equal(latestReply([message('thought', [{ type: 'thinking', thinking: 'hidden' }])]), undefined);
  assert.equal(latestReply([message('code', [{ type: 'text', text: '```sh\nrm -rf never-read-this\n```' }])]), undefined);
});

test('remove fenced and indented code while retaining prose and inline names', () => {
  const input = '# Title\nRead `foo` and [the docs](https://example.com).\n```js\nsecret()\n```\n    another_secret()\n- 继续。\n~~~python\nprivate()\n~~~\nEnd.';
  assert.equal(speechText(input), 'Title\nRead foo and the docs.\n继续。\nEnd.');
  assert.equal(speechText('Before.\n````js\n```\nnot prose\n````\nAfter.'), 'Before.\nAfter.');
  assert.equal(speechText('Before.\n~~~\nunfinished code'), 'Before.');
});

test('exclude fenced code nested inside quotes or lists', () => {
  assert.equal(speechText('> ```js\n> secret()\n> ```\nRead me.'), 'Read me.');
  assert.equal(speechText('- ```js\n  secret()\n  ```\nRead me.'), 'Read me.');
});

test('chunk at sentences and bound long unbroken Unicode text without corruption', () => {
  assert.deepEqual([...speechChunks('你好。 Hello world!')], ['你好。', 'Hello world!']);
  const text = '中😀'.repeat(1000);
  const chunks = [...speechChunks(text)];
  assert(chunks.length > 1);
  assert(chunks.every(chunk => chunk.length > 0 && chunk.length <= 400 && chunk.isWellFormed()));
  assert.equal(chunks.join(''), text);
});

test('chunking does not lose words from long English sentences', () => {
  const text = ('Keep all these words and numbers 123 ').repeat(80).trim();
  const chunks = [...speechChunks(text)];
  assert(chunks.every(chunk => chunk.length <= 400));
  assert.equal(chunks.join(' ').replace(/\s+/g, ' '), text);
});
