// An uploaded black-and-white drawing, turned into a printable design area.
//
// Studios want to upload a drawing instead of drawing live. Everything
// downstream — queue, dispatch, colour change, printing — is unchanged, because
// the design layer already prints an AREA rather than a pile of strokes (see
// fill.js). An image only has to become that same coverage mask, and then
// designLayer() draws it exactly as it draws a kid's finger-shaded shape.
//
// Decoding is NOT done here: the browser decodes the PNG/JPEG on the tablet and
// posts a thresholded binary bitmap. What is done here is the part the browser
// cannot be trusted with, because it is where prints fall off the plate.
//
// A single extruded bead is ~0.45mm wide but stands 0.56mm tall (2 x 0.28
// layers): a ridge taller than it is wide, which is what snaps off in a pocket.
// A 1000px drawing on a 60mm plate is 0.06mm/px, so a 5px pencil stroke is
// 0.3mm. Traced literally, most of a child's drawing comes out as gaps,
// whiskers and specks that fall off the bed.
//
// So the trace enforces a minimum feature width: thicken anything thinner than
// that rather than print it thin, and drop specks too small to survive. That is
// exactly what erode/dilate in outline.js already do to heal a hand-drawn
// outline, so the same morphology is reused here.
//
// IMAGE_MIN_FEATURE_MM is 0.5, not the 0.8 of build.penRange. Those two are
// different questions and it is worth not confusing them again: penRange[0] is
// the thinnest PEN a child is offered, chosen so a deliberate hand-drawn line
// reads as a line. This is the thinnest bead the printer will hold at all, and
// on this machine that is 0.5 — a shade over one line width. Line art scanned
// from paper is full of detail between those two numbers, and rounding it all
// up to 0.8 turns a face into a blot.
const IMAGE_MIN_FEATURE_MM = 0.5;

import { erode, dilate, fillPolygon } from './outline.js';
import { clearDisc } from './fill.js';

/**
 * Build a design coverage mask from a binary bitmap.
 *
 * `bitmap` = { w, h, ink } where `ink` is a row-major array (Uint8Array or
 * plain), 1 where the drawing is (dark ink), 0 where it is paper. Origin is the
 * top-left with y DOWN — the ordinary image convention. We flip to the plate's
 * y-up here, so the keychain comes out the same way up as the file looked.
 *
 * Returns the same { mask, w, h, cell, pad, toMm } shape buildCoverage returns,
 * so designLayer draws it with no change — or null if nothing printable
 * survives (blank scan, or every mark too small to keep).
 *
 * The mm knobs live under cfg.build with `image` prefixes and have defaults, so
 * this works before any are added to config.json. They are deliberately
 * conservative placeholders: the right values are a question only real sample
 * uploads can answer (a clean export and a phone photo of pencil are different
 * problems), and they are meant to be tuned against those.
 */
