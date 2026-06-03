# Graph Report - .  (2026-06-03)

## Corpus Check
- 124 files · ~198,152 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 711 nodes · 797 edges · 98 communities (93 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 68 edges (avg confidence: 0.83)
- Token cost: 303,429 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Enemy AI & Grappling Hook|Enemy AI & Grappling Hook]]
- [[_COMMUNITY_CrewMember AI & Hiding|CrewMember AI & Hiding]]
- [[_COMMUNITY_Player State & Transforms|Player State & Transforms]]
- [[_COMMUNITY_Doors & Dance Combat|Doors & Dance Combat]]
- [[_COMMUNITY_Achievement Viewer|Achievement Viewer]]
- [[_COMMUNITY_TitleScene & PlayerData Reset|TitleScene & PlayerData Reset]]
- [[_COMMUNITY_Achievement Toasts|Achievement Toasts]]
- [[_COMMUNITY_MazeScene Gameplay Loop|MazeScene Gameplay Loop]]
- [[_COMMUNITY_Achievements Persistence|Achievements Persistence]]
- [[_COMMUNITY_Scene Flow & Rhythm Systems|Scene Flow & Rhythm Systems]]
- [[_COMMUNITY_Save System & Space Scene|Save System & Space Scene]]
- [[_COMMUNITY_HUD & Input System|HUD & Input System]]
- [[_COMMUNITY_Love2D Port & Tile Rendering|Love2D Port & Tile Rendering]]
- [[_COMMUNITY_Microwave, Food & Items|Microwave, Food & Items]]
- [[_COMMUNITY_NPC Scripts & Trigger Schema|NPC Scripts & Trigger Schema]]
- [[_COMMUNITY_Config Single Source of Truth|Config Single Source of Truth]]
- [[_COMMUNITY_Cutscenes & World State|Cutscenes & World State]]
- [[_COMMUNITY_Data Flow & Dialog|Data Flow & Dialog]]
- [[_COMMUNITY_Boot Sequence & Room Lookup|Boot Sequence & Room Lookup]]
- [[_COMMUNITY_CrewMember Sync & Grapple Charge|CrewMember Sync & Grapple Charge]]
- [[_COMMUNITY_Player Battery & Sanity|Player Battery & Sanity]]
- [[_COMMUNITY_In-Game Menu & Map|In-Game Menu & Map]]
- [[_COMMUNITY_Portal Doors|Portal Doors]]
- [[_COMMUNITY_CreditsScene|CreditsScene]]
- [[_COMMUNITY_Dance Difficulty & Enemy AI|Dance Difficulty & Enemy AI]]
- [[_COMMUNITY_Grapple Tiles & Colliders|Grapple Tiles & Colliders]]
- [[_COMMUNITY_Plungerang & Prop Systems|Plungerang & Prop Systems]]
- [[_COMMUNITY_Cluster 73|Cluster 73]]
- [[_COMMUNITY_Cluster 83|Cluster 83]]
- [[_COMMUNITY_Cluster 95|Cluster 95]]

