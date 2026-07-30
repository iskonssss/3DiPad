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

const parts = ENGINE_MODULES.map((rel) => ({
  file: rel,
  code: stripModuleSyntax(fs.readFileSync(path.join(root, rel), 'utf8')).trim(),
}));
assertNoDuplicateDeclarations(parts);

const engine = parts.map((p) => `/* ===== ${p.file} ===== */\n${p.code}`).join('\n\n');

const src = fs.readFileSync(path.join(root, 'src/kiosk/kiosk.html'), 'utf8');
if (!src.includes('/*@ENGINE@*/')) {
  console.error('src/kiosk/kiosk.html is missing the /*@ENGINE@*/ placeholder.');
  process.exit(1);
}

const titleMatch = src.match(/<title>[\s\S]*?<\/title>/);
const title = titleMatch ? titleMatch[0] : '<title>3DiPad</title>';
const body = src.replace(/<title>[\s\S]*?<\/title>\s*/, '').replace('/*@ENGINE@*/', engine);

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
