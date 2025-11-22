// Royal Rush - Complete Game Logic
// Version 2.0 with Save System, Achievements, Prestige, and More

// ============================================
// SOUND SYSTEM
// ============================================
const sounds = {
    shuffle: null,
    flip: null,
    win: null,
    fail: null,
    coin: null,
    achievement: null,
    prestige: null
};

// Initialize Web Audio context for sound generation
let audioContext = null;

function initAudio() {
    try {
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
    } catch (e) {
        console.log('Web Audio not supported');
    }
}

function playSound(type) {
    if (!audioContext) return;

    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();

    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);

    switch(type) {
        case 'shuffle':
            oscillator.frequency.setValueAtTime(200, audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(100, audioContext.currentTime + 0.1);
            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);
            oscillator.start();
            oscillator.stop(audioContext.currentTime + 0.1);
            break;

        case 'flip':
            oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(1200, audioContext.currentTime + 0.05);
            gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.05);
            oscillator.start();
            oscillator.stop(audioContext.currentTime + 0.05);
            break;

        case 'win':
            // Play a victory chord
            [523.25, 659.25, 783.99].forEach((freq, i) => {
                const osc = audioContext.createOscillator();
                const gain = audioContext.createGain();
                osc.connect(gain);
                gain.connect(audioContext.destination);
                osc.frequency.setValueAtTime(freq, audioContext.currentTime);
                gain.gain.setValueAtTime(0.2, audioContext.currentTime + i * 0.1);
                gain.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5 + i * 0.1);
                osc.start(audioContext.currentTime + i * 0.1);
                osc.stop(audioContext.currentTime + 0.5 + i * 0.1);
            });
            break;

        case 'fail':
            oscillator.frequency.setValueAtTime(300, audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(100, audioContext.currentTime + 0.3);
            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
            oscillator.start();
            oscillator.stop(audioContext.currentTime + 0.3);
            break;

        case 'coin':
            oscillator.frequency.setValueAtTime(1200, audioContext.currentTime);
            oscillator.frequency.setValueAtTime(1600, audioContext.currentTime + 0.05);
            gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);
            oscillator.start();
            oscillator.stop(audioContext.currentTime + 0.1);
            break;

        case 'achievement':
            [880, 1108.73, 1318.51].forEach((freq, i) => {
                const osc = audioContext.createOscillator();
                const gain = audioContext.createGain();
                osc.connect(gain);
                gain.connect(audioContext.destination);
                osc.frequency.setValueAtTime(freq, audioContext.currentTime + i * 0.15);
                gain.gain.setValueAtTime(0.15, audioContext.currentTime + i * 0.15);
                gain.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3 + i * 0.15);
                osc.start(audioContext.currentTime + i * 0.15);
                osc.stop(audioContext.currentTime + 0.3 + i * 0.15);
            });
            break;

        case 'prestige':
            for (let i = 0; i < 5; i++) {
                const osc = audioContext.createOscillator();
                const gain = audioContext.createGain();
                osc.connect(gain);
                gain.connect(audioContext.destination);
                osc.frequency.setValueAtTime(400 + i * 200, audioContext.currentTime + i * 0.1);
                gain.gain.setValueAtTime(0.2, audioContext.currentTime + i * 0.1);
                gain.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3 + i * 0.1);
                osc.start(audioContext.currentTime + i * 0.1);
                osc.stop(audioContext.currentTime + 0.3 + i * 0.1);
            }
            break;
    }
}

