# Graph Report - .  (2026-07-15)

## Corpus Check
- Large corpus: 513 files · ~223,720 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 803 nodes · 926 edges · 107 communities (102 shown, 5 thin omitted)
- Extraction: 93% EXTRACTED · 7% INFERRED · 0% AMBIGUOUS · INFERRED: 69 edges (avg confidence: 0.8)
- Token cost: 309,886 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Enemy AI & Grappling Hook|Enemy AI & Grappling Hook]]
- [[_COMMUNITY_Room Loading & Map Generation|Room Loading & Map Generation]]
- [[_COMMUNITY_Player State & Actions|Player State & Actions]]
- [[_COMMUNITY_CrewMember AI & Dance Combat|CrewMember AI & Dance Combat]]
- [[_COMMUNITY_HUD & Player Systems (Love2D)|HUD & Player Systems (Love2D)]]
- [[_COMMUNITY_Achievements Viewer|Achievements Viewer]]
- [[_COMMUNITY_DanceScene canFight Combat|DanceScene canFight Combat]]
- [[_COMMUNITY_Procedural Map Generator|Procedural Map Generator]]
- [[_COMMUNITY_Title Scene & PlayerData Reset|Title Scene & PlayerData Reset]]
- [[_COMMUNITY_Achievement Toasts|Achievement Toasts]]
- [[_COMMUNITY_MazeScene Core Loop|MazeScene Core Loop]]
- [[_COMMUNITY_Achievements Library Core|Achievements Library Core]]
- [[_COMMUNITY_LDtk Export Tooling|LDtk Export Tooling]]
- [[_COMMUNITY_canFight Skill Feature (SDD)|canFight Skill Feature (SDD)]]
- [[_COMMUNITY_Cockpit Scene|Cockpit Scene]]
- [[_COMMUNITY_Config & Boot Architecture|Config & Boot Architecture]]
- [[_COMMUNITY_Doors & Wall Plugs|Doors & Wall Plugs]]
- [[_COMMUNITY_Portals & Run Transitions|Portals & Run Transitions]]
- [[_COMMUNITY_In-Game Menu & Map Drawer|In-Game Menu & Map Drawer]]
- [[_COMMUNITY_Achievement Grant Wrappers|Achievement Grant Wrappers]]
- [[_COMMUNITY_Cutscene System|Cutscene System]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 91|Community 91]]
- [[_COMMUNITY_Community 102|Community 102]]
- [[_COMMUNITY_Community 103|Community 103]]
- [[_COMMUNITY_Community 106|Community 106]]

## God Nodes (most connected - your core abstractions)
1. `MapGenerator.generate()` - 12 edges
2. `PlayerData (global mutable state)` - 11 edges
3. `scene:enter()` - 10 edges
4. `Procedural Generation (doc)` - 10 edges
5. `CockpitScene` - 9 edges
6. `Love2D Port Guide (doc)` - 9 edges
7. `export_images()` - 8 edges
8. `at.initialize()` - 8 edges
9. `av.drawCards()` - 8 edges
10. `Config global table` - 8 edges

## Surprising Connections (you probably didn't know these)
- `PlayerDance:init(bpm, spritePath)` --implements--> `Full-screen 400x240 combat sprite sizing`  [EXTRACTED]
  source/entities/UI/battle/playerDance.lua → .superpowers/sdd/task-2-brief.md
- `PlayerDance:init(bpm, spritePath)` --conceptually_related_to--> `Optional spritePath parameter pattern`  [INFERRED]
  source/entities/UI/battle/playerDance.lua → .superpowers/sdd/task-4-brief.md
- `EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)` --implements--> `Full-screen 400x240 combat sprite sizing`  [EXTRACTED]
  source/entities/UI/battle/enemyRatDance.lua → .superpowers/sdd/task-2-brief.md
- `EnemyRatDance:init(bpm, evolveType, isEvolving, spritePath)` --conceptually_related_to--> `Optional spritePath parameter pattern`  [INFERRED]
  source/entities/UI/battle/enemyRatDance.lua → .superpowers/sdd/task-4-brief.md
