extends Node

# Royal Rush 3D - Game State Autoload
# Manages all game state, save/load, and core game logic

signal money_changed(old_value: int, new_value: int)
signal combo_changed(value: int)
signal card_collected(card: String)
signal card_reset()
signal win_achieved()
signal achievement_unlocked(key: String, achievement: Dictionary)
signal upgrade_purchased(key: String)
signal prestige_completed(level: int)
signal notification_requested(message: String)
signal secret_discovered(secret: String)
signal tier_unlocked(tier: int)
signal perfect_round_achieved()

# Core gameplay
var draws: int = 0
var money: int = 50
var deck_size: int = 52
var combo: int = 0
var total_wins: int = 0

# Story mode - Casino Tiers
var current_tier: int = 1
var tier_progress: int = 0
const TIER_NAMES: Array = ["", "Street Corner", "Back Alley", "Underground", "The Velvet Room", "High Stakes", "VIP Lounge", "The Penthouse", "Royal Suite"]
const TIER_REQUIREMENTS: Array = [0, 0, 5, 15, 30, 50, 100, 200, 500]  # Wins needed

# New mechanics
var mulligan_available: bool = true
var peek_uses: int = 0
var insurance_active: bool = false
var golden_touch_proc: bool = false
var perfect_round: bool = true  # No wrong cards this round
var win_streak: int = 0
var dog_pets: int = 0

# Secrets
var secrets_discovered: Array = []
var konami_progress: int = 0
var secret_mode_active: bool = false

# Royal flush tracking
var royal_flush: Dictionary = {
	"10": {"found": false, "suit": null},
	"J": {"found": false, "suit": null},
	"Q": {"found": false, "suit": null},
	"K": {"found": false, "suit": null},
	"A": {"found": false, "suit": null}
}

var target_suit: String = "hearts"
var has_dog: bool = false
var is_shuffling: bool = false
var cards_laid_out: bool = false

# Prestige system
var prestige_level: int = 0
var prestige_points: int = 0
var lifetime_money: int = 0

# Statistics
var stats: Dictionary = {
	"total_draws": 0,
	"total_wins": 0,
	"total_money": 0,
	"highest_combo": 0,
	"cards_collected": 0,
	"wrong_cards": 0,
	"current_streak": 0,
	"best_streak": 0,
	"time_played": 0,
	"games_played": 0
}

# Daily bonus
var last_daily_bonus: String = ""
var daily_bonus_streak: int = 0

# Achievements
var achievements: Dictionary = {
	"first_win": {"name": "First Victory", "description": "Win your first Royal Flush", "unlocked": false, "icon": "trophy"},
	"combo5": {"name": "Perfect Hand", "description": "Get a 5x combo", "unlocked": false, "icon": "fire"},
	"rich": {"name": "High Roller", "description": "Have $10,000 at once", "unlocked": false, "icon": "money"},
	"draws100": {"name": "Card Sharp", "description": "Draw 100 cards", "unlocked": false, "icon": "cards"},
	"draws1000": {"name": "Card Master", "description": "Draw 1,000 cards", "unlocked": false, "icon": "crown"},
	"wins10": {"name": "Lucky Streak", "description": "Win 10 Royal Flushes", "unlocked": false, "icon": "star"},
	"wins50": {"name": "Flush Master", "description": "Win 50 Royal Flushes", "unlocked": false, "icon": "star_shine"},
	"prestige1": {"name": "Reborn", "description": "Prestige for the first time", "unlocked": false, "icon": "refresh"},
	"prestige5": {"name": "Eternal", "description": "Reach prestige level 5", "unlocked": false, "icon": "infinity"},
	"max_upgrade": {"name": "Maxed Out", "description": "Max out any upgrade", "unlocked": false, "icon": "arrow_up"},
	"daily_streak7": {"name": "Dedicated", "description": "Claim daily bonus 7 days in a row", "unlocked": false, "icon": "calendar"},
	"dog_owner": {"name": "Good Boy", "description": "Get the dog companion", "unlocked": false, "icon": "dog"},
	"speedrun": {"name": "Speed Demon", "description": "Win in under 20 draws", "unlocked": false, "icon": "lightning"},
	"collector": {"name": "Collector", "description": "Collect 100 cards total", "unlocked": false, "icon": "book"},
	# New achievements
	"perfect_round": {"name": "Flawless", "description": "Win without any wrong cards", "unlocked": false, "icon": "diamond"},
	"millionaire": {"name": "Millionaire", "description": "Accumulate $1,000,000 lifetime", "unlocked": false, "icon": "crown"},
	"win_streak5": {"name": "Hot Streak", "description": "Win 5 rounds in a row", "unlocked": false, "icon": "fire"},
	"win_streak10": {"name": "Unstoppable", "description": "Win 10 rounds in a row", "unlocked": false, "icon": "meteor"},
	"tier_max": {"name": "Royal Suite", "description": "Reach the highest casino tier", "unlocked": false, "icon": "castle"},
	"minimalist": {"name": "Minimalist", "description": "Win with no upgrades purchased", "unlocked": false, "icon": "leaf"},
	"risk_taker": {"name": "Risk Taker", "description": "Win with deck size under 20", "unlocked": false, "icon": "dice"},
	"golden_100": {"name": "Midas Touch", "description": "Trigger Golden Touch 100 times", "unlocked": false, "icon": "gold"},
	# Secret achievements
	"secret_dog100": {"name": "Best Friend", "description": "Pet the dog 100 times", "unlocked": false, "icon": "heart", "secret": true},
	"secret_konami": {"name": "Old School", "description": "Enter the classic code", "unlocked": false, "icon": "gamepad", "secret": true},
	"secret_patience": {"name": "Patience", "description": "Wait 10 minutes without playing", "unlocked": false, "icon": "clock", "secret": true}
}