// ============================================
// GAME STATE
// ============================================
const gameState = {
    // Core gameplay
    draws: 0,
    money: 50,
    deckSize: 52,
    combo: 0,
    totalWins: 0,

    // Royal flush tracking
    royalFlush: {
        '10': { found: false, suit: null },
        'J': { found: false, suit: null },
        'Q': { found: false, suit: null },
        'K': { found: false, suit: null },
        'A': { found: false, suit: null }
    },
    targetSuit: 'hearts',
    currentCard: null,
    hasDog: false,
    isShuffling: false,
    cardsLaidOut: false,

    // Prestige system
    prestigeLevel: 0,
    prestigePoints: 0,
    lifetimeMoney: 0,

    // Statistics
    stats: {
        totalDraws: 0,
        totalWins: 0,
        totalMoney: 0,
        highestCombo: 0,
        cardsCollected: 0,
        wrongCards: 0,
        currentStreak: 0,
        bestStreak: 0,
        timePlayed: 0,
        gamesPlayed: 0
    },

    // Daily bonus
    lastDailyBonus: null,
    dailyBonusStreak: 0,

    // Achievements
    achievements: {
        firstWin: { name: "First Victory", description: "Win your first Royal Flush", unlocked: false, icon: "🏆" },
        combo5: { name: "Perfect Hand", description: "Get a 5x combo", unlocked: false, icon: "🔥" },
        rich: { name: "High Roller", description: "Have $10,000 at once", unlocked: false, icon: "💰" },
        draws100: { name: "Card Sharp", description: "Draw 100 cards", unlocked: false, icon: "🃏" },
        draws1000: { name: "Card Master", description: "Draw 1,000 cards", unlocked: false, icon: "👑" },
        wins10: { name: "Lucky Streak", description: "Win 10 Royal Flushes", unlocked: false, icon: "⭐" },
        wins50: { name: "Flush Master", description: "Win 50 Royal Flushes", unlocked: false, icon: "🌟" },
        prestige1: { name: "Reborn", description: "Prestige for the first time", unlocked: false, icon: "🔄" },
        prestige5: { name: "Eternal", description: "Reach prestige level 5", unlocked: false, icon: "♾️" },
        maxUpgrade: { name: "Maxed Out", description: "Max out any upgrade", unlocked: false, icon: "⬆️" },
        dailyStreak7: { name: "Dedicated", description: "Claim daily bonus 7 days in a row", unlocked: false, icon: "📅" },
        dogOwner: { name: "Good Boy", description: "Get the dog companion", unlocked: false, icon: "🐕" },
        speedrun: { name: "Speed Demon", description: "Win in under 20 draws", unlocked: false, icon: "⚡" },
        collector: { name: "Collector", description: "Collect 100 cards total", unlocked: false, icon: "📚" }
    },

    // Upgrades (rebalanced)
    upgrades: {
        deckReduction: {
            name: "Deck Trimmer",
            description: "Remove 4 cards from the deck",
            level: 0,
            maxLevel: 10,
            baseCost: 20,
            effect: 4
        },
        shuffleSpeed: {
            name: "Quick Hands",
            description: "Reduce shuffle time by 0.2s",
            level: 0,
            maxLevel: 5,
            baseCost: 25,
            effect: 0.2
        },
        luck: {
            name: "Lady Luck",
            description: "Increase chance of correct card",
            level: 0,
            maxLevel: 5,  // Reduced from 7
            baseCost: 30,
            effect: 0.05  // Reduced from 0.1
        },
        suitFilter: {
            name: "Suit Converter",
            description: "Convert random cards to hearts",
            level: 0,
            maxLevel: 5,
            baseCost: 35,
            effect: 0.04  // Reduced from 0.05
        },
        moneyBoost: {
            name: "Lucky Charm",
            description: "Earn more money per correct card",
            level: 0,
            maxLevel: 10,
            baseCost: 20,
            effect: 5
        },
        multiplierBoost: {
            name: "Combo Master",
            description: "Increase combo multiplier by 0.3x",
            level: 0,
            maxLevel: 10,
            baseCost: 40,
            effect: 0.3  // Reduced from 0.5
        },
        dog: {
            name: "Good Boy",
            description: "Get an Irish Setter companion",
            level: 0,
            maxLevel: 1,
            baseCost: 500,
            effect: 1
        }
    }
};

// Card data
const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
const suitSymbols = {
    hearts: '♥',
    diamonds: '♦',
    clubs: '♣',
    spades: '♠'
};

const royalCards = ['10', 'J', 'Q', 'K', 'A'];

// ============================================
// SAVE/LOAD SYSTEM
// ============================================
function saveGame() {
    const saveData = {
        draws: gameState.draws,
        money: gameState.money,
        deckSize: gameState.deckSize,
        combo: gameState.combo,
        totalWins: gameState.totalWins,
        royalFlush: gameState.royalFlush,
        hasDog: gameState.hasDog,
        prestigeLevel: gameState.prestigeLevel,
        prestigePoints: gameState.prestigePoints,
        lifetimeMoney: gameState.lifetimeMoney,
        stats: gameState.stats,
        lastDailyBonus: gameState.lastDailyBonus,
        dailyBonusStreak: gameState.dailyBonusStreak,
        achievements: gameState.achievements,
        upgrades: {}
    };

    // Save upgrade levels
    for (const [key, upgrade] of Object.entries(gameState.upgrades)) {
        saveData.upgrades[key] = upgrade.level;
    }

    localStorage.setItem('royalRushSave', JSON.stringify(saveData));
}

