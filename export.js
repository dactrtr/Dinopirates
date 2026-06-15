#!/usr/bin/env node

const fs   = require('fs');
const path = require('path');

// ─── CONFIG ────────────────────────────────────────────────────────────────
// Folder where LDtk exported all Room_X subfolders (data.json, Gameplay.csv, etc.)
const LDTK_EXPORT_DIR = process.argv[2] || './LDTK/DPplaydate/simplified';
const BUILD_DIR       = path.join(LDTK_EXPORT_DIR, 'build');
const OUT_DATA        = path.join(BUILD_DIR, 'assets', 'data');
const OUT_IMAGES      = path.join(BUILD_DIR, 'assets', 'images', 'rooms');
// ───────────────────────────────────────────────────────────────────────────

// ─── HELPERS ───────────────────────────────────────────────────────────────
function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function jsonToLua(obj, indent = 0) {
  const spaces = '  '.repeat(indent);

  if (obj === null || obj === undefined) return 'nil';
  if (typeof obj === 'boolean')          return obj.toString();
  if (typeof obj === 'number')           return obj.toString();
  if (typeof obj === 'string')           return `"${obj.replace(/"/g, '\\"')}"`;

  if (Array.isArray(obj)) {
	if (obj.length === 0) return '{}';
	const items = obj.map(item => `${spaces}  ${jsonToLua(item, indent + 1)}`);
	return `{\n${items.join(',\n')}\n${spaces}}`;
  }

  if (typeof obj === 'object') {
	const entries = Object.entries(obj);
	if (entries.length === 0) return '{}';
	const items = entries.map(([k, v]) => {
	  const luaKey = /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(k) ? k : `["${k}"]`;
	  return `${spaces}  ${luaKey} = ${jsonToLua(v, indent + 1)}`;
	});
	return `{\n${items.join(',\n')}\n${spaces}}`;
  }

  return 'nil';
}

function matrixToCompactLua(matrix) {
  const rows = matrix.map(row => `{${row.join(', ')}}`);
  return `{\n${rows.join(',\n')}\n}`;
}
// ───────────────────────────────────────────────────────────────────────────

// ─── LOAD ROOMS ────────────────────────────────────────────────────────────
function loadRooms() {
  const rooms = [];

  const entries = fs.readdirSync(LDTK_EXPORT_DIR, { withFileTypes: true });
  for (const entry of entries) {
	if (!entry.isDirectory()) continue;
	if (!entry.name.startsWith('Room_')) continue;

	const roomDir  = path.join(LDTK_EXPORT_DIR, entry.name);
	const dataFile = path.join(roomDir, 'data.json');

	if (!fs.existsSync(dataFile)) {
	  console.warn(`  ⚠️  No data.json in ${entry.name}, skipping`);
	  continue;
	}

	try {
	  const data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
	  rooms.push({ identifier: entry.name, data, dir: roomDir });
	} catch (e) {
	  console.warn(`  ⚠️  Could not parse ${dataFile}: ${e.message}`);
	}
  }

  console.log(`Loaded ${rooms.length} rooms`);
  return rooms;
}
// ───────────────────────────────────────────────────────────────────────────

// ─── FILTER ────────────────────────────────────────────────────────────────
function hasDoors(data) {
  const doors       = data.entities?.Doors       && data.entities.Doors.length > 0;
  const portalDoors = data.entities?.PortalDoors && data.entities.PortalDoors.length > 0;
  return doors || portalDoors;
}

function filterRoomData(data) {
  const hasForeground = data.layers?.includes('Foreground.png') ?? false;

  const filtered = {
	identifier:      data.identifier,
	uniqueIdentifer: data.uniqueIdentifer,
	neighbourLevels: data.neighbourLevels || [],
	customFields: {
	  ...data.customFields,
	  hasForeground
	},
	entities: {}
  };

  for (const [type, list] of Object.entries(data.entities || {})) {
	if (!list || list.length === 0) continue;
	filtered.entities[type] = list.map(e => ({
	  id:           e.id,
	  iid:          e.iid,
	  x:            e.x,
	  y:            e.y,
	  width:        e.width,
	  height:       e.height,
	  customFields: e.customFields
	}));
  }

  return filtered;
}
// ───────────────────────────────────────────────────────────────────────────

// ─── LEVELS LUA ────────────────────────────────────────────────────────────
function generateLevels(rooms) {
  const valid = rooms
	.filter(r => hasDoors(r.data))
	.map(r => filterRoomData(r.data))
	.sort((a, b) => {
	  const lA = a.customFields?.level      || 0;
	  const lB = b.customFields?.level      || 0;
	  if (lA !== lB) return lB - lA;
	  const rA = a.customFields?.roomNumber || 0;
	  const rB = b.customFields?.roomNumber || 0;
	  return rA - rB;
	});

  if (valid.length === 0) {
	console.warn('  ⚠️  No rooms with doors found');
	return;
  }

  // Group by floor
  const floors = {};
  const floorOrder = [];
  for (const room of valid) {
	const floor = room.customFields?.level || 0;
	if (!floors[floor]) { floors[floor] = []; floorOrder.push(floor); }
	floors[floor].push(room);
  }

  // levels.lua orchestrator
  const imports = floorOrder.map(f => `import 'assets/data/levels_floor${f}'`).join('\n');
  fs.writeFileSync(path.join(OUT_DATA, 'levels.lua'), `levelsLDTK = {}\n${imports}\n`);
  console.log(`  ✓ levels.lua (${floorOrder.length} floors)`);

  // levels_floorN.lua
  for (const floor of floorOrder) {
	const inserts = floors[floor].map(room => {
	  const rn      = room.customFields?.roomNumber || '';
	  const comment = rn ? `\t--${rn}\n` : '';
	  return `${comment}table.insert(levelsLDTK, ${jsonToLua(room, 0)})`;
	});
	const filename = `levels_floor${floor}.lua`;
	fs.writeFileSync(path.join(OUT_DATA, filename), inserts.join('\n') + '\n');
	console.log(`  ✓ ${filename} (${floors[floor].length} rooms)`);
  }
}
// ───────────────────────────────────────────────────────────────────────────

