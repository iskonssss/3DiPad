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

import { watchPrinter } from '../integrations/bambu.js';

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
      if (status.state && status.state !== prev.state) applyTransition(printer, status.state, h);
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
    if (s.errorCode) bits.push(`error code ${s.errorCode} (look it up on the printer screen)`);
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

    if (state === 'RUNNING' && job.status !== 'printing') {
      queue.setStatus(job.id, 'printing');
    } else if (state === 'PAUSE' && job.status !== 'colour_change') {
      queue.setStatus(job.id, 'colour_change');
      console.log(`[${printer.id}] paused — swap to ${job.colours?.layer2} for ${job.contact?.name}`);
    } else if (state === 'FINISH') {
      queue.setStatus(job.id, 'ready');
      console.log(`[${printer.id}] finished ${job.filename} — notifying ${job.contact?.name}`);
      Promise.resolve(onReady(job)).catch((e) => console.error('ready notify failed', e));
      freed();
    } else if (state === 'FAILED') {
      const why = failureReason(printer, handle);
      queue.setStatus(job.id, 'failed', { failure: why || null });
      console.error(`[${printer.id}] print FAILED for ${job.filename}${why ? ` — ${why}` : ''}`);
      console.error(`           The g-code is still on the SD card. "Print again" in History re-queues it.`);
      freed();
    }
  }

  return {
    stop() { for (const h of handles) h.stop(); },
    states: () => states,
    /** Per-printer MQTT health, for telling apart the ways "no status" happens. */
    health: () => Object.fromEntries([...watchers].map(([id, h]) => [id, h.health()])),
  };
}
