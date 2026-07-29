// 3DiPad kiosk front-end. Vanilla JS, no build step — just works in Safari.
'use strict';

const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];

const COLOUR_HEX = {
  BLACK: '#1c1c1e', WHITE: '#f5f5f7', RED: '#e23b3b', BLUE: '#2f6fed',
  GREEN: '#34a853', YELLOW: '#f4c20d', PINK: '#ff5fa2', PURPLE: '#8b5cf6',
  ORANGE: '#ff8a34', TEAL: '#14b8a6', GREY: '#8e8e93', GRAY: '#8e8e93',
  GOLD: '#d4af37', SILVER: '#c0c4cc', BROWN: '#8b5a2b',
};
const isLight = (hex) => {
  const n = parseInt(hex.slice(1), 16);
  const [r, g, b] = [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  return 0.2126 * r + 0.7152 * g + 0.0722 * b > 150;
};

const state = {
  cfg: { palette: Object.keys(COLOUR_HEX), build: { plateWidth: 100, plateHeight: 40, bulgeRadius: 13, holeDiameter: 5, holeInset: 9, beadWidth: 1.4 }, limits: { maxStrokeLengthMm: 5000, maxPrintMinutes: 15 } },
  contact: { name: '', phone: '' },
  colours: { layer1: null, layer2: null },
  hole: null,
  strokes: [], // each: array of {x,y} in plate-local mm, y-up
};

// ---------- boot ----------
init();
async function init() {
  try {
    const r = await fetch('api/config');
    if (r.ok) state.cfg = await r.json();
  } catch { /* offline: keep defaults */ }
  buildPalette();
  wireNav();
  wireContact();
  wireHole();
  setupCanvas();
  wireReview();
}

// ---------- navigation ----------
function show(name) {
  $$('.screen').forEach((s) => s.classList.toggle('active', s.dataset.screen === name));
  if (name === 'review') enterReview();
  if (name === 'draw') redraw();
}
function wireNav() {
  $$('[data-go]').forEach((el) =>
    el.addEventListener('click', () => {
      const v = el.dataset.validate;
      if (v && !validate(v)) return;
      show(el.dataset.go);
    }),
  );
  $('#again').addEventListener('click', resetAll);
}
function validate(step) {
  if (step === 'contact') {
    const name = $('#f-name').value.trim();
    const phone = $('#f-phone').value.trim();
    if (name.length < 1) return toast('Please enter a name', true), false;
    if (phone.replace(/\D/g, '').length < 7) return toast('Please enter a valid mobile number', true), false;
    if (!$('#f-consent').checked) return toast('Please tick the consent box', true), false;
    state.contact = { name, phone };
    return true;
  }
  if (step === 'colours') {
    if (!state.colours.layer1 || !state.colours.layer2) return toast('Pick both colours', true), false;
    return true;
  }
  if (step === 'hole') {
    if (!state.hole) return toast('Pick a hole position', true), false;
    return true;
  }
  return true;
}

// ---------- contact ----------
function wireContact() {
  // nothing extra; validated on Next
}

// ---------- palette ----------
function buildPalette() {
  for (const layer of ['layer1', 'layer2']) {
    const wrap = $(`#sw-${layer}`);
    wrap.innerHTML = '';
    for (const name of state.cfg.palette) {
      const hex = COLOUR_HEX[name] || '#888';
      const el = document.createElement('button');
      el.className = 'swatch ' + (isLight(hex) ? 'light' : 'dark');
      el.style.background = hex;
      el.textContent = name;
      el.addEventListener('click', () => {
        state.colours[layer] = name;
        $$('.swatch', wrap).forEach((s) => s.classList.toggle('sel', s === el));
      });
      wrap.appendChild(el);
    }
  }
}

// ---------- hole ----------
function wireHole() {
  $$('.hole-opt').forEach((el) =>
    el.addEventListener('click', () => {
      state.hole = el.dataset.hole;
      $$('.hole-opt').forEach((o) => o.classList.toggle('sel', o === el));
    }),
  );
}

// ---------- canvas drawing ----------
let pad, ctx, drawing = false, activeId = null, penSeen = false;
function setupCanvas() {
  pad = $('#pad');
  ctx = pad.getContext('2d');
  const opts = { passive: false };
  pad.addEventListener('pointerdown', onDown, opts);
  pad.addEventListener('pointermove', onMove, opts);
  pad.addEventListener('pointerup', onUp, opts);
  pad.addEventListener('pointercancel', onUp, opts);
  pad.addEventListener('pointerleave', onUp, opts);
  $('#undo').addEventListener('click', () => { state.strokes.pop(); redraw(); });
  $('#clear').addEventListener('click', () => { state.strokes = []; redraw(); });
  redraw();
}

function toMM(ev) {
  const rect = pad.getBoundingClientRect();
  const b = state.cfg.build;
  let x = ((ev.clientX - rect.left) / rect.width) * b.plateWidth;
  let y = b.plateHeight - ((ev.clientY - rect.top) / rect.height) * b.plateHeight; // y-up
  x = Math.max(0, Math.min(b.plateWidth, x));
  y = Math.max(0, Math.min(b.plateHeight, y));
  return { x, y };
}

function onDown(ev) {
  ev.preventDefault();
  if (ev.pointerType === 'pen') penSeen = true;
  if (penSeen && ev.pointerType === 'touch') return; // palm rejection once a pencil is in use
  if (drawing) return; // ignore extra fingers
  drawing = true; activeId = ev.pointerId;
  state.strokes.push([toMM(ev)]);
  redraw();
}
function onMove(ev) {
  if (!drawing || ev.pointerId !== activeId) return;
  ev.preventDefault();
  const events = ev.getCoalescedEvents ? ev.getCoalescedEvents() : [ev];
  const stroke = state.strokes[state.strokes.length - 1];
  for (const e of events) stroke.push(toMM(e));
  redraw();
}
function onUp(ev) {
  if (ev.pointerId !== activeId) return;
  drawing = false; activeId = null;
  redraw();
}

function redraw() {
  const b = state.cfg.build;
  const W = pad.width, H = pad.height;
  const sx = W / b.plateWidth, sy = H / b.plateHeight;
  const px = (p) => [p.x * sx, H - p.y * sy]; // mm y-up -> canvas y-down

  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, W, H);

  // faint border + hole guide
  ctx.strokeStyle = '#dfe5f0'; ctx.lineWidth = 2;
  ctx.strokeRect(3, 3, W - 6, H - 6);
  drawHoleGuide(px);

  // strokes
  const hex = state.colours.layer2 ? (COLOUR_HEX[state.colours.layer2] || '#e11') : '#2b6cff';
  ctx.strokeStyle = hex; ctx.fillStyle = hex;
  ctx.lineJoin = 'round'; ctx.lineCap = 'round';
  ctx.lineWidth = Math.max(6, b.beadWidth * ((sx + sy) / 2));
  for (const stroke of state.strokes) {
    if (stroke.length === 1) {
      const [cx, cy] = px(stroke[0]);
      ctx.beginPath(); ctx.arc(cx, cy, ctx.lineWidth / 2, 0, 7); ctx.fill();
      continue;
    }
    ctx.beginPath();
    stroke.forEach((p, i) => { const [X, Y] = px(p); i ? ctx.lineTo(X, Y) : ctx.moveTo(X, Y); });
    ctx.stroke();
  }
  updateMeter();
}