- `Fight spritesheet swap with dev-time probe` --rationale_for--> `resolveFightPath(basePath, useFight)`  [EXTRACTED]
  .superpowers/sdd/final-diff.txt → source/scenes/DanceScene.lua

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Turn-Based 'time moves when you move' sync** — docs_data_flow_turn_based_sync, docs_enemies_and_combat_movementframes, docs_crewmember_and_collisions_turn_sync, docs_input_system_b_button [INFERRED 0.85]
- **Stand-On Crank-Driven Props (minifier/microwave)** — docs_props_and_items_minifier, docs_microwave_and_food_cooking_flow, docs_player_systems_transformation [INFERRED 0.85]
- **canFight sprite path wiring in DanceScene:enter()** — dancescene_lua_resolvefightpath, playerdance_lua_playerdance_init, enemyratdance_lua_enemyratdance_init, backgrounddance_lua_backgrounddance_init [EXTRACTED 1.00]
- **DanceScene canFight gating flow** — concept_canfight_skill, scenes_dancescene_keyprovider, scenes_dancescene_pickarrow, scenes_dancescene_resolvefightpath [EXTRACTED 1.00]
- **Cutscene input-blocking flags** — concept_panels_library, concept_iscutscene_flag, concept_isgaming_flag, concept_seencomics [EXTRACTED 1.00]
- **Procedural door connectivity** — concept_doorsconnection, concept_door_signature_matching, door_createdoorsfromnode, concept_procedural_run_graph [EXTRACTED 1.00]
- **HUD elements sharing PlayerData + follow-player render** — concept_playerhud, concept_battery_hud, concept_healthindicator, concept_sanityhud, concept_uihud [EXTRACTED 1.00]
- **Procedural run generation pipeline** — concept_mapgenerator, concept_runstate, concept_room_pool, concept_door_signature_matching, concept_secret_rooms_portals [EXTRACTED 1.00]
- **Run persistence across save/title/dead flows** — concept_savesystem, concept_runstate, concept_titlescene, concept_deadscene [INFERRED 0.85]

## Communities (107 total, 5 thin omitted)

### Community 0 - "Enemy AI & Grappling Hook"
Cohesion: 0.05
Nodes (13): Enemy:moveCollision(), GrappleHook:update(), Player:checkHoleTile(), Player:checkTinyHoleTile(), Player:isOnHole(), Player:checkSlimeTile(), Player:updateSliding(), GetTileUnderPlayer() (+5 more)

### Community 1 - "Room Loading & Map Generation"
Cohesion: 0.09
Nodes (41): conditionalScripts evaluator, Conditions.lua evaluator, Config (tunable constants), CreateTileColliders (segment merge), Crew roster & endgame (final room), DeadScene (game over), Door signature matching, inGameMenu (map + crew hats) (+33 more)

### Community 2 - "Player State & Actions"
Cohesion: 0.05
Nodes (4): Player:fallBelow(), Player:riseAbove(), scene:init(), RunState.startRun()

### Community 3 - "CrewMember AI & Dance Combat"
Cohesion: 0.06
Nodes (34): CrewMember AI States, CrewMember Capture (taken), CrewMember Entity, exitHiding Group Bug, Hiding State & hidingTokens, Turn-Based Sync via movementFrames, Balance Bar System, ButtonPress System (+26 more)

### Community 4 - "HUD & Player Systems (Love2D)"
Cohesion: 0.09
Nodes (33): anim8 (Love2D animations), Battery bar (HUD), Battery drain/charge system, bump.lua (Love2D collisions), Calories and pedometer, CollideGroups (collision groups), Crank -> Q/E key mapping, DanceScene (rhythm combat) (+25 more)

### Community 5 - "Achievements Viewer"
Cohesion: 0.16
Nodes (22): av.animateInUpdate(), av.animateOutUpdate(), av.backupUserSettings(), av.beginExit(), av.clearCaches(), av.destroy(), av.drawCard(), av.drawCards() (+14 more)

