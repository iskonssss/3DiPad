// Keeps every free printer fed from the queue.
//
// Submitting used to be the ONLY moment a job could reach a printer: if all
// printers were busy right then, the job sat 'queued' for ever — the g-code was
// on disk and the lead was captured, but nothing ever printed it, and the
// dashboard's buttons only relabel a job's status. At a booth with three
// printers and a line of kids that loses every print past the third.
//
// So dispatching is a pump, not a one-shot. It runs when a job is submitted AND
// whenever a printer frees up, and it always works from the queue.
//
// Reserving is instant; uploading is not. A job is marked 'assigned' to its
// printer synchronously, so the kid's screen can name the printer straight
// away, and the ~2s FTPS upload happens after the tablet has moved on.

import path from 'node:path';
import { sendToPrinter } from '../integrations/bambu.js';

export function createDispatcher({ cfg, queue, outDir, onEvent = () => {}, transport = sendToPrinter, confirmStart = null }) {
  let running = false;
  let again = false;

  const printers = () => cfg.integrations?.printers || [];
  // A printer that is off, or off the network, fails every send. Retrying for
  // ever would spin the whole queue against it, so a job that has failed this
  // many times waits for an operator (the dashboard's send button clears it).
  const maxAttempts = cfg.integrations?.lan?.maxDispatchAttempts ?? 3;

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
    const r = await Promise.resolve(transport(printer, filePath, cfg, { sequenceId: job.seq }))
      .catch((e) => ({ ok: false, stage: 'send', error: String(e.message || e) }));

    if (r.sent) {
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
      const printer = reserve(job);
      if (printer) send(job, printer).then((r) => { if (r.sent) pump(); }).catch(() => {});
      return printer;
    },
  };
}
