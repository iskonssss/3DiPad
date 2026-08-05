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
// layers): a ridge taller than it is wide. Below about 0.8mm wide it snaps off
// in a pocket, which is why build.penRange starts at 0.8 and not at the line
// width. A 1000px drawing on a 60mm plate is 0.06mm/px, so a 5px pencil stroke
// is 0.3mm — well under that minimum. Traced literally, most of a child's
// drawing comes out as gaps, whiskers and specks that fall off the bed.
//
// So the trace enforces a minimum feature width: thicken anything thinner than
// one bead rather than print it thin, and drop specks too small to survive.
// That is exactly what erode/dilate in outline.js already do to heal a
// hand-drawn outline, so the same morphology is reused here.

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
  const offX = (bbox.w - drawW) / 2, offY = (bbox.h - drawH) / 2;

  let mask = new Uint8Array(w * h);
  const inkAt = (px, py) => {
    if (px < 0 || py < 0 || px >= bitmap.w || py >= bitmap.h) return 0;
    return bitmap.ink[py * bitmap.w + px] ? 1 : 0;
  };
  for (let j = 0; j < h; j++) {
    const my = (j - pad) * cell;                 // plate-local mm, y-up
    if (my < offY || my > offY + drawH) continue;
    // image y is DOWN, plate y is UP: the top of the drawing (row 0) belongs at
    // the top of the plate (largest y).
    const v = (my - offY) / drawH;               // 0 at bottom, 1 at top
    const py = Math.min(bitmap.h - 1, Math.floor((1 - v) * bitmap.h));
    for (let i = 0; i < w; i++) {
      const mx = (i - pad) * cell;
      if (mx < offX || mx > offX + drawW) continue;
      const u = (mx - offX) / drawW;
      const px = Math.min(bitmap.w - 1, Math.floor(u * bitmap.w));
      if (inkAt(px, py)) mask[j * w + i] = 1;
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
  const speckMm = b.imageSpeckMm ?? (b.penRange?.[0] ?? 0.8);
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
  const minW = b.imageMinFeatureMm ?? (b.penRange?.[0] ?? 0.8);
  const minR = (minW / 2) / cell;
  if (minR > 0) {
    const wide = dilate(erode(mask, w, h, minR), w, h, minR);   // opening: parts >= minW wide
    const thin = new Uint8Array(w * h);
    let anyThin = false;
    for (let i = 0; i < mask.length; i++) if (mask[i] && !wide[i]) { thin[i] = 1; anyThin = true; }
    if (anyThin) {
      const grown = dilate(thin, w, h, minR);
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
  return { w, h, ink };
}
