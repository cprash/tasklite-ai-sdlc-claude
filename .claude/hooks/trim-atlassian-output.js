#!/usr/bin/env node
// PostToolUse hook: shrinks verbose Jira/Confluence MCP results before they enter context.
// Removes low-value noise: null/empty values, bare URL strings, and a fixed set of metadata keys
// (DROP_KEYS), and flattens ADF rich text to plain text. Story content fields are left intact.
// Fails open: on any problem it prints nothing and the original result passes through untouched.

// Results shorter than this are passed through as-is; trimming them isn't worth the risk.
const MIN_CHARS = 2000;

// Jira/Confluence response keys that are API plumbing, duplicates (renderedFields), or
// rarely useful to the pipeline (changelog, worklog, time tracking, votes, watchers).
const DROP_KEYS = new Set([
  'self', 'expand', 'avatarUrls', 'iconUrl', 'renderedFields', 'names', 'schema',
  'changelog', 'statusCategory', 'votes', 'watches', 'worklog', 'timetracking',
  'aggregatetimeoriginalestimate', 'aggregatetimeestimate', 'aggregatetimespent',
  'aggregateprogress', 'progress', 'workratio', 'lastViewed', '_links', '_expandable',
]);

// ADF node types whose children are joined with newlines (one child per line).
const BLOCK_NODES = new Set(['doc', 'bulletList', 'orderedList']);

// Flattens an Atlassian Document Format tree to plain text; list items become "- " lines.
function adfToText(node) {
  if (!node || typeof node !== 'object') return '';
  if (node.type === 'text') return node.text || '';
  const inner = (node.content || []).map(adfToText).join(BLOCK_NODES.has(node.type) ? '\n' : '');
  return node.type === 'listItem' ? `- ${inner}` : inner;
}

// Recursively strips noise from parsed JSON. Returns undefined for anything that ends up
// empty, so parents drop the key/element entirely.
function prune(value) {
  if (Array.isArray(value)) {
    const items = value.map(prune).filter((v) => v !== undefined);
    return items.length ? items : undefined;
  }
  if (value && typeof value === 'object') {
    if (value.type === 'doc' && Array.isArray(value.content)) return adfToText(value).trim() || undefined;
    const out = {};
    for (const [k, v] of Object.entries(value)) {
      if (DROP_KEYS.has(k)) continue;
      const p = prune(v);
      if (p !== undefined) out[k] = p;
    }
    return Object.keys(out).length ? out : undefined;
  }
  if (value === null || value === '' || value === undefined) return undefined;
  if (typeof value === 'string' && /^https?:\/\/\S+$/.test(value)) return undefined;
  return value;
}

// Extracts the JSON text from a tool response; null if it isn't purely text (e.g. contains images).
function responseText(resp) {
  if (typeof resp === 'string') return resp;
  if (resp && Array.isArray(resp.content)) {
    const texts = resp.content.filter((c) => c && c.type === 'text').map((c) => c.text);
    return texts.length === resp.content.length ? texts.join('\n') : null;
  }
  return null;
}

// The jira-epam server returns {"result": "<JSON as a string>"}; unwrap it so prune() sees the real data.
function unwrapResult(parsed) {
  if (parsed && typeof parsed === 'object' && Object.keys(parsed).length === 1 && typeof parsed.result === 'string') {
    try { return JSON.parse(parsed.result); } catch { return parsed; }
  }
  return parsed;
}

function main(raw) {
  const input = JSON.parse(raw);
  const resp = input.tool_response !== undefined ? input.tool_response : input.tool_output;
  const text = responseText(resp);
  if (!text || text.length < MIN_CHARS) return;

  const trimmed = JSON.stringify(prune(unwrapResult(JSON.parse(text))) ?? {});
  // Skip the rewrite unless it saves at least ~10%.
  if (trimmed.length >= text.length * 0.9) return;

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PostToolUse',
      // Same payload under both keys: updatedToolOutput (general) and updatedMCPToolOutput (MCP tools).
      updatedToolOutput: trimmed,
      updatedMCPToolOutput: trimmed,
    },
  }));
}

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (d) => (raw += d));
process.stdin.on('end', () => {
  try {
    main(raw);
  } catch {
    // Fail open: non-JSON or unexpected shapes leave the original output untouched.
  }
});