function loadGame() {
    const saveData = localStorage.getItem('royalRushSave');
    if (!saveData) return false;

    try {
        const data = JSON.parse(saveData);

        gameState.draws = data.draws || 0;
        gameState.money = data.money || 50;
        gameState.deckSize = data.deckSize || 52;
        gameState.combo = data.combo || 0;
        gameState.totalWins = data.totalWins || 0;
        gameState.royalFlush = data.royalFlush || gameState.royalFlush;
        gameState.hasDog = data.hasDog || false;
        gameState.prestigeLevel = data.prestigeLevel || 0;
        gameState.prestigePoints = data.prestigePoints || 0;
        gameState.lifetimeMoney = data.lifetimeMoney || 0;
        gameState.stats = { ...gameState.stats, ...data.stats };
        gameState.lastDailyBonus = data.lastDailyBonus || null;
        gameState.dailyBonusStreak = data.dailyBonusStreak || 0;

        // Load achievements
        if (data.achievements) {
            for (const [key, achievement] of Object.entries(data.achievements)) {
                if (gameState.achievements[key]) {
                    gameState.achievements[key].unlocked = achievement.unlocked;
                }
            }
        }

        // Load upgrade levels
        if (data.upgrades) {
            for (const [key, level] of Object.entries(data.upgrades)) {
                if (gameState.upgrades[key]) {
                    gameState.upgrades[key].level = level;
                }
            }
        }

        // Recalculate deck size based on upgrades
        gameState.deckSize = 52 - (gameState.upgrades.deckReduction.level * gameState.upgrades.deckReduction.effect);

        return true;
    } catch (e) {
        console.error('Failed to load save:', e);
        return false;
    }
}

// ============================================
// DAILY BONUS SYSTEM
// ============================================
function checkDailyBonus() {
    const now = new Date();
    const today = now.toDateString();

    if (gameState.lastDailyBonus === today) {
        return false; // Already claimed today
    }

    // Check if streak continues
    if (gameState.lastDailyBonus) {
        const lastDate = new Date(gameState.lastDailyBonus);
        const diffDays = Math.floor((now - lastDate) / (1000 * 60 * 60 * 24));

        if (diffDays > 1) {
            gameState.dailyBonusStreak = 0; // Streak broken
        }
    }

    return true; // Can claim
}

function claimDailyBonus() {
    if (!checkDailyBonus()) return;

    gameState.dailyBonusStreak++;
    const bonus = 50 + (gameState.dailyBonusStreak * 25) + (gameState.prestigeLevel * 10);

    gameState.money += bonus;
    gameState.lastDailyBonus = new Date().toDateString();

    // Check achievement
    if (gameState.dailyBonusStreak >= 7) {
        unlockAchievement('dailyStreak7');
    }

    showNotification(`Daily Bonus! +$${bonus} (Day ${gameState.dailyBonusStreak})`);
    playSound('coin');

    saveGame();
    updateUI();
}

// ============================================
// ACHIEVEMENT SYSTEM
// ============================================
function unlockAchievement(key) {
    if (!gameState.achievements[key] || gameState.achievements[key].unlocked) return;

    gameState.achievements[key].unlocked = true;

    // Show achievement notification
    const achievement = gameState.achievements[key];
    showAchievementPopup(achievement);
    playSound('achievement');

    saveGame();
    updateAchievementsDisplay();
}

function showAchievementPopup(achievement) {
    const popup = document.createElement('div');
    popup.className = 'achievement-popup';
    popup.innerHTML = `
        <div class="achievement-icon">${achievement.icon}</div>
        <div class="achievement-text">
            <div class="achievement-title">Achievement Unlocked!</div>
            <div class="achievement-name">${achievement.name}</div>
        </div>
    `;
    document.body.appendChild(popup);

    setTimeout(() => {
        popup.classList.add('show');
    }, 100);

    setTimeout(() => {
        popup.classList.remove('show');
        setTimeout(() => popup.remove(), 500);
    }, 3000);
}

function checkAchievements() {
    // Check various achievements
    if (gameState.stats.totalWins >= 1) unlockAchievement('firstWin');
    if (gameState.stats.totalWins >= 10) unlockAchievement('wins10');
    if (gameState.stats.totalWins >= 50) unlockAchievement('wins50');
    if (gameState.stats.totalDraws >= 100) unlockAchievement('draws100');
    if (gameState.stats.totalDraws >= 1000) unlockAchievement('draws1000');
    if (gameState.stats.highestCombo >= 5) unlockAchievement('combo5');
    if (gameState.money >= 10000) unlockAchievement('rich');
    if (gameState.prestigeLevel >= 1) unlockAchievement('prestige1');
    if (gameState.prestigeLevel >= 5) unlockAchievement('prestige5');
    if (gameState.hasDog) unlockAchievement('dogOwner');
    if (gameState.stats.cardsCollected >= 100) unlockAchievement('collector');

    // Check max upgrade
    for (const upgrade of Object.values(gameState.upgrades)) {
        if (upgrade.level >= upgrade.maxLevel) {
            unlockAchievement('maxUpgrade');
            break;
        }
    }
}

// ============================================
// PRESTIGE SYSTEM
// ============================================
function canPrestige() {
    return gameState.totalWins >= 5;
}

function getPrestigePoints() {
    return Math.floor(gameState.totalWins / 5) + Math.floor(gameState.lifetimeMoney / 10000);
}