# Upgrades
var upgrades: Dictionary = {
	"deck_reduction": {
		"name": "Deck Trimmer",
		"description": "Remove 4 cards from the deck",
		"level": 0,
		"max_level": 10,
		"base_cost": 20,
		"effect": 4
	},
	"shuffle_speed": {
		"name": "Quick Hands",
		"description": "Reduce shuffle time by 0.2s",
		"level": 0,
		"max_level": 5,
		"base_cost": 25,
		"effect": 0.2
	},
	"luck": {
		"name": "Lady Luck",
		"description": "Increase chance of correct card",
		"level": 0,
		"max_level": 5,
		"base_cost": 30,
		"effect": 0.05
	},
	"suit_filter": {
		"name": "Suit Converter",
		"description": "Convert random cards to hearts",
		"level": 0,
		"max_level": 5,
		"base_cost": 35,
		"effect": 0.04
	},
	"money_boost": {
		"name": "Lucky Charm",
		"description": "Earn more money per correct card",
		"level": 0,
		"max_level": 10,
		"base_cost": 20,
		"effect": 5
	},
	"multiplier_boost": {
		"name": "Combo Master",
		"description": "Increase combo multiplier by 0.3x",
		"level": 0,
		"max_level": 10,
		"base_cost": 40,
		"effect": 0.3
	},
	"dog": {
		"name": "Good Boy",
		"description": "Get an Irish Setter companion",
		"level": 0,
		"max_level": 1,
		"base_cost": 500,
		"effect": 1
	},
	# New upgrades
	"peek": {
		"name": "X-Ray Vision",
		"description": "Peek at cards before choosing (+1 use/level)",
		"level": 0,
		"max_level": 5,
		"base_cost": 100,
		"effect": 1
	},
	"mulligan": {
		"name": "Second Chance",
		"description": "Reshuffle once per round",
		"level": 0,
		"max_level": 1,
		"base_cost": 200,
		"effect": 1
	},
	"golden_touch": {
		"name": "Golden Touch",
		"description": "5% chance per level for 2x money",
		"level": 0,
		"max_level": 10,
		"base_cost": 50,
		"effect": 0.05
	},
	"insurance": {
		"name": "Insurance",
		"description": "Keep one card on wrong pick",
		"level": 0,
		"max_level": 1,
		"base_cost": 300,
		"effect": 1
	},
	"card_counter": {
		"name": "Card Counter",
		"description": "See remaining hearts in deck",
		"level": 0,
		"max_level": 1,
		"base_cost": 150,
		"effect": 1
	},
	"vip_bonus": {
		"name": "VIP Status",
		"description": "+10% money per casino tier",
		"level": 0,
		"max_level": 5,
		"base_cost": 75,
		"effect": 0.1
	}
}

# Constants
const SUITS: Array = ["hearts", "diamonds", "clubs", "spades"]
const SUIT_SYMBOLS: Dictionary = {
	"hearts": "♥",
	"diamonds": "♦",
	"clubs": "♣",
	"spades": "♠"
}
const ROYAL_CARDS: Array = ["10", "J", "Q", "K", "A"]
const ALL_RANKS: Array = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const SAVE_PATH: String = "user://royal_rush_save.json"

