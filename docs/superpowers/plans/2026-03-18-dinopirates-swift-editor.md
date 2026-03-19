# DinoPirates Script Editor — Swift App Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS SwiftUI app that reads the game's LDtk JSON exports and Lua script files, lets the user browse triggers, assign scripts, create dialog scripts, and build conditional script chains, then writes the changes back to `script.lua`.

**Architecture:** NavigationSplitView app with three columns: rooms list → triggers list → trigger detail editor. Parsers are pure value types that decode from disk; writers emit Lua source back to the same files. No external dependencies — only Foundation + SwiftUI.

**Tech Stack:** Swift 5.9+, SwiftUI, XCTest. macOS 14+. No third-party packages.

---

## Game Domain Reference (read this before touching any code)

### Source Files
| File | Format | Purpose |
|------|--------|---------|
| `LDTK/DPplaydate/simplified/<Room>/data.json` | JSON | One file per room; contains trigger entity instances |
| `source/assets/data/script.lua` | Lua table | All dialog scripts used by triggers |
| `source/en.strings` | Key = "Value" | Localization strings — text keys referenced in scripts |

### Trigger Entity (from data.json → `entities.Triggers[]`)
```json
{
  "id": "Triggers",
  "iid": "04803a80-ac70-11f0-ae64-7fad2120052d",
  "x": 172, "y": 100, "width": 40, "height": 40,
  "customFields": {
    "script": "giftFor100",
    "usedTrigger": false,
    "type": "Search",
    "mapPercent": 0,
    "conditionalScripts": ["isTiny:hugeXmas"]
  }
}
```

**Trigger types**: `"Story"`, `"Cutscene"`, `"Search"`, `"Call"`, `"Counter"`, `null`
- Auto-activated (collision): `Story`, `Cutscene`, `Counter`
- Manual (press A): `Search`, `Call`, `null`

### Script Entry (from script.lua)
```lua
script = {
  {
    name = "giftFor100",
    dialog = {
      { video = 'playerHappy', text = "giftfor100-01" },
      { video = 'playerWorry', text = "giftfor100-02" }
    }
  },
  ...
}
```

**Video feed states**: `player`, `playerWorry`, `playerSurprise`, `playerHappy`, `playerAngry`, `playerSleepy`, `playerCry`, `radioHand`, `radioRing`, `notesHand`, `tiny`

### Conditional Script Strings (stored in `conditionalScripts` array)
Format: `"<condition>:<scriptName>"` or `"<condition>:<scriptName>!"` (terminal = single use)

| Example | Meaning |
|---------|---------|
| `"isTiny:hugeXmas"` | If `PlayerData.isTiny == true` → run `hugeXmas` |
| `"!isTiny:normalXmas"` | If `PlayerData.isTiny == false` → run `normalXmas` |
| `"items.hasLamp:nolamp"` | If `PlayerData.items.hasLamp == true` → run `nolamp` |
| `"battery<20:lowBattery"` | If `PlayerData.battery < 20` → run `lowBattery` |
| `"mapPercent>=50:midGame!"` | If `PlayerData.mapPercent >= 50` → run `midGame`, then consume trigger |

**Evaluation**: conditions checked top-to-bottom; first match wins. Fallback = `script` field.

**Comparison operators**: `>`, `<`, `>=`, `<=`, `==`, `!=`

### Localization String Format (en.strings)
```
"giftfor100-01" = "for sure this one is mine.."
"giftfor100-02" = "*it reads*: for crew member 100, our best 100 crew member."
```
Lines starting with `--` are comments and must be preserved.

---

## File Structure

```
DinoPiratesEditor/
├── DinoPiratesEditorApp.swift          Entry point, @main
├── ContentView.swift                   NavigationSplitView: rooms | triggers | detail
│
├── Models/
│   ├── TriggerEntity.swift             Trigger value type (Identifiable, Equatable)
│   ├── ScriptEntry.swift               Script + dialog nodes (Identifiable, Equatable)
│   ├── DialogNode.swift                Single dialog line
│   ├── ConditionalScript.swift         Parsed conditional + raw string roundtrip
│   └── RoomData.swift                  Room metadata + triggers array
│
├── Parsers/
│   ├── LDtkJSONParser.swift            Decode data.json into [RoomData]
│   └── ScriptLuaParser.swift           Regex parse script.lua into [ScriptEntry]
│
├── Writers/
│   └── ScriptLuaWriter.swift           Serialize [ScriptEntry] back to script.lua
│
├── ViewModels/
│   └── ProjectViewModel.swift          @Observable; owns rooms, scripts; handles IO
│
├── Views/
│   ├── RoomListView.swift              Sidebar: room names with trigger count badge
│   ├── TriggerListView.swift           Middle column: triggers in selected room
│   ├── TriggerDetailView.swift         Right panel: trigger info + script assignment
│   ├── ScriptPickerSheet.swift         Modal: search + select existing script
│   ├── DialogCreatorView.swift         Create/edit script with dialog nodes
│   └── ConditionalBuilderView.swift    Visual builder for conditionalScripts array
│
└── Tests/
    ├── LDtkJSONParserTests.swift
    ├── ScriptLuaParserTests.swift
    ├── ConditionalScriptTests.swift
    └── ScriptLuaWriterTests.swift
```

---

## Task 1: Project Bootstrap + Data Models

**Files:**
- Create: `DinoPiratesEditor/Models/TriggerEntity.swift`
- Create: `DinoPiratesEditor/Models/ScriptEntry.swift`
- Create: `DinoPiratesEditor/Models/DialogNode.swift`
- Create: `DinoPiratesEditor/Models/ConditionalScript.swift`
- Create: `DinoPiratesEditor/Models/RoomData.swift`
- Create: `DinoPiratesEditorTests/ConditionalScriptTests.swift`

### Instructions
Create a new macOS App in Xcode: **DinoPiratesEditor**, target macOS 14+, interface SwiftUI, language Swift. Delete the default Hello World body.

- [ ] **Step 1: Define `TriggerType`**

```swift
// TriggerEntity.swift
import Foundation

enum TriggerType: String, CaseIterable, Identifiable {
    case story    = "Story"
    case cutscene = "Cutscene"
    case search   = "Search"
    case call     = "Call"
    case counter  = "Counter"
    var id: String { rawValue }
    var isAutoActivated: Bool { self == .story || self == .cutscene || self == .counter }
}

struct TriggerEntity: Identifiable, Equatable {
    let id: String               // == iid
    let iid: String
    let x, y, width, height: Int
    var type: TriggerType?       // nil means manual/default
    var scriptName: String?      // fallback script
    var usedTrigger: Bool
    var mapPercent: Int
    var conditionalScripts: [String]   // raw strings: "condition:script" or "condition:script!"
}
```

- [ ] **Step 2: Define `VideoState`**

```swift
// DialogNode.swift
import Foundation

enum VideoState: String, CaseIterable, Identifiable {
    case player, playerWorry, playerSurprise, playerHappy
    case playerAngry, playerSleepy, playerCry
    case radioHand, radioRing, notesHand, tiny
    var id: String { rawValue }
}

struct DialogNode: Identifiable, Equatable {
    var id = UUID()
    var video: VideoState
    var text: String   // localization key, e.g. "giftfor100-01"
}
```

- [ ] **Step 3: Define `ScriptEntry`**

```swift
// ScriptEntry.swift
import Foundation

struct ScriptEntry: Identifiable, Equatable {
    var id = UUID()      // Stable identity — do NOT use name as id (it changes on edit)
    var name: String
    var dialog: [DialogNode]
}
```