function prestige() {
    if (!canPrestige()) return;

    const points = getPrestigePoints();
    gameState.prestigeLevel++;
    gameState.prestigePoints += points;

    // Reset progress but keep prestige bonuses
    gameState.draws = 0;
    gameState.money = 50 + (gameState.prestigeLevel * 25); // Bonus starting money
    gameState.deckSize = 52;
    gameState.combo = 0;
    gameState.totalWins = 0;
    gameState.hasDog = false;

    // Reset royal flush
    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;
    }

    // Reset upgrades
    for (const upgrade of Object.values(gameState.upgrades)) {
        upgrade.level = 0;
    }

    // Remove dog
    const existingDog = document.getElementById('dog');
    if (existingDog) existingDog.remove();

    playSound('prestige');
    showNotification(`Prestige Level ${gameState.prestigeLevel}! +${points} points`);

    unlockAchievement('prestige1');
    if (gameState.prestigeLevel >= 5) unlockAchievement('prestige5');

    saveGame();
    updateUI();
    renderUpgrades();
    resetRoyalFlushDisplay();
}

// ============================================
// VISUAL EFFECTS
// ============================================
function screenShake() {
    const container = document.querySelector('.game-container');
    container.classList.add('shake');
    setTimeout(() => container.classList.remove('shake'), 300);
}

function createParticles(x, y, type = 'win') {
    const colors = type === 'win' ? ['#ffd700', '#ff6b6b', '#4ecdc4', '#45b7d1'] : ['#ff0000'];

    for (let i = 0; i < 20; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = x + 'px';
        particle.style.top = y + 'px';
        particle.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
        particle.style.setProperty('--tx', (Math.random() - 0.5) * 200 + 'px');
        particle.style.setProperty('--ty', (Math.random() - 0.5) * 200 + 'px');
        document.body.appendChild(particle);

        setTimeout(() => particle.remove(), 1000);
    }
}

function animateMoney(oldValue, newValue) {
    const moneyElement = document.getElementById('money');
    const diff = newValue - oldValue;
    const duration = 500;
    const steps = 20;
    const increment = diff / steps;
    let current = oldValue;
    let step = 0;

    const interval = setInterval(() => {
        step++;
        current += increment;
        moneyElement.textContent = `$${Math.floor(current)}`;

        if (step >= steps) {
            clearInterval(interval);
            moneyElement.textContent = `$${newValue}`;
        }
    }, duration / steps);

    // Add pulse effect
    moneyElement.classList.add('money-pulse');
    setTimeout(() => moneyElement.classList.remove('money-pulse'), 500);
}

function highlightNextTarget() {
    // Remove previous highlights
    document.querySelectorAll('.card-slot').forEach(slot => {
        slot.classList.remove('next-target');
    });

    // Find next needed card
    for (const card of royalCards) {
        if (!gameState.royalFlush[card].found) {
            const slot = document.querySelector(`[data-card="${card}"]`);
            if (slot) {
                slot.classList.add('next-target');
            }
            break;
        }
    }
}

function showNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'game-notification';
    notification.textContent = message;
    document.body.appendChild(notification);

    setTimeout(() => notification.classList.add('show'), 100);
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 500);
    }, 2500);
}

// ============================================
// CORE GAME FUNCTIONS
// ============================================
function initGame() {
    initAudio();

    // Load saved game
    const loaded = loadGame();

    // Check for daily bonus
    if (checkDailyBonus()) {
        setTimeout(() => {
            if (confirm('Daily bonus available! Claim now?')) {
                claimDailyBonus();
            }
        }, 500);
    }

    updateUI();
    renderUpgrades();
    updateAchievementsDisplay();
    highlightNextTarget();

    // Restore dog if owned
    if (gameState.hasDog) {
        spawnDog();
    }

    // Restore royal flush display
    updateRoyalFlushDisplay();

    // Event listeners
    document.getElementById('shuffleButton').addEventListener('click', startShuffle);

    // Auto-save every 30 seconds
    setInterval(saveGame, 30000);

    // Track time played
    setInterval(() => {
        gameState.stats.timePlayed++;
    }, 1000);
}

function createDeck() {
    const deck = [];
    const currentDeckSize = Math.max(5, gameState.deckSize);

    // Calculate luck bonus with prestige modifier
    const prestigeBonus = gameState.prestigeLevel * 0.02;
    const luckBonus = (gameState.upgrades.luck.level * gameState.upgrades.luck.effect) + prestigeBonus;
    const correctCardCopies = 1 + Math.floor(luckBonus * 10);

    // Add hearts royal flush cards that haven't been found
    for (const card of royalCards) {
        if (!gameState.royalFlush[card].found) {
            for (let i = 0; i < correctCardCopies; i++) {
                deck.push({ rank: card, suit: 'hearts' });
            }
        }
    }

    // Fill rest with random cards
    const allRanks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    while (deck.length < currentDeckSize) {
        const randomSuit = suits[Math.floor(Math.random() * suits.length)];
        const randomRank = allRanks[Math.floor(Math.random() * allRanks.length)];

        // Apply suit filter upgrade
        const suitFilterChance = gameState.upgrades.suitFilter.level * gameState.upgrades.suitFilter.effect;
        if (Math.random() < suitFilterChance) {
            deck.push({ rank: randomRank, suit: 'hearts' });
        } else {
            deck.push({ rank: randomRank, suit: randomSuit });
        }
    }

    return deck;
}

