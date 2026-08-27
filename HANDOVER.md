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

Hard-won facts, each bought with a real print — and then overturned by a file
that cost nothing:

| what | result |
|---|---|
| `T255` | "no tool" — silently does nothing, prints one colour |
| `T254`, `M620 S254` | no cut. Load prompts and works |
| `M620 S254A`, `M620.11 … I254` | no cut |
| `M620 S1A`, `M620.11 … I1`, with `T1` | cut + eject happened once; load deadlocked |
| `M620 S1A`, `M620.11 … I1`, no `T` | no cut |

**Every row above was measured with a command that does not exist.** We were
sending `M620.11 S1 I<tool> E-18 F1200`, whose S value, `I` parameter and `E`
retraction were all reasoned out from `retraction_distances_when_cut` in the
machine profile. Six prints went into varying the arguments of a command whose
real signature takes none of them, which is why the cut never fired and why the
table above explains nothing.

A real Bambu Studio two-colour export for this exact machine — A1 mini,
external spool, `extruder_ams_count = 1#0|4#0`, i.e. **no AMS of any size
attached** — settles all of it:

```
G392 S0 / M1007 S0
M620 S1A                 <- filament INDEX 1, and the A is there with no AMS
M204 S9000 / G1 Z.. / M400 / M106 P1 S0 / M106 P2 S0 / M104 S220
G1 X180 F18000           <- the cutter
M620.11 S0               <- the cut. No I, no E, no F. Emitted TWICE.
M400
M620.1 E F299.339 T240   <- flush at the HIGHER temp, not the print temp
M620.10 A0 F299.339
T1                       <- the toolchange IS what drives cut-unload-reload
M73 E1
M620.1 E F299.339 T240
M620.10 A1 F299.339 L342.471 H0.4 T240
G1 Y90 F9000
M620.11 S0               <- again, after the change
M400 / G92 E0 / M628 S0
   ... FLUSH / WIPE / FLUSH / WIPE ...
M629
   ... cool-down wipe, M622 cali block ...
M621 S1A
G392 S0 / M1007 S1
```

Three beliefs written into this file were wrong, and each cost prints:

1. **`254` is not "the external spool" and `255` is not "no tool".** `T<n>` takes
   an index into the print's own filament list — 0 for the first colour, 1 for
   the second. 255 appears once, in the end-of-print unload.
2. **The `A` suffix is not AMS addressing.** The no-AMS export writes `S1A` and
   `S0A` on every change.
3. **`M620.11` does not perform the cut and takes no arguments.** `T<n>` drives
   the routine.

There is also **no pause anywhere in the real file** — `M400 U1` appears only as
the `machine_pause_gcode` config value. The stop comes from
`manual_color_change` in the print task, which we already send. Our pause is
kept anyway, outside `M620…M621`, because a file that never stops is a
one-colour keychain and that is the one failure nobody can see coming.

`src/gcode/engine.js` emits the sequence above verbatim, and **as of 2026-08-27
the automatic change works on hardware**: cut, eject, prompt, the operator
feeds colour 2 in, the printer grabs it, purges at the right edge and prints.

What it took, after the g-code was already right, was three more transcriptions
and one bisect — none of them a guess:

1. **Start g-code.** Bambu's own start has a "prepare material" section
   (`M620 M` enable remap → `M620 S0A` → `T0` → `M621 S0A`). Ours homed and
   primed. Without it the later `T1` had nothing to bind to and went looking
   for an AMS Lite. Transcribed into `a1mini.start.gcode`.
2. **Header.** Studio writes `; filament: 1,2` with per-filament lengths; ours
   said `; filament: 1`. Now per filament.
