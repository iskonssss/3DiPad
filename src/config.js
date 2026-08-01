// Config loader: reads config.json (falling back to config.example.json),
// resolves the start/end template files, and returns a ready-to-use object.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export function loadConfig() {
  const examplePath = path.join(root, 'config.example.json');
  const userPath = path.join(root, 'config.json');
  const defaults = readJson(examplePath);
  const hasUser = fs.existsSync(userPath);
  const user = hasUser ? readJson(userPath) : null;

  const cfg = hasUser ? mergeDefaults(defaults, user) : defaults;
  resolveTemplates(cfg);
  resolveDataDirs(cfg);
  cfg._root = root;
  cfg._configPath = hasUser ? userPath : examplePath;
  cfg._defaulted = hasUser ? missingKeys(defaults, user) : [];
  return cfg;
}

/**
 * Read a JSON file, and if it will not parse, say where and why in terms an
 * operator can act on.
 *
 * config.json is edited by hand — a printer's IP, a colour, a debug flag — and
 * one missing comma took the whole booth down behind twelve lines of Node
 * stack trace ending in `at async asyncRunEntryPointWithESMLoader`. That is
 * unreadable at a fair, and it buries the one useful fact: which line.
 */
export function readJson(file) {
  const text = fs.readFileSync(file, 'utf8');
  try {
    return JSON.parse(text);
  } catch (e) {
    const at = /position (\d+)/.exec(e.message);
    const pos = at ? Number(at[1]) : -1;
    const before = pos >= 0 ? text.slice(0, pos) : '';
    const line = pos >= 0 ? before.split('\n').length : 0;
    const col = pos >= 0 ? pos - before.lastIndexOf('\n') : 0;
    const lines = text.split('\n');

    const out = [`${path.basename(file)} is not valid JSON.`, ''];
    if (line > 0) {
      // the line before is usually where the missing comma belongs
      for (let n = Math.max(1, line - 1); n <= Math.min(lines.length, line + 1); n++) {
        out.push(`  ${String(n).padStart(4)} | ${lines[n - 1]}`);
        if (n === line) out.push(`       | ${' '.repeat(Math.max(0, col - 1))}^`);
      }
      out.push('');
    }
    if (/Expected ',' or/.test(e.message)) {
      out.push('  The line ABOVE this one is probably missing a comma at the end.');
      out.push('  Every entry except the last one in a block needs a comma after it.');
    } else if (/Unexpected token/.test(e.message) || /Expected double-quoted/.test(e.message)) {
      out.push('  Check for a stray comma before a } or ], or a missing quote.');
    }
    out.push(`  (${e.message})`);
    out.push('');
    out.push(`  Fix ${file} and start the booth again.`);
    out.push('  If you are stuck: delete config.json and run the printer setup page again,');
    out.push('  or copy config.example.json over it — but that loses your printer details.');

    const err = new Error(out.join('\n'));
    err.friendly = true;
    throw err;
  }
}

/**
 * config.json is the booth's copy, made once and then edited by hand (and by
 * `npm run set-printer`). Settings added upstream afterwards were simply absent
 * from it, and the engine silently fell back to whatever its own default was —
 * which is how a booth laptop kept printing a 7-layer design layer after the
 * fix that made it 2 had already been pulled. So the local file is layered over
 * the shipped defaults rather than replacing them.
 *
 * Objects merge key by key; arrays and scalars are taken whole from the local
 * file, so an edited `printers` or `palette` list wins outright instead of
 * being interleaved with the placeholders in the example.
 */
export function mergeDefaults(defaults, override) {
  if (override === undefined) return defaults;
  if (!isPlainObject(defaults) || !isPlainObject(override)) return override;
  const out = { ...defaults };
  for (const [k, v] of Object.entries(override)) out[k] = mergeDefaults(defaults[k], v);
  return out;
}

/** Dotted paths present in the defaults but absent from the local config. */
export function missingKeys(defaults, override, prefix = '') {
  const out = [];
  for (const [k, v] of Object.entries(defaults)) {
    if (k.startsWith('_')) continue;
    const p = prefix ? `${prefix}.${k}` : k;
    if (!isPlainObject(override) || !(k in override)) out.push(p);
    else if (isPlainObject(v)) out.push(...missingKeys(v, override[k], p));
  }
  return out;
}

const isPlainObject = (v) => !!v && typeof v === 'object' && !Array.isArray(v);

/**
 * Where generated g-code and lead records are written.
 *
 * These were pinned to the repo folder, so the only way to get the day's files
 * into a synced drive was to put the whole checkout there — node_modules, .git
 * and all — which is a bad place to run from. Point these at the synced folder
 * instead and leave the app on local disk.
 *
 * Absolute paths are used as given; anything else is relative to the project.
 */
function resolveDataDirs(cfg) {
  const out = cfg.output || (cfg.output = {});
  const at = (v, fallback) => {
    const p = String(v || fallback);
    return path.isAbsolute(p) ? p : path.join(root, p);
  };
  out.dirResolved = at(out.dir, 'output');
  out.leadsResolved = at(out.leadsDir, 'leads');
}

/**
 * Cloud-synced folders are a poor place to RUN from: the sync client copies
 * node_modules and .git file by file, locks files mid-write, and answers reads
 * with placeholders it has to fetch first. Google Drive's "Other computers"
 * area is a backup of another machine and is normally read-only outright.
 * Worth one line at startup — it is otherwise diagnosed as random breakage.
 */
export function syncedFolderWarning(dir = root) {
  const p = dir.replace(/\\/g, '/');
  if (/\/Other computers\//i.test(p)) {
    return 'This folder is Google Drive > Other computers, which is a read-only backup of another machine. Copy the project to a local folder (e.g. C:\\Users\\<you>\\3DiPad) and run it from there.';
  }
  const m = /\/(Google ?Drive|My Drive|OneDrive[^/]*|Dropbox)\//i.exec(p);
  if (m) {
    return `This folder is inside ${m[1]}, which syncs every file as it changes — including node_modules and .git. Run the booth from a local folder instead, and point output.dir / output.leadsDir at the synced folder if you want the files backed up.`;
  }
  return null;
}

function resolveTemplates(cfg) {
  const read = (rel, fallback) => {
    try {
      return fs.readFileSync(path.join(root, rel), 'utf8');
    } catch {
      return fallback;
    }
  };
  cfg.template.startResolved = read(cfg.template.startFile, '');
  cfg.template.endResolved = read(cfg.template.endFile, '');
}

export { root };