### Community 6 - "DanceScene canFight Combat"
Cohesion: 0.10
Nodes (10): PlayerData.skills.canFight, Config.Dance rhythm combat difficulties, Fight variant spritesheets, EnemyPatterns, getPatternKey(), keyProvider, pickArrow(), resolveFightPath (+2 more)

### Community 7 - "Procedural Map Generator"
Cohesion: 0.17
Nodes (20): DoorsConnection customField, connect(), doorCountsOf(), doorSidesOf(), doorSlotsSig(), hasHolesTemplate(), isDarkTemplate(), makeNode() (+12 more)

### Community 8 - "Title Scene & PlayerData Reset"
Cohesion: 0.13
Nodes (12): deepcopy(), ResetPlayerData(), scene:enter(), scene:init(), selectNext(), selectPrevious(), updateMenuSelection(), RunState.clear() (+4 more)

### Community 9 - "Achievement Toasts"
Cohesion: 0.17
Nodes (15): advanceByWithToast(), advanceToWithToast(), advanceWithToast(), at.destroy(), at.drawCard(), at.initialize(), at.isToasting(), at.loadFile() (+7 more)

### Community 10 - "MazeScene Core Loop"
Cohesion: 0.11
Nodes (10): scene:exit(), captureResumePosition(), MazeScene.onDeviceSleep(), scene:finish(), scene:init(), scene:pause(), playdate.deviceDidWake(), RunState.serialize() (+2 more)

### Community 11 - "Achievements Library Core"
Cohesion: 0.22
Nodes (16): achievements.initialize(), achievements.paths.get_achievement_data_file_path(), achievements.paths.get_achievement_folder_root_path(), achievements.paths.get_shared_images_path(), achievements.paths.get_shared_images_updated_file_path(), achievements.save(), copy_file(), crawlImagePaths() (+8 more)

### Community 13 - "LDtk Export Tooling"
Cohesion: 0.18
Nodes (12): BUILD_DIR, copyImages(), ensureDir(), fs, generateLevels(), generateTilemap(), hasDoors(), loadRooms() (+4 more)

### Community 14 - "canFight Skill Feature (SDD)"
Cohesion: 0.23
Nodes (15): BackgroundDance:init(spritePath), Fight spritesheet swap with dev-time probe, Full-screen 400x240 combat sprite sizing, Optional spritePath parameter pattern, getPatternKey(profile), keyProvider (canFight gating), pickArrow helper, resolveFightPath(basePath, useFight) (+7 more)

### Community 16 - "Cockpit Scene"
Cohesion: 0.18
Nodes (11): CockpitBars, CockpitButton, CockpitIndicators, CockpitPointer, CockpitRadar, Accelerometer pointer control + calibration, Cockpit sequence/pattern system, Noble Engine scene lifecycle (+3 more)

### Community 17 - "Config & Boot Architecture"
Cohesion: 0.22
Nodes (11): Config.Cockpit, Config.CollideGroups, Config.Doors positions and spawnCoords, Config.ZIndex render layers, Key system (PlayerData.keys), Config global table, Architecture — Boot Sequence and Global Connections, Config.lua — Complete Reference (+3 more)

### Community 18 - "Doors & Wall Plugs"
Cohesion: 0.24
Nodes (8): CreateDoorsFromNode(), CreateWallPlugsFromNode(), Door:init(), plugBrickImage(), setRectValues(), WallPlug:init(), scene:enter(), MapGenerator.opposite()

### Community 19 - "Portals & Run Transitions"
Cohesion: 0.20
Nodes (7): Door:goTo(), CreatePortalsFromNode(), PortalDoor:canEnter(), PortalDoor:goTo(), resolvePath(), scene:checkDanceResults(), RunState.goTo()

### Community 20 - "In-Game Menu & Map Drawer"
Cohesion: 0.20
Nodes (3): inGameMenu:drawMapOnMenu(), buildLayout(), MapDrawer.drawMap()

### Community 22 - "Achievement Grant Wrappers"
Cohesion: 0.22
Nodes (9): achievements.grant, achievements.crossgame, achievements.toasts, achievements.viewer, PlaydateSquad achievements library, achievementData definitions, Achievements System, checkSanityAchievements (+1 more)