// ─── TILEMAP LUA ───────────────────────────────────────────────────────────
function generateTilemap(rooms) {
  const tilemapData   = {};
  const tileUsage     = {};
  let   processed     = 0;
  let   skipped       = 0;

  for (const { identifier, data, dir } of rooms) {
	const tileIndex = data.customFields?.tile;
	if (tileIndex === undefined || tileIndex === null) {
	  console.warn(`  ⚠️  No tile index for ${identifier}`);
	  skipped++;
	  continue;
	}

	const csvFile = path.join(dir, 'Gameplay.csv');
	if (!fs.existsSync(csvFile)) {
	  console.warn(`  ⚠️  No Gameplay.csv for ${identifier}`);
	  skipped++;
	  continue;
	}

	// Duplicate check
	if (!tileUsage[tileIndex]) tileUsage[tileIndex] = [];
	tileUsage[tileIndex].push(identifier);
	if (tileUsage[tileIndex].length > 1) {
	  console.error(`  ❌ DUPLICATE tile index ${tileIndex}: ${tileUsage[tileIndex].join(', ')}`);
	}

	const csvText = fs.readFileSync(csvFile, 'utf8');
	const lines   = csvText.trim().split('\n').filter(l => l.trim().length > 0);
	const matrix  = lines.map(line =>
	  line.split(',').map(v => {
		const n = parseInt(v.trim());
		return isNaN(n) ? 0 : n;
	  })
	);

	const hasNonZero = matrix.some(row => row.some(v => v !== 0));
	if (!hasNonZero) {
	  console.warn(`  ⚠️  ${identifier} tilemap is all zeros`);
	}

	tilemapData[tileIndex] = matrix;
	processed++;
  }

  if (Object.keys(tilemapData).length === 0) {
	console.warn('  ⚠️  No tilemap data generated');
	return;
  }

  const sorted  = Object.keys(tilemapData).map(Number).sort((a, b) => a - b);
  // Emit explicit keys ([idx] = ...) so rooms index by their `tile` value directly.
  // A bare sequential array breaks as soon as the tile numbers have gaps (e.g. a
  // secret room with tile=81), since the array position no longer equals the tile id.
  const entries = sorted.map(idx => `\t[${idx}] = ${matrixToCompactLua(tilemapData[idx])}`);
  const lua     = `tileMapData = {\n${entries.join(',\n')}\n}\n`;

  fs.writeFileSync(path.join(OUT_DATA, 'tilemap.lua'), lua);
  console.log(`  ✓ tilemap.lua (${processed} rooms, ${skipped} skipped)`);
}
// ───────────────────────────────────────────────────────────────────────────

// ─── IMAGES ────────────────────────────────────────────────────────────────
function copyImages(rooms) {
  let gameplay   = 0;
  let foreground = 0;

  for (const { identifier, data, dir } of rooms) {
	if (!hasDoors(data)) continue;

	const floor      = data.customFields?.level      || 0;
	const roomNumber = data.customFields?.roomNumber || 0;
	const floorDir   = path.join(OUT_IMAGES, `floor${floor}`);
	ensureDir(floorDir);

	const gpSrc = path.join(dir, 'Gameplay.png');
	if (fs.existsSync(gpSrc)) {
	  fs.copyFileSync(gpSrc, path.join(floorDir, `room_${roomNumber}.png`));
	  gameplay++;
	}

	const fgSrc = path.join(dir, 'Foreground.png');
	if (fs.existsSync(fgSrc)) {
	  fs.copyFileSync(fgSrc, path.join(floorDir, `foreground_${roomNumber}.png`));
	  foreground++;
	}
  }

  console.log(`  ✓ Gameplay images: ${gameplay}`);
  console.log(`  ✓ Foreground images: ${foreground}`);
}
// ───────────────────────────────────────────────────────────────────────────

// ─── MAIN ──────────────────────────────────────────────────────────────────
function main() {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('  Dinopirates — Asset Exporter');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`Input:  ${path.resolve(LDTK_EXPORT_DIR)}`);
  console.log(`Output: ${path.resolve(BUILD_DIR)}`);
  console.log('');

  if (!fs.existsSync(LDTK_EXPORT_DIR)) {
	console.error(`❌ Input folder not found: ${LDTK_EXPORT_DIR}`);
	process.exit(1);
  }

  // Clean & create output dirs
  ensureDir(OUT_DATA);
  ensureDir(OUT_IMAGES);

  const rooms = loadRooms();
  if (rooms.length === 0) {
	console.error('❌ No rooms found');
	process.exit(1);
  }

  console.log('\n── Levels ──');
  generateLevels(rooms);

  console.log('\n── Tilemap ──');
  generateTilemap(rooms);

  console.log('\n── Images ──');
  copyImages(rooms);

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('  ✅ Done!');
  console.log(`  ${path.resolve(BUILD_DIR)}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

main();