export function imageCoverage(bitmap, cfg, bbox, clipPoly, hole, edgeMargin) {
  const b = cfg.build;
  if (!bitmap || !bitmap.ink || !(bitmap.w > 0) || !(bitmap.h > 0)) return null;
  if (bitmap.ink.length < bitmap.w * bitmap.h) return null;

  const cell = b.designCell ?? 0.12;
  const pad = Math.ceil(3 / cell);
  const w = Math.ceil(bbox.w / cell) + pad * 2;
  const h = Math.ceil(bbox.h / cell) + pad * 2;
  if (w < 4 || h < 4 || w * h > 6_000_000) return null;

  // --- 1. sample the bitmap onto the plate grid, aspect-preserving ---
  // Contain-fit the image inside the plate box, keeping its own aspect ratio so
  // a drawing is never stretched. The letterboxed margin is plain paper.
  const imgAspect = bitmap.w / bitmap.h;
  const plateAspect = bbox.w / bbox.h;
  let drawW, drawH;
  if (imgAspect > plateAspect) { drawW = bbox.w; drawH = bbox.w / imgAspect; }
  else { drawH = bbox.h; drawW = bbox.h * imgAspect; }
  // The size slider: a fraction of the contain-fit, shrunk about the centre of
  // the plate, so a drawing can sit smaller than the base rather than always
  // touching two edges of it.
  const scale = Number.isFinite(bitmap.scale) ? Math.max(0.2, Math.min(1, bitmap.scale)) : 1;
  drawW *= scale; drawH *= scale;
  // Dragged into place: an offset from centred, in plate mm. Whatever ends up
  // off the plate is clipped below, same as a stroke drawn over the edge.
  const ox = Number.isFinite(bitmap.offset?.x) ? bitmap.offset.x : 0;
  const oy = Number.isFinite(bitmap.offset?.y) ? bitmap.offset.y : 0;
  const offX = (bbox.w - drawW) / 2 + ox, offY = (bbox.h - drawH) / 2 + oy;

  let mask = new Uint8Array(w * h);
  // How many source pixels fall under one cell. Below 1 the drawing is being
  // UPSCALED — a small logo on a big plate — and the union below would just
  // copy each source pixel's hard edge onto the plate as a step. Sampling the
  // source as a continuous field instead (bilinear between pixel centres,
  // cut at half) turns a diagonal of pixel steps into a straight edge, which
  // is what the drawing meant. Downscaling keeps the union: there, the risk is
  // losing a line, not a step.
  const pxPerCell = Math.min(bitmap.w / (drawW / cell), bitmap.h / (drawH / cell));
  if (pxPerCell < 1) {
    for (let j = 0; j < h; j++) {
      const my = (j - pad) * cell;
      const v = 1 - (my - offY) / drawH;                 // image v, y-down
      const fy = v * bitmap.h - 0.5;
      if (fy < -0.5 || fy > bitmap.h - 0.5) continue;
      for (let i = 0; i < w; i++) {
        const mx = (i - pad) * cell;
        const fx = ((mx - offX) / drawW) * bitmap.w - 0.5;
        if (fx < -0.5 || fx > bitmap.w - 0.5) continue;
        if (bilinear(bitmap, fx, fy) >= 0.5) mask[j * w + i] = 1;
      }
    }
  }
  // Sample by COVERAGE, not by point: a cell is ink if ANY source pixel under it
  // is ink.
  //
  // Point-sampling one source pixel per cell looks equivalent and is not. A
  // drawing posted at a higher resolution than the plate grid is being
  // downscaled here, so point-sampling steps straight over whole rows of it: a
  // one-pixel line that happens to fall on a skipped row is gone before the
  // minimum-width pass below ever sees it, and the drawing quietly comes out
  // missing a line. Measured on two hairlines 0.6mm apart, both vanished
  // completely — nothing in the file, nothing to notice until the part is in a
  // child's hand.
  //
  // Taking the union over the footprint cannot lose a line: whatever the scale,
  // every source pixel belongs to some cell. Thin is then a thickening problem,
  // which is solved below, rather than a disappearing one, which cannot be.
  for (let j = 0; pxPerCell >= 1 && j < h; j++) {
    const my = (j - pad) * cell;                 // plate-local mm, y-up (centre)
    // image y is DOWN, plate y is UP: the top of the drawing (row 0) belongs at
    // the top of the plate (largest y), so the v range flips into rows.
    const v0 = (my - cell / 2 - offY) / drawH, v1 = (my + cell / 2 - offY) / drawH;
    let py0 = Math.floor((1 - v1) * bitmap.h);
    let py1 = Math.ceil((1 - v0) * bitmap.h) - 1;
    // entirely off the drawing: letterbox margin, and it stays blank paper
    if (py1 < 0 || py0 > bitmap.h - 1) continue;
    if (py0 < 0) py0 = 0;
    if (py1 > bitmap.h - 1) py1 = bitmap.h - 1;
    for (let i = 0; i < w; i++) {
      const mx = (i - pad) * cell;
      const u0 = (mx - cell / 2 - offX) / drawW, u1 = (mx + cell / 2 - offX) / drawW;
      let px0 = Math.floor(u0 * bitmap.w);
      let px1 = Math.ceil(u1 * bitmap.w) - 1;
      if (px1 < 0 || px0 > bitmap.w - 1) continue;
      if (px0 < 0) px0 = 0;
      if (px1 > bitmap.w - 1) px1 = bitmap.w - 1;
      let on = 0;
      for (let py = py0; py <= py1 && !on; py++) {
        const row = py * bitmap.w;
        for (let px = px0; px <= px1; px++) if (bitmap.ink[row + px]) { on = 1; break; }
      }
      if (on) mask[j * w + i] = 1;
    }
  }

  // --- 2. close: bridge the pin-holes threshold speckle leaves in a fill ---
  const closeR = (b.imageCloseMm ?? 0.3) / cell;
  if (closeR > 0) {
    mask = dilate(mask, w, h, closeR);
    mask = erode(mask, w, h, closeR);
  }

  // --- 3. drop specks too small to survive as their own bead ---
  // By AREA, not by opening: opening deletes thin LINES too, and a line is the
  // one thing we must keep (and thicken). A speck is small every way; a pencil
  // line is narrow but long, so it clears the area threshold and stays.
  const speckMm = b.imageSpeckMm ?? IMAGE_MIN_FEATURE_MM;
  const minCells = Math.max(4, Math.round(Math.PI * (speckMm / 2) ** 2 / (cell * cell)));
  mask = dropSpecks(mask, w, h, minCells);

  // --- 4. thicken thin features to the minimum, leaving thick ones as drawn ---
  // "Thicken anything below ~0.8mm rather than print it thin" — but only the
  // thin things. An opening (erode then dilate) by the minimum half-width keeps
  // exactly the parts already at least that wide; whatever the opening drops is,
  // by definition, thinner than the minimum. Those thin parts are dilated up to
  // width and unioned back, so a thick blob is untouched while a hairline is
  // grown to a printable bead. A blanket dilation would instead bold everything
  // by the same amount and merge features a child meant to keep apart.
  const minW = b.imageMinFeatureMm ?? IMAGE_MIN_FEATURE_MM;
  const minR = (minW / 2) / cell;
  // Growth is quantised by the grid: a one-cell line dilates to 3 cells or to
  // 5, never to the 4.17 that would be exactly 0.5mm. 3 cells is 0.36mm, under
  // the floor and liable to snap, so the wider one is taken — a line comes out
  // at 0.60mm, at or above what was asked for, never under it.
  if (minR > 0) {
    const wide = dilate(erode(mask, w, h, minR), w, h, minR);   // opening: parts >= minW wide
    const thin = new Uint8Array(w * h);
    let anyThin = false;
    for (let i = 0; i < mask.length; i++) if (mask[i] && !wide[i]) { thin[i] = 1; anyThin = true; }
    if (anyThin) {
      // Not everything the opening drops is a line. The tip of every sharp
      // corner on a THICK shape is thinner than minW too, and growing those
      // put a round knob on every corner of a logo. A line is long; a corner
      // crumb is not. Only pieces at least a few line-widths long are grown;
      // the crumbs stay exactly as drawn (they are still in `mask`).
      const longEnough = (2 * minW) / cell;
      const lines = keepLongComponents(thin, w, h, longEnough);
      const grown = dilate(lines, w, h, minR);
      for (let i = 0; i < mask.length; i++) if (grown[i]) mask[i] = 1;
    }
  }

  // --- 5. clip to the plate as an AREA, and carve out the hole ---
  // A mark whose centre sits legally inside can still have its bead hang over
  // the rim; only the area can see that, same as buildCoverage.
  if (clipPoly && clipPoly.length >= 3) {
    let clip = fillPolygon(clipPoly.map((p) => ({ x: p.x / cell + pad, y: p.y / cell + pad })), w, h);
    if (edgeMargin > 0) clip = erode(clip, w, h, edgeMargin / cell);
    for (let i = 0; i < mask.length; i++) if (!clip[i]) mask[i] = 0;
  }
  if (hole && !hole.none) {
    const cx = hole.cx / cell + pad, cy = hole.cy / cell + pad;
    const r = (hole.r + b.lineWidth) / cell;
    clearDisc(mask, w, h, cx, cy, r);
  }

  let any = false;
  for (let i = 0; i < mask.length && !any; i++) if (mask[i]) any = true;
  if (!any) return null;

  return { mask, w, h, cell, pad, toMm: (c) => ({ x: (c.x - pad) * cell, y: (c.y - pad) * cell }) };
}

