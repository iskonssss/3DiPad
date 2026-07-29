// Plate geometry in plate-local millimetres.
//
// Coordinate frame: origin at the bottom-left of the rectangular plate.
//   x in [0, W]  (W = plateWidth,  default 100)
//   y in [0, H]  (H = plateHeight, default 40)
// The optional centre "bulge" is a semicircle sitting on the top edge (y = H),
// extending above H, and only exists when the keyring hole is placed 'centre'.
//
// Everything downstream (perimeters, infill, hole avoidance) is derived from two
// primitives defined here:
//   - outline(): closed boundary polygons for perimeters
//   - spanAtY(): the solid x-intervals at a given scan height (hole removed)

/** Centre + radius of the 5 mm keyring hole for the chosen position. */
export function holeCircle(cfg, hole) {
  const { plateWidth: W, plateHeight: H, holeDiameter, holeInset, bulgeRadius: R } = cfg;
  const r = holeDiameter / 2;
  if (hole === 'left') return { cx: holeInset, cy: H / 2, r };
  if (hole === 'right') return { cx: W - holeInset, cy: H / 2, r };
  // centre: sit the hole up inside the bulge
  return { cx: W / 2, cy: H + R * 0.5, r };
}

/** Does this design use the top-edge semicircle bulge? Only the 'centre' hole does. */
export function hasBulge(hole) {
  return hole === 'centre';
}

/**
 * Closed boundary loops (arrays of {x,y}) for the plate and the hole.
 * Returns { plate, hole } where each is a closed polygon (first point repeated at end).
 */
export function outline(cfg, hole) {
  const { plateWidth: W, plateHeight: H, bulgeRadius: R } = cfg;
  const bulge = hasBulge(hole);
  const pts = [];
  pts.push({ x: 0, y: 0 });
  pts.push({ x: W, y: 0 });
  pts.push({ x: W, y: H });
  if (bulge) {
    // walk the top edge in from the right, arc over the bulge, continue to the left edge
    pts.push({ x: W / 2 + R, y: H });
    const steps = 48;
    for (let i = 1; i < steps; i++) {
      const a = Math.PI * (i / steps); // 0..pi, sweeping right->left over the top
      pts.push({ x: W / 2 + R * Math.cos(a), y: H + R * Math.sin(a) });
    }
    pts.push({ x: W / 2 - R, y: H });
  }
  pts.push({ x: 0, y: H });
  pts.push({ x: 0, y: 0 });

  const { cx, cy, r } = holeCircle(cfg, hole);
  const holePts = [];
  const hSteps = 40;
  for (let i = 0; i <= hSteps; i++) {
    const a = (2 * Math.PI * i) / hSteps;
    holePts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) });
  }
  return { plate: pts, hole: holePts };
}

/** Vertical extent (plate-local y) that contains solid material. */
export function yBounds(cfg, hole) {
  const { plateHeight: H, bulgeRadius: R } = cfg;
  return { yMin: 0, yMax: hasBulge(hole) ? H + R : H };
}

/**
 * Solid x-intervals at scan height y, with the keyring hole removed.
 * Returns an array of [x0, x1] (possibly empty, possibly split by the hole).
 * `inset` shrinks each interval on both sides (used to keep infill under the perimeter).
 */
export function spanAtY(y, cfg, hole, inset = 0) {
  const { plateWidth: W, plateHeight: H, bulgeRadius: R } = cfg;
  let base = [];
  if (y >= 0 && y <= H) {
    base = [[0, W]];
  } else if (hasBulge(hole) && y > H && y <= H + R) {
    const hw = Math.sqrt(Math.max(0, R * R - (y - H) * (y - H)));
    base = [[W / 2 - hw, W / 2 + hw]];
  } else {
    return [];
  }

  // remove the hole where the scanline crosses it
  const { cx, cy, r } = holeCircle(cfg, hole);
  if (Math.abs(y - cy) < r) {
    const dx = Math.sqrt(r * r - (y - cy) * (y - cy));
    base = subtractInterval(base, cx - dx, cx + dx);
  }

  // apply inset and drop slivers
  const out = [];
  for (const [a, b] of base) {
    const a2 = a + inset;
    const b2 = b - inset;
    if (b2 - a2 > 0.2) out.push([a2, b2]);
  }
  return out;
}

/** Remove [lo,hi] from a set of intervals, splitting where necessary. */
function subtractInterval(intervals, lo, hi) {
  const out = [];
  for (const [a, b] of intervals) {
    if (hi <= a || lo >= b) {
      out.push([a, b]); // no overlap
    } else {
      if (a < lo) out.push([a, lo]);
      if (hi < b) out.push([hi, b]);
    }
  }
  return out;
}

/** Translate a plate-local point to absolute bed coordinates (centred on the bed). */
export function toBed(pt, cfg) {
  const { plateWidth: W, plateHeight: H, bedCenter } = cfg;
  return { x: pt.x - W / 2 + bedCenter[0], y: pt.y - H / 2 + bedCenter[1] };
}

/** True if a plate-local point lies inside the solid plate region (ignoring the hole). */
export function insidePlate(pt, cfg, hole) {
  const spans = spanAtY(pt.y, cfg, hole, 0);
  return spans.some(([a, b]) => pt.x >= a && pt.x <= b);
}