### Community 24 - "Cutscene System"
Cohesion: 0.28
Nodes (9): comics registry, PlayerData.isCutscene flag, Panels cutscene library, Procedural run graph, PlayerData.seenComics one-shot tracking, Cutscene System, CreateDoorsFromNode, MazeScene:enter() (+1 more)

### Community 27 - "Community 27"
Cohesion: 0.32
Nodes (3): itemHeight(), scene:drawBackground(), scene:enter()

### Community 30 - "Community 30"
Cohesion: 0.25
Nodes (7): extension, identifier, name, extensionTemplate, extensionValues, playdate.base-path, playdate.main-path

### Community 31 - "Community 31"
Cohesion: 0.33
Nodes (7): Config.Grapple, Tile 33 grapplePoint, Grappling Hook, Player:beginGrappleCharge, GrappleHook class, GrappleRope class, IsTileWalkable

### Community 32 - "Community 32"
Cohesion: 0.38
Nodes (6): CrewMember:taken(), RunState.consumePending(), RunState.currentNode(), RunState.deserialize(), RunState.getNode(), RunState.revealFinalRoom()

### Community 37 - "Community 37"
Cohesion: 0.33
Nodes (6): PlayerData.isGaming flag, PlayerData.isTalking flag, script table (dialogs), dialogScreen, videoFeed animated portrait, Dialog System

### Community 38 - "Community 38"
Cohesion: 0.33
Nodes (6): Calorie-Burn-Skip While Cooking, Config.Microwave Tunables, Cooking Flow, Emergent Difficulty Tension, Food Resource (PlayerData.food), Microwave + Food Healing System

### Community 42 - "Community 42"
Cohesion: 0.60
Nodes (5): Conditions.eval(), Conditions.met(), entryMet(), resolvePath(), trim()

### Community 44 - "Community 44"
Cohesion: 0.40
Nodes (5): Accelerometer Crosshair Control, Danger Bar System, Fighter/Travel Modes, Meteorite Parallax System, SpaceScene

### Community 45 - "Community 45"
Cohesion: 0.60
Nodes (5): Box Collider Class, CreateTileColliders Algorithm, FXshadow Darkness/Light Mask, Tile Loading, tileMapData / IntGrid Values

### Community 47 - "Community 47"
Cohesion: 0.40
Nodes (4): editor.default_syntax, workspace.art_style, workspace.color, workspace.name

### Community 53 - "Community 53"
Cohesion: 0.40
Nodes (4): Lua.diagnostics.globals, Lua.workspace.library, playdate.output, playdate.source

### Community 60 - "Community 60"
Cohesion: 0.50
Nodes (4): returnScript Logic, Trigger System, Trigger Types, usedTrigger Persistence

### Community 69 - "Community 69"
Cohesion: 0.67
Nodes (3): CreditsScene, Image Preload Strategy, Credits Scroll System

## Knowledge Gaps
- **77 isolated node(s):** `allow`, `editor.default_syntax`, `workspace.art_style`, `workspace.color`, `workspace.name` (+72 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RunState.startRun()` connect `Player State & Actions` to `Title Scene & PlayerData Reset`, `Doors & Wall Plugs`, `Community 32`, `Procedural Map Generator`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `DoorsConnection customField` connect `Procedural Map Generator` to `Room Loading & Map Generation`, `Config & Boot Architecture`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Are the 9 inferred relationships involving `scene:enter()` (e.g. with `CreateDoorsFromNode()` and `CreateWallPlugsFromNode()`) actually correct?**
  _`scene:enter()` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `allow`, `editor.default_syntax`, `workspace.art_style` to the rest of the system?**
  _85 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Enemy AI & Grappling Hook` be split into smaller, more focused modules?**
  _Cohesion score 0.051207729468599035 - nodes in this community are weakly interconnected._
- **Should `Room Loading & Map Generation` be split into smaller, more focused modules?**
  _Cohesion score 0.09024390243902439 - nodes in this community are weakly interconnected._
- **Should `Player State & Actions` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._