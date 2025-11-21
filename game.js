// Game State
const gameState = {
    draws: 0,
    money: 100000,
    deckSize: 52,
    combo: 0, // Tracks consecutive correct cards
    totalWins: 0, // Track total wins for EXIT sign progression
    royalFlush: {
        '10': { found: false, suit: null },
        'J': { found: false, suit: null },
        'Q': { found: false, suit: null },
        'K': { found: false, suit: null },
        'A': { found: false, suit: null }
    },
    targetSuit: 'hearts', // ONLY hearts are allowed
    currentCard: null,
    hasDog: false,
    isShuffling: false,
    cardsLaidOut: false,
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
            baseCost: 20,
            effect: 0.2
        },
        luck: {
            name: "Lady Luck",
            description: "Increase chance of correct card appearing",
            level: 0,
            maxLevel: 7,
            baseCost: 20,
            effect: 0.1
        },
        suitFilter: {
            name: "Suit Converter",
            description: "Convert random cards to hearts",
            level: 0,
            maxLevel: 5,
            baseCost: 20,
            effect: 0.05
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
            description: "Increase combo multiplier by 0.5x",
            level: 0,
            maxLevel: 10,
            baseCost: 20,
            effect: 0.5
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

// Initialize game
function initGame() {
    updateUI();
    renderUpgrades();

    document.getElementById('shuffleButton').addEventListener('click', startShuffle);
    document.getElementById('playAgainButton').addEventListener('click', resetGame);
}

// Create a deck
function createDeck() {
    const deck = [];
    const currentDeckSize = Math.max(5, gameState.deckSize);

    // Calculate luck bonus - adds more correct cards to the deck
    const luckBonus = gameState.upgrades.luck.level * gameState.upgrades.luck.effect;
    const correctCardCopies = 1 + Math.floor(luckBonus * 10); // Each 10% luck = 1 extra copy

    // Add hearts royal flush cards that haven't been found (with luck bonus)
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

        // Apply suit filter upgrade - convert to hearts
        const suitFilterChance = gameState.upgrades.suitFilter.level * gameState.upgrades.suitFilter.effect;
        if (Math.random() < suitFilterChance) {
            deck.push({ rank: randomRank, suit: 'hearts' });
        } else {
            deck.push({ rank: randomRank, suit: randomSuit });
        }
    }

    return deck;
}

// Start shuffle animation
function startShuffle() {
    if (gameState.isShuffling || gameState.cardsLaidOut) return;

    gameState.isShuffling = true;
    document.getElementById('shuffleButton').disabled = true;

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

// Lay out cards for selection
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

// Select a card
function selectCard(card, cardElement) {
    if (!gameState.cardsLaidOut) return;

    gameState.cardsLaidOut = false;
    gameState.draws++;

    // Flip the card
    cardElement.innerHTML = `
        <div class="card-display ${card.suit}">
            <div class="card-rank">${card.rank}</div>
            <div class="card-suit">${suitSymbols[card.suit]}</div>
        </div>
    `;

    // Check result after flip animation
    setTimeout(() => {
        checkCardResult(card);

        // Clear selection area
        setTimeout(() => {
            document.getElementById('cardSelectionArea').innerHTML = '';
            document.getElementById('shuffleButton').disabled = false;
        }, 1500);
    }, 500);
}

// Check card result
function checkCardResult(card) {
    const isRoyalCard = royalCards.includes(card.rank);
    const isHearts = card.suit === 'hearts';
    const cardNotFound = isRoyalCard && !gameState.royalFlush[card.rank].found;

    if (cardNotFound && isHearts) {
        // Found a needed hearts royal card!
        gameState.royalFlush[card.rank].found = true;
        gameState.royalFlush[card.rank].suit = 'hearts';
        gameState.combo++; // Increase combo counter

        // Calculate multiplier: base is combo count (1x, 2x, 3x, etc.)
        // Plus multiplier boost upgrade adds 0.5x per level
        const baseMultiplier = gameState.combo;
        const bonusMultiplier = gameState.upgrades.multiplierBoost.level * gameState.upgrades.multiplierBoost.effect;
        const totalMultiplier = baseMultiplier + bonusMultiplier;

        // Base money with lucky charm boost
        const baseMoney = 10 + (gameState.upgrades.moneyBoost.level * gameState.upgrades.moneyBoost.effect);
        const moneyEarned = Math.floor(baseMoney * totalMultiplier);

        gameState.money += moneyEarned;

        showResult('success', `Amazing! ${card.rank}${suitSymbols['hearts']} found! ${totalMultiplier}x COMBO! +$${moneyEarned}`);
        updateRoyalFlushDisplay();

        // Check if royal flush is complete
        if (checkWinCondition()) {
            setTimeout(showWinModal, 1000);
        }
    } else {
        // Wrong card - RESET all collected cards!
        gameState.combo = 0; // Reset combo
        resetCollectedCards();
        showResult('fail', `Wrong card! All progress lost! Combo reset!`);
    }

    updateUI();
    renderUpgrades();
}

// Reset all collected cards
function resetCollectedCards() {
    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;

        // Reset UI
        const cardSlot = document.querySelector(`[data-card="${card}"]`);
        if (cardSlot) {
            cardSlot.className = 'card-slot empty';
            cardSlot.textContent = card;
        }
    }
}

