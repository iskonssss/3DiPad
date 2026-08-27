import { test } from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import zlib from 'node:zlib';
import { build3mf, zip, solidPng, colourHex, zipNames, zipMember, isBambuStudio3mf, plateGcodeName } from '../src/integrations/bambu3mf.js';
import { buildPrintCommand, startVariants, container } from '../src/integrations/bambu.js';

/**
 * Read a zip without a library, so the test is checking the bytes we wrote
 * rather than agreeing with the writer. Walks the central directory, which is
 * what any real unzip does.
 */
function unzip(buf) {
  const eocd = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  assert.ok(eocd >= 0, 'no end-of-central-directory record — this is not a zip');
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  const out = {};
  for (let i = 0; i < count; i++) {
    assert.equal(buf.readUInt32LE(p), 0x02014b50, 'central directory entry ' + i);
    const method = buf.readUInt16LE(p + 10);
    const csize = buf.readUInt32LE(p + 20);
    const usize = buf.readUInt32LE(p + 24);
    const nameLen = buf.readUInt16LE(p + 28);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.slice(p + 46, p + 46 + nameLen).toString('utf8');
    const lNameLen = buf.readUInt16LE(local + 26);
    const lExtra = buf.readUInt16LE(local + 28);
    const start = local + 30 + lNameLen + lExtra;
    const body = buf.slice(start, start + csize);
    const data = method === 8 ? zlib.inflateRawSync(body) : body;
    assert.equal(data.length, usize, `${name} unpacked to the wrong size`);
    out[name] = data;
    p += 46 + nameLen + buf.readUInt16LE(p + 30) + buf.readUInt16LE(p + 32);
  }
  return out;
}

const GCODE = ';3DiPad\nG28\n' + 'G1 X10 Y10 E0.5 F3000\n'.repeat(500);
const CFG = { build: { bedCenter: [90, 90], layerHeight: 0.28 }, integrations: { lan: {} } };
const META = { bbox: { w: 100, h: 40 }, colours: { layer1: 'YELLOW', layer2: 'BLACK' }, estMinutes: 15.2, estGrams: 6.4 };

test('the 3mf holds the g-code where the printer looks for it', () => {
  const files = unzip(build3mf({ gcode: GCODE, meta: META, cfg: CFG, name: 'YELLOW-BLACK_0009' }));

  // The parts, taken from a 3mf Bambu Studio produced for this printer.
  for (const part of [
    '[Content_Types].xml', '_rels/.rels', '3D/3dmodel.model',
    'Metadata/model_settings.config', 'Metadata/_rels/model_settings.config.rels',
    'Metadata/plate_1.gcode', 'Metadata/plate_1.gcode.md5',
    'Metadata/plate_1.json', 'Metadata/slice_info.config', 'Metadata/plate_1.png',
  ]) assert.ok(files[part], `missing ${part}`);

  assert.equal(files['Metadata/plate_1.gcode'].toString('utf8'), GCODE, 'the g-code survives the round trip');

  // The md5 sidecar is checked by the printer when it loads the project. Upper
  // case hex — a lower-case digest is a file the printer will refuse.
  const md5 = files['Metadata/plate_1.gcode.md5'].toString('utf8');
  assert.equal(md5, crypto.createHash('md5').update(Buffer.from(GCODE, 'utf8')).digest('hex').toUpperCase());
  assert.match(md5, /^[0-9A-F]{32}$/);

  // The relationship that tells the printer which member is the g-code.
  assert.match(files['Metadata/_rels/model_settings.config.rels'].toString(), /Target="\/Metadata\/plate_1\.gcode"/);
  assert.match(files['Metadata/model_settings.config'].toString(), /key="gcode_file" value="Metadata\/plate_1\.gcode"/);
});

test('the 3mf carries the numbers the tablet promised', () => {
  const files = unzip(build3mf({ gcode: GCODE, meta: META, cfg: CFG, name: 'k' }));
  const plate = JSON.parse(files['Metadata/plate_1.json'].toString());
  assert.deepEqual(plate.filament_colors, [colourHex('YELLOW'), colourHex('BLACK')]);
  // 100x40 centred on a 90,90 bed
  assert.deepEqual(plate.bbox_all, [40, 70, 140, 110]);

  const info = files['Metadata/slice_info.config'].toString();
  assert.match(info, /key="prediction" value="912"/, '15.2 minutes in seconds');
  assert.match(info, /key="weight" value="6.4"/);
  assert.match(info, /key="printer_model_id" value="N1"/, 'the A1 mini');
});

