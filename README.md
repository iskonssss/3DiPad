# 3DiPad — Draw-to-Print Keychain Booth

A fair-booth kiosk: kids draw on a tablet with a pencil, and their drawing becomes
a two-colour 3D-printed keychain on a Bambu Lab **A1 mini**. Built as a lead-gen
activity — every design is captured with the parent's name + phone, and they get a
WhatsApp when the print is ready.

```
 3 tablets (Safari PWA)                 Booth laptop (this server)              3× A1 mini
 ┌───────────────────┐   draw+submit   ┌──────────────────────────┐   .gcode   ┌──────────┐
 │ contact ▸ colours │ ──────────────▶ │ g-code engine            │ ─────────▶ │ Printer 1│
 │ ▸ hole ▸ draw     │   (local WiFi)  │ lead capture (CSV+SVG)   │  LAN/USB   │ Printer 2│
 │ ▸ preview ▸ send  │ ◀────────────── │ queue + operator board   │            │ Printer 3│
 └───────────────────┘   "in queue!"   │ Drive + WhatsApp         │            └──────────┘
                                        └──────────────────────────┘
```

## The keychain

- Flat, `100 × 40 mm`, ~4 mm thick: **backing plate (colour 1)** + **raised drawing (colour 2)**.
- One **5 mm keyring hole**: left, right, or **centre** (a semicircle bump on the top edge).
- The backing is a speed-optimized solid plate (solid top/bottom, sparse middle) so it
  prints in time; the drawing is extruded as raised beads (like a fat marker).
- Target **≤ 15 min** per print (the engine estimates and blocks over-budget designs).

## Two colours with no AMS — the operating model

Each job is **one colour swap**: the printer lays the backing in colour 1, pauses at the
transition (`M600`), an operator loads colour 2, and it finishes the drawing. **The g-code
itself is colour-agnostic — it just pauses.** Which two colours to load is encoded in the
**filename**:

```
BLUE-PINK_0001.gcode     →  load BLUE first, swap to PINK at the pause
BLACK-WHITE_0002.gcode   →  load BLACK first, swap to WHITE at the pause
```

The kid's **name and phone are not in the filename** — they live in the lead record
(`leads/leads.csv` + a per-design `.svg`), and the drawn name is visible on the print.

> ⚠️ **Staffing:** with no AMS, every print needs a mid-print filament swap, and with 3
> printers cycling the pauses collide. Plan for **one person dedicated to the printers**
> (swapping + clearing plates). The operator dashboard flags each job that needs a swap.

## Quick start

```bash
npm install
cp config.example.json config.json     # edit for your booth
cp .env.example .env                    # add secrets here (never committed)
npm start
```

- Kiosk (open on each tablet): `http://<laptop-ip>:3000/`
- Operator dashboard: `http://<laptop-ip>:3000/dashboard/`

On each iPad: open the kiosk URL in Safari → Share → **Add to Home Screen** for a
full-screen, no-address-bar kiosk. Apple Pencil works out of the box (palm-rejected once
the pencil is in use).

### Booth networking

Bring your **own travel router** — venue WiFi usually blocks device-to-device traffic, and
LAN print dispatch needs the tablets, laptop, and printers on the same subnet.

## What you must provide before the fair

1. **A real A1 mini start/end sequence.** Slice any simple print in Bambu Studio/OrcaSlicer
   with your filament, open the `.gcode`, and replace
   `src/gcode/templates/a1mini.start.gcode` / `a1mini.end.gcode` with its header/footer.
   This runs the A1's bed levelling + flow calibration — without it prints can fail.
   Keep the `{nozzle} {bed} {nozzleFirst} {bedFirst}` placeholders.
2. **The exact pause sequence** your firmware wants at a colour change — grab it from a
   Bambu print that has a colour change and paste into `config.json → colourChange.gcode`
   (default is `M600`).
3. **One calibration print.** Print a generated file once and check the wall-clock time,
   then tune `config.json → speed.*`, `build.layerHeight`, and `build.sparseSpacing` until
   it lands comfortably under 15 min. The estimator is deliberately conservative.

## Configuration (`config.json`)

| Key | What it controls |
| --- | --- |
| `build.*` | Plate size, layer/bead widths, hole/bulge, backing fill, bed centre |
| `speed.*` | Feedrates (mm/min). The main lever for the 15-min budget |
| `temp.*` | Nozzle/bed temps (substituted into the template) |
| `limits.*` | Hard print-time cap + drawing-length cap |
| `colourChange.gcode` | The pause inserted between backing and drawing |
| `palette` | Colours kids can pick (must match the spools you bring) |
| `output.filenamePattern` | Default `{c1}-{c2}_{seq}.gcode` |
| `integrations.*` | Drive folder, WhatsApp template, per-printer LAN details |

## Integrations

- **WhatsApp** (fully wired): set `integrations.whatsapp.enabled=true`, put
  `WHATSAPP_PHONE_NUMBER_ID` + `WHATSAPP_ACCESS_TOKEN` in `.env`, and create an **approved**
  template in Meta WhatsApp Manager (name in config, e.g. body
  `Hi {{1}}, your 3D print is ready for pickup!`). Fires when a job is marked **Ready**.
- **Google Drive** (optional): `npm install googleapis`, set
  `GOOGLE_APPLICATION_CREDENTIALS` to a service-account key, share the target folder with
  that service account, and set `integrations.drive.folderId`. Files always save locally too.
- **Bambu LAN auto-send** (interface + stub): sending over LAN is FTPS-upload + MQTT-start
  with each printer's Access Code. `src/integrations/bambu.js` documents the protocol and is
  ready to wire (`npm install bambulabs-api`). Until then the dashboard drives printing
  manually and the `.gcode` is available for download + on Drive.

## Operator dashboard

Live queue (auto-refreshing). Each card shows the two colours to load, the design preview,
the hole position, and the estimated time. Buttons: assign a printer, mark **Printing**,
flag a **Colour swap** (highlights the card), mark **Ready** (fires WhatsApp), mark
**Collected**. A `.gcode` download link is on every card.

## Development

```bash
npm test                       # engine test suite
npm run gen                    # sample design -> output/sample_centre.gcode + .svg preview
node src/gcode/cli.js left     # try a different hole
```

The g-code engine (`src/gcode/`) is pure and printer-independent — it takes strokes +
config and returns g-code + a time/material estimate, and is fully unit-tested.

## Data & privacy

Every submission writes a row to `leads/leads.csv` and a design `.svg`. These hold personal
contact details — they are **git-ignored**, kept only on the booth laptop. Handle per your
privacy notice / the consent the parent ticked.
