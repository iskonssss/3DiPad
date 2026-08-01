import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { mergeDefaults, missingKeys, root, loadConfig, syncedFolderWarning , readJson} from '../src/config.js';

// The booth laptop's config.json is copied once and then edited by hand, so it
// goes stale as settings are added upstream. It must layer over the shipped
// defaults, not replace them.

test('a stale config.json still picks up newer settings', () => {
  const defaults = { build: { layerHeight: 0.28, designLayers: 2, wallLoops: 2 }, fan: { other: 255 } };
  const stale = { build: { layerHeight: 0.28, designThickness: 2.0 } };
  const cfg = mergeDefaults(defaults, stale);

  assert.equal(cfg.build.designLayers, 2, 'the setting that was missing arrives from the defaults');
  assert.equal(cfg.build.wallLoops, 2);
  assert.equal(cfg.fan.other, 255, 'whole sections missing locally are filled in');
  assert.equal(cfg.build.designThickness, 2.0, 'local extras are left alone');
});

test('local edits beat the defaults', () => {
  const defaults = { build: { layerHeight: 0.28 }, integrations: { lan: { enabled: false, timeoutMs: 30000 } } };
  const local = { build: { layerHeight: 0.2 }, integrations: { lan: { enabled: true } } };
  const cfg = mergeDefaults(defaults, local);

  assert.equal(cfg.build.layerHeight, 0.2, 'an edited value wins');
  assert.equal(cfg.integrations.lan.enabled, true);
  assert.equal(cfg.integrations.lan.timeoutMs, 30000, 'siblings of an edited value survive');
});

test('arrays are taken whole, never interleaved with the example placeholders', () => {
  const defaults = { integrations: { printers: [{ id: 'A1-1', ip: '' }, { id: 'A1-2', ip: '' }, { id: 'A1-3', ip: '' }] } };
  const local = { integrations: { printers: [{ id: 'A1-1', ip: '192.168.10.105', serial: 'SN', accessCode: 'x' }] } };
  const cfg = mergeDefaults(defaults, local);

  assert.equal(cfg.integrations.printers.length, 1, 'the configured list replaces the placeholder list');
  assert.equal(cfg.integrations.printers[0].ip, '192.168.10.105');
});

test('missingKeys reports what the local config never set', () => {
  const defaults = { build: { a: 1, b: 2, nested: { c: 3 } }, _comment: 'ignored' };
  const local = { build: { a: 9, nested: {} } };
  assert.deepEqual(missingKeys(defaults, local), ['build.b', 'build.nested.c']);
  assert.deepEqual(missingKeys(defaults, defaults), [], 'a current config reports nothing');
});

// --- the tablet's copy of the settings ------------------------------------
//
// The kiosk used to carry a hand-written duplicate of these values, which drifted
// from config.example.json — the design-layer fix landed on the server while the
// standalone build kept printing the old thickness. It is generated now, and
// these tests fail if that ever stops being true.

const buildDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const bundles = ['public/standalone.html', 'public/index.html']
  .map((p) => path.join(buildDir, p))
  .filter((p) => fs.existsSync(p));

function bundledConfig(file) {
  const html = fs.readFileSync(file, 'utf8');
  const start = html.indexOf('const CFG = ');
  assert.ok(start > -1, `${file} has no CFG — rebuild with npm run build`);
  const open = html.indexOf('{', start);
  let depth = 0, end = -1, inStr = false, esc = false;
  for (let i = open; i < html.length; i++) {
    const ch = html[i];
    if (inStr) { if (esc) esc = false; else if (ch === '\\') esc = true; else if (ch === '"') inStr = false; continue; }
    if (ch === '"') inStr = true;
    else if (ch === '{') depth++;
    else if (ch === '}' && --depth === 0) { end = i + 1; break; }
  }
  assert.ok(end > -1, 'CFG object is not closed');
  return JSON.parse(html.slice(open, end));
}

for (const file of bundles) {
  const name = path.basename(file);

  test(`${name}: the tablet prints to the same settings as the server`, () => {
    const example = JSON.parse(fs.readFileSync(path.join(root, 'config.example.json'), 'utf8'));
    const cfg = bundledConfig(file);
    for (const key of ['designLayers', 'layerHeight', 'backingThickness', 'lineWidth', 'chamferMm', 'wallLoops', 'infillWallOverlap', 'holeDiameter']) {
      assert.equal(cfg.build[key], example.build[key], `build.${key} matches config.example.json`);
    }
    assert.equal(cfg.build.designLayers, 2, 'design layer is two layers');
    assert.ok(!('designThickness' in cfg.build), 'the superseded thickness setting is gone');
    assert.deepEqual(cfg.palette, example.palette);
    // the bundle drops the explanatory _comment keys, so compare what is left
    const withoutComments = (o) => Object.fromEntries(Object.entries(o).filter(([k]) => !k.startsWith('_')));
    assert.deepEqual(cfg.speed, withoutComments(example.speed));
    assert.ok(cfg.template.startResolved.includes('G28'), 'the real start template, not a trimmed copy');
    assert.ok(cfg.template.startResolved.includes('{calibration}'), 'with the calibration step left for the engine to fill in');
    for (const key of ['bedLevel', 'flow', 'startupMinutes']) {
      assert.equal(cfg.calibration[key], example.calibration[key], `calibration.${key} matches the server`);
    }
    assert.ok(!('_comment' in cfg.calibration), 'the explanatory comments are stripped from the bundle');
  });

  test(`${name}: no booth secrets are served to the browser`, () => {
    const cfg = bundledConfig(file);
    assert.ok(!('integrations' in cfg), 'printer credentials and CRM webhooks stay server-side');
    assert.ok(!('output' in cfg), 'server output paths are not the tablet\'s business');
    assert.ok(!JSON.stringify(cfg).includes('accessCode'));
  });
}