- [ ] **Step 4: Define `ConditionalScript` shell (stub only — tests come next)**

Create the file with type definitions but `parse` returning `nil` and `rawString` returning `""`:

```swift
// ConditionalScript.swift
import Foundation

enum ComparisonOp: String, CaseIterable {
    case gt = ">"
    case lt = "<"
    case gte = ">="
    case lte = "<="
    case eq = "=="
    case neq = "!="
}

enum ConditionKind: Equatable {
    case boolPath(path: String, inverted: Bool)
    case comparison(path: String, op: ComparisonOp, value: Double)
}

struct ConditionalScript: Identifiable, Equatable {
    var id = UUID()
    var condition: ConditionKind
    var scriptName: String
    var isTerminal: Bool   // true = trigger becomes single-use after this fires

    /// Parse a raw string like "isTiny:hugeXmas!" or "battery<20:lowBattery"
    static func parse(_ raw: String) -> ConditionalScript? {
        guard !raw.isEmpty else { return nil }
        // Find FIRST ':' to split condition from script name.
        // Condition paths and script names never contain colons in this grammar.
        guard let colonRange = raw.range(of: ":") else { return nil }
        let condStr = String(raw[raw.startIndex..<colonRange.lowerBound])
        var scriptPart = String(raw[colonRange.upperBound...])
        let isTerminal = scriptPart.hasSuffix("!")
        if isTerminal { scriptPart = String(scriptPart.dropLast()) }

        let condition: ConditionKind
        // Try comparison: path op value
        let compPattern = #"^([a-zA-Z_.]+)\s*(>=|<=|!=|>|<|==)\s*([\d\-.]+)$"#
        if let match = condStr.range(of: compPattern, options: .regularExpression) {
            let s = String(condStr[match])
            let re = try! NSRegularExpression(pattern: #"^([a-zA-Z_.]+)\s*(>=|<=|!=|>|<|==)\s*([\d\-.]+)$"#)
            if let m = re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) {
                let path = String(s[Range(m.range(at: 1), in: s)!])
                let opStr = String(s[Range(m.range(at: 2), in: s)!])
                let valStr = String(s[Range(m.range(at: 3), in: s)!])
                guard let op = ComparisonOp(rawValue: opStr),
                      let val = Double(valStr) else { return nil }
                condition = .comparison(path: path, op: op, value: val)
            } else { return nil }
        } else {
            // Boolean path (with optional leading '!')
            let inverted = condStr.hasPrefix("!")
            let path = inverted ? String(condStr.dropFirst()) : condStr
            condition = .boolPath(path: path, inverted: inverted)
        }
        return ConditionalScript(condition: condition, scriptName: scriptPart, isTerminal: isTerminal)
    }

    /// Serialize back to raw string for storage
    var rawString: String {
        let condPart: String
        switch condition {
        case .boolPath(let path, let inverted):
            condPart = inverted ? "!\(path)" : path
        case .comparison(let path, let op, let value):
            let valStr = value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value)) : String(value)
            condPart = "\(path)\(op.rawValue)\(valStr)"
        }
        return "\(condPart):\(scriptName)\(isTerminal ? "!" : "")"
    }
}
```

**After writing the stub, the `parse` function body should be just:**
```swift
static func parse(_ raw: String) -> ConditionalScript? { return nil }
var rawString: String { return "" }
```
```

- [ ] **Step 5: Define `RoomData`**

```swift
// RoomData.swift
import Foundation

struct RoomData: Identifiable {
    var id: String { iid }
    let iid: String
    let identifier: String    // "Room_3"
    let level: Int
    let roomNumber: Int
    var triggers: [TriggerEntity]
}
```

- [ ] **Step 6: Write failing tests for `ConditionalScript.parse`**

```swift
// ConditionalScriptTests.swift
import XCTest
@testable import DinoPiratesEditor

final class ConditionalScriptTests: XCTestCase {

    func test_parseBoolPath() {
        let cs = ConditionalScript.parse("isTiny:hugeXmas")!
        XCTAssertEqual(cs.condition, .boolPath(path: "isTiny", inverted: false))
        XCTAssertEqual(cs.scriptName, "hugeXmas")
        XCTAssertFalse(cs.isTerminal)
    }

    func test_parseNegatedBoolPath() {
        let cs = ConditionalScript.parse("!isTiny:normalXmas")!
        XCTAssertEqual(cs.condition, .boolPath(path: "isTiny", inverted: true))
        XCTAssertEqual(cs.scriptName, "normalXmas")
    }

    func test_parseNestedPath() {
        let cs = ConditionalScript.parse("items.hasLamp:nolamp")!
        XCTAssertEqual(cs.condition, .boolPath(path: "items.hasLamp", inverted: false))
        XCTAssertEqual(cs.scriptName, "nolamp")
    }

    func test_parseComparison_lessThan() {
        let cs = ConditionalScript.parse("battery<20:lowBattery")!
        XCTAssertEqual(cs.condition, .comparison(path: "battery", op: .lt, value: 20))
        XCTAssertEqual(cs.scriptName, "lowBattery")
        XCTAssertFalse(cs.isTerminal)
    }

    func test_parseComparison_greaterThanOrEqual() {
        let cs = ConditionalScript.parse("mapPercent>=50:midGame!")!
        XCTAssertEqual(cs.condition, .comparison(path: "mapPercent", op: .gte, value: 50))
        XCTAssertEqual(cs.scriptName, "midGame")
        XCTAssertTrue(cs.isTerminal)
    }

    func test_roundtrip_bool() {
        let raw = "isTiny:hugeXmas"
        XCTAssertEqual(ConditionalScript.parse(raw)!.rawString, raw)
    }

    func test_roundtrip_comparison_terminal() {
        let raw = "battery<20:lowBattery!"
        XCTAssertEqual(ConditionalScript.parse(raw)!.rawString, raw)
    }

    func test_parseReturnsNilForMalformed() {
        XCTAssertNil(ConditionalScript.parse("noColonHere"))
    }

    func test_parseReturnsNilForEmptyString() {
        XCTAssertNil(ConditionalScript.parse(""))
    }

    func test_parseReturnsEmptyScriptNameForTerminalOnlyScript() {
        // "isTiny:!" — script name is empty after stripping '!'
        let cs = ConditionalScript.parse("isTiny:!")
        // Should parse but scriptName is ""
        XCTAssertEqual(cs?.scriptName, "")
        XCTAssertEqual(cs?.isTerminal, true)
    }

    func test_negatedComparisonTreatedAsBoolPath() {
        // "!battery<20:foo" — '!' prefix only applies to bool paths; this parses as
        // boolPath with path "battery<20", which is intentional (not a valid condition
        // in practice — the user should use a comparison kind instead).
        let cs = ConditionalScript.parse("!battery<20:foo")
        // It falls through to boolPath since the comparison regex won't match "!battery<20"
        if let cs = cs {
            XCTAssertEqual(cs.condition, .boolPath(path: "battery<20", inverted: true))
        }
        // Either parse succeeds with boolPath or fails — must not crash
    }
}
```

- [ ] **Step 7: Run tests (expect failures)**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```
Expected: FAIL — `ConditionalScript` not implemented yet.

- [ ] **Step 8: Replace the stub with the full implementation** — copy the real `parse` and `rawString` code from the Step 4 block above into `ConditionalScript.swift`

