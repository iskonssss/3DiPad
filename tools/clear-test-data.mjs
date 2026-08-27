// Clear test leads and the queue before a real event.
//
//   npm run clear-data           # back up, then clear
//   npm run clear-data -- --keep-numbers   # clear but do NOT reset the sequence
//
// Every test submission is recorded three ways: a row in leads/leads.csv, a
// design .svg beside it, and a job in output/jobs.json (the dashboard queue and
// History). This wipes all three so the fair starts clean — after backing every
// file up to output/_test-backup-<timestamp>/ first, so nothing is truly lost.
//
// The booth caches the queue in memory, so this refuses to run while the server
// is up: stop the booth, run this, start it again. Leads and the generated
// files are on disk and would clear either way, but jobs.json would be
// overwritten by the running server, leaving a half-cleared booth.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { refuseIfBoothRunning } from './booth-running.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const leadsDir = path.join(root, 'leads');
const outDir = path.join(root, 'output');
const keepNumbers = process.argv.includes('--keep-numbers');

await refuseIfBoothRunning(process.argv, 'clear-test-data');

// A timestamp for the backup folder. new Date() is fine in a plain script.
const ts = new Date().toISOString().replace(/[:T]/g, '-').slice(0, 19);
const backup = path.join(outDir, `_test-backup-${ts}`);
const bkLeads = path.join(backup, 'leads');
const bkGcode = path.join(backup, 'gcode');
fs.mkdirSync(bkLeads, { recursive: true });
fs.mkdirSync(bkGcode, { recursive: true });

const move = (from, to) => { try { fs.renameSync(from, to); } catch { /* not there */ } };
const copy = (from, to) => { try { fs.copyFileSync(from, to); } catch { /* not there */ } };

// 1. leads.csv -> keep only the header; .svg records -> backup
const csv = path.join(leadsDir, 'leads.csv');
let leadCount = 0;
if (fs.existsSync(csv)) {
  const lines = fs.readFileSync(csv, 'utf8').split('\n');
  leadCount = lines.filter((l) => l.trim()).length - 1;   // minus header
  copy(csv, path.join(bkLeads, 'leads.csv'));
  fs.writeFileSync(csv, (lines[0] || '') + '\n');          // header alone
}
let svgCount = 0;
if (fs.existsSync(leadsDir)) {
  for (const f of fs.readdirSync(leadsDir)) {
    if (f.endsWith('.svg')) { move(path.join(leadsDir, f), path.join(bkLeads, f)); svgCount++; }
  }
}

// 2. the queue: back up jobs.json, then reset it (seq too, unless --keep-numbers)
const jobsFile = path.join(outDir, 'jobs.json');
let jobCount = 0, seq = 0;
if (fs.existsSync(jobsFile)) {
  const q = JSON.parse(fs.readFileSync(jobsFile, 'utf8'));
  jobCount = (q.jobs || []).length;
  seq = keepNumbers ? (q.seq || 0) : 0;
  copy(jobsFile, path.join(backup, 'jobs.json'));
}
fs.writeFileSync(jobsFile, JSON.stringify({ seq, jobs: [] }, null, 2) + '\n');

// 3. the generated print files -> backup, and reset the retry outbox
let fileCount = 0;
for (const f of fs.readdirSync(outDir)) {
  if (f.endsWith('.gcode') || f.endsWith('.3mf')) { move(path.join(outDir, f), path.join(bkGcode, f)); fileCount++; }
}
const outbox = path.join(outDir, 'outbox.json');
if (fs.existsSync(outbox)) { copy(outbox, path.join(backup, 'outbox.json')); fs.writeFileSync(outbox, JSON.stringify({ pending: [] }, null, 2) + '\n'); }

console.log('');
console.log('  Cleared for a fresh event:');
console.log(`    ${leadCount} lead rows and ${svgCount} design SVGs`);
console.log(`    ${jobCount} jobs from the queue / History`);
console.log(`    ${fileCount} generated .gcode/.3mf files`);
console.log(`    sequence ${keepNumbers ? `kept at ${seq}` : 'reset — the next print is #0001'}`);
console.log('');
console.log(`  All of it backed up to:`);
console.log(`    ${path.relative(root, backup)}`);
console.log(`  (delete that folder once you are sure, or keep it as an archive.)`);
console.log('');
console.log('  Start the booth again and the dashboard is empty, ready for real designs.');
console.log('');