test('the archive is a real zip, and a smaller upload than the raw g-code', () => {
  const buf = build3mf({ gcode: GCODE, meta: META, cfg: CFG, name: 'k' });
  assert.equal(buf.readUInt32LE(0), 0x04034b50, 'starts with a local file header');
  // The 3mf now carries a fixed ~53KB slicer profile, which a two-line test
  // g-code cannot pay for. What matters is the real case: a keychain is
  // hundreds of thousands of lines of very repetitive g-code, and that
  // compresses far harder than the profile costs.
  const real = build3mf({ gcode: GCODE.repeat(4000), meta: META, cfg: CFG, name: 'k' });
  assert.ok(real.length < Buffer.byteLength(GCODE.repeat(4000)) / 2,
    'g-code compresses, so the booth uploads much less than it generated');

  // an empty archive is still a valid one
  assert.equal(unzip(zip([])) && Object.keys(unzip(zip([]))).length, 0);
  // and a stored (incompressible) member round-trips too
  const noise = crypto.randomBytes(4096);
  assert.deepEqual(unzip(zip([{ name: 'n.bin', data: noise }]))['n.bin'], noise);
});

test('the thumbnail is a valid PNG in the backing colour', () => {
  const png = solidPng(8, 4, [0xf4, 0xc2, 0x0d]);
  assert.deepEqual([...png.slice(0, 8)], [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  assert.equal(png.readUInt32BE(16), 8, 'width');
  assert.equal(png.readUInt32BE(20), 4, 'height');
  assert.equal(png.slice(12, 16).toString(), 'IHDR');
  assert.ok(png.includes(Buffer.from('IEND')));
});

test('a 3mf is started as a project, with no shape to guess at', () => {
  assert.equal(container({}), '3mf', 'the default is what Bambu itself sends');
  assert.deepEqual(startVariants({}), ['project_file'], 'one command — nothing to probe');
  assert.deepEqual(startVariants({ integrations: { lan: { container: 'gcode' } } }).length, 3,
    'the bare-gcode path still probes, because firmware disagrees there');

  const cmd = buildPrintCommand('/sdcard/YELLOW-BLACK_0009.3mf', {
    sequenceId: 9, variant: 'project_file', gcodePath: 'Metadata/plate_1.gcode',
  });
  assert.equal(cmd.print.command, 'project_file');
  assert.equal(cmd.print.param, 'Metadata/plate_1.gcode', 'which member of the archive to run');
  assert.equal(cmd.print.url, 'file:///sdcard/YELLOW-BLACK_0009.3mf');
  assert.equal(cmd.print.subtask_name, 'YELLOW-BLACK_0009');
  // the calibration skips the booth asked for, as print-task parameters
  assert.equal(cmd.print.bed_leveling, false);
  assert.equal(cmd.print.flow_cali, false);
  // Captured from Bambu Studio's own command for a two-colour external-spool
  // print on this printer. ams_id 255 is the external spool, once per filament.
  // Our old [254, 254] with no ams_mapping2 sent T1 to an AMS slot.
  assert.deepEqual(cmd.print.ams_mapping, [-1, -1]);
  assert.deepEqual(cmd.print.ams_mapping2, [{ ams_id: 255, slot_id: 0 }, { ams_id: 255, slot_id: 0 }]);
  assert.equal(cmd.print.use_ams, false);
  assert.equal(cmd.print.bed_type, 'textured_plate');
  // Bisected on the printer: this one field is what makes the task record say
  // manual_color_change true for our file. Nothing else did.
  assert.equal(cmd.print.cfg, '1');
});

test('extra parts can be added, for bisecting what the firmware requires', () => {
  // The printer refuses our project with err_code 0x05024007 and Bambu's own
  // 3mf carries fourteen parts ours does not. Guessing which one matters is
  // what tools/probe-start.mjs exists to avoid: it builds variants with parts
  // added and asks the printer, one at a time.
  const settings = '{"probe":"one part at a time"}';
  const files = unzip(build3mf({
    gcode: GCODE, meta: META, cfg: CFG, name: 'k',
    extraParts: [{ name: 'Metadata/probe.config', data: settings }],
  }));
  assert.equal(files['Metadata/probe.config'].toString(), settings);
  // and the archive is still whole: the g-code and its digest survive
  assert.equal(files['Metadata/plate_1.gcode'].toString(), GCODE);
  assert.ok(files['Metadata/plate_1.gcode.md5']);

  // adding nothing changes nothing
  const plain = unzip(build3mf({ gcode: GCODE, meta: META, cfg: CFG, name: 'k' }));
  assert.equal(Object.keys(files).length, Object.keys(plain).length + 1);
});

test('a Bambu Studio 3mf can be told apart from one of ours', () => {
  // So a reference file can be found in a folder rather than typed as a path.
  // The last person asked for one pasted the words "path\to" from the example,
  // which is a fair reading of an example that looks like a command.
  // This used to answer by looking for a slicer profile, on the grounds that
  // theirs had one and ours never would. Ours carries one now, so an absence
  // proves nothing — a real export names itself instead, and that is asked
  // directly.
  const ours = build3mf({ gcode: GCODE, meta: META, cfg: CFG, name: 'k' });
  assert.equal(isBambuStudio3mf(ours), false, 'ours is not a Bambu Studio export');
  assert.equal(plateGcodeName(ours), 'Metadata/plate_1.gcode');

  const theirs = build3mf({
    gcode: GCODE, meta: META, cfg: CFG, name: 'k',
    extraParts: [{ name: '3D/3dmodel.model', data: '<model><metadata name="Application">BambuStudio-02.07.01.62</metadata></model>' }],
  });
  assert.equal(isBambuStudio3mf(theirs), true);

  // and nothing here may throw on a file that is not a zip at all — the folder
  // being searched belongs to the user and can contain anything
  const junk = Buffer.from('this is not a zip, it is a sentence');
  assert.equal(isBambuStudio3mf(junk), false);
  assert.equal(plateGcodeName(junk), null);
  assert.deepEqual(zipNames(junk), []);
  assert.equal(zipMember(junk, 'anything'), null);
  assert.equal(zipMember(ours, 'Metadata/nope'), null, 'a missing member is null, not a throw');
});

/**
 * The profile the printer needs in order to LOAD the second colour.
 *
 * Everything worked right up to the moment the printer was asked to take
 * filament 2, at which point it sat on "the filament is not inserted" and
 * refused every other command. Our 3mf declared that a second filament exists
 * and shipped nothing saying what it is — no type, no temperature, nothing to
 * run a load routine with. A real Bambu Studio export carries 571 settings for
 * that, 168 of them one per filament, and we carried none.
 */
test('the 3mf carries a filament profile for both colours', async () => {
  const { build3mf, zipMember, zipNames, isBambuStudio3mf } = await import('../src/integrations/bambu3mf.js');
  const { generate } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const cfg = loadConfig({ exampleOnly: true });
  const colours = { layer1: 'BLACK', layer2: 'PINK' };
  const { gcode, meta } = generate({
    shape: 'rectangle', colours, hole: null,
    design: [{ w: 1.6, pts: [{ x: -12, y: 0 }, { x: 12, y: 0 }] }],
  }, cfg);
  const buf = build3mf({ gcode, meta: { ...meta, colours }, cfg, name: 'test' });

  assert.ok(zipNames(buf).includes('Metadata/project_settings.config'), 'no slicer profile at all');
  // ...but carrying a profile does not make it a Bambu Studio export, and the
  // two questions must not be conflated again.
  assert.equal(isBambuStudio3mf(buf), false);

  const ps = JSON.parse(zipMember(buf, 'Metadata/project_settings.config').toString());
  // Two of everything per-filament, or the second slot is a slot the printer
  // knows the name of and nothing else.
  for (const k of ['filament_type', 'filament_colour', 'filament_settings_id', 'nozzle_temperature', 'filament_self_index']) {
    assert.ok(Array.isArray(ps[k]) && ps[k].length === 2, `${k} must describe both filaments, got ${JSON.stringify(ps[k])}`);
  }
  assert.deepEqual(ps.filament_colour, ['#1c1c1e', '#ff5fa2'], 'the job\'s own colours must reach the profile');
  assert.deepEqual(ps.nozzle_temperature, [String(cfg.temp.nozzle), String(cfg.temp.nozzle)]);
});

test('the 3mf says which layers each colour covers', async () => {
  const { build3mf, zipMember } = await import('../src/integrations/bambu3mf.js');
  const { generate } = await import('../src/gcode/engine.js');
  const { loadConfig } = await import('../src/config.js');
  const cfg = loadConfig({ exampleOnly: true });
  const colours = { layer1: 'BLACK', layer2: 'PINK' };
  const { gcode, meta } = generate({
    shape: 'rectangle', colours, hole: null,
    design: [{ w: 1.6, pts: [{ x: -12, y: 0 }, { x: 12, y: 0 }] }],
  }, cfg);
  const info = zipMember(build3mf({ gcode, meta: { ...meta, colours }, cfg, name: 'test' }), 'Metadata/slice_info.config').toString();

  // Bambu's own export declares this. Without it the firmware is told two
  // filaments exist but never where the second one starts.
  assert.match(info, /<layer_filament_lists>/);
  assert.match(info, /filament_list="0 1"/, 'the layer where the two colours meet must be named');
  assert.match(info, /<nozzle id="0"/);
  // and both filaments must be fully described, not just colour-tagged
  const filaments = info.match(/<filament id="\d"[^>]*>/g) || [];
  assert.equal(filaments.length, 2);
  for (const f of filaments) assert.match(f, /nozzle_diameter="[\d.]+"/, `no nozzle on ${f}`);
});
