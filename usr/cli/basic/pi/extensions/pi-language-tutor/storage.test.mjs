import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

// Run against a package copy outside node_modules, with a disposable HOME.
const agent = path.join(os.homedir(), '.pi', 'agent');
const directory = path.join(agent, 'pi-language-tutor');
const linked = process.argv[3] === 'symlink';
if (linked) {
  const backing = path.join(os.homedir(), 'Gist', 'Data', 'pi', 'pi-language-tutor');
  fs.mkdirSync(backing, { recursive: true });
  fs.mkdirSync(agent, { recursive: true });
  fs.symlinkSync(backing, directory);
}
const load = (file) => import(pathToFileURL(path.join(process.argv[2], 'src', file)));
const config = await load('config.ts');
const settings = await load('flashcard-settings.ts');
const cards = await load('flashcards.ts');

for (const round of [1, 2]) {
  const cfg = { ...config.DEFAULT_CONFIG, native: round === 1 ? 'zh' : 'en' };
  config.saveConfig(cfg);
  assert.ok(fs.existsSync(path.join(directory, 'language-learn.json')), 'config uses the tutor directory');
  assert.deepEqual(config.loadConfig(), cfg);

  const review = { ...settings.DEFAULT_SETTINGS, newPerDay: round };
  settings.saveSettings(review);
  assert.ok(fs.existsSync(path.join(directory, 'flashcards-settings.json')), 'review settings use the tutor directory');
  assert.deepEqual(settings.loadSettings(), review);

  const library = cards.loadCards();
  assert.equal(cards.addCard(library, `word-${round}`, 'test note', 'manual'), true);
  cards.saveCards(library);
  assert.ok(fs.existsSync(path.join(directory, 'flashcards.json')), 'flashcards use the tutor directory');
  assert.equal(JSON.stringify(cards.loadCards()), JSON.stringify(library));
  if (linked) assert.ok(fs.lstatSync(directory).isSymbolicLink(), 'atomic writes preserve the directory link');
}
assert.deepEqual(fs.readdirSync(agent), ['pi-language-tutor']);
assert.deepEqual(fs.readdirSync(directory).sort(), ['flashcards-settings.json', 'flashcards.json', 'language-learn.json']);
console.log(`Tutor storage passed (${linked ? 'directory symlink' : 'fresh directory'})`);
