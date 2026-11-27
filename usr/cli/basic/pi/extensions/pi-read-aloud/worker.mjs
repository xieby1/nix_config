import { createRequire } from 'node:module';
import { accessSync } from 'node:fs';
import { join } from 'node:path';

const require = createRequire(import.meta.url);
const modelDir = process.argv[2];
const file = name => { const path = join(modelDir, name); accessSync(path); return path; };
let engine;
let busy = false;

// This file is forked with stdout/stderr pointing directly at the private log.
process.on('disconnect', () => process.exit(0));
process.on('message', async ({ text }) => {
  if (busy) { process.send({ error: 'Synthesis is already busy' }); return; }
  busy = true;
  try {
    if (typeof text !== 'string' || !text.trim() || text.length > 600) throw new Error('Invalid speech chunk');
    if (!engine) {
      const config = {
        model: {
          kokoro: {
            model: file('model.onnx'), voices: file('voices.bin'), tokens: file('tokens.txt'),
            dataDir: file('espeak-ng-data'), lengthScale: 1,
            lexicon: ['lexicon-us-en.txt', 'lexicon-zh.txt'].map(file).join(','),
          },
          numThreads: 4, provider: 'cpu',
        },
        ruleFsts: ['number-zh.fst', 'date-zh.fst', 'phone-zh.fst'].map(file).join(','),
      };
      const { OfflineTts } = require('sherpa-onnx-node');
      engine = new OfflineTts(config);
    }
    // The native progress callback is unsafe in 1.13.0; cancellation kills this child.
    const audio = await engine.generateAsync({ text, sid: 0, speed: 1 });
    process.send({ samples: audio.samples, sampleRate: audio.sampleRate ?? engine.sampleRate }, () => {});
  } catch (error) {
    process.send({ error: error instanceof Error ? error.message : String(error) }, () => {});
  } finally { busy = false; }
});