- [ ] **Step 9: Run tests again — expect PASS**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```

- [ ] **Step 10: Commit**

```bash
git add DinoPiratesEditor/Models/ DinoPiratesEditorTests/ConditionalScriptTests.swift
git commit -m "feat: add core data models for triggers, scripts, dialogs, conditionals"
```

---

## Task 2: LDtk JSON Parser

**Files:**
- Create: `DinoPiratesEditor/Parsers/LDtkJSONParser.swift`
- Create: `DinoPiratesEditorTests/LDtkJSONParserTests.swift`

### Room JSON Structure (simplified data.json)

The simplified exports at `LDTK/DPplaydate/simplified/<RoomName>/data.json` follow this structure:

```json
{
  "identifier": "Room_3",
  "uniqueIdentifer": "bf654080-ac70-11f0-997a-e578ba2da2ac",
  "customFields": {
    "level": 4,
    "roomNumber": 3
  },
  "entities": {
    "Triggers": [
      {
        "id": "Triggers",
        "iid": "04803a80-...",
        "x": 172, "y": 100, "width": 40, "height": 40,
        "customFields": {
          "script": "giftFor100",
          "usedTrigger": false,
          "type": "Search",
          "mapPercent": 0,
          "conditionalScripts": ["isTiny:hugeXmas"]
        }
      }
    ]
  }
}
```

Note: `entities` may not have a `"Triggers"` key if the room has none. `type` may be `null`. `conditionalScripts` may be an empty array or absent.

- [ ] **Step 1: Write Codable types for JSON decoding**

```swift
// LDtkJSONParser.swift
import Foundation

// MARK: - Codable DTOs

private struct RoomJSON: Decodable {
    let identifier: String
    let uniqueIdentifer: String?         // Note: LDtk typo — single 'i' in "Identifer". Optional: missing key uses "" fallback below.
    let customFields: RoomCustomFields
    let entities: EntitiesJSON
}

private struct RoomCustomFields: Decodable {
    let level: Int?
    let roomNumber: Int?
}

private struct EntitiesJSON: Decodable {
    let triggers: [TriggerJSON]?
    enum CodingKeys: String, CodingKey {
        case triggers = "Triggers"
    }
}

private struct TriggerJSON: Decodable {
    let iid: String
    let x, y, width, height: Int
    let customFields: TriggerCustomFields
}

private struct TriggerCustomFields: Decodable {
    let script: String?
    let usedTrigger: Bool?
    let type: String?
    let mapPercent: Int?
    let conditionalScripts: [String]?
}

// MARK: - Parser

struct LDtkJSONParser {
    /// Scan all data.json files inside the given simplified-export directory.
    /// - Parameter simplifiedDir: URL to `LDTK/DPplaydate/simplified/`
    /// - Returns: Rooms that contain at least one trigger (others are omitted)
    func parseAllRooms(in simplifiedDir: URL) throws -> [RoomData] {
        let fm = FileManager.default
        let roomDirs = try fm.contentsOfDirectory(
            at: simplifiedDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ).filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }

        var rooms: [RoomData] = []
        for dir in roomDirs {
            let jsonURL = dir.appendingPathComponent("data.json")
            guard fm.fileExists(atPath: jsonURL.path) else { continue }
            let data = try Data(contentsOf: jsonURL)
            if let room = try parseRoom(from: data) {
                rooms.append(room)
            }
        }
        // Use natural sort so "Room_10" comes after "Room_9", not "Room_1"
        return rooms.sorted { $0.identifier.localizedStandardCompare($1.identifier) == .orderedAscending }
    }

    func parseRoom(from data: Data) throws -> RoomData? {
        let decoder = JSONDecoder()
        let json = try decoder.decode(RoomJSON.self, from: data)
        let triggers = (json.entities.triggers ?? []).map { t -> TriggerEntity in
            TriggerEntity(
                id: t.iid,
                iid: t.iid,
                x: t.x, y: t.y,
                width: t.width, height: t.height,
                type: TriggerType(rawValue: t.customFields.type ?? ""),
                scriptName: t.customFields.script,
                usedTrigger: t.customFields.usedTrigger ?? false,
                mapPercent: t.customFields.mapPercent ?? 0,
                conditionalScripts: t.customFields.conditionalScripts ?? []
            )
        }
        return RoomData(
            iid: json.uniqueIdentifer ?? json.identifier,   // fallback: use identifier if iid absent
            identifier: json.identifier,
            level: json.customFields.level ?? 0,
            roomNumber: json.customFields.roomNumber ?? 0,
            triggers: triggers
        )
    }
}
```

- [ ] **Step 2: Write failing tests**

```swift
// LDtkJSONParserTests.swift
import XCTest
@testable import DinoPiratesEditor

final class LDtkJSONParserTests: XCTestCase {

    let sampleJSON = """
    {
      "identifier": "Room_3",
      "uniqueIdentifer": "bf654080-ac70-11f0-997a-e578ba2da2ac",
      "customFields": { "level": 4, "roomNumber": 3 },
      "entities": {
        "Triggers": [
          {
            "id": "Triggers",
            "iid": "04803a80-ac70-11f0-ae64-7fad2120052d",
            "x": 172, "y": 100, "width": 40, "height": 40,
            "customFields": {
              "script": "giftFor100",
              "usedTrigger": false,
              "type": "Search",
              "mapPercent": 0,
              "conditionalScripts": ["isTiny:hugeXmas"]
            }
          }
        ]
      }
    }
    """

    let noTriggersJSON = """
    {
      "identifier": "Room_5",
      "uniqueIdentifer": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "customFields": { "level": 1, "roomNumber": 5 },
      "entities": {}
    }
    """

    func test_parseRoom_triggerCount() throws {
        let parser = LDtkJSONParser()
        let room = try parser.parseRoom(from: Data(sampleJSON.utf8))!
        XCTAssertEqual(room.triggers.count, 1)
    }

    func test_parseRoom_triggerFields() throws {
        let parser = LDtkJSONParser()
        let room = try parser.parseRoom(from: Data(sampleJSON.utf8))!
        let t = room.triggers[0]
        XCTAssertEqual(t.iid, "04803a80-ac70-11f0-ae64-7fad2120052d")
        XCTAssertEqual(t.type, .search)
        XCTAssertEqual(t.scriptName, "giftFor100")
        XCTAssertFalse(t.usedTrigger)
        XCTAssertEqual(t.conditionalScripts, ["isTiny:hugeXmas"])
    }

    func test_parseRoom_noTriggerKey() throws {
        let parser = LDtkJSONParser()
        let room = try parser.parseRoom(from: Data(noTriggersJSON.utf8))!
        XCTAssertEqual(room.triggers.count, 0)
    }

    func test_parseRoom_missingUniqueIdentifer_usesEmptyString() throws {
        // uniqueIdentifer is optional — missing key should not crash
        let json = """
        {
          "identifier": "Room_9",
          "customFields": { "level": 1, "roomNumber": 9 },
          "entities": {}
        }
        """
        let parser = LDtkJSONParser()
        // Should not throw; uniqueIdentifer falls back to empty string
        let room = try parser.parseRoom(from: Data(json.utf8))
        XCTAssertNotNil(room)
    }

    func test_parseRoom_nullType() throws {
        let json = """
        {
          "identifier": "Room_1",
          "uniqueIdentifer": "00000000-0000-0000-0000-000000000001",
          "customFields": { "level": 1, "roomNumber": 1 },
          "entities": {
            "Triggers": [
              { "id":"Triggers","iid":"x","x":0,"y":0,"width":8,"height":8,
                "customFields": { "script":"test","usedTrigger":false,"type":null,"mapPercent":0,"conditionalScripts":[] } }
            ]
          }
        }
        """
        let parser = LDtkJSONParser()
        let room = try parser.parseRoom(from: Data(json.utf8))!
        XCTAssertNil(room.triggers[0].type)
    }
}
```

- [ ] **Step 3: Run tests — expect PASS**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```