3. **The print command — `cfg: "1"`.** The printer writes a task record to
   `/sdcard/cache/<plate>_<name>.bbl` the moment it accepts a job, and that
   record carries `manual_color_change`. Studio's prints recorded `true`, ours
   `false`, whatever we sent — `manual_color_change: true`, `ext_change_assist`,
   `ams_mapping [254,254]`: all guesses, all ignored. Studio's real command was
   captured off the printer's report topic (it echoes every command it
   receives), and `tools/probe-change.mjs` then bisected its fields against
   the task record without printing anything: upload, start, read the record
   after 20 s, stop. Studio's own 3mf with our command → false (the file was
   never the problem). Ours + `cfg: "1"` → **true**. md5, cali flags, the
   `ftp://` url form → nothing. One field.

`ams_mapping [-1,-1]` / `ams_mapping2 [{ams_id:255,slot_id:0}×2]` (external
spool per filament) are also sent because Studio sends them; the bisect did
not isolate whether they are needed on top of `cfg`, so they stay.

Two tools worth knowing about, both zero-cost: `GET /api/printers/:slot/recent`
returns the printer's last command echoes in full (how Studio's command was
read), and `tools/probe-change.mjs` is the bisect harness. The printer ignores
a second MQTT client, so the probe publishes through the booth
(`POST /api/printers/:slot/command`, localhost only) — the booth must be up.

Also fixed the same day: the purge after the pause now re-parks at X180 Y90
first (the screen-driven load leaves the head over the part, and a blob landed
on a keychain); a FINISH printer is sendable (it was refused as "holding a
job" while the tile said READY); mode `"manual"` exists as a no-toolchange
fallback but is unneeded.

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
- **A printer that reports nothing is not a printer doing nothing.** Bambu sends
  DELTAS, and a delta need not mention `gcode_state` at all, so any code that
  waits passively for a state to change can time out while the printer is
  working perfectly. Anything that waits on printer state must ask for a
  `pushall` part way through rather than only listening. This was diagnosed
  once, in #54, and fixed in `clearIfStuck` — `confirmStart` had the same loop
  ten lines away in another file and kept the bug for months, which is why "the
  file is on the SD card but the printer did not start it" came back long after
  it was supposedly settled. **When a fix like this lands, grep for the other
  call sites before closing it.**
- **A paused printer holds the machine exactly like a failed one.** The next
  file uploads, the print command is accepted, and nothing starts. `PAUSE` is
  deliberately NOT in `STUCK_STATES` — a pause mid-job is the colour change
  doing its job — so it is cleared only in `clearBeforeSend`, where any pause
  belongs to a job already finished with. A booth ends up here every time an
  operator abandons a swap.

## Open items

1. ~~Run the transcribed colour change once~~ — done, works, `mode: "bambu"`
   is the booth setting. See the colour-change section for what it took.
2. **`GHL_LEAD_WEBHOOK_URL` is empty.** Every lead is sitting in a JSON file on
   the laptop. This is a lead-gen product with no lead capture wired up. Highest
   business value of anything on this list.
3. **A `FAILED` printer needs its own screen, and nothing else reaches it.**
   `stop` is accepted — the printer answers "success" — and `gcode_state` stays
   `FAILED` anyway. The dashboard's reset sends that same `stop`, so it does not
   help either. Someone has to dismiss the dead job on the touchscreen, or start
   a file from it. Until then every upload lands on a printer that will not
   start anything, and the booth reports "on the SD card but the printer did not
   start it" over and over.
   Worth an honest note about diagnosing this: an earlier version of this entry
   said printer 2's IP was on the wrong subnet, reasoned from one log where the
   laptop was on `192.168.100.x` and the printer on `192.168.10.x`. Running
   `npm run test-printer` showed the printer reachable, logging in over FTPS,
   and reporting `FAILED 0%`. The printers move between a home network and the
   booth's; a timeout usually means the machine is elsewhere, not misconfigured.
   **Run the tool before theorising about the network** — it answers in 30
   seconds what a log will not.
4. **PNG/JPEG import** — built on `claude/png-jpeg-image-import-wb68kf`, not yet
   merged. The booth laptop is still on `main` and does not have it.

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
