# 3D Models Guide for Royal Rush

This guide provides detailed specifications for creating or replacing the placeholder 3D models in Royal Rush.

## Table of Contents
- [General Guidelines](#general-guidelines)
- [Model Specifications](#model-specifications)
  - [Playing Card](#playing-card-cardgltf)
  - [Poker Chip](#poker-chip-chipgltf)
  - [Casino Table](#casino-table-tablegltf)
  - [Dog Companion](#dog-companion-doggltf)
- [Importing Models](#importing-models)
- [Material Setup](#material-setup)
- [Troubleshooting](#troubleshooting)

---

## General Guidelines

### File Format
- **Preferred**: `.gltf` / `.glb` (Godot's best-supported format)
- **Alternative**: `.blend` (if you have Blender installed)
- **Avoid**: `.fbx` (can have import issues)

### Coordinate System
- Godot uses **Y-up** coordinate system
- Forward direction is **-Z**
- Right direction is **+X**

### Units
- All measurements in **meters**
- 1 Godot unit = 1 meter

### Origin Points
- Place origin at the **center bottom** for objects that sit on surfaces
- Place origin at **true center** for floating/held objects

### Polygon Counts (Recommended)
| Model | Low-poly | Medium | High |
|-------|----------|--------|------|
| Card | 50-100 | 200-500 | 1000+ |
| Chip | 100-200 | 500-1000 | 2000+ |
| Table | 500-1000 | 2000-5000 | 10000+ |
| Dog | 500-1000 | 2000-5000 | 10000+ |

---

## Model Specifications

### Playing Card (`card.gltf`)

#### Dimensions
```
Width:  0.8 meters (80cm)
Height: 1.2 meters (120cm)
Depth:  0.02 meters (2cm)
```

#### Structure
- Single mesh named `CardMesh`
- Root node named `Card`
- Slight rounded corners (radius: 0.05m)

#### Origin
- Center of the card (both horizontally and vertically)
- Z-origin at center of thickness

#### UV Layout
- **Front face**: Full UV space (0,0 to 1,1) - for card face texture
- **Back face**: Separate UV or flipped - for card back design
- **Edges**: Can share minimal UV space

#### Materials (2 required)
1. **CardFront** - For displaying card value/suit
   - Base Color: White (#FFFFFF)
   - Roughness: 0.4
   - Metallic: 0.0

2. **CardBack** - For the card back design
   - Base Color: Deep Purple (#260D33)
   - Roughness: 0.3
   - Metallic: 0.2
   - Optional: Normal map for texture

#### Notes
- Keep front face perfectly flat for clean text rendering
- Consider adding slight bevel on edges for realism
- The game will overlay Label3D for card values

---

### Poker Chip (`chip.gltf`)

#### Dimensions
```
Radius: 0.15 meters (15cm)
Height: 0.05 meters (5cm)
```

#### Structure
- Single mesh named `ChipMesh`
- Root node named `Chip`
- Cylindrical shape with edge details

#### Origin
- Center of cylinder
- Y-origin at bottom (sits on table)

#### UV Layout
- **Top/Bottom**: Circular UV for chip design
- **Edge**: Strip UV for edge pattern

#### Material Variants
Create these color variants (or use material parameters):

| Variant | Color | Value |
|---------|-------|-------|
| White | #F5F5F5 | $1 |
| Red | #DC143C | $5 |
| Blue | #1E90FF | $10 |
| Green | #228B22 | $25 |
| Black | #1A1A1A | $100 |
| Purple | #8B008B | $500 |
| Gold | #FFD700 | $1000 |

#### Material Properties
- Roughness: 0.3-0.4
- Metallic: 0.1-0.2
- Optional: Slight rim lighting

#### Details to Include
- Edge ridges (casino chip style)
- Top/bottom inlay circles
- Optional: Value text/symbols on faces

---

### Casino Table (`table.gltf`)

#### Dimensions
```
Width:  4.0 meters
Depth:  2.5 meters
Height: 0.9 meters (table surface)
```

#### Structure
```
CasinoTable (root)
├── TableSurface (the felt top)
├── TableRail (padded edge)
├── TableBase (wooden structure)
└── TableLegs (4 legs)
```

#### Origin
- Center of table surface
- Y-origin at floor level

#### Key Measurements
- Felt surface inset: 0.1m from edge
- Rail width: 0.15m
- Rail height: 0.08m above felt
- Leg positions: corners, inset 0.2m

#### Materials (3-4 required)

1. **FeltMaterial**
   - Base Color: Casino Green (#0D5F1C)
   - Roughness: 0.8-0.9
   - Normal map: Felt texture

2. **WoodMaterial**
   - Base Color: Dark Wood (#3D2817)
   - Roughness: 0.4-0.5
   - Normal map: Wood grain

3. **RailMaterial** (padded leather)
   - Base Color: Dark Brown (#2A1810)
   - Roughness: 0.6
   - Normal map: Leather texture

4. **TrimMaterial** (optional gold accents)
   - Base Color: Gold (#FFD700)
   - Metallic: 0.8
   - Roughness: 0.3

#### Card Positions
The game places 5 cards in these positions (in meters from center):
```
Card 0: X = -1.2, Y = 0.92, Z = 0
Card 1: X = -0.6, Y = 0.92, Z = 0
Card 2: X =  0.0, Y = 0.92, Z = 0
Card 3: X =  0.6, Y = 0.92, Z = 0
Card 4: X =  1.2, Y = 0.92, Z = 0
```

---

### Dog Companion (`dog.gltf`)

#### Dimensions
```
Body Length: 0.6 meters
Body Height: 0.3 meters
Total Height: 0.5 meters (to top of head)
```

#### Structure (Rigged)
```
Dog (root)
├── Armature
│   ├── Root
│   │   ├── Spine
│   │   │   ├── Chest
│   │   │   │   ├── Neck
│   │   │   │   │   └── Head
│   │   │   │   ├── FrontLegL
│   │   │   │   │   └── FrontPawL
│   │   │   │   └── FrontLegR
│   │   │   │       └── FrontPawR
│   │   │   └── Hips
│   │   │       ├── BackLegL
│   │   │       │   └── BackPawL
│   │   │       ├── BackLegR
│   │   │       │   └── BackPawR
│   │   │       └── Tail (3-4 bones)
└── DogMesh (skinned)
```

#### Origin
- Center of body at floor level
- Facing -Z direction

#### Required Animations

1. **Idle** (2-4 seconds, looping)
   - Subtle breathing
   - Occasional ear twitch
   - Tail slow wag

2. **Walk** (1 second cycle, looping)
   - 4-beat walk cycle
   - Natural head bob
   - Tail movement

3. **Happy** (1-2 seconds, looping)
   - Fast tail wag
   - Slight body wiggle
   - Ears perked up

4. **Sit** (optional)
   - Sitting pose
   - Tail gentle wag

#### Animation Names (exact)
```
"Idle"
"Walk"
"Happy"
"Sit"
```

#### Material
- **DogMaterial**
  - Base Color: Golden Brown (#D4A574)
  - Roughness: 0.7-0.8
  - Optional: Darker patches for spots

#### Bone Naming Convention
- Use these exact names for the game to find them:
  - `FrontLegL`, `FrontLegR`
  - `BackLegL`, `BackLegR`
  - `Tail`, `Tail.001`, `Tail.002`

---

## Importing Models

### Step 1: Place Files
```
godot/assets/models/
├── card.gltf
├── chip.gltf
├── table.gltf
└── dog.gltf
```

### Step 2: Reimport in Godot
1. Open Godot project
2. Go to `FileSystem` dock
3. Navigate to `assets/models/`
4. Double-click each `.gltf` file
5. Click `Reimport` button

### Step 3: Configure Import Settings
For each model:
1. Select the `.gltf` file
2. Go to `Import` dock
3. Set these options:

**For static models (card, chip, table):**
```
Meshes > Ensure Tangents: On
Meshes > Light Baking: Static Lightmaps
```

**For animated models (dog):**
```
Animation > Import: On
Animation > FPS: 30
Meshes > Ensure Tangents: On
Skeleton > Bone Renaming: None
```

### Step 4: Update Scene References
After importing, update the scenes to use your models:

1. Open `scenes/main.tscn`
2. Find the placeholder nodes
3. Replace with instances of your imported models

---

## Material Setup

### Using Godot Materials

If your models don't include materials, create them in Godot:

1. Create new `StandardMaterial3D`
2. Set properties:
   - Albedo > Color or Texture
   - Metallic
   - Roughness
   - Normal Map (if available)

### PBR Texture Naming
Use this naming convention for automatic detection:
```
card_albedo.png      (or _basecolor, _diffuse)
card_normal.png      (or _normal_map)
card_roughness.png   (or _rough)
card_metallic.png    (or _metal)
card_ao.png          (or _ambient_occlusion)
```

### Texture Sizes (Recommended)
| Model | Texture Size |
|-------|-------------|
| Card | 512x512 or 1024x1024 |
| Chip | 256x256 or 512x512 |
| Table | 1024x1024 or 2048x2048 |
| Dog | 512x512 or 1024x1024 |

---

## Troubleshooting

### Model Appears Too Large/Small
- Check your modeling software's unit settings
- Godot expects meters; Blender default is also meters
- If using other software, scale on export

### Model Facing Wrong Direction
- Rotate the root node by 180 degrees on Y-axis
- Or re-export with correct orientation

### Animations Not Playing
- Check animation names match exactly (case-sensitive)
- Ensure animations are set to loop in export settings
- Verify the AnimationPlayer node was created

### Materials Look Wrong
- Ensure textures are power-of-2 sizes
- Check that UV maps are properly laid out
- Verify normal maps are set to "Normal Map" in import

### Bones Not Found
- Match bone names exactly as specified
- Check for extra characters or spaces
- Some exporters add prefixes - remove them

### Performance Issues
- Reduce polygon count
- Use smaller textures
- Enable GPU compression on textures
- Consider LOD (Level of Detail) versions

---

## Quick Reference Card

```
Card:   0.8 x 1.2 x 0.02 m  | Origin: Center    | Mats: 2
Chip:   R=0.15, H=0.05 m    | Origin: Bottom    | Mats: 1-7
Table:  4.0 x 0.9 x 2.5 m   | Origin: Floor     | Mats: 3-4
Dog:    0.6 x 0.5 x 0.3 m   | Origin: Floor     | Mats: 1 | Anims: 3-4
```

---

## Resources

### Free 3D Model Sources
- [Kenney Assets](https://kenney.nl/assets) - CC0 game assets
- [OpenGameArt](https://opengameart.org/) - Various licenses
- [Sketchfab](https://sketchfab.com/) - Many free models
- [Quaternius](https://quaternius.com/) - CC0 low-poly packs

### Blender Tutorials
- Official Blender docs: https://docs.blender.org/
- Blender to Godot workflow: Search "Blender Godot export tutorial"

### Godot 3D Import Docs
- https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/

---

*Need help? The placeholder CSG models in the current scenes show the expected scale and position of each object.*
