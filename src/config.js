// Config loader: reads config.json (falling back to config.example.json),
// resolves the start/end template files, and returns a ready-to-use object.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export function loadConfig() {
  const cfgPath = fs.existsSync(path.join(root, 'config.json'))
    ? path.join(root, 'config.json')
    : path.join(root, 'config.example.json');
  const cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8'));
  resolveTemplates(cfg);
  cfg._root = root;
  cfg._configPath = cfgPath;
  return cfg;
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
