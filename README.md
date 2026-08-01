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
 └───────────────────┘   "in queue!"   │ Drive · CRM/WhatsApp      │──▶ GoHighLevel (lead+ready)
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

**On the booth laptop, no terminal needed:** double-click **`Start Booth.cmd`** (Windows) or
run `./start-booth.sh` (macOS/Linux). It updates to the latest version, installs anything
missing the first time, starts the server and opens the dashboard. Leave the window open;
closing it stops the booth.

The address to open on the iPads is printed when it starts:

```
  ON THE IPADS, OPEN:
     http://192.168.10.162:3000      (Wi-Fi)
```

Printers are set up from **Printer setup** on the dashboard — no config file editing.

<details>
<summary>The equivalent by hand</summary>

```bash
npm install
cp .env.example .env                    # secrets only; config.json is written for you
npm start
```

`config.json` is created on first use from `config.example.json`, and any setting added to
the example later is picked up automatically — a booth set up months ago still gets new
defaults without re-copying the file.
</details>

- Kiosk (open on each tablet): `http://<laptop-ip>:3000/`
- Operator dashboard: `http://<laptop-ip>:3000/dashboard/`
- Printer setup: `http://<laptop-ip>:3000/dashboard/setup.html`

> ⚠️ **Don't run the project from Google Drive, OneDrive or Dropbox.** The sync client
> copies `node_modules` (2,000+ files) and `.git` one file at a time and locks them
> mid-write, which is slow and can corrupt the checkout in the middle of a fair. Drive's
> **"Other computers"** area is worse — it is a read-only backup of a different machine, so
> `npm` and `git` fail outright there.
>
> To get the day's files into a synced folder, keep the project on local disk and point the
> **output** at the drive instead:
>
> ```json
> "output": {
>   "dir": "G:/My Drive/3DiPad/gcode",
>   "leadsDir": "G:/My Drive/3DiPad/leads"
> }
> ```
>
> Both accept an absolute path; anything relative hangs off the project folder. The g-code
> and the lead records (`leads.csv` + a per-design `.svg`) then sync automatically, while
> the code, `node_modules` and `.git` stay where they belong. The launcher and the server
> both warn if the project itself is sitting in a synced folder.

On each iPad: open the kiosk URL in Safari → Share → **Add to Home Screen** for a
full-screen, no-address-bar kiosk. Apple Pencil works out of the box (palm-rejected once
the pencil is in use).

### Booth networking

Bring your **own travel router** — venue WiFi usually blocks device-to-device traffic, and
LAN print dispatch needs the tablets, laptop, and printers on the same subnet.

## Standalone single-file version (`public/standalone.html`)

A fully self-contained build that needs **no server**: the g-code engine runs in the browser,
so a kid can draw, preview, and **download the real `.gcode`** on any iPhone/iPad. Use it to
demo the experience, or host it on any static host (GitHub Pages, Netlify) and open it on the
tablets. Touch/iOS-optimised — responsive from iPhone portrait to iPad landscape, palm-rejected
Apple Pencil, safe-area aware, add-to-home-screen full-screen.