func _ready() -> void:
	load_game()

func _process(delta: float) -> void:
	stats["time_played"] += delta

# ============================================
# SAVE/LOAD SYSTEM
# ============================================
func save_game() -> void:
	var save_data: Dictionary = {
		"draws": draws,
		"money": money,
		"deck_size": deck_size,
		"combo": combo,
		"total_wins": total_wins,
		"royal_flush": royal_flush,
		"has_dog": has_dog,
		"prestige_level": prestige_level,
		"prestige_points": prestige_points,
		"lifetime_money": lifetime_money,
		"stats": stats,
		"last_daily_bonus": last_daily_bonus,
		"daily_bonus_streak": daily_bonus_streak,
		"achievements": {},
		"upgrades": {}
	}

	# Save achievement unlock status
	for key in achievements:
		save_data["achievements"][key] = achievements[key]["unlocked"]

	# Save upgrade levels
	for key in upgrades:
		save_data["upgrades"][key] = upgrades[key]["level"]

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return false

	var data: Dictionary = json.data

	draws = data.get("draws", 0)
	money = data.get("money", 50)
	deck_size = data.get("deck_size", 52)
	combo = data.get("combo", 0)
	total_wins = data.get("total_wins", 0)
	royal_flush = data.get("royal_flush", royal_flush)
	has_dog = data.get("has_dog", false)
	prestige_level = data.get("prestige_level", 0)
	prestige_points = data.get("prestige_points", 0)
	lifetime_money = data.get("lifetime_money", 0)
	last_daily_bonus = data.get("last_daily_bonus", "")
	daily_bonus_streak = data.get("daily_bonus_streak", 0)

	# Load stats
	var loaded_stats = data.get("stats", {})
	for key in loaded_stats:
		if stats.has(key):
			stats[key] = loaded_stats[key]

	# Load achievements
	var loaded_achievements = data.get("achievements", {})
	for key in loaded_achievements:
		if achievements.has(key):
			achievements[key]["unlocked"] = loaded_achievements[key]

	# Load upgrades
	var loaded_upgrades = data.get("upgrades", {})
	for key in loaded_upgrades:
		if upgrades.has(key):
			upgrades[key]["level"] = loaded_upgrades[key]

	# Recalculate deck size
	deck_size = 52 - (upgrades["deck_reduction"]["level"] * upgrades["deck_reduction"]["effect"])

	return true

# ============================================
# DECK CREATION
# ============================================
func create_deck() -> Array:
	var deck: Array = []
	var current_deck_size = max(5, deck_size)

	# Calculate luck bonus with prestige modifier
	var prestige_bonus = prestige_level * 0.02
	var luck_bonus = (upgrades["luck"]["level"] * upgrades["luck"]["effect"]) + prestige_bonus
	var correct_card_copies = 1 + int(luck_bonus * 10)

	# Add hearts royal flush cards that haven't been found
	for card in ROYAL_CARDS:
		if not royal_flush[card]["found"]:
			for i in range(correct_card_copies):
				deck.append({"rank": card, "suit": "hearts"})

	# Fill rest with random cards
	while deck.size() < current_deck_size:
		var random_suit = SUITS[randi() % SUITS.size()]
		var random_rank = ALL_RANKS[randi() % ALL_RANKS.size()]

		# Apply suit filter upgrade
		var suit_filter_chance = upgrades["suit_filter"]["level"] * upgrades["suit_filter"]["effect"]
		if randf() < suit_filter_chance:
			deck.append({"rank": random_rank, "suit": "hearts"})
		else:
			deck.append({"rank": random_rank, "suit": random_suit})

	return deck

