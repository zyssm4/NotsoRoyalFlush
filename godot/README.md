# Royal Rush 3D - Godot Port

A full 3D port of Royal Rush built with Godot 4.5+.

## Requirements

- Godot 4.5.1 or later
- Forward+ renderer support

## Project Structure

```
godot/
├── project.godot           # Main project file
├── icon.svg                # App icon
├── scenes/
│   ├── main.tscn          # Main game scene
│   └── card_3d.tscn       # Card component scene
├── scripts/
│   ├── autoload/
│   │   ├── game_state.gd  # Global game state
│   │   └── audio_manager.gd # Sound effects
│   ├── main.gd            # Main game controller
│   ├── card_3d.gd         # Card component logic
│   └── dog_3d.gd          # Dog companion logic
└── resources/             # Materials, etc.
```

## Features Ported

### Core Gameplay
- ✅ Card deck creation with luck modifiers
- ✅ Shuffle mechanics with speed upgrades
- ✅ Card selection and flip animations
- ✅ Royal flush tracking (10♥, J♥, Q♥, K♥, A♥)
- ✅ Combo multiplier system
- ✅ Money earning and tracking

### Systems
- ✅ Save/Load system (JSON to user://)
- ✅ 7 upgrades with scaling costs
- ✅ Prestige system with bonuses
- ✅ Achievement system (14 achievements)
- ✅ Daily bonus system
- ✅ Statistics tracking

### Visual Features
- ✅ 3D card meshes with flip animation
- ✅ Hover effects on cards
- ✅ Particle effects for wins
- ✅ Screen shake on wrong cards
- ✅ Money counter animation
- ✅ Dog companion with walk/pet animations

### Audio
- ✅ Procedural sound generation
- ✅ Shuffle, flip, win, fail sounds
- ✅ Coin and achievement sounds

## How to Open

1. Open Godot 4.2+
2. Click "Import"
3. Navigate to this `godot` folder
4. Select `project.godot`
5. Click "Import & Edit"

## How to Play

1. Click **SHUFFLE** to deal 5 face-down cards
2. Click a card to flip it
3. Collect hearts royal cards in order: 10♥ → J♥ → Q♥ → K♥ → A♥
4. Wrong cards reset ALL progress
5. Complete the Royal Flush to win!

## Upgrades

| Upgrade | Effect |
|---------|--------|
| Deck Trimmer | -4 cards per level |
| Quick Hands | -0.2s shuffle time |
| Lady Luck | +5% correct card chance |
| Suit Converter | 4% convert to hearts |
| Lucky Charm | +$5 per correct card |
| Combo Master | +0.3x combo multiplier |
| Good Boy | Dog companion |

## 3D Placeholder Graphics

This port uses placeholder 3D primitives:
- **Cards**: Box meshes with Label3D text
- **Dog**: Brown box mesh
- **Table**: CSG box

To upgrade graphics, replace these with proper 3D models (.glb/.gltf).

## Customization

### Adding Custom Card Models
Replace the `MeshInstance3D` in `card_3d.tscn` with your 3D card model.

### Changing Colors
Edit the `SUIT_COLORS` dictionary in `card_3d.gd` and `main.gd`.

### Adjusting Difficulty
Modify values in `game_state.gd`:
- `deck_size` (default: 52)
- Upgrade `effect` values
- Cost multipliers

## Building for Release

### Desktop
1. Go to Project → Export
2. Add preset (Windows/macOS/Linux)
3. Configure and export

### Mobile
1. Install Android/iOS export templates
2. Add platform preset
3. Configure signing
4. Export

## Known Limitations

- Placeholder 3D graphics (no detailed models)
- Simple UI styling (no custom theme)
- No background music

## License

MIT License - Same as original Royal Rush project