// --- where the day's files go -----------------------------------------------
//
// These were pinned to the repo folder, so the only way to get g-code and leads
// into a synced drive was to put the whole checkout there — node_modules, .git
// and all — which is a bad place to run a server from.

/**
 * Run `fn` against a specific config.json, restoring whatever was there.
 * `patch === null` means "with no config.json at all" — without that, these
 * tests pass or fail depending on what the machine they run on has configured.
 */
function withConfig(patch, fn) {
  const file = path.join(root, 'config.json');
  const had = fs.existsSync(file);
  const backup = had ? fs.readFileSync(file, 'utf8') : null;
  try {
    if (patch === null) {
      if (had) fs.rmSync(file);
    } else {
      const base = JSON.parse(fs.readFileSync(path.join(root, 'config.example.json'), 'utf8'));
      patch(base);
      fs.writeFileSync(file, JSON.stringify(base));
    }
    return fn();
  } finally {
    if (had) fs.writeFileSync(file, backup);
    else if (fs.existsSync(file)) fs.rmSync(file);
  }
}

test('output directories default to the project folder', () => {
  withConfig(null, () => {
    const cfg = loadConfig();
    assert.equal(cfg.output.dirResolved, path.join(root, 'output'));
    assert.equal(cfg.output.leadsResolved, path.join(root, 'leads'));
  });
});

test('an absolute output path is taken as given, so files can land in a synced folder', () => {
  const abs = process.platform === 'win32' ? 'D:\\Drive\\gcode' : '/mnt/drive/gcode';
  withConfig((base) => { base.output.dir = abs; base.output.leadsDir = 'somewhere-else'; }, () => {
    const cfg = loadConfig();
    assert.equal(cfg.output.dirResolved, abs, 'an absolute path is used unchanged');
    assert.equal(cfg.output.leadsResolved, path.join(root, 'somewhere-else'), 'a relative one still hangs off the project');
  });
});

test('running from a synced folder is called out, running from a normal one is not', () => {
  assert.equal(syncedFolderWarning('/home/someone/3DiPad'), null);
  assert.equal(syncedFolderWarning('C:\\Users\\info\\3DiPad'), null);

  // the exact path this came up with: Drive's "Other computers" is a read-only
  // backup of a different machine, so npm and git fail outright there
  const other = syncedFolderWarning('G:\\Other computers\\My computer\\Desktop\\Projects\\3DiPad');
  assert.match(other, /Other computers/);
  assert.match(other, /read-only/);

  for (const p of ['G:\\My Drive\\3DiPad', 'C:\\Users\\info\\OneDrive\\3DiPad', 'C:\\Users\\info\\Dropbox\\3DiPad']) {
    const w = syncedFolderWarning(p);
    assert.ok(w, `${p} should be flagged`);
    assert.match(w, /node_modules/, 'says why it matters');
  }
});

test('a hand-edited config with a typo says which line, not a stack trace', () => {
  // The booth's config.json is edited by hand — a printer IP, a colour, a debug
  // flag — and one missing comma took the whole thing down behind twelve lines
  // of Node stack trace ending in `asyncRunEntryPointWithESMLoader`.
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), '3dipad-cfg-'));
  const file = path.join(dir, 'config.json');
  fs.writeFileSync(file, [
    '{',
    '  "integrations": {',
    '    "lan": {',
    '      "enabled": true',        // <- the missing comma
    '      "debug": true',
    '    }',
    '  }',
    '}',
  ].join('\n'));

  let e = null;
  try { readJson(file); } catch (err) { e = err; }
  assert.ok(e, 'a broken config must not parse silently');
  assert.match(e.message, /not valid JSON/);
  assert.ok(e.friendly, 'marked as an operator problem so the server does not dump a stack');
  assert.match(e.message, /"debug": true/, 'shows the offending line');
  assert.match(e.message, /\^/, 'and points at the column');
  assert.match(e.message, /missing a comma/, 'and names the likely cause');
  assert.match(e.message, /5 \|/, 'with line numbers to find it by');

  // a good file still just parses
  fs.writeFileSync(file, '{"a":{"b":1}}');
  assert.deepEqual(readJson(file), { a: { b: 1 } });
  fs.rmSync(dir, { recursive: true, force: true });
});