/** Ink value at a fractional pixel position, interpolated between pixel centres. */
function bilinear(bitmap, fx, fy) {
  const { w, h, ink } = bitmap;
  const x0 = Math.max(0, Math.min(w - 1, Math.floor(fx))), y0 = Math.max(0, Math.min(h - 1, Math.floor(fy)));
  const x1 = Math.min(w - 1, x0 + 1), y1 = Math.min(h - 1, y0 + 1);
  const tx = Math.max(0, Math.min(1, fx - x0)), ty = Math.max(0, Math.min(1, fy - y0));
  const a = ink[y0 * w + x0], b = ink[y0 * w + x1], c = ink[y1 * w + x0], d = ink[y1 * w + x1];
  return (a * (1 - tx) + b * tx) * (1 - ty) + (c * (1 - tx) + d * tx) * ty;
}

/** Keep only 8-connected components whose bounding box spans at least `minSpan` cells. */
function keepLongComponents(mask, w, h, minSpan) {
  const seen = new Uint8Array(w * h);
  const out = new Uint8Array(w * h);
  const stack = [];
  for (let start = 0; start < mask.length; start++) {
    if (!mask[start] || seen[start]) continue;
    const cells = [];
    let minX = w, maxX = -1, minY = h, maxY = -1;
    stack.push(start); seen[start] = 1;
    while (stack.length) {
      const c = stack.pop(); cells.push(c);
      const x = c % w, y = (c - x) / w;
      if (x < minX) minX = x; if (x > maxX) maxX = x; if (y < minY) minY = y; if (y > maxY) maxY = y;
      for (let dy = -1; dy <= 1; dy++) for (let dx = -1; dx <= 1; dx++) {
        if (!dx && !dy) continue;
        const nx = x + dx, ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        const n = ny * w + nx;
        if (mask[n] && !seen[n]) { seen[n] = 1; stack.push(n); }
      }
    }
    if (Math.max(maxX - minX, maxY - minY) + 1 >= minSpan) for (const c of cells) out[c] = 1;
  }
  return out;
}

