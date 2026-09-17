#!/usr/bin/env node
// Local save server for dialog-tool.html. Run this alongside the HTML tool
// (`node tools/dialog-server.js`) so its "Guardar en el proyecto" button can write
// script.lua / en.strings / jp.strings directly to source/, instead of going through
// the browser's Downloads folder. Browsers can't write to an arbitrary project path
// on their own — this tiny server is the trusted process that does it, listening
// only on localhost and only ever touching these three known files.

const http = require('http');
const fs   = require('fs');
const path = require('path');

const PORT = 8791;
const ROOT = path.join(__dirname, '..');

const TARGETS = {
  script: path.join(ROOT, 'source', 'assets', 'data', 'script.lua'),
  en:     path.join(ROOT, 'source', 'en.strings'),
  jp:     path.join(ROOT, 'source', 'jp.strings'),
};

function withCors(res) {
  // Origin is "null" for a page opened as a local file:// document, so "*" is required
  // (no credentials are used, so the wildcard is safe here).
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => { data += chunk; if (data.length > 5_000_000) req.destroy(); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  withCors(res);

  if (req.method === 'OPTIONS') { res.writeHead(204); res.end(); return; }

  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true }));
    return;
  }

  if (req.method === 'POST' && req.url === '/save-all') {
    try {
      const body = JSON.parse(await readBody(req));
      const written = [];
      for (const key of ['script', 'en', 'jp']) {
        if (typeof body[key] === 'string') {
          fs.writeFileSync(TARGETS[key], body[key], 'utf8');
          written.push(path.relative(ROOT, TARGETS[key]));
        }
      }
      console.log(`✓ saved: ${written.join(', ') || '(nothing sent)'}`);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ ok: true, written }));
    } catch (e) {
      console.error('✗ save failed:', e.message);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ ok: false, error: e.message }));
    }
    return;
  }

  res.writeHead(404);
  res.end('not found');
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Dialog tool save server running on http://localhost:${PORT}`);
  console.log('Targets:');
  for (const [k, p] of Object.entries(TARGETS)) console.log(`  ${k} -> ${path.relative(ROOT, p)}`);
  console.log('Leave this running, then click "Guardar en el proyecto" in dialog-tool.html.');
});
