// Injects the pi-hermes-memory managed ponytail skill into the system prompt
// on every turn, so the rules stay agent-editable without a nix rebuild.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

// Same root resolution as pi-hermes-memory (src/paths.ts); PI_CODING_AGENT_DIR
// overrides the config dir, so a hardcoded ~/.pi/agent would miss the skill.
const AGENT = process.env.PI_CODING_AGENT_DIR?.trim() || path.join(os.homedir(), ".pi", "agent");
const SKILL = path.join(AGENT, "pi-hermes-memory", "skills", "ponytail", "SKILL.md");

export default function (pi: any) {
  pi.on("before_agent_start", async (event: any) => {
    let body: string;
    try {
      // Read every turn so a skill edit applies on the next message.
      body = fs.readFileSync(SKILL, "utf8").replace(/^---[\s\S]*?---\s*/, "");
    } catch (err) {
      // Staying quiet would hide that the rules are gone; say it on every failed turn.
      console.error(`[ponytail] rules not injected: ${(err as Error).message}`);
      return;
    }
    const sections = event?.systemPromptOptions?.sections;
    if (sections && typeof sections === "object") {
      sections.ponytail = body;
      return;
    }
    if (event?.systemPrompt) {
      return { systemPrompt: `${event.systemPrompt}\n\n${body}` };
    }
  });
}
