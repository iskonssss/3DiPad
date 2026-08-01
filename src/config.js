// Config loader: reads config.json (falling back to config.example.json),
// resolves the start/end template files, and returns a ready-to-use object.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export function loadConfig() {
  const examplePath = path.join(root, 'config.example.json');
  const userPath = path.join(root, 'config.json');
  const defaults = JSON.parse(fs.readFileSync(examplePath, 'utf8'));
  const hasUser = fs.existsSync(userPath);
  const user = hasUser ? JSON.parse(fs.readFileSync(userPath, 'utf8')) : null;

  const cfg = hasUser ? mergeDefaults(defaults, user) : defaults;
  resolveTemplates(cfg);
  resolveDataDirs(cfg);
  cfg._root = root;
  cfg._configPath = hasUser ? userPath : examplePath;
  cfg._defaulted = hasUser ? missingKeys(defaults, user) : [];
  return cfg;
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