// Display the drawn card
function displayCard(card) {
    const cardElement = document.getElementById('currentCard');
    cardElement.innerHTML = `
        <div class="card-display ${card.suit}">
            <div class="card-rank">${card.rank}</div>
            <div class="card-suit">${suitSymbols[card.suit]}</div>
        </div>
    `;
}

// Show draw result message
function showResult(type, message) {
    const resultElement = document.getElementById('drawResult');
    resultElement.className = `draw-result ${type}`;
    resultElement.textContent = message;
}

// Update royal flush display
function updateRoyalFlushDisplay() {
    for (const card of royalCards) {
        const cardSlot = document.querySelector(`[data-card="${card}"]`);
        if (gameState.royalFlush[card].found) {
            const suit = gameState.royalFlush[card].suit;
            cardSlot.classList.remove('empty');
            cardSlot.classList.add('filled', suit);

            // Create detailed card art for face cards
            let cardHTML = '';
            if (card === 'J') {
                cardHTML = `
                    <div class="card-art card-art-jack">
                        <div class="card-crown">♔</div>
                        <div class="card-face">J</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                        <div class="card-details"></div>
                    </div>
                `;
            } else if (card === 'Q') {
                cardHTML = `
                    <div class="card-art card-art-queen">
                        <div class="card-crown">♕</div>
                        <div class="card-face">Q</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                        <div class="card-details"></div>
                    </div>
                `;
            } else if (card === 'K') {
                cardHTML = `
                    <div class="card-art card-art-king">
                        <div class="card-crown">♚</div>
                        <div class="card-face">K</div>
                        <div style="font-size: 0.6em; margin-top: 5px;">${suitSymbols[suit]}</div>
                        <div class="card-details"></div>
                    </div>
                `;
            } else if (card === 'A') {
                cardHTML = `
                    <div class="card-art card-art-ace">
                        <div class="card-face" style="font-size: 2.5em;">A</div>
                        <div style="font-size: 1.2em; margin-top: 5px;">${suitSymbols[suit]}</div>
                        <div class="card-details"></div>
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

// Check win condition
function checkWinCondition() {
    return royalCards.every(card => gameState.royalFlush[card].found);
}

// Show win modal
function showWinModal() {
    gameState.totalWins++;

    const modal = document.getElementById('winModal');
    const modalContent = modal.querySelector('.modal-content');

    // Clear any existing content
    modalContent.innerHTML = '';

    // Add win animation
    const animationDiv = document.createElement('div');
    animationDiv.className = 'win-animation';

    // Create infinite tables stretching into distance
    const tablesDiv = document.createElement('div');
    tablesDiv.className = 'infinite-tables';

    // More tables for a longer perspective
    for (let row = 0; row < 50; row++) {
        const tableRow = document.createElement('div');
        tableRow.className = 'table-row';
        // Create a single line of tables stretching forward
        const numTables = 1;

        for (let i = 0; i < numTables; i++) {
            const table = document.createElement('div');
            table.className = 'mini-table';
            tableRow.appendChild(table);
        }
        tablesDiv.appendChild(tableRow);
    }

    animationDiv.appendChild(tablesDiv);

    // Calculate EXIT sign progression (gets closer every win, maxes at 15 wins)
    const progression = Math.min(gameState.totalWins / 15, 1);

    if (gameState.totalWins >= 15) {
        // Show full door at 15 wins
        const exitDoor = document.createElement('div');
        exitDoor.className = 'exit-door';
        animationDiv.appendChild(exitDoor);
    } else {
        // Show progressively larger EXIT sign
        const exitSign = document.createElement('div');
        exitSign.className = 'exit-sign';
        exitSign.textContent = 'EXIT';

        // Calculate size and position based on progression
        const fontSize = 1 + (progression * 7); // From 1em to 8em
        const topPosition = 5 + (progression * 15); // From 5% to 20%
        const scale = 0.1 + (progression * 0.9); // From 0.1 to 1.0

        exitSign.style.fontSize = fontSize + 'em';
        exitSign.style.top = topPosition + '%';
        exitSign.style.setProperty('--target-scale', scale);

        animationDiv.appendChild(exitSign);
    }

    modalContent.appendChild(animationDiv);

    modal.classList.add('show');
}

// Update UI
function updateUI() {
    document.getElementById('draws').textContent = gameState.draws;
    document.getElementById('deckSize').textContent = Math.max(5, gameState.deckSize);
    document.getElementById('money').textContent = `$${gameState.money}`;

    // Update combo display
    const comboElement = document.getElementById('combo');
    if (comboElement) {
        const multiplier = gameState.combo + (gameState.upgrades.multiplierBoost.level * gameState.upgrades.multiplierBoost.effect);
        comboElement.textContent = gameState.combo > 0 ? `${multiplier.toFixed(1)}x` : '-';
    }
}

// Render upgrades
function renderUpgrades() {
    const upgradesGrid = document.getElementById('upgradesGrid');
    upgradesGrid.innerHTML = '';

    for (const [key, upgrade] of Object.entries(gameState.upgrades)) {
        const cost = Math.floor(upgrade.baseCost * Math.pow(1.5, upgrade.level));
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
                <span class="upgrade-cost">${maxed ? 'MAXED' : '$' + cost}</span>
            </div>
        `;

        if (!maxed && canAfford) {
            upgradeCard.addEventListener('click', () => purchaseUpgrade(key));
        }

        upgradesGrid.appendChild(upgradeCard);
    }
}

// Purchase upgrade
function purchaseUpgrade(upgradeKey) {
    const upgrade = gameState.upgrades[upgradeKey];
    const cost = Math.floor(upgrade.baseCost * Math.pow(1.5, upgrade.level));

    if (gameState.money >= cost && upgrade.level < upgrade.maxLevel) {
        gameState.money -= cost;
        upgrade.level++;

        // Apply upgrade effects
        if (upgradeKey === 'deckReduction') {
            gameState.deckSize -= upgrade.effect;
        } else if (upgradeKey === 'dog') {
            gameState.hasDog = true;
            spawnDog();
        }

        updateUI();
        renderUpgrades();
    }
}

// Reset game
function resetGame() {
    gameState.draws = 0;
    gameState.money = 0;
    gameState.deckSize = 52;
    gameState.combo = 0;
    gameState.targetSuit = 'hearts';
    gameState.currentCard = null;
    gameState.hasDog = false;

    for (const card of royalCards) {
        gameState.royalFlush[card].found = false;
        gameState.royalFlush[card].suit = null;
    }

    for (const upgrade of Object.values(gameState.upgrades)) {
        upgrade.level = 0;
    }

    // Remove dog if exists
    const existingDog = document.getElementById('dog');
    if (existingDog) {
        existingDog.remove();
    }

    gameState.isShuffling = false;
    gameState.cardsLaidOut = false;

    document.getElementById('winModal').classList.remove('show');
    document.getElementById('cardSelectionArea').innerHTML = '';
    document.getElementById('shuffleButton').disabled = false;
    document.getElementById('drawResult').textContent = '';

    // Reset royal flush display
    for (const card of royalCards) {
        const cardSlot = document.querySelector(`[data-card="${card}"]`);
        cardSlot.className = 'card-slot empty';
        cardSlot.textContent = card;
    }

    updateUI();
    renderUpgrades();
}

// DOG MECHANICS
let dogElement = null;
let dogPosition = { x: 100, y: 300 };
let dogVelocity = { x: 2, y: 0 };
let dogAnimationFrame = null;
let dogFrame = 0;
let dogFrameCounter = 0;

function spawnDog() {
    // Remove existing dog if any
    const existingDog = document.getElementById('dog');
    if (existingDog) {
        existingDog.remove();
    }

    // Create dog element with sprite background
    dogElement = document.createElement('div');
    dogElement.id = 'dog';
    dogElement.className = 'dog-sprite';
    dogElement.style.left = dogPosition.x + 'px';
    dogElement.style.top = dogPosition.y + 'px';
    dogElement.style.backgroundImage = 'url(assets/dog-sprite.svg)';
    dogElement.style.backgroundPosition = '0 0';

    // Add click handler for petting
    dogElement.addEventListener('click', petDog);

    document.body.appendChild(dogElement);

    // Start animation
    animateDog();
}

function animateDog() {
    if (!gameState.hasDog) return;

    // Update position
    dogPosition.x += dogVelocity.x;

    // Bounce off edges
    const maxX = window.innerWidth - 80;
    if (dogPosition.x <= 0 || dogPosition.x >= maxX) {
        dogVelocity.x *= -1;
        // Flip dog direction
        if (dogElement) {
            dogElement.style.transform = dogVelocity.x > 0 ? 'scaleX(1)' : 'scaleX(-1)';
        }
    }

    // Random direction changes
    if (Math.random() < 0.01) {
        dogVelocity.x = (Math.random() - 0.5) * 4;
    }

    // Update walk animation frame
    dogFrameCounter++;
    if (dogFrameCounter >= 8) {
        dogFrameCounter = 0;
        dogFrame = (dogFrame + 1) % 4; // Cycle through frames 0-3 for walking
        if (dogElement && !dogElement.classList.contains('happy')) {
            dogElement.style.backgroundPosition = `-${dogFrame * 64}px 0`;
        }
    }

    // Update DOM
    if (dogElement) {
        dogElement.style.left = dogPosition.x + 'px';
        dogElement.style.top = dogPosition.y + 'px';
    }

    dogAnimationFrame = requestAnimationFrame(animateDog);
}

function petDog() {
    if (!dogElement) return;

    // Show heart animation
    const heart = document.createElement('div');
    heart.className = 'dog-heart';
    heart.innerHTML = '❤️';
    heart.style.left = (dogPosition.x + 30) + 'px';
    heart.style.top = (dogPosition.y - 20) + 'px';
    document.body.appendChild(heart);

    // Dog happy animation - show frame 5 (happy pose)
    dogElement.classList.add('happy');
    dogElement.style.backgroundPosition = '-256px 0';

    setTimeout(() => {
        if (dogElement) {
            dogElement.classList.remove('happy');
            // Return to normal walk cycle
            dogElement.style.backgroundPosition = `-${dogFrame * 64}px 0`;
        }
    }, 800);

    // Remove heart after animation
    setTimeout(() => {
        heart.remove();
    }, 1000);
}

// Start the game
initGame();