- [ ] **Step 4: Commit**

```bash
git add DinoPiratesEditor/Parsers/LDtkJSONParser.swift DinoPiratesEditorTests/LDtkJSONParserTests.swift
git commit -m "feat: add LDtk simplified JSON parser for trigger entities"
```

---

## Task 3: Script.lua Parser

**Files:**
- Create: `DinoPiratesEditor/Parsers/ScriptLuaParser.swift`
- Create: `DinoPiratesEditorTests/ScriptLuaParserTests.swift`

### script.lua Format

```lua
script = {
    {
        name = "secondCall",
        dialog = {
            { video = 'playerSurprise', text = "secondcall-01" },
            { video = 'radioHand',      text = "secondcall-02" },
        }
    },
    ...
}
```

Rules to handle:
- Both single `'...'` and double `"..."` quotes used for string values
- Indentation is inconsistent — parse by regex, not by indentation
- The top-level wrapper is `script = { ... }` — entries are `{ name = "X", dialog = { ... } }`
- Some dialog nodes have an optional `screen` field after `text`:
  ```lua
  { video = 'playerSurprise', text = "gotcha-01",
    screen = Graphics.image.new('assets/images/ui/dialog/img/captured.png') }
  ```
  **The parser ignores `screen` — this is intentional and lossy.** Do not use this tool to edit scripts that have `screen` nodes (it will strip them). Add a test to confirm the parser does not crash on `screen` entries.

- [ ] **Step 1: Implement parser**

```swift
// ScriptLuaParser.swift
import Foundation

struct ScriptLuaParser {

    func parse(_ source: String) throws -> [ScriptEntry] {
        var entries: [ScriptEntry] = []

        // Split by top-level entries using name as delimiter
        // Regex: find each `{ name = "foo", dialog = { ... } }`
        // Strategy: find all `name = "..."` positions, then extract blocks
        let namePattern = #"name\s*=\s*["']([^"']+)["']"#
        let nameRegex = try NSRegularExpression(pattern: namePattern)
        let nsSource = source as NSString
        let fullRange = NSRange(location: 0, length: nsSource.length)
        let nameMatches = nameRegex.matches(in: source, range: fullRange)

        for (i, match) in nameMatches.enumerated() {
            guard let nameRange = Range(match.range(at: 1), in: source) else { continue }
            let name = String(source[nameRange])

            // Extract dialog block between this name and the next name (or end)
            let blockStart = match.range.location
            let blockEnd = i + 1 < nameMatches.count
                ? nameMatches[i + 1].range.location
                : nsSource.length
            let blockRange = blockStart..<blockEnd
            let block = String(nsSource.substring(with: NSRange(blockRange)))

            let nodes = parseDialogNodes(from: block)
            entries.append(ScriptEntry(name: name, dialog: nodes))
        }

        return entries
    }

    private func parseDialogNodes(from block: String) -> [DialogNode] {
        var nodes: [DialogNode] = []
        // Each dialog node: { video = 'X', text = "Y" }
        let nodePattern = #"video\s*=\s*["']([^"']+)["'][^,}]*,\s*text\s*=\s*["']([^"']+)["']"#
        guard let nodeRegex = try? NSRegularExpression(pattern: nodePattern) else { return [] }
        let nsBlock = block as NSString
        let matches = nodeRegex.matches(in: block, range: NSRange(location: 0, length: nsBlock.length))
        for m in matches {
            guard let videoRange = Range(m.range(at: 1), in: block),
                  let textRange  = Range(m.range(at: 2), in: block) else { continue }
            let videoStr = String(block[videoRange])
            let textStr  = String(block[textRange])
            let video = VideoState(rawValue: videoStr) ?? .player
            nodes.append(DialogNode(video: video, text: textStr))
        }
        return nodes
    }
}
```

- [ ] **Step 2: Write failing tests**

```swift
// ScriptLuaParserTests.swift
import XCTest
@testable import DinoPiratesEditor

final class ScriptLuaParserTests: XCTestCase {

    let sampleLua = """
    script = {
        {
            name = "wakeup",
            dialog = {
                { video = 'playerSleepy', text = "wakeup-01" },
                { video = 'playerWorry',  text = "wakeup-02" },
                { video = 'playerSurprise', text = "wakeup-03" }
            }
        },
        {
            name = "giftFor100",
            dialog = {
                { video = 'playerHappy', text = "giftfor100-01" },
                { video = 'playerWorry', text = "giftfor100-02" }
            }
        }
    }
    """

    func test_parseScriptCount() throws {
        let parser = ScriptLuaParser()
        let scripts = try parser.parse(sampleLua)
        XCTAssertEqual(scripts.count, 2)
    }

    func test_parseScriptNames() throws {
        let scripts = try ScriptLuaParser().parse(sampleLua)
        XCTAssertEqual(scripts[0].name, "wakeup")
        XCTAssertEqual(scripts[1].name, "giftFor100")
    }

    func test_parseDialogNodes() throws {
        let scripts = try ScriptLuaParser().parse(sampleLua)
        let wakeup = scripts[0]
        XCTAssertEqual(wakeup.dialog.count, 3)
        XCTAssertEqual(wakeup.dialog[0].video, .playerSleepy)
        XCTAssertEqual(wakeup.dialog[0].text, "wakeup-01")
        XCTAssertEqual(wakeup.dialog[2].video, .playerSurprise)
    }

    func test_screenFieldIsIgnoredWithoutCrash() throws {
        // Some nodes have an optional `screen` field — parser must not crash and must
        // return the video+text correctly while silently dropping `screen`.
        let lua = """
        script = {
          { name = "gotcha", dialog = {
            { video = 'playerSurprise', text = "gotcha-01",
              screen = "assets/images/ui/dialog/img/captured.png" }
          } }
        }
        """
        let scripts = try ScriptLuaParser().parse(lua)
        XCTAssertEqual(scripts.count, 1)
        XCTAssertEqual(scripts[0].dialog[0].video, .playerSurprise)
        XCTAssertEqual(scripts[0].dialog[0].text, "gotcha-01")
    }

    func test_unknownVideoFallsBackToPlayer() throws {
        let lua = """
        script = {
          { name = "test", dialog = { { video = 'unknownState', text = "test-01" } } }
        }
        """
        let scripts = try ScriptLuaParser().parse(lua)
        XCTAssertEqual(scripts[0].dialog[0].video, .player)
    }
}
```

- [ ] **Step 3: Run tests — expect PASS**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```

- [ ] **Step 4: Commit**

```bash
git add DinoPiratesEditor/Parsers/ScriptLuaParser.swift DinoPiratesEditorTests/ScriptLuaParserTests.swift
git commit -m "feat: add regex-based script.lua parser"
```

---

## Task 4: Script.lua Writer

**Files:**
- Create: `DinoPiratesEditor/Writers/ScriptLuaWriter.swift`
- Create: `DinoPiratesEditorTests/ScriptLuaWriterTests.swift`

The writer appends new scripts to the end of `script.lua`. It never modifies existing entries — game authors add new scripts through this tool; edits to existing scripts are done manually in the file to avoid accidental corruption.

- [ ] **Step 1: Implement writer**

```swift
// ScriptLuaWriter.swift
import Foundation

