# 3DiPad — handover

## What this is

A booth/workshop system for 3D-printing kids' drawings as two-colour keychains.
Children draw on iPads; the drawing becomes g-code and prints on Bambu Lab A1
mini printers over LAN. Originally built for one fair, now being generalised —
preschools and drawing studios are interested.

Work on branch `claude/fair-booth-gcode-generator-blgp63`, PR and squash-merge to
`main`. The booth laptop (Windows) pulls `main`.

Node 22, ESM, no build framework. `npm test` (186 tests, all passing).
`npm start` builds the kiosk then serves. Read `config.example.json` first — it
is heavily commented and is the real documentation.

## Architecture, briefly

- `src/gcode/` — the generator. `engine.js` orchestrates; `geometry.js` builds
  backing shapes; `strokes.js` prepares drawn lines; `fill.js` rasterises the
  drawing; `outline.js` has offset/smooth/trace helpers.
- `src/kiosk/kiosk.html` — the whole tablet app, single file, inlined at build
  time into `public/index.html` (booth) and `public/standalone.html` (offline).
  **Those two built files are gitignored — never commit them.**
- `src/server.js` — Express: kiosk API, dashboard API, printer setup.
- `src/integrations/bambu.js` — FTPS upload + MQTT control.
  `bambu3mf.js` — hand-written 3mf writer.
- `dashboard/index.html` — the operator board.

## Current state

Working end to end: draw → g-code → 3mf → FTPS upload → MQTT start → print.
Volumetric flow cap (12 mm³/s) stops the infill failures. Operator panel on the
iPad (hold the corner chip, PIN-gated). Dashboard has stop, reset, reprint,
history.

**Colour change is the one unfinished thing.** See below.

## The colour change — read this before touching it

The booth pauses mid-print to swap filament. Modes in `colourChange.mode`:

- `purge` — park, retract, `M400 U1` pause, purge. **Verified, works, safe.**
- `cut` — Bambu's cut+eject sequence, then pause; operator loads by hand.
- `bambu` — full sequence including the toolchange.
- `pause` — bare `M400 U1`.

Hard-won facts, each bought with a real print:

| what | result |
|---|---|
| `T255` | "no tool" — silently does nothing, prints one colour |
| `T1` + `A` suffix | AMS slot 1 → "AMS Lite communication is abnormal", deadlock |
| `T254`, no suffix | external spool — load prompts and works, but cut is skipped |
| `M620 S1A` framing | cut + eject work, load deadlocks |

So framing and slot are separate knobs (`amsFraming`, `tool`). The untested
combination is `amsFraming: true` with `tool: 254` — AMS framing for the cut,
external slot for the load. **That is the immediate next experiment: one print.**

Two things that cost prints and must not be undone:

1. The pause is emitted **outside** the `M620…M621` pair. A printer that
   declines the change skips the whole block, taking the pause with it.
2. `generate()` throws if the change block contains no `M400 U1`.

`manual_color_change: true` in the MQTT print task is required — the pause is a
print-task property, not a g-code one. The 3mf also ships a 571-key
`project_settings.config` (taken from a real Bambu Studio export) so the printer
knows what filament 2 *is*.

## Traps that have bitten before

- **`colourChange.gcode` overrides `mode` entirely.** A booth ran for weeks on a
  bare `M400 U1` while we discussed a block it was ignoring. The startup log now
  prints which swap is actually in effect — trust that, not the config file.
- **Config is read once at startup.** Editing `config.json` needs a restart.
- **`config.json` is not in git** — it lives on the booth laptop only.
- The A1 mini accepts **one MQTT client**. Diagnostic tools steal it from the
  booth; `tools/booth-running.mjs` refuses to run while the server is up.
- Printers never send PUBACK — QoS 1 always times out, QoS 0 is correct.
- **Developer Mode** must be on per-printer or print commands are refused.
- A Bambu never leaves `FAILED` on its own; the dashboard's "Bed cleared" button
  records the operator's word instead.

## Open items

1. **Test `amsFraming: true`** — one print decides whether the change is
   automatic or stays manual.
2. **`GHL_LEAD_WEBHOOK_URL` is empty.** Every lead is sitting in a JSON file on
   the laptop. This is a lead-gen product with no lead capture wired up. Highest
   business value of anything on this list.
3. **Printer 2 needs Developer Mode** turned on.
4. **PNG/JPEG import** — the next feature. See below.

## Next feature: image import

Studios want to upload a drawing (black-and-white PNG/JPEG) instead of drawing
live. Everything downstream — queue, dispatch, printing — stays the same; only
the front of the pipeline changes.

The non-obvious constraint, and the thing to design around:

A single extruded line is ~0.45 mm wide. But the drawing prints as a **raised
bead**, 0.56 mm tall (2 × 0.28 layers). A 0.45 mm-wide, 0.56 mm-tall ridge on a
plate is taller than it is wide and snaps off in a pocket. That is why
`build.penRange` starts at **0.8 mm**, not 0.45.

A 1000 px image on a 60 mm plate is 0.06 mm/px, so a 5 px pencil stroke is
0.3 mm — well under the minimum. Traced literally, most of a child's drawing
would come out as gaps, whiskers and bits that fall off. **The trace must
enforce a minimum feature width**: thicken anything below ~0.8 mm rather than
print it thin, and drop specks too small to survive. `erode`/`dilate` in
`outline.js` and the `outlineOpenMm` config already do exactly this job for
hand-drawn shapes — reuse that machinery.

Ask for **real sample images** before designing. A clean black-on-white export
and a phone photo of pencil on lined paper are completely different problems,
and the second is what will actually arrive.

## How to work on this

Measure, don't infer. This project has a long history of plausible reasoning
being wrong on hardware — four failed guesses at the print-start protocol, three
at the filament slot, and a "smoothness" fix that measurement showed changed
nothing (the real cause was raster staircasing, not stroke sampling). When a
theory is testable, spend the print and find out.

Write tests that assert the property that actually failed. Twice a test asserted
that a command was *present* in the file when the real failure was that it was
never *reached*.

The user is technical, tests on real hardware quickly, and will say plainly when
something does not work. Give them the fastest path to unstick a printer first,
and the explanation second.
