# CLAUDE.md - AI Assistant Guide for Royal Rush

## Project Overview

Royal Rush is a cross-platform incremental/idle card-drawing game where players build a Royal Flush in Hearts (10♥, J♥, Q♥, K♥, A♥) by drawing cards and managing upgrades. Built with vanilla JavaScript, HTML5, and CSS3, targeting web, desktop (Electron), and mobile (Capacitor) platforms.

## Quick Reference

### Essential Commands

```bash
# Development
npm start                    # Launch Electron for development

# Desktop Builds
npm run build:win           # Build Windows installer
npm run build:mac           # Build macOS DMG
npm run build:linux         # Build Linux AppImage/DEB
npm run build:all           # Build all platforms

# Mobile Setup
npm run mobile:init         # Initialize Capacitor
npm run mobile:add:android  # Add Android platform
npm run mobile:add:ios      # Add iOS platform (macOS only)
npm run mobile:sync         # Sync web assets to native
npm run mobile:open:android # Open in Android Studio
npm run mobile:open:ios     # Open in Xcode
```

### Web Deployment

No build step required. Deploy these files directly:
- `index.html`
- `style.css`
- `game.js`
- `assets/` folder

## Architecture

### Technology Stack

- **Frontend**: Vanilla JavaScript (ES6+), HTML5, CSS3
- **Graphics**: SVG assets with 8-bit pixel art style
- **Desktop**: Electron 28.0.0 with electron-builder
- **Mobile**: Capacitor 5.5.1 (iOS/Android)
- **State Management**: Single global `gameState` object
- **No Backend**: 100% client-side game

### File Structure

```
NotsoRoyalFlush/
├── index.html              # Game UI structure (72 lines)
├── style.css               # Complete styling & animations (854 lines)
├── game.js                 # All game logic (643 lines)
├── electron-main.js        # Desktop app entry point
├── package.json            # Dependencies & build scripts
├── capacitor.config.json   # Mobile platform config
├── assets/                 # SVG graphics
│   ├── icon.svg           # App icon (512x512)
│   ├── card-back.svg      # Card back design
│   ├── background-texture.svg
│   ├── cards-8bit.svg     # Card art symbols
│   └── dog-sprite.svg     # 5-frame dog animation
└── Documentation/
    ├── README.md
    ├── BUILDING.md
    ├── CHANGELOG.md
    ├── UPDATE-NOTES.md
    └── LATEST-CHANGES.md
```

## Core Game Logic

### Game State Variables (`game.js`)

```javascript
gameState = {
  draws: 0,           // Total card draws
  money: 100000,      // Starting balance
  deckSize: 52,       // Cards in deck (reduced by upgrades)
  combo: 0,           // Current combo multiplier (0-5)
  totalWins: 0,       // Cumulative wins
  collectedCards: [], // Current royal flush progress
  upgrades: {...}     // Upgrade levels
}
```

### Key Functions

| Function | Purpose |
|----------|---------|
| `initGame()` | Initialize game, attach event listeners |
| `createDeck()` | Generate deck with upgrades applied |
| `startShuffle()` | Animate shuffle with configurable timing |
| `layOutCards()` | Display 5 selectable cards |
| `selectCard(card)` | Handle card selection and flip |
| `checkCardResult(card)` | Validate correct/wrong card |
| `resetCollectedCards()` | Clear progress on wrong card |
| `purchaseUpgrade(key)` | Handle upgrade purchasing |
| `updateUI()` | Refresh all UI elements |
| `renderUpgrades()` | Render upgrade buttons |
| `showWinModal()` | Display victory animation |

### Upgrade System (7 Upgrades)

| Key | Name | Max Level | Effect |
|-----|------|-----------|--------|
| `deckTrimmer` | Deck Trimmer | 10 | -4 cards per level |
| `quickHands` | Quick Hands | 5 | -0.2s shuffle time |
| `ladyLuck` | Lady Luck | 7 | +10% correct cards |
| `suitConverter` | Suit Converter | 5 | 5% convert to hearts |
| `luckyCharm` | Lucky Charm | 10 | +$5 per draw |
| `comboMaster` | Combo Master | 10 | +0.5x combo multiplier |
| `dog` | Good Boy | 1 | Spawn companion dog |

**Cost Formula**: `baseCost × 1.5^level` (base costs: $20-$500)

### Win Condition

- Collect all 5 Hearts Royal cards: **10♥ → J♥ → Q♥ → K♥ → A♥**
- Drawing ANY wrong card resets ALL collected cards
- Combo multiplier rewards consecutive successes (1x-5x)

## Code Conventions

### JavaScript Patterns

- **State Management**: Single global `gameState` object
- **Event Handling**: Direct DOM event listeners
- **UI Updates**: Explicit `updateUI()` calls after state changes
- **No Frameworks**: Pure vanilla JavaScript