function drawHoleGuide(px) {
  const b = state.cfg.build;
  if (!state.hole) return;
  let c;
  if (state.hole === 'left') c = { x: b.holeInset, y: b.plateHeight / 2 };
  else if (state.hole === 'right') c = { x: b.plateWidth - b.holeInset, y: b.plateHeight / 2 };
  else c = { x: b.plateWidth / 2, y: b.plateHeight - b.holeDiameter }; // shown inside plate as a guide
  const [cx, cy] = px(c);
  const r = (b.holeDiameter / 2) * (pad.width / b.plateWidth);
  ctx.save();
  ctx.setLineDash([6, 6]); ctx.strokeStyle = '#b9c4d8'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.arc(cx, cy, r + 4, 0, 7); ctx.stroke();
  ctx.restore();
}

function strokeLenMM() {
  let L = 0;
  for (const s of state.strokes) for (let i = 1; i < s.length; i++) L += Math.hypot(s[i].x - s[i - 1].x, s[i].y - s[i - 1].y);
  return L;
}
function updateMeter() {
  const cap = state.cfg.limits.maxStrokeLengthMm || 5000;
  const ratio = Math.min(1, strokeLenMM() / cap);
  const bar = $('#fill-bar');
  bar.style.width = (ratio * 100).toFixed(0) + '%';
  bar.classList.toggle('hot', ratio > 0.8);
}

// ---------- review ----------
function wireReview() {
  $('#submit').addEventListener('click', submit);
}
async function enterReview() {
  drawPreview();
  const li = (k, v, cls = '') => `<li class="${cls}"><span>${k}</span><b>${v}</b></li>`;
  const c = state.colours;
  let rows =
    li('Name', esc(state.contact.name)) +
    li('Backing', c.layer1) +
    li('Drawing', c.layer2) +
    li('Hole', capital(state.hole));
  const summary = $('#summary');
  summary.innerHTML = rows + li('Print time', '…');

  // ask the server for the real estimate
  try {
    const r = await fetch('api/estimate', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload()) });
    const data = await r.json();
    const m = data.meta || {};
    const cls = m.overBudget ? 'over' : m.nearBudget ? 'warn' : '';
    summary.innerHTML = rows + li('Print time', `~${m.estMinutes ?? '?'} min`, cls) + li('Material', `~${m.estGrams ?? '?'} g`);
    $('#submit').disabled = !!m.overBudget;
    if (m.overBudget) toast('That design is a bit big — remove a few strokes to fit under 15 min', true);
  } catch {
    summary.innerHTML = rows;
  }
}

