// In-memory job queue with disk persistence (survives a server restart at the booth).
// A "job" is one kid's keychain from submit -> collected.

import fs from 'node:fs';
import path from 'node:path';

const STATUSES = ['queued', 'assigned', 'printing', 'colour_change', 'ready', 'collected', 'failed'];

export class Queue {
  constructor(root) {
    this.file = path.join(root, 'output', 'jobs.json');
    this.jobs = [];
    this.seq = 0;
    this._load();
  }

  _load() {
    try {
      const data = JSON.parse(fs.readFileSync(this.file, 'utf8'));
      this.jobs = data.jobs || [];
      this.seq = data.seq || 0;
    } catch { /* fresh */ }
  }

  _save() {
    fs.mkdirSync(path.dirname(this.file), { recursive: true });
    fs.writeFileSync(this.file, JSON.stringify({ seq: this.seq, jobs: this.jobs }, null, 2));
  }

  nextSeq() {
    this.seq += 1;
    this._save();
    return this.seq;
  }

  add(job) {
    job.status = 'queued';
    job.history = [{ status: 'queued', at: new Date().toISOString() }];
    this.jobs.push(job);
    this._save();
    return job;
  }

  get(id) {
    return this.jobs.find((j) => j.id === id);
  }

  setStatus(id, status, extra = {}) {
    if (!STATUSES.includes(status)) throw new Error('bad status ' + status);
    const job = this.get(id);
    if (!job) return null;
    Object.assign(job, extra, { status });
    job.history.push({ status, at: new Date().toISOString() });
    this._save();
    return job;
  }

  /** Active jobs (not collected/failed), newest first for the operator view. */
  active() {
    return this.jobs.filter((j) => !['collected', 'failed'].includes(j.status)).slice().reverse();
  }

  /**
   * Everything ever submitted, newest first. The g-code files stay on disk, so
   * an old job can be sent to a printer again — a failed print, a plate knocked
   * off, or a parent who lost the keychain before they got home.
   */
  history(limit = 200) {
    return this.jobs.slice().reverse().slice(0, Math.max(1, limit));
  }

  /** First printer with no active job, or null. */
  freePrinter(printers) {
    const busy = new Set(this.jobs.filter((j) => ['assigned', 'printing', 'colour_change'].includes(j.status)).map((j) => j.printerId));
    return printers.find((p) => p.ip && !busy.has(p.id)) || null;
  }

  stats() {
    const by = Object.fromEntries(STATUSES.map((s) => [s, 0]));
    for (const j of this.jobs) by[j.status] = (by[j.status] || 0) + 1;
    return { total: this.jobs.length, leads: this.jobs.length, by };
  }
}