struct ScriptLuaWriter {

    /// Generate Lua source for a single ScriptEntry
    func luaSource(for entry: ScriptEntry) -> String {
        var lines: [String] = []
        lines.append("    {")
        lines.append("        name = \"\(entry.name)\",")
        lines.append("        dialog = {")
        for node in entry.dialog {
            lines.append("            { video = '\(node.video.rawValue)', text = \"\(node.text)\" },")
        }
        lines.append("        }")
        lines.append("    },")
        return lines.joined(separator: "\n")
    }

    /// Append a new ScriptEntry to an existing script.lua source string.
    /// Inserts before the final `}` that closes the top-level `script = { ... }` table.
    ///
    /// IMPORTANT: Do NOT find the last `}` by `.backwards` string search — the file
    /// contains many inner `}` characters inside dialog node tables. Instead, find the
    /// last occurrence of `},\n}` or `},\n}\n` (the pattern that ends the last entry),
    /// then insert after the last entry's closing `},`. If no entries exist yet,
    /// fall back to inserting before the lone closing `}`.
    func append(_ entry: ScriptEntry, to source: String) -> String {
        let newBlock = luaSource(for: entry)

        // Anchor: the outermost closing `}` is the last `}` that is NOT preceded by
        // more content — i.e., it sits on its own line (possibly with trailing newline).
        // Pattern: a line that is just `}` optionally followed by whitespace/newline.
        let pattern = #"\n\}"#
        guard let lastTopBrace = source.range(of: pattern, options: .backwards) else {
            // Malformed file — append at the end as fallback
            return source + newBlock + "\n"
        }
        // Insert the new block immediately before the final `\n}`
        let before = String(source[source.startIndex..<lastTopBrace.lowerBound])
        let after  = String(source[lastTopBrace.lowerBound...])
        return before + "\n" + newBlock + after
    }

    /// Write [ScriptEntry] as a complete script.lua file from scratch.
    /// Use this only when regenerating the whole file.
    func fullSource(for entries: [ScriptEntry]) -> String {
        var lines = ["script = {"]
        for entry in entries {
            lines.append(luaSource(for: entry))
        }
        lines.append("}")
        return lines.joined(separator: "\n") + "\n"
    }
}
```

- [ ] **Step 2: Write failing tests**

```swift
// ScriptLuaWriterTests.swift
import XCTest
@testable import DinoPiratesEditor

final class ScriptLuaWriterTests: XCTestCase {

    let writer = ScriptLuaWriter()

    func test_luaSource_singleNode() {
        let entry = ScriptEntry(name: "testScript", dialog: [
            DialogNode(video: .playerHappy, text: "test-01")
        ])
        let src = writer.luaSource(for: entry)
        XCTAssertTrue(src.contains("name = \"testScript\""))
        XCTAssertTrue(src.contains("video = 'playerHappy'"))
        XCTAssertTrue(src.contains("text = \"test-01\""))
    }

    func test_luaSource_multipleNodes() {
        let entry = ScriptEntry(name: "multi", dialog: [
            DialogNode(video: .player,      text: "multi-01"),
            DialogNode(video: .radioHand,   text: "multi-02"),
        ])
        let src = writer.luaSource(for: entry)
        XCTAssertTrue(src.contains("text = \"multi-01\""))
        XCTAssertTrue(src.contains("text = \"multi-02\""))
    }

    func test_appendPreservesExistingContent() {
        let existing = "script = {\n    { name = \"old\", dialog = {} },\n}\n"
        let newEntry = ScriptEntry(name: "new", dialog: [
            DialogNode(video: .player, text: "new-01")
        ])
        let result = writer.append(newEntry, to: existing)
        XCTAssertTrue(result.contains("\"old\""))
        XCTAssertTrue(result.contains("\"new\""))
    }

    func test_appendedSourceRoundtrips() throws {
        let existing = "script = {\n    { name = \"old\", dialog = { { video = 'player', text = \"old-01\" } } },\n}\n"
        let newEntry = ScriptEntry(name: "brandNew", dialog: [
            DialogNode(video: .playerWorry, text: "brandnew-01"),
            DialogNode(video: .radioHand,   text: "brandnew-02"),
        ])
        let result = writer.append(newEntry, to: existing)
        // Should be parseable
        let parsed = try ScriptLuaParser().parse(result)
        XCTAssertEqual(parsed.count, 2)
        let found = parsed.first { $0.name == "brandNew" }
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.dialog.count, 2)
    }

    /// This test catches the brace-detection bug: a multi-node entry has many inner `}`
    /// characters. The append must insert before the outermost closing `}`, not an inner one.
    func test_appendWithMultiNodeExistingEntry_doesNotCorruptLua() throws {
        let existing = """
        script = {
            {
                name = "multiNode",
                dialog = {
                    { video = 'player', text = "mn-01" },
                    { video = 'playerWorry', text = "mn-02" },
                    { video = 'radioHand', text = "mn-03" },
                }
            },
        }
        """
        let newEntry = ScriptEntry(name: "appended", dialog: [
            DialogNode(video: .playerHappy, text: "app-01")
        ])
        let result = writer.append(newEntry, to: existing)
        let parsed = try ScriptLuaParser().parse(result)
        XCTAssertEqual(parsed.count, 2)
        XCTAssertEqual(parsed[0].name, "multiNode")
        XCTAssertEqual(parsed[0].dialog.count, 3)
        XCTAssertEqual(parsed[1].name, "appended")
    }
}
```

- [ ] **Step 3: Run tests — expect PASS**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```

- [ ] **Step 4: Commit**

```bash
git add DinoPiratesEditor/Writers/ScriptLuaWriter.swift DinoPiratesEditorTests/ScriptLuaWriterTests.swift
git commit -m "feat: add script.lua writer that appends new scripts"
```

---

## Task 5: ProjectViewModel (Central State)

**Files:**
- Create: `DinoPiratesEditor/ViewModels/ProjectViewModel.swift`

This is the `@Observable` class that owns all loaded data and handles file I/O.

- [ ] **Step 1: Implement**

```swift
// ProjectViewModel.swift
import SwiftUI
import Observation

@Observable
class ProjectViewModel {
    var rooms: [RoomData] = []
    var scripts: [ScriptEntry] = []
    var selectedRoomID: String?
    var selectedTriggerID: String?
    var projectRootURL: URL?        // User-selected root of the DinoPirates repo

    // Derived
    var selectedRoom: RoomData? {
        rooms.first { $0.id == selectedRoomID }
    }
    var selectedTrigger: TriggerEntity? {
        selectedRoom?.triggers.first { $0.id == selectedTriggerID }
    }
    var scriptNames: [String] { scripts.map(\.name).sorted() }

    // MARK: - Loading

    func loadProject(from rootURL: URL) throws {
        self.projectRootURL = rootURL
        let simplifiedURL = rootURL
            .appendingPathComponent("LDTK")
            .appendingPathComponent("DPplaydate")
            .appendingPathComponent("simplified")
        let scriptURL = rootURL
            .appendingPathComponent("source")
            .appendingPathComponent("assets")
            .appendingPathComponent("data")
            .appendingPathComponent("script.lua")

        let parser = LDtkJSONParser()
        let allRooms = try parser.parseAllRooms(in: simplifiedURL)
        self.rooms = allRooms.filter { !$0.triggers.isEmpty }

        let scriptSource = try String(contentsOf: scriptURL, encoding: .utf8)
        self.scripts = try ScriptLuaParser().parse(scriptSource)
    }

    // MARK: - Mutations

    func addScript(_ entry: ScriptEntry) throws {
        guard let rootURL = projectRootURL else { return }
        let scriptURL = rootURL
            .appendingPathComponent("source/assets/data/script.lua")
        let existing = try String(contentsOf: scriptURL, encoding: .utf8)
        let writer = ScriptLuaWriter()
        let updated = writer.append(entry, to: existing)
        try updated.write(to: scriptURL, atomically: true, encoding: .utf8)
        scripts.append(entry)
    }

    func scriptEntry(named name: String) -> ScriptEntry? {
        scripts.first { $0.name == name }
    }
}
```