# ============================================
# CARD RESULT CHECKING
# ============================================
func check_card_result(card: Dictionary) -> Dictionary:
	var is_royal_card = card["rank"] in ROYAL_CARDS
	var is_hearts = card["suit"] == "hearts"
	var card_not_found = is_royal_card and not royal_flush[card["rank"]]["found"]

	var result: Dictionary = {
		"success": false,
		"message": "",
		"money_earned": 0,
		"multiplier": 0.0
	}

	if card_not_found and is_hearts:
		# Found a needed hearts royal card!
		royal_flush[card["rank"]]["found"] = true
		royal_flush[card["rank"]]["suit"] = "hearts"
		combo += 1
		stats["cards_collected"] += 1
		stats["current_streak"] += 1

		if combo > stats["highest_combo"]:
			stats["highest_combo"] = combo
		if stats["current_streak"] > stats["best_streak"]:
			stats["best_streak"] = stats["current_streak"]

		# Calculate multiplier
		var base_multiplier = combo
		var bonus_multiplier = upgrades["multiplier_boost"]["level"] * upgrades["multiplier_boost"]["effect"]
		var prestige_multiplier = prestige_level * 0.1
		var total_multiplier = base_multiplier + bonus_multiplier + prestige_multiplier

		# Calculate money with new bonuses
		var base_money = 10 + (upgrades["money_boost"]["level"] * upgrades["money_boost"]["effect"])
		var tier_bonus = get_tier_bonus()
		var money_earned = int(base_money * total_multiplier * (1 + tier_bonus))

		# Golden Touch check (2x money)
		var golden_triggered = check_golden_touch()
		if golden_triggered:
			money_earned *= 2
			result["golden_touch"] = true

		var old_money = money
		money += money_earned
		lifetime_money += money_earned
		stats["total_money"] += money_earned

		emit_signal("money_changed", old_money, money)
		emit_signal("combo_changed", combo)
		emit_signal("card_collected", card["rank"])

		result["success"] = true
		var msg = "%s%s found! %.1fx COMBO! +$%d" % [card["rank"], SUIT_SYMBOLS["hearts"], total_multiplier, money_earned]
		if golden_triggered:
			msg += " ★GOLDEN★"
		result["message"] = msg
		result["money_earned"] = money_earned
		result["multiplier"] = total_multiplier

		# Check win condition
		if check_win_condition():
			total_wins += 1
			stats["total_wins"] += 1
			stats["games_played"] += 1
			win_streak += 1

			if draws <= 20:
				unlock_achievement("speedrun")

			# Check for perfect round
			if perfect_round:
				unlock_achievement("perfect_round")
				emit_signal("perfect_round_achieved")
				result["perfect"] = true

			# Check for minimalist achievement
			var has_upgrades = false
			for upgrade in upgrades.values():
				if upgrade["level"] > 0:
					has_upgrades = true
					break
			if not has_upgrades:
				unlock_achievement("minimalist")

			# Check tier progression
			check_tier_progress()

			emit_signal("win_achieved")

		check_achievements()
	else:
		# Wrong card - check for insurance
		if use_insurance():
			# Insurance saves one collected card
			var saved_card = ""
			for i in range(ROYAL_CARDS.size() - 1, -1, -1):
				if royal_flush[ROYAL_CARDS[i]]["found"]:
					saved_card = ROYAL_CARDS[i]
					break

			# Reset all except the saved one
			for c in ROYAL_CARDS:
				if c != saved_card:
					royal_flush[c]["found"] = false
					royal_flush[c]["suit"] = null

			combo = 1 if saved_card != "" else 0
			var card_name = "%s%s" % [card["rank"], SUIT_SYMBOLS[card["suit"]]]
			result["message"] = "Wrong card (%s)! Insurance saved %s!" % [card_name, saved_card]
			result["insurance_used"] = true
		else:
			# Full reset
			combo = 0
			stats["wrong_cards"] += 1
			stats["current_streak"] = 0
			win_streak = 0
			perfect_round = false

			reset_collected_cards()
			emit_signal("combo_changed", 0)
			emit_signal("card_reset")

			var card_name = "%s%s" % [card["rank"], SUIT_SYMBOLS[card["suit"]]]
			result["message"] = "Wrong card (%s)! All progress lost!" % card_name

	save_game()
	return result

func check_win_condition() -> bool:
	for card in ROYAL_CARDS:
		if not royal_flush[card]["found"]:
			return false
	return true

func reset_collected_cards() -> void:
	for card in ROYAL_CARDS:
		royal_flush[card]["found"] = false
		royal_flush[card]["suit"] = null

# ============================================
# UPGRADE SYSTEM
# ============================================
func get_upgrade_cost(upgrade_key: String) -> int:
	var upgrade = upgrades[upgrade_key]
	var prestige_discount = 1.0 - (prestige_level * 0.05)
	return int(upgrade["base_cost"] * pow(1.5, upgrade["level"]) * prestige_discount)

func can_purchase_upgrade(upgrade_key: String) -> bool:
	var upgrade = upgrades[upgrade_key]
	var cost = get_upgrade_cost(upgrade_key)
	return money >= cost and upgrade["level"] < upgrade["max_level"]

