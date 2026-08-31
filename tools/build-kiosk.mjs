// Build the two kiosk HTML bundles from a single source of truth.
//
//   public/standalone.html — no server. Generates g-code in the browser and
//                            downloads it. This is what GitHub Pages hosts.
//   public/index.html      — booth build. Same UI, but submits the design to
//                            the booth server (queue + printer + CRM).
//
// The g-code engine is NOT duplicated in the HTML: the real modules under
// src/gcode/ are inlined at build time (imports/exports stripped) so the
// browser and the booth server always run identical geometry.
//
//   node tools/build-kiosk.mjs

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// dependency order matters — later modules use earlier ones
const ENGINE_MODULES = [
  'src/gcode/outline.js',
  'src/gcode/geometry.js',
  'src/gcode/strokes.js',
  'src/gcode/fill.js',
  'src/gcode/image.js',
  'src/gcode/engine.js',
];

function stripModuleSyntax(code) {
  return code
    // drop import statements (single- and multi-line)
    .replace(/^\s*import\s+[\s\S]*?from\s*['"][^'"]+['"];?\s*$/gm, '')
    .replace(/^\s*import\s+['"][^'"]+['"];?\s*$/gm, '')
    // `export function x` -> `function x`, `export const x` -> `const x`
    .replace(/^\s*export\s+(?=(function|const|let|class)\b)/gm, '')
    // bare `export { ... };`
    .replace(/^\s*export\s*\{[^}]*\};?\s*$/gm, '');
}

/** Catch a real hazard of concatenation: two modules declaring the same name. */
function assertNoDuplicateDeclarations(parts) {
  const seen = new Map();
  const dupes = [];
  const re = /^(?:function|const|let|class)\s+([A-Za-z_$][\w$]*)/gm;
  for (const { file, code } of parts) {
    for (const m of code.matchAll(re)) {
      const name = m[1];
      if (seen.has(name)) dupes.push(`${name} (in ${seen.get(name)} and ${file})`);
      else seen.set(name, file);
    }
  }
  if (dupes.length) {
    console.error('Duplicate top-level declarations across engine modules:');
    for (const d of dupes) console.error('  - ' + d);
    process.exit(1);
  }
}

/**
 * Catch the other hazard: a module the engine imports that nobody added to
 * ENGINE_MODULES. Concatenation happily drops the import line, so the bundle
 * builds clean and then throws "x is not defined" on the tablet.
 */
function assertNoMissingModules(parts) {
  const bundled = new Set(ENGINE_MODULES.map((m) => path.basename(m)));
  const missing = [];
  for (const rel of ENGINE_MODULES) {
    const code = fs.readFileSync(path.join(root, rel), 'utf8');
    for (const m of code.matchAll(/from\s*['"]\.\/([\w.-]+)['"]/g)) {
      if (!bundled.has(m[1])) missing.push(`${rel} imports ./${m[1]}`);
    }
  }
  if (missing.length) {
    console.error('Engine modules imported but not bundled — add them to ENGINE_MODULES:');
    for (const d of missing) console.error('  - ' + d);
    process.exit(1);
  }
}

const parts = ENGINE_MODULES.map((rel) => ({
  file: rel,
  code: stripModuleSyntax(fs.readFileSync(path.join(root, rel), 'utf8')).trim(),
}));
assertNoDuplicateDeclarations(parts);
assertNoMissingModules(parts);

const engine = parts.map((p) => `/* ===== ${p.file} ===== */\n${p.code}`).join('\n\n');

/* ---- the kiosk's CFG, generated from config.example.json ----
   The tablet used to carry a hand-copied duplicate of these settings, which
   quietly drifted from the server's: a fix to the design-layer count landed in
   config.example.json and the standalone build kept printing the old value.
   Generating it removes that whole class of bug. Server-only sections (printer
   credentials, CRM webhooks, output paths) are left out — the browser has no
   use for them and they don't belong in a file served to the public. */
// Baked into the page the tablets load, so anything here is readable by anyone
// who opens the kiosk. `operator` holds the PIN: it must never be built in, and
// the kiosk asks the server about it at runtime instead.
const SERVER_ONLY = ['integrations', 'output', 'operator'];

function stripComments(value) {
  if (Array.isArray(value)) return value.map(stripComments);
  if (value && typeof value === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(value)) if (!k.startsWith('_')) out[k] = stripComments(v);
    return out;
  }
  return value;
}

// Merge the booth's own config.json over the example, so the kiosk enforces the
// SAME limits/palette/temps the server does. Building from the example alone
// baked the wrong print-time limit into the tablets: config.example.json still
// said 18 min while the booth's config.json said 15, so an over-budget design
// looked fine on the tablet and the over-15 approval never armed.
function deepMerge(base, over) {
  if (Array.isArray(over)) return over;
  if (over && typeof over === 'object' && base && typeof base === 'object' && !Array.isArray(base)) {
    const out = { ...base };
    for (const [k, v] of Object.entries(over)) out[k] = deepMerge(base[k], v);
    return out;
  }
  return over === undefined ? base : over;
}
function kioskConfig() {
  const example = JSON.parse(fs.readFileSync(path.join(root, 'config.example.json'), 'utf8'));
  const userPath = path.join(root, 'config.json');
  const merged = fs.existsSync(userPath) ? deepMerge(example, JSON.parse(fs.readFileSync(userPath, 'utf8'))) : example;
  const cfg = stripComments(merged);
  for (const key of SERVER_ONLY) delete cfg[key];
  const read = (rel) => fs.readFileSync(path.join(root, rel), 'utf8').trimEnd();
  cfg.template = {
    startResolved: read(cfg.template.startFile),
    endResolved: read(cfg.template.endFile),
  };
  return cfg;
}

const cfgJson = JSON.stringify(kioskConfig(), null, 2);

const src = fs.readFileSync(path.join(root, 'src/kiosk/kiosk.html'), 'utf8');
for (const placeholder of ['/*@ENGINE@*/', '/*@CONFIG@*/']) {
  if (!src.includes(placeholder)) {
    console.error(`src/kiosk/kiosk.html is missing the ${placeholder} placeholder.`);
    process.exit(1);
  }
}

const titleMatch = src.match(/<title>[\s\S]*?<\/title>/);
const title = titleMatch ? titleMatch[0] : '<title>3DiPad</title>';
const body = src
  .replace(/<title>[\s\S]*?<\/title>\s*/, '')
  .replace('/*@CONFIG@*/', () => cfgJson)
  .replace('/*@ENGINE@*/', () => engine);

const HEAD = `<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="3DiPad">
<meta name="theme-color" content="#0d1424">`;

function page({ boothServer, manifest }) {
  return `<!doctype html>
<html lang="en">
<head>
${HEAD}
${manifest ? '<link rel="manifest" href="manifest.webmanifest">\n' : ''}${title}
</head>
<body>
${boothServer ? '<script>window.__BOOTH_SERVER__ = true;</script>\n' : ''}${body}
</body>
</html>
`;
}

const outStandalone = path.join(root, 'public/standalone.html');
const outBooth = path.join(root, 'public/index.html');
fs.writeFileSync(outStandalone, page({ boothServer: false, manifest: false }));
fs.writeFileSync(outBooth, page({ boothServer: true, manifest: true }));

console.log(`inlined engine from ${ENGINE_MODULES.length} modules (${engine.length} bytes)`);
console.log(`built public/standalone.html (${fs.statSync(outStandalone).size} bytes)`);
console.log(`built public/index.html      (${fs.statSync(outBooth).size} bytes)`);