### CSS Conventions

- **Design Theme**: 8-bit gritty retro aesthetic
- **Colors**:
  - Background: `#0a0a0a`
  - Accent (title): `#8b0000` (dark red)
  - Combo/costs: `#ffd700` (gold)
  - Win/exit: `#00ff00` (green)
- **Typography**: Monospace (`Courier New`)
- **Animations**: Use CSS `steps()` for 8-bit feel
- **Pseudo-elements**: Used extensively for visual effects

### Naming Conventions

- **Functions**: camelCase (`createDeck`, `updateUI`)
- **Variables**: camelCase (`gameState`, `deckSize`)
- **CSS Classes**: kebab-case (`.card-slot`, `.upgrade-card`)
- **Upgrade Keys**: camelCase (`deckTrimmer`, `ladyLuck`)

## Common Development Tasks

### Adding a New Upgrade

1. Add upgrade definition in `game.js` `initGame()`:
```javascript
gameState.upgrades.newUpgrade = {
  name: 'Upgrade Name',
  level: 0,
  maxLevel: 5,
  baseCost: 20,
  description: 'Effect description'
};
```

2. Implement effect in relevant function (e.g., `createDeck()`, `checkCardResult()`)

3. Update `renderUpgrades()` if special display needed

### Modifying Game Balance

Key constants in `game.js`:
- Starting money: `100000`
- Base deck size: `52`
- Shuffle base time: `1000` (ms)
- Base money earned: `10`
- Cost multiplier: `1.5`

### Adding Visual Effects

1. Define keyframes in `style.css`
2. Add animation class to element
3. Use JavaScript to toggle class

Example pattern:
```javascript
element.classList.add('success-animation');
setTimeout(() => element.classList.remove('success-animation'), 500);
```

### Modifying Card Appearance

- Card symbols: `assets/cards-8bit.svg`
- Card backs: `assets/card-back.svg`
- Card styling: `.selectable-card` in `style.css`

## Build & Deployment

### Desktop (Electron)

Output directory: `dist-electron/`

- **Windows**: NSIS installer + portable exe
- **macOS**: DMG (requires Apple signing)
- **Linux**: AppImage + DEB package

### Mobile (Capacitor)

- **Android**: Build in Android Studio → APK/AAB
- **iOS**: Build in Xcode → IPA (macOS only, requires $99/year dev account)

### Platform Requirements

| Platform | Requirements |
|----------|-------------|
| Windows | electron-builder |
| macOS | electron-builder, signing certificate |
| Linux | electron-builder |
| Android | Android Studio, SDK 33+, JDK 17+ |
| iOS | macOS, Xcode 15+, Apple Developer account |
| Web | Static file hosting |

## Security Notes

### Electron Security (Properly Configured)

- `nodeIntegration: false` - No Node.js in renderer
- `contextIsolation: true` - Context isolation enabled
- `enableRemoteModule: false` - Remote module disabled

### Game Security

- No backend/API calls
- No user data collection
- No network communication

## Testing Considerations

- **No test framework** currently configured
- Manual testing required for:
  - All upgrade effects
  - Win condition
  - Combo system
  - UI responsiveness
  - Cross-platform builds

### Critical Test Cases

1. Royal flush completion sequence
2. Wrong card resets all progress
3. Upgrade cost calculations
4. Combo multiplier math
5. Dog spawn and animation
6. Modal display and reset
7. Money calculations with all upgrades

## Important Notes for AI Assistants

### When Modifying Game Logic

- Always update `updateUI()` after state changes
- Test upgrade interactions (they stack)
- Verify combo multiplier calculations
- Check both success and failure paths

### When Modifying Styles

- Maintain 8-bit aesthetic (use `steps()` animations)
- Avoid smooth transitions
- Keep dark theme consistency
- Test on mobile viewport (768px breakpoint)

### When Adding Features

- Keep it vanilla JS (no frameworks)
- Follow existing state management pattern
- Update relevant documentation in `/` root
- Consider all 6 platforms (web, Win, Mac, Linux, iOS, Android)

### File Modification Priority

When fixing bugs or adding features, check these files in order:
1. `game.js` - Game logic issues
2. `style.css` - Visual/animation issues
3. `index.html` - Structure issues
4. `electron-main.js` - Desktop-specific issues
5. `capacitor.config.json` - Mobile-specific issues

## Project Metadata

- **App ID**: `com.royalrush.game`
- **License**: MIT
- **Lines of Code**: ~1,823 total
- **Current Status**: Active development

## Useful Links

- Electron: https://www.electronjs.org/docs
- Capacitor: https://capacitorjs.com/docs
- electron-builder: https://www.electron.build/
