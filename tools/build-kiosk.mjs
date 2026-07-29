// Build the two kiosk HTML bundles from the single source (src/kiosk/kiosk.html):
//
//   public/standalone.html — no server. Generates g-code in the browser and
//                            downloads it. This is what GitHub Pages hosts.
//   public/index.html      — booth build. Same UI, but submits the design to
//                            the booth server (queue + printer + CRM).
//
//   node tools/build-kiosk.mjs

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const src = fs.readFileSync(path.join(root, 'src/kiosk/kiosk.html'), 'utf8');

const titleMatch = src.match(/<title>[\s\S]*?<\/title>/);
const title = titleMatch ? titleMatch[0] : '<title>3DiPad</title>';
const body = src.replace(/<title>[\s\S]*?<\/title>\s*/, '');

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

console.log(`built public/standalone.html (${fs.statSync(outStandalone).size} bytes)`);
console.log(`built public/index.html      (${fs.statSync(outBooth).size} bytes)`);