It's the same engine and flow as the full app; what it *doesn't* do (because there's no server)
is auto-dispatch to printers, push to GoHighLevel, or upload to Drive — those need the booth
server. Think of it as the client half, running offline.

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

## Notifications & CRM

The notify layer is pluggable — `config.integrations.notify.provider`:

- **`ghl` — GoHighLevel (recommended for lead-gen).** The booth fires two Inbound-Webhook
  events; GHL upserts the contact, tags it, sends the WhatsApp, and runs the nurture. GHL
  owns all messaging.
  - **On submit** → `event: "lead"` (captures the parent even if they never collect the print).
  - **On Ready** → `event: "ready"` (fires the pickup WhatsApp).
  - Setup: in GHL create a workflow with an **Inbound Webhook** trigger, copy its URL into
    `.env` (`GHL_LEAD_WEBHOOK_URL`, optionally a separate `GHL_READY_WEBHOOK_URL` — or branch
    on `payload.event` in one workflow). Map the payload to contact fields, add your tags, and
    add a **Send WhatsApp** action using your **approved template** (business-initiated messages
    require one — GHL manages it). Payload fields:
    ```
    event, status, first_name, full_name, phone, phone_e164,
    fair, tags[], job_id, seq, filename, colours, layer1, layer2,
    hole, est_minutes, drive_link, submitted_at
    ```
- **`meta` — WhatsApp Cloud API direct.** Set `integrations.whatsapp.enabled=true`, put
  `WHATSAPP_PHONE_NUMBER_ID` + `WHATSAPP_ACCESS_TOKEN` in `.env`, and create an **approved**
  template in Meta WhatsApp Manager. Fires on **Ready** only (no lead-capture step).
- **`none`** — no messaging; run the queue manually from the dashboard.

Every webhook/notification goes through a **persistent retry outbox** — if the booth WiFi
blips, the lead is queued to disk and retried, not lost. The dashboard shows a "⏳ N queued"
pill while anything is pending.

## Other integrations

- **Google Drive** (optional): `npm install googleapis`, set
  `GOOGLE_APPLICATION_CREDENTIALS` to a service-account key, share the target folder with
  that service account, and set `integrations.drive.folderId`. Files always save locally too.
## Bambu LAN auto-send + status monitoring

With LAN mode configured, a submitted design is uploaded to a free printer and started
automatically, and the print's progress drives the job forward with no operator tap:

| Printer state | Job becomes | Effect |
| --- | --- | --- |
| `RUNNING` | `printing` | shown live on the dashboard with % and ETA |
| `PAUSE` | `colour_change` | card flags **SWAP NOW → load colour 2** |
| `FINISH` | `ready` | **fires the pickup WhatsApp automatically** |
| `FAILED` | `failed` | flagged red for the operator |

**Setup — from the dashboard**

1. On each printer: **Settings → Network → LAN Mode ON**. Note its **Access Code**
   (Settings → Network) and **Serial** (Settings → Device).
2. Open **`/dashboard/setup.html`**, type them into a printer slot, press **Save**.
   Saving turns LAN auto-send on and reopens the printer connection straight away — no
   restart. Access codes are stored in `config.json` (git-ignored) and are never sent back
   to the browser, so leaving the field blank keeps the one already saved.
3. Press **Test**. It reports reachability, whether the access code was accepted, and the
   printer's live state, with something to try for each failure.

> The access code changes whenever LAN Mode is switched off and on again. If a printer
> stops answering, re-read it from the printer screen — that is usually all it is.

<details>
<summary>The equivalent by hand</summary>

```bash
node tools/set-printer.mjs 1 192.168.10.105 0309BA461400280 e94e9beb
npm run test-printer            # checks every configured printer
npm run test-printer A1-2       # just one
npm run test-printer A1-2 send  # ALSO uploads a sample and starts a real print
```

`test-printer` opens its own MQTT connection, and the printer only accepts one at a time —
stop the booth server first, or use the dashboard's Test button, which reads the connection
the server already holds.
</details>

**How it works:** FTPS upload (implicit TLS, port 990, user `bblp`, password = access code)
puts the `.gcode` on the printer's SD card, then an MQTT publish (TLS, port 8883) to
`device/<SERIAL>/request` starts it. The printer's `device/<SERIAL>/report` topic is
subscribed for status. Both use the printer's self-signed certificate, so TLS verification is
disabled for these direct-to-printer connections — traffic stays on your booth LAN.

The start command is published at **QoS 0**: the printer sends no PUBACK, so waiting for one
times out even when the command worked. Because that removes the only transport-level signal,
the server instead watches the printer's own reported state for `startConfirmMs` (25 s) after
a send. If it never turns over from idle, the job goes back to `assigned` with the file still
on the SD card, and the log says to start it from the printer screen or the dashboard.

**If it fails, nothing is lost:** the design is still generated, saved, and recorded as a lead;
the job simply stays `queued` for manual dispatch from the dashboard, and the error is logged.
With `lan.enabled = false` the booth runs fully manually, exactly as before.

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
