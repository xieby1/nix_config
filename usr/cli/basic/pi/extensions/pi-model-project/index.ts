import { mkdirSync, mkdtempSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import {
  getAgentDir,
  getPackageDir,
  ModelSelectorComponent,
  resolveModelScopeWithDiagnostics,
  SettingsManager,
  withFileMutationQueue,
  type ExtensionAPI,
  type ModelRuntime,
} from "@earendil-works/pi-coding-agent";

type Model = Parameters<ExtensionAPI["setModel"]>[0];

const lockfile = createRequire(join(getPackageDir(), "package.json"))("proper-lockfile");

function readSettings(file: string): Record<string, unknown> {
  let text: string;
  try {
    text = readFileSync(file, "utf8");
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return {};
    throw error;
  }
  const settings = JSON.parse(text.replace(/^\uFEFF/, ""));
  if (!settings || typeof settings !== "object" || Array.isArray(settings)) {
    throw new Error(`${file} must contain a JSON object`);
  }
  return settings;
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("model-project", {
    description: "Select and save the model for this project using Pi's model picker",
    handler: async (args, ctx) => {
      if (!ctx.isProjectTrusted()) {
        ctx.ui.notify("Trust this project before saving .pi/settings.json.", "error");
        return;
      }
      if (ctx.mode !== "tui") {
        ctx.ui.notify("/model-project requires Pi's interactive terminal.", "error");
        return;
      }
      const file = join(ctx.cwd, ".pi", "settings.json");
      let switched = false;
      try {
        const settings = readSettings(file);
        const registry = ctx.modelRegistry;
        // Pi 1.2's exported picker needs these four runtime methods, not the full registry.
        const runtime = {
          getAvailableSnapshot: () => registry.getAvailable(),
          getModel: (provider: string, id: string) => registry.find(provider, id),
          getError: () => registry.getError(),
          refresh: (options) => registry.refresh(options),
        } satisfies Pick<ModelRuntime, "getAvailableSnapshot" | "getModel" | "getError" | "refresh">;
        const model = await ctx.ui.custom<Model | undefined>((tui, _theme, _kb, done) =>
          new ModelSelectorComponent(
            tui, ctx.model, runtime as unknown as ModelRuntime, ctx.scopedModels,
            done, () => done(undefined), args.trim() || undefined, undefined,
            typeof settings.defaultProvider === "string" && typeof settings.defaultModel === "string"
              ? { provider: settings.defaultProvider, id: settings.defaultModel }
              : undefined,
          ),
        );
        if (!model) return;
        if (!ctx.isProjectTrusted()) throw new Error("Project is no longer trusted");
        const beforeSwitch = readSettings(file);
        const globalSettings = SettingsManager.create(ctx.cwd, getAgentDir()).getGlobalSettings();
        const patterns = beforeSwitch.enabledModels === undefined ? globalSettings.enabledModels : beforeSwitch.enabledModels;
        if (patterns !== undefined) {
          if (!Array.isArray(patterns) || patterns.some((pattern) => typeof pattern !== "string")) {
            throw new Error("enabledModels must be an array of strings");
          }
          const scopeRuntime = { getAvailable: async () => registry.getAvailable() };
          const { scopedModels } = await resolveModelScopeWithDiagnostics(patterns, scopeRuntime as unknown as ModelRuntime);
          if (scopedModels.length && !scopedModels.some((s) => s.model.provider === model.provider && s.model.id === model.id)) {
            throw new Error(`${model.provider}/${model.id} is outside enabledModels; change that setting before saving this default`);
          }
        }
        if (!(await pi.setModel(model))) throw new Error(`Could not switch to ${model.provider}/${model.id}`);
        switched = true;
        await withFileMutationQueue(file, async () => {
          if (!ctx.isProjectTrusted()) throw new Error("Project is no longer trusted");
          mkdirSync(dirname(file), { recursive: true });
          // Match Pi's settings lock; no await while holding it, so native writers cannot interleave.
          const release = lockfile.lockSync(file, { realpath: false });
          try {
            const latest = readSettings(file);
            if (JSON.stringify(latest.enabledModels) !== JSON.stringify(beforeSwitch.enabledModels)) {
              throw new Error("enabledModels changed while switching; run /model-project again");
            }
            latest.defaultProvider = model.provider;
            latest.defaultModel = model.id;
            const temp = mkdtempSync(join(dirname(file), ".model-project-"));
            try {
              const staged = join(temp, "settings.json");
              writeFileSync(staged, `${JSON.stringify(latest, null, 2)}\n`, { mode: 0o600 });
              renameSync(staged, file);
            } finally {
              rmSync(temp, { recursive: true, force: true });
            }
          } finally {
            release();
          }
        });
        ctx.ui.notify(`Project default: ${model.provider}/${model.id}\nSaved to ${file}`, "info");
      } catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`${switched ? "Session switched, but project default was not saved" : "Project model unchanged"}: ${detail}`, "error");
      }
    },
  });
}