function startShuffle() {
    if (gameState.isShuffling || gameState.cardsLaidOut) return;

    // Initialize audio on first interaction
    if (!audioContext) initAudio();

    gameState.isShuffling = true;
    document.getElementById('shuffleButton').disabled = true;

    playSound('shuffle');

    // Calculate shuffle time
    const baseTime = 1;
    const speedReduction = gameState.upgrades.shuffleSpeed.level * gameState.upgrades.shuffleSpeed.effect;
    const shuffleTime = Math.max(0.1, baseTime - speedReduction);

    // Show shuffle animation
    const shuffleArea = document.getElementById('cardSelectionArea');
    shuffleArea.innerHTML = '<div class="shuffling-animation">SHUFFLING...</div>';

    setTimeout(() => {
        gameState.isShuffling = false;
        gameState.cardsLaidOut = true;
        layOutCards();
    }, shuffleTime * 1000);
}

function layOutCards() {
    const deck = createDeck();
    const selectionArea = document.getElementById('cardSelectionArea');
    selectionArea.innerHTML = '';
    selectionArea.className = 'card-selection-area';

    // Show 5 random cards from deck
    const cardsToShow = 5;
    const selectedCards = [];

    for (let i = 0; i < cardsToShow; i++) {
        const randomIndex = Math.floor(Math.random() * deck.length);
        selectedCards.push(deck.splice(randomIndex, 1)[0]);
    }

    selectedCards.forEach((card, index) => {
        const cardEl = document.createElement('div');
        cardEl.className = 'selectable-card';
        cardEl.innerHTML = `<div class="card-back-small">?</div>`;
        cardEl.dataset.rank = card.rank;
        cardEl.dataset.suit = card.suit;
        cardEl.addEventListener('click', () => selectCard(card, cardEl));

        setTimeout(() => {
            selectionArea.appendChild(cardEl);
        }, index * 100);
    });
}

function selectCard(card, cardElement) {
    if (!gameState.cardsLaidOut) return;

    gameState.cardsLaidOut = false;
    gameState.draws++;
    gameState.stats.totalDraws++;

    playSound('flip');

    // Flip the card
    cardElement.innerHTML = `
        <div class="card-display ${card.suit}">
            <div class="card-rank">${card.rank}</div>
            <div class="card-suit">${suitSymbols[card.suit]}</div>
        </div>
    `;

    // Check result after flip animation
    setTimeout(() => {
        checkCardResult(card, cardElement);

        // Clear selection area
        setTimeout(() => {
            document.getElementById('cardSelectionArea').innerHTML = '';
            document.getElementById('shuffleButton').disabled = false;
        }, 1500);
    }, 500);
}

function checkCardResult(card, cardElement) {
    const isRoyalCard = royalCards.includes(card.rank);
    const isHearts = card.suit === 'hearts';
    const cardNotFound = isRoyalCard && !gameState.royalFlush[card.rank].found;

    if (cardNotFound && isHearts) {
        // Found a needed hearts royal card!
        gameState.royalFlush[card.rank].found = true;
        gameState.royalFlush[card.rank].suit = 'hearts';
        gameState.combo++;
        gameState.stats.cardsCollected++;
        gameState.stats.currentStreak++;

        if (gameState.combo > gameState.stats.highestCombo) {
            gameState.stats.highestCombo = gameState.combo;
        }
        if (gameState.stats.currentStreak > gameState.stats.bestStreak) {
            gameState.stats.bestStreak = gameState.stats.currentStreak;
        }

        // Calculate multiplier with prestige bonus
        const baseMultiplier = gameState.combo;
        const bonusMultiplier = gameState.upgrades.multiplierBoost.level * gameState.upgrades.multiplierBoost.effect;
        const prestigeMultiplier = gameState.prestigeLevel * 0.1;
        const totalMultiplier = baseMultiplier + bonusMultiplier + prestigeMultiplier;

        // Base money with lucky charm boost
        const baseMoney = 10 + (gameState.upgrades.moneyBoost.level * gameState.upgrades.moneyBoost.effect);
        const moneyEarned = Math.floor(baseMoney * totalMultiplier);

        const oldMoney = gameState.money;
        gameState.money += moneyEarned;
        gameState.lifetimeMoney += moneyEarned;
        gameState.stats.totalMoney += moneyEarned;

        animateMoney(oldMoney, gameState.money);
        playSound('coin');

        // Create particles at card position
        const rect = cardElement.getBoundingClientRect();
        createParticles(rect.left + rect.width / 2, rect.top + rect.height / 2, 'win');

        showResult('success', `${card.rank}${suitSymbols['hearts']} found! ${totalMultiplier.toFixed(1)}x COMBO! +$${moneyEarned}`);
        updateRoyalFlushDisplay();
        highlightNextTarget();

        // Check if royal flush is complete
        if (checkWinCondition()) {
            gameState.totalWins++;
            gameState.stats.totalWins++;
            gameState.stats.gamesPlayed++;

            // Check speedrun achievement
            if (gameState.draws <= 20) {
                unlockAchievement('speedrun');
            }

            setTimeout(() => {
                playSound('win');
                showWinModal();
            }, 1000);
        }

        checkAchievements();
    } else {
        // Wrong card
        gameState.combo = 0;
        gameState.stats.wrongCards++;
        gameState.stats.currentStreak = 0;

        resetCollectedCards();
        screenShake();
        playSound('fail');

        const cardName = `${card.rank}${suitSymbols[card.suit]}`;
        showResult('fail', `Wrong card (${cardName})! All progress lost!`);
        highlightNextTarget();
    }

    updateUI();
    renderUpgrades();
    saveGame();
}