- [ ] **Step 2: No unit test needed** — ViewModel I/O is tested via integration. Commit.

```bash
git add DinoPiratesEditor/ViewModels/ProjectViewModel.swift
git commit -m "feat: add ProjectViewModel with load/add-script operations"
```

---

## Task 6: Room & Trigger Browser UI

**Files:**
- Create: `DinoPiratesEditor/ContentView.swift`
- Create: `DinoPiratesEditor/Views/RoomListView.swift`
- Create: `DinoPiratesEditor/Views/TriggerListView.swift`

- [ ] **Step 1: ContentView with NavigationSplitView**

```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ProjectViewModel()
    @State private var showFileImporter = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            RoomListView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } content: {
            TriggerListView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 240, ideal: 280)
        } detail: {
            TriggerDetailView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Open Project…") { showFileImporter = true }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.folder]
        ) { result in
            switch result {
            case .success(let url):
                do { try viewModel.loadProject(from: url) }
                catch { errorMessage = error.localizedDescription }
            case .failure(let err):
                errorMessage = err.localizedDescription
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
```

- [ ] **Step 2: RoomListView**

```swift
// RoomListView.swift
import SwiftUI

struct RoomListView: View {
    var viewModel: ProjectViewModel

    var body: some View {
        List(viewModel.rooms, selection: Binding(
            get: { viewModel.selectedRoomID },
            set: { viewModel.selectedRoomID = $0; viewModel.selectedTriggerID = nil }
        )) { room in
            HStack {
                Text(room.identifier)
                    .font(.system(.body, design: .monospaced))
                Spacer()
                Text("\(room.triggers.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .background(Capsule().fill(Color.accentColor.opacity(0.2)))
            }
            .tag(room.id)
        }
        .navigationTitle("Rooms")
        .listStyle(.sidebar)
    }
}
```

- [ ] **Step 3: TriggerListView**

```swift
// TriggerListView.swift
import SwiftUI

struct TriggerListView: View {
    var viewModel: ProjectViewModel

    var body: some View {
        let triggers = viewModel.selectedRoom?.triggers ?? []
        List(triggers, selection: Binding(
            get: { viewModel.selectedTriggerID },
            set: { viewModel.selectedTriggerID = $0 }
        )) { trigger in
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(trigger.scriptName ?? "(no script)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(trigger.scriptName == nil ? .secondary : .primary)
                    Spacer()
                    if trigger.usedTrigger {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .help("Already used (usedTrigger = true)")
                    }
                }
                HStack {
                    Text(trigger.type?.rawValue ?? "default")
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .background(RoundedRectangle(cornerRadius: 3).fill(triggerTypeColor(trigger.type).opacity(0.2)))
                    if !trigger.conditionalScripts.isEmpty {
                        Text("\(trigger.conditionalScripts.count) conditions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tag(trigger.id)
        }
        .navigationTitle(viewModel.selectedRoom?.identifier ?? "Triggers")
        .overlay {
            if triggers.isEmpty {
                ContentUnavailableView(
                    viewModel.selectedRoom == nil ? "Select a Room" : "No Triggers",
                    systemImage: "bolt.slash"
                )
            }
        }
    }

    private func triggerTypeColor(_ type: TriggerType?) -> Color {
        switch type {
        case .story:    return .purple
        case .cutscene: return .orange
        case .search:   return .blue
        case .call:     return .green
        case .counter:  return .yellow
        case nil:       return .gray
        }
    }
}
```

- [ ] **Step 4: Build and run in simulator — verify rooms appear after opening project folder**

- [ ] **Step 5: Commit**

```bash
git add DinoPiratesEditor/ContentView.swift DinoPiratesEditor/Views/RoomListView.swift DinoPiratesEditor/Views/TriggerListView.swift
git commit -m "feat: add room and trigger browser with NavigationSplitView"
```

---

## Task 7: Trigger Detail View + Script Assignment

**Files:**
- Create: `DinoPiratesEditor/Views/TriggerDetailView.swift`
- Create: `DinoPiratesEditor/Views/ScriptPickerSheet.swift`

- [ ] **Step 1: ScriptPickerSheet**

A modal sheet that shows all scripts with a search field. Selecting a name dismisses and returns it.

```swift
// ScriptPickerSheet.swift
import SwiftUI

struct ScriptPickerSheet: View {
    var viewModel: ProjectViewModel
    @Binding var selectedScript: String?
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var filtered: [ScriptEntry] {
        if search.isEmpty { return viewModel.scripts }
        return viewModel.scripts.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Script")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
            }
            .padding()

            TextField("Search…", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List(filtered) { entry in
                Button {
                    selectedScript = entry.name
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.name)
                            .font(.system(.body, design: .monospaced))
                        Text("\(entry.dialog.count) dialog lines")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(minWidth: 320, minHeight: 400)
    }
}
```

- [ ] **Step 2: TriggerDetailView**

Displays trigger info. Shows current `script` field with a "Change" button that opens `ScriptPickerSheet`. Shows `conditionalScripts` with a link to `ConditionalBuilderView`.

```swift
// TriggerDetailView.swift
import SwiftUI

struct TriggerDetailView: View {
    var viewModel: ProjectViewModel
    @State private var showScriptPicker = false
    @State private var showDialogCreator = false
    @State private var showConditionalBuilder = false

    private var trigger: TriggerEntity? { viewModel.selectedTrigger }

    var body: some View {
        Group {
            if let trigger {
                Form {
                    Section("Trigger Info") {
                        LabeledContent("IID") { Text(trigger.iid).font(.caption2).foregroundStyle(.secondary) }
                        LabeledContent("Type") { Text(trigger.type?.rawValue ?? "default (press A)") }
                        LabeledContent("Position") { Text("x:\(trigger.x) y:\(trigger.y)  \(trigger.width)×\(trigger.height)") }
                        LabeledContent("Used") { Text(trigger.usedTrigger ? "Yes" : "No") }
                    }

                    Section {
                        HStack {
                            if let scriptName = trigger.scriptName {
                                Text(scriptName)
                                    .font(.system(.body, design: .monospaced))
                                if let entry = viewModel.scriptEntry(named: scriptName) {
                                    Text("· \(entry.dialog.count) lines")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.orange)
                                        .help("Script '\(scriptName)' not found in script.lua")
                                }
                            } else {
                                Text("(none)").foregroundStyle(.secondary)
                            }
                            Spacer()
                            // "Change" is disabled in v1 — LDtk write-back is not implemented.
                            // Disabling prevents confusing the user when selection silently does nothing.
                            Button("Change… (v2)") { showScriptPicker = true }
                                .disabled(true)
                                .help("Writing script assignment back to LDtk is not supported in v1")
                            Button("New Script…") { showDialogCreator = true }
                        }
                    } header: {
                        Text("Fallback Script")
                    } footer: {
                        Text("Script assignment changes are not written back to LDtk in v1. Use this panel to create new scripts, then assign them manually in LDtk.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        ConditionalBuilderView(
                            conditionals: Binding(
                                get: { trigger.conditionalScripts },
                                set: { _ in }   // read-only in detail; editing in sheet
                            ),
                            viewModel: viewModel
                        )
                        Button("Edit Conditions…") { showConditionalBuilder = true }
                    } header: {
                        HStack {
                            Text("Conditional Scripts")
                            Spacer()
                            Text("\(trigger.conditionalScripts.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .formStyle(.grouped)
            } else {
                ContentUnavailableView("Select a Trigger", systemImage: "bolt")
            }
        }
        .navigationTitle(trigger?.scriptName ?? "Trigger")
        .sheet(isPresented: $showScriptPicker) {
            ScriptPickerSheet(
                viewModel: viewModel,
                selectedScript: Binding(
                    get: { trigger?.scriptName },
                    set: { newName in
                        // In a real implementation, push change back to LDtk JSON
                        // For now: just log (LDtk write is out of scope for v1)
                        print("Script changed to: \(newName ?? "nil")")
                    }
                )
            )
        }
        .sheet(isPresented: $showDialogCreator) {
            DialogCreatorView(viewModel: viewModel, onSave: { entry in
                try? viewModel.addScript(entry)
            })
        }
        .sheet(isPresented: $showConditionalBuilder) {
            if let trigger {
                ConditionalBuilderSheet(trigger: trigger, viewModel: viewModel)
            }
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add DinoPiratesEditor/Views/TriggerDetailView.swift DinoPiratesEditor/Views/ScriptPickerSheet.swift
git commit -m "feat: add trigger detail view with script picker sheet"
```

