import { getAgentDir, type ExtensionAPI, type ExtensionContext } from '@earendil-works/pi-coding-agent';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { Kokoro } from './backend.mjs';
import { Player } from './player.mjs';
import { Reader } from './reader.mjs';
import { latestReply, speechText } from './text.mjs';

export default function (pi: ExtensionAPI) {
  let context: ExtensionContext | undefined;
  let version = 0;
  let disposed = false;
  const backend = new Kokoro({
    modelDir: join(homedir(), '.pi/models/tts/kokoro-multi-lang-v1_1'),
    logPath: join(getAgentDir(), 'read-aloud.log'),
  });
  const notify = (text: string, level: 'info' | 'error' = 'info') => {
    if (context?.hasUI) context.ui.notify(text, level);
  };
  const reader = new Reader({
    backend,
    createPlayer: options => new Player(options),
    onState: () => {},
    onError: error => notify(`Read aloud: ${error.message}`, 'error'),
  });
  const stop = (ctx: ExtensionContext) => { version++; context = ctx; return reader.stop(); };

  pi.registerShortcut('alt+r', {
    description: 'Read latest reply, pause, or resume / switch to a newer reply',
    handler: async ctx => {
      if (disposed) return;
      version++; context = ctx;
      const reply = latestReply(ctx.sessionManager.getBranch());
      if (!reply && reader.state === 'idle') notify('No assistant reply with speakable text.');
      else reader.toggle(reply);
    },
  });
  pi.registerCommand('voice-speak', {
    description: 'Read the latest completed assistant reply, or the supplied text',
    handler: async (args, ctx) => {
      if (disposed) return;
      const request = ++version;
      if (!args.trim()) await ctx.waitForIdle();
      if (disposed || request !== version) return;
      context = ctx;
      const latest = latestReply(ctx.sessionManager.getBranch());
      const reply = args.trim() ? { id: latest?.id, text: speechText(args) } : latest;
      if (!reply?.text) notify('No assistant reply with speakable text.');
      else reader.start(reply);
    },
  });
  pi.registerCommand('voice-speak-stop', {
    description: 'Stop speech and cancel a pending read request',
    handler: async (_args, ctx) => { if (!disposed) await stop(ctx); },
  });
  pi.on('session_start', (_event, ctx) => { context = ctx; });
  pi.on('session_tree', (_event, ctx) => stop(ctx));
  pi.on('session_shutdown', async (_event, ctx) => {
    disposed = true; version++; context = ctx;
    await reader.close();
    context = undefined;
  });
}