function resetCollectedCards() {
    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;
    }
    resetRoyalFlushDisplay();
}

function resetRoyalFlushDisplay() {
    for (const card of royalCards) {
        const cardSlot = document.querySelector(`[data-card="${card}"]`);
        if (cardSlot) {
            cardSlot.className = 'card-slot empty';
            cardSlot.textContent = card;
        }
    }
    highlightNextTarget();
}

function showResult(type, message) {
    const resultElement = document.getElementById('drawResult');
    resultElement.className = `draw-result ${type}`;
    resultElement.textContent = message;
}

function updateRoyalFlushDisplay() {
    for (const card of royalCards) {
        const cardSlot = document.querySelector(`[data-card="${card}"]`);
        if (gameState.royalFlush[card].found) {
            const suit = gameState.royalFlush[card].suit;
            cardSlot.classList.remove('empty');
            cardSlot.classList.add('filled', suit);

            let cardHTML = '';
            if (card === 'J') {
                cardHTML = `
                    <div class="card-art card-art-jack">
                        <div class="card-crown">♔</div>
                        <div class="card-face">J</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                    </div>
                `;
            } else if (card === 'Q') {
                cardHTML = `
                    <div class="card-art card-art-queen">
                        <div class="card-crown">♕</div>
                        <div class="card-face">Q</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                    </div>
                `;
            } else if (card === 'K') {
                cardHTML = `
                    <div class="card-art card-art-king">
                        <div class="card-crown">♚</div>
                        <div class="card-face">K</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                    </div>
                `;
            } else if (card === 'A') {
                cardHTML = `
                    <div class="card-art card-art-ace">
                        <div class="card-face" style="font-size: 2.5em;">A</div>
                        <div style="font-size: 1.2em; margin-top: 5px;">${suitSymbols[suit]}</div>
                    </div>
                `;
            } else {
                cardHTML = `
                    <div>${card}</div>
                    <div style="font-size: 0.8em;">${suitSymbols[suit]}</div>
                `;
            }

            cardSlot.innerHTML = cardHTML;
        }
    }
}

function checkWinCondition() {
    return royalCards.every(card => gameState.royalFlush[card].found);
}

