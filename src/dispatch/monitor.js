// Printer monitor: watches every configured printer over MQTT and moves jobs
// through their lifecycle without an operator tap.
//
//   RUNNING            -> job 'printing'
//   PAUSE              -> job 'colour_change'  (the M400 U1 swap pause)
//   FINISH             -> job 'ready'  + fires the pickup notification
//   FAILED             -> job 'failed'
//
// The dashboard still allows manual overrides — this only automates the
// happy path. Jobs are matched to a printer by printerId, so a job must be
// assigned/dispatched before its status can be tracked.

import { watchPrinter, isPrintComplete, errorCodeText } from '../integrations/bambu.js';

export function startMonitor(cfg, queue, onReady, onPrinterFree = () => {}) {
  const printers = cfg.integrations?.printers || [];
  if (!cfg.integrations?.lan?.enabled) return { stop() {}, states: () => ({}), health: () => ({}) };

  const states = {};
  const handles = [];
  const watchers = new Map();

  for (const printer of printers) {
    const h = watchPrinter(printer, cfg, (status) => {
      const prev = states[printer.id] || {};
      states[printer.id] = { ...prev, ...status, at: new Date().toISOString() };
      if (status.state && status.state !== prev.state) {
        // Any genuine change makes an operator's "I've dealt with it" stale. A
        // dismissal must never be able to hide the *next* failure.
        delete states[printer.id].acknowledged;
        applyTransition(printer, status.state, h);
      }
    });
    handles.push(h);
    watchers.set(printer.id, h);
  }

  /**
   * Why a print failed, in whatever terms the printer gave us. "print FAILED"
   * on its own is a dead end for an operator standing at the booth: the error
   * code and the printer's own answer to the last command are the only clues
   * that exist, and both were being collected and then dropped.
   */
  function failureReason(printer, handle) {
    const bits = [];
    const s = states[printer.id] || {};
    if (s.errorCode) bits.push(`${errorCodeText(s.errorCode)} — look it up on the printer screen`);
    const c = handle?.health?.().lastCommand;
    if (c && String(c.result || '').toUpperCase() !== 'SUCCESS') {
      bits.push(`it answered "${c.command}" with ${c.result || '?'}${c.reason ? ` — ${c.reason}` : ''}`);
    }
    if (s.percent != null) bits.push(`stopped at ${s.percent}%`);
    return bits.join('; ');
  }

  // The printer just let go of its job, so the next kid in the queue can have
  // it. Without this a job submitted while every printer was busy would sit
  // queued for ever — its g-code written, its lead captured, never printed.
  const freed = () => { try { onPrinterFree(); } catch (e) { console.error('dispatch pump failed', e); } };

  function applyTransition(printer, state, handle) {
    // the job currently on this printer
    const job = queue
      .active()
      .find((j) => j.printerId === printer.id && ['assigned', 'printing', 'colour_change'].includes(j.status));
    if (!job) return;

    if (state === 'RUNNING' || state === 'PREPARE') {
      // A fresh run: forget any error code the last job left behind, or the new
      // job's own clean FINISH would be read as that old job's cancel.
      if (states[printer.id]) delete states[printer.id].errorCode;
      if (state === 'RUNNING' && job.status !== 'printing') queue.setStatus(job.id, 'printing');
    } else if (state === 'PAUSE' && job.status !== 'colour_change') {
      queue.setStatus(job.id, 'colour_change');
      console.log(`[${printer.id}] paused — swap to ${job.colours?.layer2} for ${job.contact?.name}`);
    } else if (state === 'FINISH' && isPrintComplete(states[printer.id])) {
      queue.setStatus(job.id, 'ready');
      console.log(`[${printer.id}] finished ${job.filename} — notifying ${job.contact?.name}`);
      Promise.resolve(onReady(job)).catch((e) => console.error('ready notify failed', e));
      freed();
    } else if (state === 'FAILED' || state === 'FINISH') {
      // FINISH here means it reported done without completing — a cancel or a
      // stop, which carries an error code and halts short of 100%. Marked
      // failed, NOT ready, so no pickup message goes out for a partial print.
      const why = failureReason(printer, handle) || (state === 'FINISH' ? 'ended before finishing — cancelled or stopped on the printer' : null);
      queue.setStatus(job.id, 'failed', { failure: why || null });
      console.error(`[${printer.id}] print ${state === 'FINISH' ? 'was cancelled' : 'FAILED'} for ${job.filename}${why ? ` — ${why}` : ''}`);
      console.error(`           The g-code is still on the SD card. "Print again" in History re-queues it.`);
      freed();
    }
  }

  return {
    stop() { for (const h of handles) h.stop(); },
    states: () => states,
    /**
     * The operator has cleared the bed and this printer is ready, whatever it
     * still says about itself.
     *
     * A Bambu does not leave FAILED on its own. It accepts `stop`, answers
     * "success", and goes on reporting FAILED and naming the job that died —
     * so a booth that only ever repeats what the printer says shows a red tile
     * for a machine that is standing there empty and willing. We cannot make
     * the printer forget, but we can record that a person looked at it, which
     * is the fact the board is actually trying to convey.
     *
     * Deliberately not a lie about the printer: the acknowledgement is dropped
     * the instant the printer reports any new state, so the next real failure
     * shows up at once.
     */
    acknowledge(printerId) {
      const s = states[printerId];
      if (!s) return null;
      s.acknowledged = { state: s.state || null, file: s.file || null, at: new Date().toISOString() };
      return s.acknowledged;
    },
    /** Per-printer MQTT health, for telling apart the ways "no status" happens. */
    health: () => Object.fromEntries([...watchers].map(([id, h]) => [id, h.health()])),
  };
}
