// Wrapping a .gcode in the 3MF container a Bambu printer will actually start.
//
// The booth uploaded a bare .gcode to the SD card and asked the printer to run
// it. The file arrived, appeared in the printer's file list, and nothing ever
// happened. The reason is in the printer's own task record, which it wrote
// after a successful print from Bambu Studio:
//
//   { "file path": "/sdcard/cache/salahudine_plate_2.3mf", ... }
//
// Bambu Studio never sends g-code. It sends a *project* — a zip with the g-code
// inside at Metadata/plate_N.gcode — and starts it with `project_file`. Taking
// that 3mf apart gives the exact list of parts, and this builds the same shape
// with one plate in it:
//
//   [Content_Types].xml
//   _rels/.rels                              -> the model, and the thumbnail
//   3D/3dmodel.model                          (no geometry: it is already sliced)
//   Metadata/_rels/model_settings.config.rels -> the g-code
//   Metadata/model_settings.config            which plate owns which files
//   Metadata/plate_1.gcode                    the g-code we generated
//   Metadata/plate_1.gcode.md5                uppercase hex, checked on load
//   Metadata/plate_1.json                     bounding box + filament colours
//   Metadata/slice_info.config                weight, time, printer model
//   Metadata/plate_1.png, plate_1_small.png   what the printer screen shows
//
// Zipped here rather than with a library: the booth laptop should not need an
// npm install the morning of a fair.

import fs from 'node:fs';
import zlib from 'node:zlib';
import crypto from 'node:crypto';

/* ---------------------------------------------------------------- zip ---- */

const CRC_TABLE = (() => {
  const t = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c;
  }
  return t;
})();

function crc32(buf) {
  let c = -1;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ -1) >>> 0;
}

/** MS-DOS date/time, which is what a zip entry carries. */
function dosStamp(date) {
  const time = ((date.getHours() & 31) << 11) | ((date.getMinutes() & 63) << 5) | ((date.getSeconds() / 2) & 31);
  const day = (((date.getFullYear() - 1980) & 127) << 9) | (((date.getMonth() + 1) & 15) << 5) | (date.getDate() & 31);
  return { time, day };
}

/**
 * A zip archive from [{ name, data }]. Deflated — a keychain's g-code is around
 * 350 kB of very repetitive text and compresses to a fraction of that, which is
 * time saved on every FTPS upload at the booth.
 */
export function zip(entries, now = new Date()) {
  const { time, day } = dosStamp(now);
  const locals = [];
  const central = [];
  let offset = 0;

  for (const { name, data } of entries) {
    const raw = Buffer.isBuffer(data) ? data : Buffer.from(data, 'utf8');
    const deflated = zlib.deflateRawSync(raw, { level: 6 });
    // Storing is legal and occasionally smaller; take whichever wins.
    const useDeflate = deflated.length < raw.length;
    const body = useDeflate ? deflated : raw;
    const method = useDeflate ? 8 : 0;
    const crc = crc32(raw);
    const nameBuf = Buffer.from(name, 'utf8');

    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(20, 4);          // version needed
    local.writeUInt16LE(0, 6);           // flags
    local.writeUInt16LE(method, 8);
    local.writeUInt16LE(time, 10);
    local.writeUInt16LE(day, 12);
    local.writeUInt32LE(crc, 14);
    local.writeUInt32LE(body.length, 18);
    local.writeUInt32LE(raw.length, 22);
    local.writeUInt16LE(nameBuf.length, 26);
    local.writeUInt16LE(0, 28);          // extra field length
    locals.push(local, nameBuf, body);

    const dir = Buffer.alloc(46);
    dir.writeUInt32LE(0x02014b50, 0);
    dir.writeUInt16LE(20, 4);            // version made by
    dir.writeUInt16LE(20, 6);            // version needed
    dir.writeUInt16LE(0, 8);
    dir.writeUInt16LE(method, 10);
    dir.writeUInt16LE(time, 12);
    dir.writeUInt16LE(day, 14);
    dir.writeUInt32LE(crc, 16);
    dir.writeUInt32LE(body.length, 20);
    dir.writeUInt32LE(raw.length, 24);
    dir.writeUInt16LE(nameBuf.length, 28);
    dir.writeUInt16LE(0, 30);            // extra
    dir.writeUInt16LE(0, 32);            // comment
    dir.writeUInt16LE(0, 34);            // disk
    dir.writeUInt16LE(0, 36);            // internal attrs
    dir.writeUInt32LE(0, 38);            // external attrs
    dir.writeUInt32LE(offset, 42);
    central.push(dir, nameBuf);

    offset += local.length + nameBuf.length + body.length;
  }

  const cd = Buffer.concat(central);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(0, 4);
  end.writeUInt16LE(0, 6);
  end.writeUInt16LE(entries.length, 8);
  end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(cd.length, 12);
  end.writeUInt32LE(offset, 16);
  end.writeUInt16LE(0, 20);
  return Buffer.concat([...locals, cd, end]);
}