function showWinModal() {
    const modal = document.getElementById('winModal');
    const modalContent = modal.querySelector('.modal-content');

    modalContent.innerHTML = '';

    // Add win animation
    const animationDiv = document.createElement('div');
    animationDiv.className = 'win-animation';

    // Create infinite tables
    const tablesDiv = document.createElement('div');
    tablesDiv.className = 'infinite-tables';

    for (let row = 0; row < 50; row++) {
        const tableRow = document.createElement('div');
        tableRow.className = 'table-row';
        const table = document.createElement('div');
        table.className = 'mini-table';
        tableRow.appendChild(table);
        tablesDiv.appendChild(tableRow);
    }

    animationDiv.appendChild(tablesDiv);

    // EXIT sign progression
    const progression = Math.min(gameState.totalWins / 15, 1);

    if (gameState.totalWins >= 15) {
        const exitDoor = document.createElement('div');
        exitDoor.className = 'exit-door';
        animationDiv.appendChild(exitDoor);
    } else {
        const exitSign = document.createElement('div');
        exitSign.className = 'exit-sign';
        exitSign.textContent = 'EXIT';

        const fontSize = 1 + (progression * 7);
        const topPosition = 5 + (progression * 15);

        exitSign.style.fontSize = fontSize + 'em';
        exitSign.style.top = topPosition + '%';

        animationDiv.appendChild(exitSign);
    }

    modalContent.appendChild(animationDiv);

    // Add Play Again button
    const buttonContainer = document.createElement('div');
    buttonContainer.className = 'modal-buttons';
    buttonContainer.innerHTML = `
        <button id="playAgainButton" class="btn btn-primary">Play Again</button>
        ${canPrestige() ? `<button id="prestigeButton" class="btn btn-prestige">Prestige (+${getPrestigePoints()} pts)</button>` : ''}
    `;
    modalContent.appendChild(buttonContainer);

    modal.classList.add('show');

    // Attach event listeners
    document.getElementById('playAgainButton').addEventListener('click', () => {
        modal.classList.remove('show');
        resetForNewRound();
    });

    const prestigeBtn = document.getElementById('prestigeButton');
    if (prestigeBtn) {
        prestigeBtn.addEventListener('click', () => {
            modal.classList.remove('show');
            prestige();
        });
    }

    // Create celebration particles
    for (let i = 0; i < 5; i++) {
        setTimeout(() => {
            createParticles(
                Math.random() * window.innerWidth,
                Math.random() * window.innerHeight,
                'win'
            );
        }, i * 200);
    }
}

function resetForNewRound() {
    // Reset only the current round, keep money and upgrades
    gameState.draws = 0;
    gameState.combo = 0;

    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;
    }

    gameState.isShuffling = false;
    gameState.cardsLaidOut = false;

    document.getElementById('cardSelectionArea').innerHTML = '';
    document.getElementById('shuffleButton').disabled = false;
    document.getElementById('drawResult').textContent = '';

    resetRoyalFlushDisplay();
    updateUI();
    saveGame();
}

function resetGame() {
    // Full game reset
    gameState.draws = 0;
    gameState.money = 50 + (gameState.prestigeLevel * 25);
    gameState.deckSize = 52;
    gameState.combo = 0;
    gameState.totalWins = 0;
    gameState.hasDog = false;

    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;
    }

    for (const upgrade of Object.values(gameState.upgrades)) {
        upgrade.level = 0;
    }

    const existingDog = document.getElementById('dog');
    if (existingDog) existingDog.remove();

    gameState.isShuffling = false;
    gameState.cardsLaidOut = false;

    document.getElementById('winModal').classList.remove('show');
    document.getElementById('cardSelectionArea').innerHTML = '';
    document.getElementById('shuffleButton').disabled = false;
    document.getElementById('drawResult').textContent = '';

    resetRoyalFlushDisplay();
    updateUI();
    renderUpgrades();
    saveGame();
}

// ============================================
// UI FUNCTIONS
// ============================================
function updateUI() {
    document.getElementById('draws').textContent = gameState.draws;
    document.getElementById('deckSize').textContent = Math.max(5, gameState.deckSize);
    document.getElementById('money').textContent = `$${gameState.money}`;

    // Update combo display
    const comboElement = document.getElementById('combo');
    if (comboElement) {
        if (gameState.combo > 0) {
            const multiplier = gameState.combo +
                (gameState.upgrades.multiplierBoost.level * gameState.upgrades.multiplierBoost.effect) +
                (gameState.prestigeLevel * 0.1);
            comboElement.textContent = `${multiplier.toFixed(1)}x`;
        } else {
            comboElement.textContent = '-';
        }
    }

    // Update prestige display if exists
    const prestigeElement = document.getElementById('prestigeLevel');
    if (prestigeElement) {
        prestigeElement.textContent = gameState.prestigeLevel;
    }
}

function renderUpgrades() {
    const upgradesGrid = document.getElementById('upgradesGrid');
    upgradesGrid.innerHTML = '';

    for (const [key, upgrade] of Object.entries(gameState.upgrades)) {
        // Apply prestige discount
        const prestigeDiscount = 1 - (gameState.prestigeLevel * 0.05);
        const cost = Math.floor(upgrade.baseCost * Math.pow(1.5, upgrade.level) * prestigeDiscount);
        const canAfford = gameState.money >= cost;
        const maxed = upgrade.level >= upgrade.maxLevel;
        const progress = (upgrade.level / upgrade.maxLevel) * 100;

        const upgradeCard = document.createElement('div');
        upgradeCard.className = 'upgrade-card';

        if (maxed) {
            upgradeCard.classList.add('maxed');
        } else if (!canAfford) {
            upgradeCard.classList.add('locked');
        }

        upgradeCard.innerHTML = `
            <h3>${upgrade.name}</h3>
            <p>${upgrade.description}</p>
            <div class="upgrade-progress-bar">
                <div class="upgrade-progress-fill" style="width: ${progress}%"></div>
            </div>
            <div class="upgrade-info">
                <span class="upgrade-level">${upgrade.level}/${upgrade.maxLevel}</span>
                <span class="upgrade-cost">${maxed ? 'MAXED' : '$' + cost}</span>
            </div>
        `;

        if (!maxed && canAfford) {
            upgradeCard.addEventListener('click', () => purchaseUpgrade(key));
        }

        upgradesGrid.appendChild(upgradeCard);
    }
}

