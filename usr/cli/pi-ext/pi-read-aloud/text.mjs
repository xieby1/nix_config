/** Select persisted assistant text only; never thinking, tool results or failed replies. */
export function latestReply(entries) {
  for (let i = entries.length - 1; i >= 0; i--) {
    const { id, type, message } = entries[i];
    if (type !== 'message' || message.role !== 'assistant' || ['error', 'aborted'].includes(message.stopReason)) continue;
    const text = speechText(message.content.filter(block => block.type === 'text').map(block => block.text).join('\n'));
    if (text) return { id, text };
  }
}

/** Conservative Markdown-to-prose filtering, not a second Markdown renderer. */
export function speechText(text) {
  let fence;
  const prose = [];
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.replace(/^(?: {0,3}> ?)+/, '').replace(/^ {0,3}(?:[-+*]|\d+[.)]) +/, '');
    const marker = line.match(/^ {0,3}(`{3,}|~{3,})(.*)$/);
    if (fence) {
      if (marker && marker[1][0] === fence[0] && marker[1].length >= fence.length && !marker[2].trim()) fence = undefined;
      continue;
    }
    if (marker) { fence = marker[1]; continue; }
    if (/^( {4}|\t)/.test(line)) continue;
    const cleaned = line
      .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
      .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
      .replace(/^\s*(?:#{1,6}\s+|>\s*|[-+*]\s+|\d+[.)]\s+)/, '')
      .replace(/[*_`~]/g, '').trim();
    if (cleaned && !/^[-|: ]+$/.test(cleaned)) prose.push(cleaned);
  }
  return prose.join('\n');
}

/** Yield sentences lazily; bound exceptional long sentences without splitting surrogate pairs. */
export function* speechChunks(text) {
  for (const { segment } of new Intl.Segmenter(undefined, { granularity: 'sentence' }).segment(text)) {
    let remaining = segment.trim();
    while (remaining) {
      let end = Math.min(400, remaining.length);
      if (end < remaining.length) {
        const space = remaining.lastIndexOf(' ', end);
        if (space > 0) end = space;
        if (/[\uD800-\uDBFF]/.test(remaining[end - 1])) end--;
      }
      yield remaining.slice(0, end).trim();
      remaining = remaining.slice(end).trimStart();
    }
  }
}
