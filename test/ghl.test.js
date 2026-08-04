import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildPayload } from '../src/integrations/ghl.js';

const cfg = {
  integrations: { ghl: { eventName: 'Some Fair', tags: ['NSLF-2026', '3d-workshop-lead'] } },
};

const job = {
  id: 'j7', seq: 7, status: 'queued',
  contact: { name: 'Emma Tan', phone: '+60 12-345 6789' },
  colours: { layer1: 'BLUE', layer2: 'PINK' },
  hole: 'centre', filename: 'BLUE-PINK_0007.gcode',
  meta: { estMinutes: 14.1 }, createdAt: '2026-07-29T12:00:00.000Z',
};

test('GHL lead payload maps contact + context fields', () => {
  const p = buildPayload(cfg, job, 'lead');
  assert.equal(p.event, 'lead');
  assert.equal(p.first_name, 'Emma');
  assert.equal(p.full_name, 'Emma Tan');
  assert.equal(p.phone_e164, '+60123456789');
  assert.equal(p.colours, 'BLUE-PINK');
  assert.equal(p.layer1, 'BLUE');
  assert.equal(p.layer2, 'PINK');
  assert.equal(p.hole, 'centre');
  assert.equal(p.est_minutes, 14.1);
  assert.equal(p.fair, 'Some Fair');
  assert.deepEqual(p.tags, ['NSLF-2026', '3d-workshop-lead']);
});

test('GHL ready payload flips the event', () => {
  const p = buildPayload(cfg, job, 'ready');
  assert.equal(p.event, 'ready');
  assert.equal(p.filename, 'BLUE-PINK_0007.gcode');
});

test('E.164 handles a leading zero without a plus', () => {
  const p = buildPayload(cfg, { ...job, contact: { name: 'X', phone: '012-345 6789' } }, 'lead');
  assert.equal(p.phone_e164, '+123456789');
});
