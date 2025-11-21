# Game Changes - Update Log

## Major Gameplay Changes

### 🎴 Hearts Only Royal Flush
- **OLD:** Could build Royal Flush with any suit
- **NEW:** Only Hearts (♥) Royal Flush counts as winning condition
- Target clearly shows "Royal Flush ♥" at the top

### 💰 Money System Overhaul
- **OLD:** Earned money on every draw
- **NEW:** Only earn money when drawing a CORRECT Hearts Royal card
- Money amount shown in success message: "Amazing! K♥ found! +$10"
- Base: $10 per correct card
- Increases with Lucky Charm upgrade: +$5 per level

### ⚠️ Progress Reset on Wrong Card
- **OLD:** Collected cards persisted even when drawing wrong cards
- **NEW:** Drawing ANY wrong card RESETS all collected cards to empty!
- High stakes! You must get all 5 cards in sequence without mistakes
- Makes the game significantly more challenging

### 🐕 Dog Companion Upgrade
- **NEW UPGRADE:** "Good Boy" - Costs $1,000
- Spawns a cute dog emoji (🐕) that runs around the screen
- Dog bounces off screen edges and changes direction randomly
- **Click the dog to pet it!**
  - Shows heart (❤️) animation
  - Dog bounces happily
  - Does nothing else - just for fun!

## Visual Changes

### 8-Bit Gritty Art Style
- Dark, textured background with pixel grain
- Blocky borders with no rounded corners
- Hard drop shadows instead of soft glows
- Pixelated rendering (crisp edges)
- Monospace font (Courier New)
- Scanline effects for retro feel

### Assets Created
- `assets/icon.svg` - 8-bit game icon with ace card and crown
- `assets/card-back.svg` - Purple gritty card back design
- `assets/background-texture.svg` - Tileable dark texture pattern

### UI Updates
- Purple/dark color scheme
- Physical button press animations
- Step-based animations (no smooth transitions)
- Gold-bordered win modal
- Worn/gritty card slot appearance

## Upgrade Changes

### Modified Upgrades
1. **Suit Converter** - Now converts cards to Hearts specifically
2. **Lucky Charm** - Description updated to "Earn more money per correct card"
3. **Good Boy** (NEW) - Dog companion for $1,000

## Technical Implementation

### Game Logic
- `targetSuit` permanently set to 'hearts'
- `resetCollectedCards()` function clears all progress
- Money only added on successful Hearts Royal card draw
- Dog spawning and animation system with click handlers

### Animations
- Dog walking animation (bobbing motion)
- Dog bounce animation when petted
- Heart float animation
- Pixelated/stepped card animations

## How to Play (Updated Rules)

1. **Objective:** Build a Royal Flush in Hearts (10♥ J♥ Q♥ K♥ A♥)
2. **Drawing:** Click "Draw Card" to pull from the deck
3. **Success:** If you draw a needed Hearts Royal card, it's added to your collection and you earn money
4. **Failure:** If you draw ANY other card, ALL your progress resets!
5. **Upgrades:** Use earned money to buy upgrades that make it easier
6. **Dog:** Save up $1,000 to get a dog companion you can pet!

## Difficulty

The game is now MUCH harder because:
- Only 1 suit counts (Hearts)
- Wrong card = lose everything
- Must get all 5 cards without mistakes
- Upgrades are essential to have any chance of winning

Good luck! 🍀