func purchase_upgrade(upgrade_key: String) -> bool:
	if not can_purchase_upgrade(upgrade_key):
		return false

	var cost = get_upgrade_cost(upgrade_key)
	var old_money = money
	money -= cost
	upgrades[upgrade_key]["level"] += 1

	emit_signal("money_changed", old_money, money)

	# Apply upgrade effects
	match upgrade_key:
		"deck_reduction":
			deck_size -= upgrades[upgrade_key]["effect"]
		"dog":
			has_dog = true
			unlock_achievement("dog_owner")

	emit_signal("upgrade_purchased", upgrade_key)
	check_achievements()
	save_game()
	return true

# ============================================
# ACHIEVEMENT SYSTEM
# ============================================
func unlock_achievement(key: String) -> void:
	if not achievements.has(key) or achievements[key]["unlocked"]:
		return

	achievements[key]["unlocked"] = true
	emit_signal("achievement_unlocked", key, achievements[key])
	save_game()

func check_achievements() -> void:
	if stats["total_wins"] >= 1:
		unlock_achievement("first_win")
	if stats["total_wins"] >= 10:
		unlock_achievement("wins10")
	if stats["total_wins"] >= 50:
		unlock_achievement("wins50")
	if stats["total_draws"] >= 100:
		unlock_achievement("draws100")
	if stats["total_draws"] >= 1000:
		unlock_achievement("draws1000")
	if stats["highest_combo"] >= 5:
		unlock_achievement("combo5")
	if money >= 10000:
		unlock_achievement("rich")
	if prestige_level >= 1:
		unlock_achievement("prestige1")
	if prestige_level >= 5:
		unlock_achievement("prestige5")
	if has_dog:
		unlock_achievement("dog_owner")
	if stats["cards_collected"] >= 100:
		unlock_achievement("collector")

	# New achievements
	if lifetime_money >= 1000000:
		unlock_achievement("millionaire")
	if win_streak >= 5:
		unlock_achievement("win_streak5")
	if win_streak >= 10:
		unlock_achievement("win_streak10")
	if current_tier >= 8:
		unlock_achievement("tier_max")
	if deck_size < 20 and stats["total_wins"] > 0:
		unlock_achievement("risk_taker")
	if dog_pets >= 100:
		unlock_achievement("secret_dog100")

	# Check max upgrade
	for upgrade in upgrades.values():
		if upgrade["level"] >= upgrade["max_level"]:
			unlock_achievement("max_upgrade")
			break

# ============================================
# TIER PROGRESSION SYSTEM
# ============================================
func check_tier_progress() -> void:
	var new_tier = current_tier
	for i in range(TIER_REQUIREMENTS.size() - 1, 0, -1):
		if stats["total_wins"] >= TIER_REQUIREMENTS[i]:
			new_tier = i
			break

	if new_tier > current_tier:
		current_tier = new_tier
		emit_signal("tier_unlocked", current_tier)
		emit_signal("notification_requested", "Welcome to %s!" % TIER_NAMES[current_tier])
		save_game()

func get_tier_name() -> String:
	if current_tier < TIER_NAMES.size():
		return TIER_NAMES[current_tier]
	return "Unknown"

func get_tier_bonus() -> float:
	return current_tier * upgrades["vip_bonus"]["level"] * upgrades["vip_bonus"]["effect"]

# ============================================
# NEW MECHANICS
# ============================================
func use_peek() -> bool:
	if peek_uses > 0:
		peek_uses -= 1
		return true
	return false

func reset_peek_uses() -> void:
	peek_uses = upgrades["peek"]["level"]

func use_mulligan() -> bool:
	if mulligan_available and upgrades["mulligan"]["level"] > 0:
		mulligan_available = false
		return true
	return false

func reset_mulligan() -> void:
	mulligan_available = upgrades["mulligan"]["level"] > 0

func check_golden_touch() -> bool:
	var chance = upgrades["golden_touch"]["level"] * upgrades["golden_touch"]["effect"]
	golden_touch_proc = randf() < chance
	if golden_touch_proc:
		stats["golden_touch_procs"] = stats.get("golden_touch_procs", 0) + 1
		if stats["golden_touch_procs"] >= 100:
			unlock_achievement("golden_100")
	return golden_touch_proc

func use_insurance() -> bool:
	if insurance_active and upgrades["insurance"]["level"] > 0:
		insurance_active = false
		return true
	return false

func reset_insurance() -> void:
	insurance_active = upgrades["insurance"]["level"] > 0

func pet_dog() -> void:
	dog_pets += 1
	if dog_pets >= 100:
		unlock_achievement("secret_dog100")
	save_game()