/** Keep only connected components of at least `minCells` cells (4-connected). */
function dropSpecks(mask, w, h, minCells) {
  const seen = new Uint8Array(w * h);
  const out = new Uint8Array(w * h);
  const stack = [];
  for (let start = 0; start < mask.length; start++) {
    if (!mask[start] || seen[start]) continue;
    stack.length = 0;
    stack.push(start);
    seen[start] = 1;
    const cells = [];
    while (stack.length) {
      const i = stack.pop();
      cells.push(i);
      const x = i % w, y = (i - x) / w;
      if (x > 0 && mask[i - 1] && !seen[i - 1]) { seen[i - 1] = 1; stack.push(i - 1); }
      if (x < w - 1 && mask[i + 1] && !seen[i + 1]) { seen[i + 1] = 1; stack.push(i + 1); }
      if (y > 0 && mask[i - w] && !seen[i - w]) { seen[i - w] = 1; stack.push(i - w); }
      if (y < h - 1 && mask[i + w] && !seen[i + w]) { seen[i + w] = 1; stack.push(i + w); }
    }
    if (cells.length >= minCells) for (const i of cells) out[i] = 1;
  }
  return out;
}

/**
 * Decode the wire form the kiosk posts: { w, h, data } where `data` is a
 * base64-encoded, bit-packed ink mask (bit set = ink), row-major, MSB first.
 * Returns { w, h, ink: Uint8Array } or null if the payload is unusable.
 *
 * Bit-packed because a plate-resolution mask is one bit a cell; at 8 cells a
 * byte an 850x340 bitmap is ~36KB rather than a third of a megabyte of "0"/"1".
 */
export function decodeBitmap(image) {
  if (!image || !(image.w > 0) || !(image.h > 0) || typeof image.data !== 'string') return null;
  const w = image.w | 0, h = image.h | 0;
  const n = w * h;
  let bytes;
  try {
    bytes = typeof Buffer !== 'undefined'
      ? Uint8Array.from(Buffer.from(image.data, 'base64'))
      : Uint8Array.from(atob(image.data), (c) => c.charCodeAt(0));
  } catch { return null; }
  if (bytes.length < Math.ceil(n / 8)) return null;
  const ink = new Uint8Array(n);
  for (let i = 0; i < n; i++) ink[i] = (bytes[i >> 3] >> (7 - (i & 7))) & 1;
  const out = { w, h, ink };
  if (Number.isFinite(image.scale)) out.scale = image.scale;
  if (image.offset && Number.isFinite(image.offset.x) && Number.isFinite(image.offset.y)) out.offset = { x: image.offset.x, y: image.offset.y };
  return out;
}