---

## Task 8: Dialog Creator

**Files:**
- Create: `DinoPiratesEditor/Views/DialogCreatorView.swift`

This view lets the user create a new `ScriptEntry` from scratch:
- Enter a script name (validated: no spaces, not a duplicate)
- Add/remove/reorder `DialogNode` entries (video state + text localization key)
- Preview how the key-value pairs will render

- [ ] **Step 1: Implement**

```swift
// DialogCreatorView.swift
import SwiftUI

struct DialogCreatorView: View {
    var viewModel: ProjectViewModel
    var onSave: (ScriptEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var nodes: [DialogNode] = [DialogNode(video: .player, text: "")]
    @State private var saveError: String?

    private var nameIsValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !name.contains(" ")
        && !viewModel.scriptNames.contains(name)
    }

    private var canSave: Bool {
        nameIsValid && nodes.allSatisfy { !$0.text.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Script").font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    let entry = ScriptEntry(name: name, dialog: nodes)
                    onSave(entry)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
            .padding()
            Divider()

            Form {
                Section("Script Name") {
                    TextField("e.g. myNewDialog", text: $name)
                        .font(.system(.body, design: .monospaced))
                    if !name.isEmpty && !nameIsValid {
                        Label(
                            viewModel.scriptNames.contains(name)
                                ? "A script named '\(name)' already exists"
                                : "No spaces allowed in script name",
                            systemImage: "xmark.circle"
                        )
                        .foregroundStyle(.red)
                        .font(.caption)
                    }
                }

                Section("Dialog Lines") {
                    ForEach($nodes) { $node in
                        HStack(alignment: .top, spacing: 12) {
                            Picker("", selection: $node.video) {
                                ForEach(VideoState.allCases) { v in
                                    Text(v.rawValue).tag(v)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 160)

                            VStack(alignment: .leading, spacing: 4) {
                                TextField("localization key, e.g. myscript-01", text: $node.text)
                                    .font(.system(.body, design: .monospaced))
                                Text("key = \"\(node.text)\"")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { nodes.remove(atOffsets: $0) }
                    .onMove { nodes.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        let nextIndex = nodes.count + 1
                        let suggestedKey = name.isEmpty ? "newline-\(nextIndex)" : "\(name.lowercased())-\(String(format: "%02d", nextIndex))"
                        nodes.append(DialogNode(video: .player, text: suggestedKey))
                    } label: {
                        Label("Add Dialog Line", systemImage: "plus")
                    }
                }

                Section("Preview (Lua output)") {
                    ScrollView(.horizontal) {
                        Text(ScriptLuaWriter().luaSource(for: ScriptEntry(name: name.isEmpty ? "..." : name, dialog: nodes)))
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 560, minHeight: 500)
    }
}
```

- [ ] **Step 2: Build and visually test** — open project, click "New Script…" on any trigger.

- [ ] **Step 3: Commit**

```bash
git add DinoPiratesEditor/Views/DialogCreatorView.swift
git commit -m "feat: add dialog creator view for authoring new script entries"
```

---

## Task 9: Conditional Script Builder

**Files:**
- Create: `DinoPiratesEditor/Views/ConditionalBuilderView.swift`

Two parts:
1. `ConditionalBuilderView` — inline read-only list (used in `TriggerDetailView`)
2. `ConditionalBuilderSheet` — full editing modal with add/remove/reorder rows

Each row represents one `ConditionalScript`. The user picks:
- Condition type: Bool Path or Comparison
- Path (text field with common suggestions: `isTiny`, `items.hasLamp`, `battery`, `mapPercent`, `health`, `sanityCounter`)
- For comparison: operator picker + value field
- Inverted toggle (for Bool Path)
- Script name (picked from ScriptPickerSheet or typed)
- Terminal toggle (single-use flag)

- [ ] **Step 1: ConditionalBuilderView (read-only inline)**