function drawPreview() {
  const cv = $('#preview'), g = cv.getContext('2d');
  const b = state.cfg.build;
  const W = cv.width, H = cv.height;
  const bulge = state.hole === 'centre' ? b.bulgeRadius : 0;
  const totalH = b.plateHeight + bulge;
  const pad2 = 40;
  const scale = Math.min((W - pad2 * 2) / b.plateWidth, (H - pad2 * 2) / totalH);
  const ox = (W - b.plateWidth * scale) / 2;
  const oy = H - pad2; // bottom baseline
  const X = (x) => ox + x * scale;
  const Y = (y) => oy - y * scale;

  g.fillStyle = '#0b1120'; g.fillRect(0, 0, W, H);

  // plate body in backing colour
  const c1 = COLOUR_HEX[state.colours.layer1] || '#888';
  const c2 = COLOUR_HEX[state.colours.layer2] || '#e11';
  g.fillStyle = c1; g.strokeStyle = '#00000030'; g.lineWidth = 1;
  roundRect(g, X(0), Y(b.plateHeight), b.plateWidth * scale, b.plateHeight * scale, 6 * scale);
  g.fill();
  if (state.hole === 'centre') {
    g.beginPath(); g.arc(X(b.plateWidth / 2), Y(b.plateHeight), b.bulgeRadius * scale, Math.PI, 2 * Math.PI); g.fill();
  }
  // hole
  let hc;
  if (state.hole === 'left') hc = { x: b.holeInset, y: b.plateHeight / 2 };
  else if (state.hole === 'right') hc = { x: b.plateWidth - b.holeInset, y: b.plateHeight / 2 };
  else hc = { x: b.plateWidth / 2, y: b.plateHeight + b.bulgeRadius * 0.5 };
  g.fillStyle = '#0b1120';
  g.beginPath(); g.arc(X(hc.x), Y(hc.y), (b.holeDiameter / 2) * scale, 0, 7); g.fill();

  // design strokes in colour 2
  g.strokeStyle = c2; g.fillStyle = c2; g.lineJoin = 'round'; g.lineCap = 'round';
  g.lineWidth = Math.max(3, b.beadWidth * scale);
  for (const s of state.strokes) {
    if (s.length === 1) { g.beginPath(); g.arc(X(s[0].x), Y(s[0].y), g.lineWidth / 2, 0, 7); g.fill(); continue; }
    g.beginPath(); s.forEach((p, i) => (i ? g.lineTo(X(p.x), Y(p.y)) : g.moveTo(X(p.x), Y(p.y)))); g.stroke();
  }
}

// ---------- submit ----------
function payload() {
  return {
    contact: state.contact,
    colours: state.colours,
    hole: state.hole,
    design: state.strokes,
  };
}
async function submit() {
  if (!state.strokes.length) return toast('Draw something first!', true);
  $('#submit').disabled = true;
  try {
    const r = await fetch('api/submit', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload()) });
    const data = await r.json();
    if (!r.ok || !data.ok) {
      toast(data.error || 'Something went wrong — please try again', true);
      $('#submit').disabled = false;
      return;
    }
    $('#done-title').textContent = `You're in the queue, ${state.contact.name.split(' ')[0]}!`;
    $('#done-msg').textContent = data.printer
      ? `Printing on ${data.printer}. We'll WhatsApp you when it's ready (~${data.meta?.estMinutes ?? 15} min).`
      : `Saved! We'll WhatsApp you when it's ready.`;
    show('done');
  } catch {
    toast('No connection to the booth server', true);
    $('#submit').disabled = false;
  }
}

function resetAll() {
  state.contact = { name: '', phone: '' };
  state.colours = { layer1: null, layer2: null };
  state.hole = null;
  state.strokes = [];
  penSeen = false;
  $('#f-name').value = ''; $('#f-phone').value = ''; $('#f-consent').checked = false;
  $$('.swatch').forEach((s) => s.classList.remove('sel'));
  $$('.hole-opt').forEach((s) => s.classList.remove('sel'));
  $('#submit').disabled = false;
  show('welcome');
}

// ---------- utils ----------
function roundRect(g, x, y, w, h, r) {
  g.beginPath();
  g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r);
  g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath();
}
let toastT;
function toast(msg, err = false) {
  const t = $('#toast');
  t.textContent = msg; t.classList.toggle('err', err); t.classList.add('show');
  clearTimeout(toastT); toastT = setTimeout(() => t.classList.remove('show'), 2600);
}
const esc = (s) => s.replace(/[<>&]/g, (c) => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;' }[c]));
const capital = (s) => (s ? s[0].toUpperCase() + s.slice(1) : s);

// register the service worker for install-to-homescreen / offline shell
if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