function updateAchievementsDisplay() {
    const achievementsList = document.getElementById('achievementsList');
    if (!achievementsList) return;

    achievementsList.innerHTML = '';

    for (const [key, achievement] of Object.entries(gameState.achievements)) {
        const item = document.createElement('div');
        item.className = `achievement-item ${achievement.unlocked ? 'unlocked' : 'locked'}`;
        item.innerHTML = `
            <span class="achievement-icon">${achievement.icon}</span>
            <div class="achievement-info">
                <div class="achievement-name">${achievement.name}</div>
                <div class="achievement-desc">${achievement.description}</div>
            </div>
        `;
        achievementsList.appendChild(item);
    }
}

function purchaseUpgrade(upgradeKey) {
    const upgrade = gameState.upgrades[upgradeKey];
    const prestigeDiscount = 1 - (gameState.prestigeLevel * 0.05);
    const cost = Math.floor(upgrade.baseCost * Math.pow(1.5, upgrade.level) * prestigeDiscount);

    if (gameState.money >= cost && upgrade.level < upgrade.maxLevel) {
        gameState.money -= cost;
        upgrade.level++;

        playSound('coin');

        // Apply upgrade effects
        if (upgradeKey === 'deckReduction') {
            gameState.deckSize -= upgrade.effect;
        } else if (upgradeKey === 'dog') {
            gameState.hasDog = true;
            spawnDog();
            unlockAchievement('dogOwner');
        }

        checkAchievements();
        updateUI();
        renderUpgrades();
        saveGame();
    }
}

// ============================================
// DOG MECHANICS
// ============================================
let dogElement = null;
let dogPosition = { x: 100, y: 0 };
let dogVelocity = { x: 2, y: 0 };
let dogAnimationFrame = null;
let dogFrame = 0;
let dogFrameCounter = 0;

function spawnDog() {
    const existingDog = document.getElementById('dog');
    if (existingDog) existingDog.remove();

    // Set Y position based on window height
    dogPosition.y = window.innerHeight - 100;

    dogElement = document.createElement('div');
    dogElement.id = 'dog';
    dogElement.className = 'dog-sprite';
    dogElement.style.left = dogPosition.x + 'px';
    dogElement.style.top = dogPosition.y + 'px';
    dogElement.style.backgroundImage = 'url(assets/dog-sprite.svg)';
    dogElement.style.backgroundPosition = '0 0';

    dogElement.addEventListener('click', petDog);

    document.body.appendChild(dogElement);
    animateDog();
}

function animateDog() {
    if (!gameState.hasDog || !dogElement) return;

    dogPosition.x += dogVelocity.x;

    const maxX = window.innerWidth - 80;
    if (dogPosition.x <= 0 || dogPosition.x >= maxX) {
        dogVelocity.x *= -1;
        if (dogElement) {
            dogElement.style.transform = dogVelocity.x > 0 ? 'scaleX(1)' : 'scaleX(-1)';
        }
    }

    if (Math.random() < 0.01) {
        dogVelocity.x = (Math.random() - 0.5) * 4;
    }

    dogFrameCounter++;
    if (dogFrameCounter >= 8) {
        dogFrameCounter = 0;
        dogFrame = (dogFrame + 1) % 4;
        if (dogElement && !dogElement.classList.contains('happy')) {
            dogElement.style.backgroundPosition = `-${dogFrame * 64}px 0`;
        }
    }

    if (dogElement) {
        dogElement.style.left = dogPosition.x + 'px';
        dogElement.style.top = dogPosition.y + 'px';
    }

    dogAnimationFrame = requestAnimationFrame(animateDog);
}

function petDog() {
    if (!dogElement) return;

    const heart = document.createElement('div');
    heart.className = 'dog-heart';
    heart.innerHTML = '❤️';
    heart.style.left = (dogPosition.x + 30) + 'px';
    heart.style.top = (dogPosition.y - 20) + 'px';
    document.body.appendChild(heart);

    dogElement.classList.add('happy');
    dogElement.style.backgroundPosition = '-256px 0';

    setTimeout(() => {
        if (dogElement) {
            dogElement.classList.remove('happy');
            dogElement.style.backgroundPosition = `-${dogFrame * 64}px 0`;
        }
    }, 800);

    setTimeout(() => heart.remove(), 1000);
}

// ============================================
// INITIALIZE GAME
// ============================================
document.addEventListener('DOMContentLoaded', initGame);