# ============================================
# SECRET SYSTEM
# ============================================
func check_konami_input(key: String) -> bool:
	const KONAMI: Array = ["up", "up", "down", "down", "left", "right", "left", "right", "b", "a"]

	if key == KONAMI[konami_progress]:
		konami_progress += 1
		if konami_progress >= KONAMI.size():
			konami_progress = 0
			activate_secret("konami")
			return true
	else:
		konami_progress = 0
	return false

func activate_secret(secret_name: String) -> void:
	if secret_name in secrets_discovered:
		return

	secrets_discovered.append(secret_name)

	match secret_name:
		"konami":
			money += 1000
			unlock_achievement("secret_konami")
			emit_signal("notification_requested", "SECRET: +$1000!")
		"patience":
			money += 500
			unlock_achievement("secret_patience")
			emit_signal("notification_requested", "SECRET: Patience rewarded! +$500")

	emit_signal("secret_discovered", secret_name)
	save_game()

# ============================================
# PRESTIGE SYSTEM
# ============================================
func can_prestige() -> bool:
	return total_wins >= 5

func get_prestige_points() -> int:
	return int(total_wins / 5) + int(lifetime_money / 10000)

func prestige() -> void:
	if not can_prestige():
		return

	var points = get_prestige_points()
	prestige_level += 1
	prestige_points += points

	# Reset progress
	draws = 0
	money = 50 + (prestige_level * 25)
	deck_size = 52
	combo = 0
	total_wins = 0
	has_dog = false

	reset_collected_cards()

	# Reset upgrades
	for key in upgrades:
		upgrades[key]["level"] = 0

	unlock_achievement("prestige1")
	if prestige_level >= 5:
		unlock_achievement("prestige5")

	emit_signal("prestige_completed", prestige_level)
	emit_signal("notification_requested", "Prestige Level %d! +%d points" % [prestige_level, points])
	save_game()

# ============================================
# DAILY BONUS SYSTEM
# ============================================
func check_daily_bonus() -> bool:
	var today = Time.get_date_string_from_system()
	if last_daily_bonus == today:
		return false

	# Check streak
	if last_daily_bonus != "":
		var last_dict = Time.get_datetime_dict_from_datetime_string(last_daily_bonus + "T00:00:00", false)
		var today_dict = Time.get_datetime_dict_from_system()
		# Simple check - if more than 1 day difference, reset streak
		# This is simplified; proper implementation would calculate actual day difference
		daily_bonus_streak = 0

	return true

func claim_daily_bonus() -> int:
	if not check_daily_bonus():
		return 0

	daily_bonus_streak += 1
	var bonus = 50 + (daily_bonus_streak * 25) + (prestige_level * 10)

	var old_money = money
	money += bonus
	last_daily_bonus = Time.get_date_string_from_system()

	if daily_bonus_streak >= 7:
		unlock_achievement("daily_streak7")

	emit_signal("money_changed", old_money, money)
	emit_signal("notification_requested", "Daily Bonus! +$%d (Day %d)" % [bonus, daily_bonus_streak])
	save_game()

	return bonus

# ============================================
# RESET FUNCTIONS
# ============================================
func reset_for_new_round() -> void:
	draws = 0
	combo = 0
	is_shuffling = false
	cards_laid_out = false
	perfect_round = true
	reset_collected_cards()
	reset_peek_uses()
	reset_mulligan()
	reset_insurance()
	emit_signal("card_reset")
	save_game()

func reset_game() -> void:
	draws = 0
	money = 50 + (prestige_level * 25)
	deck_size = 52
	combo = 0
	total_wins = 0
	has_dog = false
	is_shuffling = false
	cards_laid_out = false

	reset_collected_cards()

	for key in upgrades:
		upgrades[key]["level"] = 0

	emit_signal("card_reset")
	save_game()

# ============================================
# UTILITY FUNCTIONS
# ============================================
func get_current_multiplier() -> float:
	if combo <= 0:
		return 0.0
	return combo + (upgrades["multiplier_boost"]["level"] * upgrades["multiplier_boost"]["effect"]) + (prestige_level * 0.1)

func get_shuffle_time() -> float:
	var base_time = 1.0
	var speed_reduction = upgrades["shuffle_speed"]["level"] * upgrades["shuffle_speed"]["effect"]
	return max(0.1, base_time - speed_reduction)

func get_next_needed_card() -> String:
	for card in ROYAL_CARDS:
		if not royal_flush[card]["found"]:
			return card
	return ""
