# NFC Spinner Keychain — reference files

Print-in-place flip-spinner keychain used in corporate workshops.
The centre disc flips freely about the axis through the hanging loop.
An NFC tag sits in a floating cavity inside the disc.

Folders:
- `blank/`        — spinner with no design (STL, G-code, sliced 3mf, .bbl)
- `with design/`  — same spinner with a two-colour drawing, plus photos

The 3mf files are Bambu "sliced plate" exports: settings + g-code only,
no mesh and no paint data. The STL is the geometry source. It comes from
Tinkercad and holds several separate shells that Bambu Studio splits into
parts and assigns filaments to.

## Geometry (measured from the STL, mm; centre of the round body = 0,0)

| part | value |
|---|---|
| body | Ø45, 5.0 thick (25 layers × 0.2) |
| outer ring | r 18.0 → 22.5, 0.5 mm edge round top and bottom |
| disc | r 16.5 → gap to ring 1.5 |
| pivot pins | on the disc at +Y and −Y only. Diamond profile: start Z 0.5, out to r 20.3 at Z 2.2, flat to Z 2.8, back to r 16.5 at Z 4.5 |
| pivot pockets | matching recess in the ring: r 18 → 20.8 at Z 2.2–2.8. ~0.5 mm radial clearance, pocket starts ~0.15 mm above the pin |
| NFC cavity | 22 (X) × 12 (Y) × 0.6, Z 2.2–2.8, centred in the disc. A separate negative shell in the STL |
| hanging loop | at +Y: hole r 22.5–25, ring r 25–27, only 4.0 mm thick (Z 0–4.0) |
| design | separate shells, 22.5 × 28 area on the disc, Z 0–0.4 (bottom) and Z 4.6–5.0 (top). Inlaid flush, 2 layers each face |

## Slicer settings that matter (from the G-code config block)

Profile "0.2mm NFC Keychain A1 Mini", Bambu Studio 02.08.02.61,
A1 mini, 0.4 nozzle, Generic PLA, Textured PEI at 65 °C, nozzle 220 °C.

- layer 0.2, first layer 0.2, line width 0.42 (outer) / 0.45 (inner)
- walls 2, top shell 5, bottom shell 3, sparse 15 % grid
- colour penetration 2 layers top and bottom
- bridge speed 20 (default 50), thick bridges on, bridge flow 1.0
- outer wall 200, inner 300, sparse 270, solid 250, top 200, first layer 50
- max volumetric 12 mm³/s, retraction 0.8, z-hop 0.4
- support ON, tree(auto), threshold 30° — the slicer only puts support under
  the two pivot pins in layers 1–2
- pause `M400 U1` before layer 15 (Z 3.0) to drop the NFC tag in; the
  cavity roof bridges on layer 15
- prime tower ON in the design print (35 mm wide), off in the blank

## How the two-colour print runs today (external spool, no AMS)

Colour 2 prints on layers 1–2 (bottom design) and 24–25 (top design).
The slicer interleaves per layer, so there are FOUR filament changes:
T1 in layer 1, T0 in layer 2, T1 in layer 24, T0 in layer 25.

| | blank | with design |
|---|---|---|
| print time | 21 min | 38 min |
| filament | 5.9 g | 9.3 g + 1.6 g |

The bottom-face design must be mirrored so it reads correctly from below.

## What the booth generator does with this (src/gcode/spinner.js)

Every number above is a setting in `config.example.json` under `spinner`.
The body is generated from those; only the drawings change per child.

- Same layer plan as the slicer's file: 25 layers, cavity on 12–14, pause
  before 15, roof bridged on 15 at 20 mm/s, colour on 1–2 and 24–25.
- Colour order: body L1 → drawing L1–2 → body L2–24 → drawing L24–25 →
  body L25. Four swaps, the same as the slicer needs. `colourLayers: 1`
  makes it three.
- Support under the pins as the slicer did it: two layers of loose lines in
  the gap under each pin nose, a gap layer, then the pin. Breaks away on the
  first flip. (`pin.foot` is an alternative that grows the disc down instead.)
- The back face is mirrored so it reads correctly when the disc is flipped;
  a different back drawing is optional.
- First print (2026-09-26): pins fused to the pockets at the modelled
  clearance. The pocket is now opened by `pin.extraClearance` (0.3) and the
  floating walls print at 10 mm/s like the slicer's. Tune from there.

## Future

- Printers: A1 mini and A1, both with AMS, 0.2 mm nozzle, PLA.
- Keep every number above parametric; the 0.2 nozzle changes layer
  height and line width.
