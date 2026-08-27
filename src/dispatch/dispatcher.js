// Getting a finished design onto a printer.
//
// Nothing goes anywhere on its own. A submitted job lands in the queue and
// stays there until an operator presses that printer's button on the dashboard,
// which uploads it to the SD card and starts it.
//
// That is deliberate. Each printer is loaded with particular filament, so which
// machine a job goes to is a decision about colour, and only a person standing
// at the booth can make it — sending to "whichever is free" is exactly how a
// kid's drawing comes out in the wrong colour.
//
// integrations.lan.autoDispatch turns the automatic behaviour back on: jobs go
// to the first free printer on submit, and queued jobs follow as printers free
// up. That only makes sense if every printer carries the same two colours.

import path from 'node:path';
import { sendToPrinter } from '../integrations/bambu.js';

export function createDispatcher({ cfg, queue, outDir, onEvent = () => {}, transport = sendToPrinter, confirmStart = null, probeStart = null, beforeSend = null }) {
  let running = false;
  let again = false;

  const printers = () => cfg.integrations?.printers || [];
  // A printer that is off, or off the network, fails every send. Retrying for
  // ever would spin the whole queue against it, so a job that has failed this
  // many times waits for an operator (the dashboard's send button clears it).
  const maxAttempts = cfg.integrations?.lan?.maxDispatchAttempts ?? 3;
  // off by default — see the note at the top of this file
  const auto = () => cfg.integrations?.lan?.autoDispatch === true;
  // Printers whose NEXT print should run a bed level. One-shot: set from the
  // dashboard, consumed by the send that carries it. The config's bedLevel is
  // every print or none, and needs a restart either way — no good for "this
  // one is printing badly, level it once".
  const levelNext = new Set();

  /** Oldest queued job first — whoever has been waiting longest goes next. */
  function nextQueued() {
    return queue.jobs
      .filter((j) => j.status === 'queued' && (j.dispatchAttempts || 0) < maxAttempts)
      .sort((a, b) => a.seq - b.seq)[0] || null;
  }

  /**
   * Reserve a free printer for the oldest queued job, if there is both.
   * Returns the printer it reserved (so a caller can name it), or null.
   */
  function reserve(job) {
    const free = queue.freePrinter(printers());
    if (!free) return null;
    queue.setStatus(job.id, 'assigned', { printerId: free.id });
    return free;
  }

  /** Upload + start a job already assigned to `printer`. Never throws. */
  async function send(job, printer) {
    const filePath = path.join(outDir, job.filename);
    // A printer that failed its last print keeps holding it, and refuses every
    // new job until told to let go. Without this, one bad print takes a machine
    // out of the booth for the rest of the day and every send after it fails
    // for a reason that has nothing to do with the job being sent.
    if (beforeSend) {
      try {
        const r = await beforeSend(printer, job);
        if (r?.needed) onEvent({ type: 'cleared', job, printer, ok: !!r.cleared, state: r.state });
        // A printer that would not let go is not going to print this either.
        //
        // We used to upload and send the start command anyway, on the theory
        // that a lingering FAILED might only be the printer's record of the last
        // job rather than a lock on the next one. Sometimes it is. When it is
        // not, the file lands on the SD card, the start is ignored, and the
        // booth says so two minutes later — so the operator presses Send again,
        // and again, with nothing in the message naming the one thing that
        // actually has to happen: someone clearing the job on the printer's own
        // screen. An afternoon went that way.
        //
        // The job stays assigned to this printer, so pressing Send once the
        // screen is clear picks it straight back up.
        // FINISH is not a lock. A printer that has just completed a print takes
        // the next one; it only needs the plate cleared, which the operator
        // does by hand and the booth cannot see. FAILED is the one that refuses.
        if (r?.needed && !r.cleared && String(r.state || '').toUpperCase() !== 'FINISH') {
          queue.setStatus(job.id, 'assigned', {
            printerId: printer.id,
            dispatch: { ok: false, uploaded: false, blocked: r.state, error: `printer is holding a ${r.state} job` },
          });
          onEvent({ type: 'blocked', job, printer, state: r.state });
          // Returned, not dropped: the dashboard's Send awaits this and read
          // `.sent` off undefined, which took the server down mid-booth.
          return { ok: false, sent: false, blocked: r.state, error: `${printer.name} is holding a ${r.state} job — clear it on the printer's screen, then Send again` };
        }
      } catch (e) { console.error('pre-send check failed', e); }
    }
    // probeStart lets the transport find out which start command this firmware
    // obeys, by watching whether the printer moved after each one. It is a short
    // wait (a few seconds each) and only happens while the shape is unknown.
    const bedLevel = levelNext.has(printer.id);
    const r = await Promise.resolve(transport(printer, filePath, cfg, { sequenceId: job.seq, confirmStarted: probeStart, meta: job.meta, bedLevel }))
      .catch((e) => ({ ok: false, stage: 'send', error: String(e.message || e) }));

    if (r.variant) onEvent({ type: 'variant', job, printer, variant: r.variant, confirmed: !!r.confirmed });

    if (r.sent) {
      if (bedLevel) { levelNext.delete(printer.id); onEvent({ type: 'levelled', job, printer }); }
      queue.setStatus(job.id, 'printing', { printerId: printer.id, dispatchAttempts: 0, dispatch: { ok: true, remotePath: r.remotePath } });
      onEvent({ type: 'sent', job, printer });
      // The transport only says the command went out — the printer sends no
      // acknowledgement, so a print that never starts is indistinguishable from
      // one that did until someone walks over and looks. Watch the printer's own
      // state in the background and say so if it never turns over. Deliberately
      // not awaited: the wait is tens of seconds and the other printers should
      // not sit idle through it.
      if (confirmStart) {
        Promise.resolve(confirmStart(printer, job)).then((started) => {
          const now = queue.get(job.id);
          if (started !== false || !now || now.status !== 'printing') return;
          queue.setStatus(job.id, 'assigned', {
            printerId: printer.id,
            dispatch: { ok: false, uploaded: true, remotePath: r.remotePath, error: 'printer did not start' },
          });
          onEvent({ type: 'notstarted', job, printer, remotePath: r.remotePath });
        }).catch(() => {});
      }
    } else if (r.manual) {
      // LAN off or printer unconfigured: leave it assigned for a manual load
      queue.setStatus(job.id, 'assigned', { printerId: printer.id, dispatch: { ok: false, manual: true, reason: r.reason } });
      onEvent({ type: 'manual', job, printer, reason: r.reason });
    } else {
      // A real failure. Put it back in the queue with the printer released, so
      // the next nudge can retry it on this or any other printer.
      const attempts = (job.dispatchAttempts || 0) + 1;
      queue.setStatus(job.id, 'queued', {
        printerId: null, dispatchAttempts: attempts,
        dispatch: { ok: false, stage: r.stage, error: r.error, attempts },
      });
      onEvent({ type: 'failed', job, printer, stage: r.stage, error: r.error, attempts, giveUp: attempts >= maxAttempts });
    }
    return r;
  }

  /**
   * Fill every free printer from the queue. Safe to call from anywhere and as
   * often as you like: overlapping calls collapse into one more pass, so two
   * printers finishing at once cannot hand the same job to both.
   */
  async function pump() {
    if (!auto()) return; // operator-driven: the dashboard sends, nothing else does
    if (running) { again = true; return; }
    running = true;
    try {
      do {
        again = false;
        for (;;) {
          const job = nextQueued();
          if (!job) break;
          const printer = reserve(job);
          if (!printer) break; // every printer is busy — the rest wait
          await send(job, printer);
        }
      } while (again);
    } finally {
      running = false;
    }
  }

  return {
    pump,
    reserve,
    send,
    nextQueued,
    /**
     * Reserve for this job now and upload in the background, so the tablet is
     * not held for the couple of seconds the FTPS transfer takes.
     * A failed send deliberately does NOT pump: it would grab the next kid and
     * throw them at the same broken printer straight away.
     */
    submit(job) {
      if (!auto()) return null; // straight into the queue for an operator to place
      const printer = reserve(job);
      if (printer) send(job, printer).then((r) => { if (r.sent) pump(); }).catch(() => {});
      return printer;
    },
    autoDispatch: auto,
    /** Arm (or disarm) a bed level for the next print sent to this printer. */
    setLevelNext(printerId, on) { if (on) levelNext.add(printerId); else levelNext.delete(printerId); return levelNext.has(printerId); },
    levelNext(printerId) { return levelNext.has(printerId); },
  };
}