## God Nodes (most connected - your core abstractions)
1. `MapGenerator.generate()` - 11 edges
2. `Config (single source of truth)` - 11 edges
3. `Save System` - 10 edges
4. `Player Systems` - 9 edges
5. `export_images()` - 8 edges
6. `at.initialize()` - 8 edges
7. `av.drawCards()` - 8 edges
8. `achievements.paths.get_shared_images_path()` - 7 edges
9. `achievements.initialize()` - 7 edges
10. `scene:enter()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `PortalDoor System` --semantically_similar_to--> `Shared Condition Evaluator`  [INFERRED] [semantically similar]
  source/DOCS/PROPS_AND_ITEMS.md → source/DOCS/SCRIPTS_TRIGGERS_NPC_SCHEMA.md
- `scene:enter()` --calls--> `Utilities.clearAllAchievements()`  [INFERRED]
  source/scenes/TitleScene.lua → source/utilities/Utilities.lua
- `Enemy movementFrames System` --semantically_similar_to--> `Turn-Based Sync via movementFrames`  [INFERRED] [semantically similar]
  source/DOCS/ENEMIES_AND_COMBAT.md → source/DOCS/CREWMEMBER_AND_COLLISIONS.md
- `crossgame.loadImage()` --calls--> `achievements.paths.get_shared_images_path()`  [INFERRED]
  source/achievements/crossgame.lua → source/achievements/achievements.lua
- `at.initialize()` --calls--> `achievements.paths.get_shared_images_path()`  [INFERRED]
  source/achievements/toasts.lua → source/achievements/achievements.lua

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Turn-Based 'time moves when you move' sync** — docs_data_flow_turn_based_sync, docs_enemies_and_combat_movementframes, docs_crewmember_and_collisions_turn_sync, docs_input_system_b_button [INFERRED 0.85]
- **Config as global source of truth with ZIndex/CollideGroups aliases** — docs_config_reference_config, docs_architecture_zindex_collidegroups_aliases, docs_config_reference_zindex, docs_config_reference_collidegroups [EXTRACTED 0.90]
- **MazeScene:enter() room loading + entity spawn pipeline** — docs_level_loading_mazescene_enter, docs_level_loading_createtilecolliders, docs_doors_and_keys_createdoorsfromldtk, docs_cutscene_system_room_entry_cutscene [EXTRACTED 0.90]
- **Turn-Based World Synchronization** — docs_playerdata_reference_isactive, docs_player_systems_turn_based_sync, docs_player_systems_movement [EXTRACTED 0.85]
- **Stand-On Crank-Driven Props (minifier/microwave)** — docs_props_and_items_minifier, docs_microwave_and_food_cooking_flow, docs_player_systems_transformation [INFERRED 0.85]
- **Entity Persistence by iid** — docs_save_system_restore_level_state, docs_trigger_system_used_trigger_persistence, docs_npc_system_grant_system, docs_scripts_triggers_npc_schema_schema [EXTRACTED 0.85]

## Communities (98 total, 5 thin omitted)

### Community 0 - "Enemy AI & Grappling Hook"
Cohesion: 0.05
Nodes (13): Enemy:moveCollision(), GrappleHook:update(), Player:checkHoleTile(), Player:checkTinyHoleTile(), Player:isOnHole(), Player:checkSlimeTile(), Player:updateSliding(), GetTileUnderPlayer() (+5 more)

### Community 1 - "CrewMember AI & Hiding"
Cohesion: 0.06
Nodes (25): CrewMember:taken(), CreateDoorsFromNode(), scene:enter(), connect(), doorCountsOf(), doorSidesOf(), doorSlotsSig(), hasHolesTemplate() (+17 more)

### Community 2 - "Player State & Transforms"
Cohesion: 0.05
Nodes (4): Player:fallBelow(), Player:riseAbove(), scene:init(), RunState.startRun()

### Community 3 - "Doors & Dance Combat"
Cohesion: 0.09
Nodes (9): CalculateLeadsTo(), ConvertLDTKDirection(), CreateDoorsFromLDTK(), Door:goTo(), Door:init(), FindRoomByIid(), setRectValues(), scene:checkDanceResults() (+1 more)

### Community 4 - "Achievement Viewer"
Cohesion: 0.16
Nodes (22): av.animateInUpdate(), av.animateOutUpdate(), av.backupUserSettings(), av.beginExit(), av.clearCaches(), av.destroy(), av.drawCard(), av.drawCards() (+14 more)

### Community 5 - "TitleScene & PlayerData Reset"
Cohesion: 0.13
Nodes (12): deepcopy(), ResetPlayerData(), scene:enter(), scene:init(), selectNext(), selectPrevious(), updateMenuSelection(), RunState.clear() (+4 more)

### Community 6 - "Achievement Toasts"
Cohesion: 0.17
Nodes (15): advanceByWithToast(), advanceToWithToast(), advanceWithToast(), at.destroy(), at.drawCard(), at.initialize(), at.isToasting(), at.loadFile() (+7 more)

### Community 7 - "MazeScene Gameplay Loop"
Cohesion: 0.12
Nodes (10): scene:exit(), captureResumePosition(), MazeScene.onDeviceSleep(), scene:finish(), scene:init(), scene:pause(), playdate.deviceDidWake(), RunState.serialize() (+2 more)

### Community 8 - "Achievements Persistence"
Cohesion: 0.22
Nodes (16): achievements.initialize(), achievements.paths.get_achievement_data_file_path(), achievements.paths.get_achievement_folder_root_path(), achievements.paths.get_shared_images_path(), achievements.paths.get_shared_images_updated_file_path(), achievements.save(), copy_file(), crawlImagePaths() (+8 more)

### Community 9 - "Scene Flow & Rhythm Systems"
Cohesion: 0.15
Nodes (15): Scene Flow Diagram, Accelerometer Control & Calibration, CockpitButton, CockpitPointer, CockpitScene, Cockpit failLimit System, Cockpit Sequence System, CreditsScene (+7 more)

### Community 10 - "Save System & Space Scene"
Cohesion: 0.15
Nodes (15): createOriginalBackup, gameState Datastore Key, getLevelState Extraction, restoreLevelState (iid patching), Save System, Save Version 2.0-LDTK, Accelerometer Crosshair Control, Danger Bar System (+7 more)

### Community 11 - "HUD & Input System"
Cohesion: 0.15
Nodes (13): isTalking Input Blocking, Battery Bar, hasDWatch HUD Visibility Gate, HealthIndicator, playerHud Container, sanityHud, inGameMenu, Pause-via-isGaming Simulation (+5 more)

### Community 12 - "Love2D Port & Tile Rendering"
Cohesion: 0.19
Nodes (13): anim8 Animation Library, Bayer Dither GLSL Shader, bump.lua Collision System, dt Accumulator Timer Pattern, Love2D Port Guide, Custom Scene Manager, LightBurst Ability, Player Movement (+5 more)

### Community 13 - "Microwave, Food & Items"
Cohesion: 0.20
Nodes (12): Crank to Q/E Key Mapping, Calorie-Burn-Skip While Cooking, Config.Microwave Tunables, Cooking Flow, Emergent Difficulty Tension, Food Resource (PlayerData.food), Microwave + Food Healing System, Transformation (tiny/big) (+4 more)

### Community 14 - "NPC Scripts & Trigger Schema"
Cohesion: 0.21
Nodes (12): NPC Conditional Script System, NPC Grant System (hasGranted), NPC Class, NPCCollider, Shared Condition Evaluator, Room customFields Schema, customFields Schema Reference, Script / DialogLine Schema (+4 more)

### Community 16 - "Config Single Source of Truth"
Cohesion: 0.22
Nodes (11): Global State Table, ZIndex / CollideGroups Aliases, Config.Battery Thresholds, Config.CollideGroups, Config (single source of truth), Config.Doors Positions & Spawns, Config.Enemy AI Constants, Config.ZIndex Render Layers (+3 more)

### Community 17 - "Cutscenes & World State"
Cohesion: 0.18
Nodes (11): CrewMember Capture (taken), comics Registry, Panels Cutscene Library, Room-Entry Cutscene, Trigger-Activated Cutscene, Trigger Cutscene Does Not Start Panels, levelsLDTK World State, Crew Hats Display (+3 more)

### Community 18 - "Data Flow & Dialog"
Cohesion: 0.20
Nodes (11): Player collisionResponse Dispatch Map, Data Flow Map, grants System (items -> PlayerData), PlayerData Mutable State, Save / Load Data Flow, dialogScreen, script.lua Dialog Table, videoFeed Animated Portrait (+3 more)

### Community 19 - "Boot Sequence & Room Lookup"
Cohesion: 0.22
Nodes (10): Boot Sequence (main.lua), RoomID = level*100 + room Formula, roomsByIid Hash Lookup, CalculateLeadsTo Formula, ConvertLDTKDirection Mapping, CreateDoorsFromLDTK, FindRoomByIid Lookup, MazeScene:enter() Sequence (+2 more)

### Community 20 - "CrewMember Sync & Grapple Charge"
Cohesion: 0.22
Nodes (10): Config.CrewMember Constants, CrewMember AI States, CrewMember Entity, exitHiding Group Bug, Hiding State & hidingTokens, Turn-Based Sync via movementFrames, Turn-Based Sync Mechanic, Grapple Charge/Release Input Flow (+2 more)

### Community 21 - "Player Battery & Sanity"
Cohesion: 0.24
Nodes (10): Player Animation State Machine, Battery System, Player Systems, Sanity System, Turn-Based Sync (isActive / movementFrames), isActive Turn Signal, PlayerData items and skills Subtables, PlayerData Global State (+2 more)

### Community 28 - "CreditsScene"
Cohesion: 0.32
Nodes (3): itemHeight(), scene:drawBackground(), scene:enter()

### Community 31 - "Dance Difficulty & Enemy AI"
Cohesion: 0.29
Nodes (7): Config.Dance Difficulty Weights, DanceScene Difficulty System, Enemy AI Methods (search/blindSearch/linealSearch), Brocorat Enemy, Enemy Base Class, Enemy movementFrames System, powerLevel & EnemiesData

### Community 36 - "Grapple Tiles & Colliders"
Cohesion: 0.33
Nodes (6): Config.Tiles IntGrid, GrappleHook Projectile Class, Grappling Hook, Tile 33 grapplePoint, Tile Sampling (no sprite collision), CreateTileColliders Segment Merge

### Community 41 - "Plungerang & Prop Systems"
Cohesion: 0.40
Nodes (5): NPC Dynamic Z-Index (y-sort), Homing Return Phase, Projectile Class, Plungerang Projectile System, PropItem System

## Knowledge Gaps
- **43 isolated node(s):** `Noble Engine Scene Lifecycle`, `RoomID = level*100 + room Formula`, `Accelerometer Control & Calibration`, `CockpitButton`, `CockpitPointer` (+38 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `RunState.startRun()` connect `Player State & Transforms` to `CrewMember AI & Hiding`, `TitleScene & PlayerData Reset`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `scene:enter()` connect `TitleScene & PlayerData Reset` to `Enemy AI & Grappling Hook`, `Player State & Transforms`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `Utilities.clearAllAchievements()` connect `Enemy AI & Grappling Hook` to `TitleScene & PlayerData Reset`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `Noble Engine Scene Lifecycle`, `RoomID = level*100 + room Formula`, `Accelerometer Control & Calibration` to the rest of the system?**
  _52 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Enemy AI & Grappling Hook` be split into smaller, more focused modules?**
  _Cohesion score 0.04995374653098982 - nodes in this community are weakly interconnected._
- **Should `CrewMember AI & Hiding` be split into smaller, more focused modules?**
  _Cohesion score 0.06464646464646465 - nodes in this community are weakly interconnected._
- **Should `Player State & Transforms` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._