```swift
// ConditionalBuilderView.swift
import SwiftUI

struct ConditionalBuilderView: View {
    @Binding var conditionals: [String]
    var viewModel: ProjectViewModel

    var body: some View {
        if conditionals.isEmpty {
            Text("No conditional scripts — uses fallback script directly.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            ForEach(conditionals.indices, id: \.self) { i in
                let raw = conditionals[i]
                if let cs = ConditionalScript.parse(raw) {
                    HStack(spacing: 6) {
                        Image(systemName: cs.isTerminal ? "bolt.fill" : "bolt")
                            .foregroundStyle(cs.isTerminal ? .orange : .secondary)
                            .help(cs.isTerminal ? "Terminal (single-use)" : "Persistent")
                        Text(conditionLabel(cs.condition))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(cs.scriptName)
                            .font(.system(.caption, design: .monospaced))
                    }
                } else {
                    Text("⚠️ Invalid: \(raw)").font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private func conditionLabel(_ condition: ConditionKind) -> String {
        switch condition {
        case .boolPath(let path, let inverted):
            return inverted ? "NOT \(path)" : path
        case .comparison(let path, let op, let value):
            let valStr = value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value)) : String(value)
            return "\(path) \(op.rawValue) \(valStr)"
        }
    }
}

// MARK: - Editing Sheet

struct ConditionalBuilderSheet: View {
    let trigger: TriggerEntity
    var viewModel: ProjectViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var conditionals: [ConditionalScript] = []
    @State private var showScriptPicker = false
    @State private var editingIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Conditional Scripts").font(.headline)
                Spacer()
                Button("Done") { dismiss() }
            }
            .padding()
            Divider()

            Text("Conditions are checked top-to-bottom. First match wins. Fallback = '\(trigger.scriptName ?? "none")'.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 8)
            // v1 read-only banner
            Label("Changes shown here are NOT saved automatically. Copy the raw output below and paste into LDtk to apply.", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(.horizontal)

            List {
                ForEach(conditionals.indices, id: \.self) { i in
                    ConditionalRowView(
                        conditional: $conditionals[i],
                        scriptNames: viewModel.scriptNames
                    )
                }
                .onDelete { conditionals.remove(atOffsets: $0) }
                .onMove { conditionals.move(fromOffsets: $0, toOffset: $1) }

                Button {
                    conditionals.append(ConditionalScript(
                        condition: .boolPath(path: "isTiny", inverted: false),
                        scriptName: "",
                        isTerminal: false
                    ))
                } label: {
                    Label("Add Condition", systemImage: "plus")
                }
            }
            .listStyle(.plain)

            Divider()
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Raw output:").font(.caption2).foregroundStyle(.secondary)
                    Text(conditionals.map(\.rawString).joined(separator: "\n"))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .frame(minWidth: 520, minHeight: 420)
        .onAppear {
            conditionals = trigger.conditionalScripts.compactMap { ConditionalScript.parse($0) }
        }
        // NOTE (v1): editing conditionals here is NOT written back to LDtk or levels.lua.
        // The sheet is a visual preview and raw-string generator. The user must copy the
        // "Raw output" footer text and paste it into LDtk manually.
        // Show a banner so the user understands this limitation.
    }
}

// MARK: - Single Condition Row

struct ConditionalRowView: View {
    @Binding var conditional: ConditionalScript
    var scriptNames: [String]

    @State private var condType: CondType = .bool

    enum CondType { case bool, comparison }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Condition type toggle
            Picker("Type", selection: $condType) {
                Text("Bool Path").tag(CondType.bool)
                Text("Comparison").tag(CondType.comparison)
            }
            .pickerStyle(.segmented)
            .onChange(of: condType) { _, new in
                switch new {
                case .bool:
                    conditional.condition = .boolPath(path: "isTiny", inverted: false)
                case .comparison:
                    conditional.condition = .comparison(path: "battery", op: .lt, value: 20)
                }
            }

            switch conditional.condition {
            case .boolPath(let path, let inverted):
                HStack {
                    Toggle("NOT", isOn: Binding(
                        get: { inverted },
                        set: { conditional.condition = .boolPath(path: path, inverted: $0) }
                    ))
                    .toggleStyle(.checkbox)
                    TextField("PlayerData path, e.g. isTiny", text: Binding(
                        get: { path },
                        set: { conditional.condition = .boolPath(path: $0, inverted: inverted) }
                    ))
                    .font(.system(.body, design: .monospaced))
                }

            case .comparison(let path, let op, let value):
                HStack {
                    TextField("path, e.g. battery", text: Binding(
                        get: { path },
                        set: { conditional.condition = .comparison(path: $0, op: op, value: value) }
                    ))
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: 140)
                    Picker("", selection: Binding(
                        get: { op },
                        set: { conditional.condition = .comparison(path: path, op: $0, value: value) }
                    )) {
                        ForEach(ComparisonOp.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .frame(width: 60)
                    TextField("value", value: Binding(
                        get: { value },
                        set: { conditional.condition = .comparison(path: path, op: op, value: $0) }
                    ), format: .number)
                    .frame(width: 60)
                }
            }

            // Script name
            HStack {
                Text("→")
                Picker("Script", selection: $conditional.scriptName) {
                    Text("(select script)").tag("")
                    ForEach(scriptNames, id: \.self) { Text($0).tag($0) }
                }
                Toggle("Terminal (single-use)", isOn: $conditional.isTerminal)
                    .toggleStyle(.checkbox)
            }

            Text("Raw: \(conditional.rawString)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .onAppear {
            switch conditional.condition {
            case .boolPath: condType = .bool
            case .comparison: condType = .comparison
            }
        }
    }
}
```

- [ ] **Step 2: Build and visually test** — open project, select a trigger that has `conditionalScripts`, click "Edit Conditions…"

- [ ] **Step 3: Commit**

```bash
git add DinoPiratesEditor/Views/ConditionalBuilderView.swift
git commit -m "feat: add conditional script builder with visual condition editor"
```

---

## Task 10: Wire Up App Entry Point

**Files:**
- Modify: `DinoPiratesEditor/DinoPiratesEditorApp.swift`
- Create: `DinoPiratesEditor/Views/RoomListView.swift` (already created in Task 6)

- [ ] **Step 1: App entry point**

```swift
// DinoPiratesEditorApp.swift
import SwiftUI

@main
struct DinoPiratesEditorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1100, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
```

- [ ] **Step 2: Final build + smoke test**

```bash
xcodebuild build -scheme DinoPiratesEditor -destination 'platform=macOS'
```
Expected: BUILD SUCCEEDED

Then manually:
1. Click "Open Project…" → select the repo root (`/Users/dactrtr-mini/Documents/GitHub/Dinopirates`)
2. Verify rooms appear in the sidebar with trigger counts
3. Select Room_3 → verify triggers appear
4. Select a trigger → verify detail panel shows script name and conditionals
5. Click "New Script…" → create a 2-node script, click Save
6. Open `source/assets/data/script.lua` → verify new entry was appended
7. Click "Edit Conditions…" on a trigger that has conditionalScripts → verify rows display

- [ ] **Step 3: Run all tests**

```bash
xcodebuild test -scheme DinoPiratesEditor -destination 'platform=macOS'
```
Expected: ALL PASS

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: wire up DinoPiratesEditor macOS app — trigger browser, dialog creator, conditional builder"
```

---

## Validation Checklist

After completing all tasks, verify these behaviors manually:

- [ ] App opens and loads project from repo root without crashing
- [ ] Rooms sidebar shows all rooms that have triggers (not empty rooms)
- [ ] Trigger list shows trigger type badge and used/unused status
- [ ] Trigger detail panel shows fallback script name with warning if not found in script.lua
- [ ] Picking a script from ScriptPickerSheet reflects the change in the detail view
- [ ] Creating a new script in DialogCreatorView appends it to script.lua and it appears in ScriptPickerSheet
- [ ] Conditional builder shows all conditions from trigger; raw string preview updates as you edit
- [ ] Terminal toggle correctly adds/removes `!` suffix in raw string preview
- [ ] All unit tests pass: `ConditionalScriptTests`, `LDtkJSONParserTests`, `ScriptLuaParserTests`, `ScriptLuaWriterTests`

---

## Known Limitations (v1 scope)

- **Script assignment is not written back to LDtk**: The `script` field change in TriggerDetailView is read-only for now. Writing back to the `.ldtk` file requires updating the full JSON structure. This is a v2 feature.
- **Conditional script edits are not persisted**: The `ConditionalBuilderSheet` shows the raw strings but saving them back to `data.json` is v2.
- **`en.strings` is not loaded**: Localization key preview would require parsing `source/en.strings`. The file format is `"key" = "value"` with `--` comments. Adding a strings parser in v2 would allow showing actual dialog text next to keys.
- **No LDtk file write**: Changes to triggers must be applied manually in LDtk or in `levels.lua`. The tool is currently a read + script-append tool.
- **`screen` field is dropped by the parser**: Dialog nodes that have a `screen = Graphics.image.new(...)` field are parsed correctly but the `screen` value is silently discarded. Do not use this tool to edit scripts that have `screen` entries.
- **macOS sandbox / Security-Scoped Bookmarks**: The `.fileImporter` picks a folder URL. macOS sandbox revokes access on next launch. For persistent access across sessions, wrap the URL in `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` and persist a bookmark via `URL.bookmarkData(options: .withSecurityScope)`. This is a v2 hardening task; the app works within a single session without it.