/* --------------------------------------------------------- reading zip --- */

/** Every member name in a zip, read from the central directory. */
export function zipNames(buf) {
  const eocd = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  if (eocd < 0) return [];
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  const out = [];
  for (let i = 0; i < count; i++) {
    if (buf.readUInt32LE(p) !== 0x02014b50) break;
    const nameLen = buf.readUInt16LE(p + 28);
    out.push(buf.slice(p + 46, p + 46 + nameLen).toString('utf8'));
    p += 46 + nameLen + buf.readUInt16LE(p + 30) + buf.readUInt16LE(p + 32);
  }
  return out;
}

/** One member's bytes, or null if the archive does not have it. */
export function zipMember(buf, want) {
  const eocd = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  if (eocd < 0) return null;
  const count = buf.readUInt16LE(eocd + 10);
  let p = buf.readUInt32LE(eocd + 16);
  for (let i = 0; i < count; i++) {
    if (buf.readUInt32LE(p) !== 0x02014b50) return null;
    const method = buf.readUInt16LE(p + 10);
    const csize = buf.readUInt32LE(p + 20);
    const nameLen = buf.readUInt16LE(p + 28);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.slice(p + 46, p + 46 + nameLen).toString('utf8');
    if (name === want) {
      const start = local + 30 + buf.readUInt16LE(local + 26) + buf.readUInt16LE(local + 28);
      const body = buf.slice(start, start + csize);
      return method === 8 ? zlib.inflateRawSync(body) : body;
    }
    p += 46 + nameLen + buf.readUInt16LE(p + 30) + buf.readUInt16LE(p + 32);
  }
  return null;
}

/**
 * Did Bambu Studio make this 3mf, or did we?
 *
 * This used to answer by looking for Metadata/project_settings.config, on the
 * grounds that theirs carried the slicer profile and ours never had one. Ours
 * carries one now — that is the whole point of the change that broke this — so
 * the absence of a profile no longer means anything.
 *
 * A real export names itself in 3D/3dmodel.model — Application is
 * "BambuStudio-02.07.01.62" — so ask that directly. Asking what a file IS beats
 * inferring from what we happen not to produce yet, which is exactly what rotted
 * the moment we started producing it.
 */
export function isBambuStudio3mf(buf) {
  try {
    const model = zipMember(buf, '3D/3dmodel.model');
    if (!model) return false;
    // A real export names itself: Application = "BambuStudio-02.07.01.62".
    return /name="Application">\s*BambuStudio/i.test(model.toString());
  } catch { return false; }
}

/** Which plate inside a 3mf holds the g-code: Metadata/plate_N.gcode. */
export function plateGcodeName(buf) {
  try { return zipNames(buf).filter((n) => /^Metadata\/plate_\d+\.gcode$/.test(n)).sort()[0] || null; }
  catch { return null; }
}

/* ---------------------------------------------------------------- png ---- */

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body), 0);
  return Buffer.concat([len, body, crc]);
}

/**
 * A small solid PNG for the printer's screen. The A1 mini shows the plate
 * thumbnail while it prints, and at a booth that is the operator's fastest way
 * to tell which machine is running whose keychain — so it is the backing
 * colour, not a grey square.
 */
export function solidPng(width, height, [r, g, b]) {
  const row = Buffer.alloc(1 + width * 3);
  for (let x = 0; x < width; x++) {
    row[1 + x * 3] = r; row[2 + x * 3] = g; row[3 + x * 3] = b;
  }
  const raw = Buffer.concat(Array.from({ length: height }, () => row));
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;    // bit depth
  ihdr[9] = 2;    // truecolour
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 6 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

const HEX = { BLACK: '#1c1c1e', WHITE: '#f5f5f7', RED: '#e23b3b', BLUE: '#2f6fed', GREEN: '#34a853',
  YELLOW: '#f4c20d', PINK: '#ff5fa2', PURPLE: '#8b5cf6', ORANGE: '#ff8a34', TEAL: '#14b8a6',
  GREY: '#8e8e93', GRAY: '#8e8e93', GOLD: '#d4af37', SILVER: '#c0c4cc', BROWN: '#8b5a2b' };

export function colourHex(name) {
  return HEX[String(name || '').toUpperCase()] || '#8e8e93';
}
const rgb = (hex) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16));

/* --------------------------------------------------------------- 3mf ----- */

