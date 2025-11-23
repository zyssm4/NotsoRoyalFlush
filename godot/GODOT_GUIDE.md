# Godot Development Guide for Royal Rush

A comprehensive guide for working with the Royal Rush Godot project, even if you're new to Godot.

## Table of Contents
- [Getting Started](#getting-started)
- [Project Overview](#project-overview)
- [Common Tasks](#common-tasks)
- [Working with Scenes](#working-with-scenes)
- [Working with Scripts](#working-with-scripts)
- [Modifying Game Balance](#modifying-game-balance)
- [Adding Content](#adding-content)
- [Testing & Debugging](#testing--debugging)
- [Building & Exporting](#building--exporting)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### Installing Godot

1. Download Godot 4.5.1 from https://godotengine.org/download
2. Choose the **Standard** version (not .NET)
3. Extract and run - no installation required

### Opening the Project

1. Launch Godot
2. Click **Import** button
3. Navigate to `/NotsoRoyalFlush/godot/`
4. Select `project.godot`
5. Click **Import & Edit**

### First Time Setup

After opening, Godot will:
- Import all assets (may take a moment)
- Show any warnings in the Output panel
- Open to the main editor view

---

## Project Overview

### Folder Structure
```
godot/
├── project.godot          # Project configuration
├── icon.svg               # App icon
├── scenes/                # Scene files (.tscn)
│   ├── main.tscn         # Main game scene
│   └── card_3d.tscn      # Card prefab
├── scripts/               # GDScript files (.gd)
│   ├── autoload/         # Global singletons
│   │   ├── game_state.gd # All game data & logic
│   │   └── audio_manager.gd
│   ├── main.gd           # Main scene controller
│   ├── card_3d.gd        # Card behavior
│   └── dog_3d.gd         # Dog companion
└── assets/               # Resources
    ├── models/           # 3D models (.gltf)
    ├── textures/         # Images
    └── materials/        # Godot materials
```

### Key Concepts

#### Scenes (.tscn)
- Reusable templates for game objects
- Composed of nodes in a tree structure
- Can be instantiated (copied) multiple times

#### Scripts (.gd)
- Written in GDScript (Python-like language)
- Attached to nodes to add behavior
- Use signals for communication

#### Autoloads
- Globally accessible singletons
- `GameState` - All game data and logic
- `AudioManager` - Sound effects

---

## Common Tasks

### Changing Colors

#### Card Back Color
1. Open `scenes/card_3d.tscn`
2. Select `CardBody/MainBody` node
3. In Inspector, find `Material`
4. Click to edit, change `Albedo Color`

#### Table Felt Color
1. Open `scenes/main.tscn`
2. Select `CasinoTable/FeltTop`
3. In Inspector, change material color

#### UI Colors
1. Open `scenes/main.tscn`
2. Select UI nodes (e.g., `GameUI/MainPanel`)
3. In Inspector, find `Theme Overrides` > `Styles`
4. Modify `StyleBoxFlat` colors

### Changing Text

#### UI Labels
1. Open `scenes/main.tscn`
2. Select the Label node (e.g., `TitleLabel`)
3. In Inspector, modify `Text` property

#### Card Text
- Card values are set dynamically in code
- Edit `scripts/card_3d.gd`, function `set_card()`

### Adjusting Camera

1. Open `scenes/main.tscn`
2. Select `Camera3D` node
3. Use the 3D viewport to position, or:
4. In Inspector, modify `Transform` > `Position`/`Rotation`

**Current FPS-style settings:**
- Position: (0, 3.5, 5)
- Rotation: Looking down at ~30 degrees
- FOV: 60

### Changing Sounds

Edit `scripts/autoload/audio_manager.gd`:
- `play_card_flip()` - Card flip sound
- `play_success()` - Correct card
- `play_fail()` - Wrong card
- `play_shuffle()` - Shuffling
- `play_win()` - Victory fanfare

---

## Working with Scenes

### Opening a Scene
1. In FileSystem dock (bottom-left)
2. Double-click `.tscn` file
3. Scene opens in 2D/3D viewport

### Navigating 3D View
- **Rotate**: Middle mouse button + drag
- **Pan**: Shift + Middle mouse button
- **Zoom**: Mouse wheel
- **Focus on node**: Select node, press F

### Adding Nodes
1. Select parent node
2. Click + button (or Ctrl+A)
3. Search for node type
4. Click Create

### Moving/Scaling Objects
1. Select node in scene tree
2. Use toolbar buttons:
   - W - Move
   - E - Rotate
   - R - Scale
3. Drag the gizmo handles

### Instancing Scenes
To add a card to a scene:
1. Right-click parent node
2. **Instantiate Child Scene**
3. Select `scenes/card_3d.tscn`

---

## Working with Scripts

### Opening Scripts
- Double-click `.gd` file in FileSystem
- Or click script icon on a node

### Script Structure
```gdscript
extends Node3D  # Parent class

# Variables
var my_variable: int = 0

# Called when node enters scene
func _ready():
    pass

# Called every frame
func _process(delta):
    pass

# Custom function
func my_function():
    pass
```

### Important Scripts

#### game_state.gd - Game Data
```gdscript
# Access from anywhere:
GameState.money          # Current money
GameState.draws          # Total draws
GameState.combo          # Current combo
GameState.collected_cards # Cards collected
GameState.upgrades       # All upgrades

# Key functions:
GameState.purchase_upgrade("upgrade_key")
GameState.check_card_result(card_value, card_suit)
GameState.reset_collected_cards()
GameState.save_game()
GameState.load_game()
```

#### main.gd - Game Flow
```gdscript
# Key functions:
start_shuffle()      # Begin shuffle animation
lay_out_cards()      # Display 5 cards
handle_card_selected(card_data)  # Process selection
update_ui()          # Refresh all displays
```

#### card_3d.gd - Card Behavior
```gdscript
# Key functions:
set_card(value, suit)  # Set card face
flip_to_front()        # Animate flip
flip_to_back()         # Animate to back
```

### Signals
Signals are Godot's event system:
```gdscript
# Defining a signal
signal card_selected(card_data)

# Emitting a signal
card_selected.emit({"value": "A", "suit": "hearts"})

# Connecting to a signal
card.card_selected.connect(_on_card_selected)

func _on_card_selected(data):
    print("Card selected: ", data)
```

---

## Modifying Game Balance

### File: `scripts/autoload/game_state.gd`

### Starting Values
```gdscript
var money: int = 100000
var deck_size: int = 52
```

### Upgrade Configuration
Find the `upgrades` dictionary in `_ready()`:
```gdscript
upgrades = {
    "deck_trimmer": {
        "name": "Deck Trimmer",
        "level": 0,
        "max_level": 10,
        "base_cost": 50,
        "description": "Remove 4 cards from deck"
    },
    # ... more upgrades
}
```

To modify an upgrade:
- `max_level`: Maximum purchasable level
- `base_cost`: Starting price
- Cost formula: `base_cost * pow(1.5, level)`

### Upgrade Effects
Find where each upgrade is applied:

| Upgrade | Location | Function |
|---------|----------|----------|
| deck_trimmer | `create_deck()` | Removes non-heart cards |
| quick_hands | `start_shuffle()` | Reduces shuffle time |
| lady_luck | `create_deck()` | Adds extra correct cards |
| suit_converter | `create_deck()` | Converts suits to hearts |
| lucky_charm | `check_card_result()` | Bonus money per draw |
| combo_master | `check_card_result()` | Increased combo multiplier |

### Story Mode Tiers
```gdscript
const TIER_NAMES: Array = [
    "", "Street Corner", "Back Alley", "Underground",
    "The Velvet Room", "High Stakes", "VIP Lounge",
    "The Penthouse", "Royal Suite"
]

const TIER_REQUIREMENTS: Array = [0, 0, 5, 15, 30, 50, 100, 200, 500]
```

### Achievement Requirements
Find `check_achievements()` function to modify unlock conditions.

---

## Adding Content

### Adding a New Upgrade

1. **Define the upgrade** in `game_state.gd`:
```gdscript
# In _ready(), add to upgrades dictionary:
"my_upgrade": {
    "name": "My New Upgrade",
    "level": 0,
    "max_level": 5,
    "base_cost": 100,
    "description": "Does something cool"
}
```

2. **Implement the effect** where appropriate:
```gdscript
# Example: In check_card_result()
var my_bonus = upgrades.my_upgrade.level * 10
money += my_bonus
```

3. The UI automatically displays new upgrades.

### Adding an Achievement

1. **Add to achievements dictionary** in `game_state.gd`:
```gdscript
"my_achievement": {
    "name": "Achievement Name",
    "description": "How to unlock",
    "unlocked": false,
    "secret": false  # true to hide until unlocked
}
```

2. **Add unlock check** in `check_achievements()`:
```gdscript
if some_condition and not achievements.my_achievement.unlocked:
    unlock_achievement("my_achievement")
```

### Adding a New Card Animation

In `scripts/card_3d.gd`:
```gdscript
func my_animation():
    var tween = create_tween()
    tween.tween_property(self, "rotation_degrees:y", 360, 0.5)
    tween.tween_property(self, "position:y", 0.5, 0.2)
    await tween.finished
```

---

## Testing & Debugging

### Running the Game

- Press **F5** or click Play button
- Game runs in a separate window
- Press **F8** to stop

### Running Current Scene

- Press **F6** to run just the open scene
- Useful for testing individual components

### Debug Output

```gdscript
print("Debug message")
print("Value: ", my_variable)
print("Dict: ", my_dictionary)
```

View output in **Output** panel at bottom of editor.

### Remote Inspector

While game is running:
1. Click **Remote** tab in Scene dock
2. Inspect live node properties
3. Modify values in real-time

### Common Debug Techniques

```gdscript
# Print when function is called
func my_function():
    print("my_function called")

# Print variable state
func _process(delta):
    if Input.is_action_just_pressed("ui_accept"):
        print("GameState: ", GameState.money, " ", GameState.combo)

# Breakpoints
# Click left margin of script editor to add breakpoint
# Game pauses when line is reached
```

---

## Building & Exporting

### Export Templates

First time only:
1. **Editor** > **Manage Export Templates**
2. Click **Download and Install**

### Creating Export Preset

1. **Project** > **Export**
2. Click **Add** button
3. Select platform (Windows, Linux, macOS, Web, Android, iOS)

### Platform-Specific Settings

#### Windows
- Export as `.exe`
- Set icon in export settings

#### Linux
- Export as `.x86_64`
- Mark as executable after export

#### macOS
- Export as `.dmg` or `.app`
- Requires signing for distribution

#### Web (HTML5)
- Exports to `.html` + supporting files
- Host on any web server
- Enable SharedArrayBuffer for threading

#### Android
- Requires Android SDK
- Set up keystore for signing
- Export as `.apk` or `.aab`

### Export Steps

1. **Project** > **Export**
2. Select preset
3. Click **Export Project**
4. Choose location and filename
5. Click **Save**

---

## Troubleshooting

### Scene Won't Load

**Error: "Resource not found"**
- Check file paths are correct
- Ensure resource exists in FileSystem
- Reimport if recently added

### Script Errors

**"Invalid operands"**
```gdscript
# Wrong - mixing types
var result = "text" + 5

# Correct
var result = "text" + str(5)
```

**"Node not found"**
```gdscript
# Check path is correct
@onready var my_node = $Path/To/Node

# Use print to debug
print(get_node_or_null("Path/To/Node"))
```

### Performance Issues

1. **Reduce draw calls**
   - Merge meshes where possible
   - Use instancing for repeated objects

2. **Optimize scripts**
   - Move calculations out of `_process()`
   - Cache node references with `@onready`

3. **Check for infinite loops**
   - Add print statements to trace execution

### Model Import Issues

**Model appears black**
- Missing or broken materials
- Create new StandardMaterial3D

**Model is wrong size**
- Scale in import settings
- Or scale root node transform

**Animations not working**
- Check animation names match code
- Ensure animations loop setting is correct

### Build/Export Failures

**"No export template found"**
- Download export templates (Editor > Manage Export Templates)

**Android build fails**
- Verify Android SDK path in Editor Settings
- Check JDK version (17+ required)

---

## Quick Reference

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| F5 | Run project |
| F6 | Run current scene |
| F8 | Stop running |
| Ctrl+S | Save scene |
| Ctrl+Shift+S | Save all |
| Ctrl+Z | Undo |
| Ctrl+A | Add node |
| Ctrl+D | Duplicate |
| Delete | Delete node |
| F | Focus selected |
| Ctrl+F | Search in script |

### GDScript Quick Reference

```gdscript
# Variables
var x = 5
var y: int = 10
const CONSTANT = 100

# Functions
func my_func(param: int) -> String:
    return str(param)

# Conditionals
if condition:
    pass
elif other:
    pass
else:
    pass

# Loops
for i in range(10):
    print(i)

for item in array:
    print(item)

# Arrays
var arr = [1, 2, 3]
arr.append(4)
arr.size()

# Dictionaries
var dict = {"key": "value"}
dict["new_key"] = 123
dict.get("key", "default")

# Signals
signal my_signal(data)
my_signal.emit(data)
other_node.my_signal.connect(callback)

# Tweens
var tween = create_tween()
tween.tween_property(node, "position", Vector3(1,2,3), 0.5)
await tween.finished

# Timers
await get_tree().create_timer(1.0).timeout
```

### Useful Resources

- **Godot Docs**: https://docs.godotengine.org/
- **GDScript Reference**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **Godot Forums**: https://forum.godotengine.org/
- **Godot Discord**: https://discord.gg/godotengine
- **YouTube Tutorials**: Search "Godot 4 tutorial"

---

## Getting Help

### In-Editor Help
- Hover over properties for tooltips
- F1 while cursor on class name opens docs
- Right-click node > "Open Documentation"

### Project-Specific Questions
- Check existing code for patterns
- Review `game_state.gd` for game logic
- Look at `main.gd` for flow control

---

*This guide covers the basics. For advanced topics, refer to the official Godot documentation.*
