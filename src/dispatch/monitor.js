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

export function startMonitor(cfg, queue, onReady) {
  const printers = cfg.integrations?.printers || [];
  if (!cfg.integrations?.lan?.enabled) return { stop() {}, states: () => ({}) };

  const states = {};
  const handles = [];

  for (const printer of printers) {
    const h = watchPrinter(printer, cfg, (status) => {
      const prev = states[printer.id] || {};
      states[printer.id] = { ...prev, ...status, at: new Date().toISOString() };
      if (status.state && status.state !== prev.state) applyTransition(printer, status.state);
    });
    handles.push(h);
  }

  function applyTransition(printer, state) {
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
    } else if (state === 'FAILED') {
      queue.setStatus(job.id, 'failed');
      console.error(`[${printer.id}] print FAILED for ${job.filename}`);
    }
  }

  return {
    stop() { for (const h of handles) h.stop(); },
    states: () => states,
  };
}