const xmlEscape = (s) => String(s ?? '').replace(/[<>&"']/g, (c) =>
  ({ '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;', "'": '&apos;' }[c]));

/**
 * Wrap one plate's g-code as a Bambu 3MF.
 *
 * `meta` is the generator's own output — bbox, colours, estimated minutes and
 * grams — so the printer's screen shows the same numbers the tablet promised.
 */
/**
 * The slicer profile the printer needs in order to LOAD the second colour.
 *
 * A real Bambu Studio 3mf carries Metadata/project_settings.config: 571 keys,
 * 168 of them one-per-filament. We shipped none of it, and everything worked
 * right up to the moment the printer was asked to take filament 2 — at which
 * point it sat on "the filament is not inserted" and refused every other
 * command, because it had been told a second filament exists and given nothing
 * that says what it is. No type, no temperature, nothing to run a load with.
 *
 * This is that file, taken verbatim from a two-colour external-spool export for
 * an A1 mini — a profile known to work on this exact printer, rather than one
 * assembled from guesses. Only the colours are substituted; nozzle_temperature
 * in it is already 220, which is what the booth prints at.
 */
const PROJECT_SETTINGS = JSON.parse(
  fs.readFileSync(new URL('./templates/a1mini.project_settings.json', import.meta.url), 'utf8'),
);

/** The profile with this job's two colours in it. */
function projectSettings(c1, c2, cfg) {
  const out = { ...PROJECT_SETTINGS, filament_colour: [c1, c2] };
  const t = cfg.temp?.nozzle;
  if (t) {
    out.nozzle_temperature = [String(t), String(t)];
    out.nozzle_temperature_initial_layer = [String(cfg.temp?.nozzleFirst ?? t), String(t)];
  }
  return JSON.stringify(out, null, 4);
}

export function build3mf({ gcode, meta = {}, cfg = {}, name = 'plate', now = new Date(), extraParts = [] }) {
  const body = Buffer.from(gcode, 'utf8');
  const md5 = crypto.createHash('md5').update(body).digest('hex').toUpperCase();
  const date = now.toISOString().slice(0, 10);

  const c1 = colourHex(meta.colours?.layer1);
  const c2 = colourHex(meta.colours?.layer2);
  const [bx, by] = cfg.build?.bedCenter || [90, 90];
  const w = meta.bbox?.w ?? 100;
  const h = meta.bbox?.h ?? 40;
  const bbox = [bx - w / 2, by - h / 2, bx + w / 2, by + h / 2];
  const nozzle = cfg.build?.nozzleDiameter ?? 0.4;
  const seconds = Math.round((meta.estMinutes ?? 12) * 60);
  // Which layers each colour covers, and the one layer where they meet. Bambu's
  // own export declares this; without it the firmware is told two filaments
  // exist but never where the second one starts.
  const backing = meta.backingLayers ?? 7;
  const total = meta.layers ?? backing + (meta.designLayers ?? 2);

  const plateJson = {
    bbox_all: bbox,
    bbox_objects: [{ area: +(w * h).toFixed(2), bbox, id: 1, layer_height: cfg.build?.layerHeight ?? 0.28, name: `${name}.stl` }],
    bed_type: cfg.integrations?.lan?.bedType || 'textured_plate',
    filament_colors: [c1, c2],
    filament_ids: [0, 1],
    first_extruder: 0,
    first_layer_time: 200,
    is_seq_print: false,
    nozzle_diameter: nozzle,
    version: 2,
  };

  const sliceInfo = `<?xml version="1.0" encoding="UTF-8"?>
<config>
  <header>
    <header_item key="X-BBL-Client-Type" value="slicer"/>
    <header_item key="X-BBL-Client-Version" value="02.07.01.62"/>
  </header>
  <plate>
    <metadata key="index" value="1"/>
    <metadata key="extruder_type" value="0"/>
    <metadata key="nozzle_volume_type" value="0"/>
    <metadata key="enable_filament_dynamic_map" value="false"/>
    <metadata key="has_filament_switcher" value="false"/>
    <metadata key="filament_maps" value="1 1"/>
    <metadata key="limit_filament_maps" value="0 0"/>
    <metadata key="printer_model_id" value="${xmlEscape(cfg.integrations?.lan?.printerModelId || 'N1')}"/>
    <metadata key="nozzle_diameters" value="${nozzle}"/>
    <metadata key="timelapse_type" value="0"/>
    <metadata key="prediction" value="${seconds}"/>
    <metadata key="weight" value="${meta.estGrams ?? 6}"/>
    <metadata key="outside" value="false"/>
    <metadata key="support_used" value="false"/>
    <metadata key="label_object_enabled" value="false"/>
    <object identify_id="1" name="${xmlEscape(name)}" skipped="false" />
    <filament id="1" tray_info_idx="GFL99" type="PLA" color="${c1}" used_m="2.00" used_g="${meta.estGrams ?? 6}" group_id="0" nozzle_diameter="${nozzle}" volume_type="Standard" used_for_object="true" used_for_support="false"/>
    <filament id="2" tray_info_idx="GFL99" type="PLA" color="${c2}" used_m="0.30" used_g="1" group_id="0" nozzle_diameter="${nozzle}" volume_type="Standard" used_for_object="true" used_for_support="false"/>
    <nozzle id="0" extruder_id="1" nozzle_diameter="${nozzle}" volume_type="Standard"/>
    <layer_filament_lists>
      <layer_filament_list filament_list="0" layer_ranges="0 ${Math.max(0, backing - 1)}" />
      <layer_filament_list filament_list="0 1" layer_ranges="${backing} ${backing}" />
      <layer_filament_list filament_list="1" layer_ranges="${backing + 1} ${Math.max(backing + 1, total - 1)}" />
    </layer_filament_lists>
  </plate>
</config>
`;

  const model = `<?xml version="1.0" encoding="UTF-8"?>
<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" xmlns:BambuStudio="http://schemas.bambulab.com/package/2021">
 <metadata name="Application">3DiPad</metadata>
 <metadata name="BambuStudio:3mfVersion">1</metadata>
 <metadata name="CreationDate">${date}</metadata>
 <metadata name="ModificationDate">${date}</metadata>
 <metadata name="Title">${xmlEscape(name)}</metadata>
 <resources>
 </resources>
 <build/>
</model>
`;

  const modelSettings = `<?xml version="1.0" encoding="UTF-8"?>
<config>
  <plate>
    <metadata key="plater_id" value="1"/>
    <metadata key="plater_name" value=""/>
    <metadata key="locked" value="false"/>
    <metadata key="gcode_file" value="Metadata/plate_1.gcode"/>
    <metadata key="thumbnail_file" value="Metadata/plate_1.png"/>
    <metadata key="pattern_bbox_file" value="Metadata/plate_1.json"/>
  </plate>
</config>
`;

  const parts = [
    { name: '[Content_Types].xml', data: `<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
 <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
 <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
 <Default Extension="png" ContentType="image/png"/>
 <Default Extension="gcode" ContentType="text/x.gcode"/>
</Types>
` },
    { name: '_rels/.rels', data: `<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
 <Relationship Target="/Metadata/plate_1.png" Id="rel-2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail"/>
 <Relationship Target="/Metadata/plate_1.png" Id="rel-4" Type="http://schemas.bambulab.com/package/2021/cover-thumbnail-middle"/>
 <Relationship Target="/Metadata/plate_1_small.png" Id="rel-5" Type="http://schemas.bambulab.com/package/2021/cover-thumbnail-small"/>
</Relationships>
` },
    { name: '3D/3dmodel.model', data: model },
    { name: 'Metadata/_rels/model_settings.config.rels', data: `<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Target="/Metadata/plate_1.gcode" Id="rel-1" Type="http://schemas.bambulab.com/package/2021/gcode"/>
</Relationships>
` },
    { name: 'Metadata/model_settings.config', data: modelSettings },
    { name: 'Metadata/plate_1.png', data: solidPng(128, 128, rgb(c1)) },
    { name: 'Metadata/plate_1_small.png', data: solidPng(48, 48, rgb(c1)) },
    { name: 'Metadata/plate_1.json', data: JSON.stringify(plateJson) },
    { name: 'Metadata/slice_info.config', data: sliceInfo },
    { name: 'Metadata/project_settings.config', data: projectSettings(c1, c2, cfg) },
    // Which filament is in use across the print: colour 1, then 2, and this is
    // what tells the firmware a change is coming rather than surprising it.
    { name: 'Metadata/filament_sequence.json', data: JSON.stringify({ plate_1: { nozzle_sequence: [0, 0], optimal_assignment: [0, 0], sequence: [1, 2] } }) },
    { name: 'Metadata/plate_1.gcode', data: body },
    { name: 'Metadata/plate_1.gcode.md5', data: md5 },
    // For bisecting what the firmware actually requires: tools/probe-start.mjs
    // builds variants of this archive with parts added, so the difference
    // between a project the printer opens and one it refuses can be found a
    // part at a time rather than guessed at.
  ];

  // An extra part named the same as one we already ship REPLACES it. Appending
  // used to put a second entry with that name behind the first in the central
  // directory, so the override silently did nothing and the probe tool was
  // measuring an archive it thought it had modified.
  const byName = new Map(parts.map((part) => [part.name, part]));
  for (const part of extraParts) byName.set(part.name, part);
  return zip([...byName.values()], now);
}
