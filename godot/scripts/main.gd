extends Node3D

# Royal Rush 3D - Main Game Controller
# Handles game flow, card display, and player interaction

@onready var camera: Camera3D = $Camera3D
@onready var card_spawn_area: Node3D = $CardSpawnArea
@onready var collected_cards_display: Node3D = $CollectedCardsDisplay
@onready var game_ui: CanvasLayer = $GameUI
@onready var shuffle_button: Button = $GameUI/MainPanel/ShuffleButton
@onready var money_label: Label = $GameUI/MainPanel/StatsPanel/MoneyLabel
@onready var draws_label: Label = $GameUI/MainPanel/StatsPanel/DrawsLabel
@onready var combo_label: Label = $GameUI/MainPanel/StatsPanel/ComboLabel
@onready var deck_label: Label = $GameUI/MainPanel/StatsPanel/DeckLabel
@onready var result_label: Label = $GameUI/MainPanel/ResultLabel
@onready var notification_container: VBoxContainer = $GameUI/NotificationContainer
@onready var upgrade_panel: Control = $GameUI/UpgradePanel
@onready var win_modal: Control = $GameUI/WinModal
@onready var dog_3d: Node3D = $Dog3D

const Card3DScene = preload("res://scenes/card_3d.tscn")

var active_cards: Array = []
var collected_card_meshes: Dictionary = {}

# Card colors for 3D display
const SUIT_COLORS: Dictionary = {
	"hearts": Color(0.9, 0.1, 0.1),
	"diamonds": Color(0.9, 0.1, 0.1),
	"clubs": Color(0.1, 0.1, 0.1),
	"spades": Color(0.1, 0.1, 0.1)
}

func _ready() -> void:
	# Connect signals
	GameState.money_changed.connect(_on_money_changed)
	GameState.combo_changed.connect(_on_combo_changed)
	GameState.card_collected.connect(_on_card_collected)
	GameState.card_reset.connect(_on_card_reset)
	GameState.win_achieved.connect(_on_win_achieved)
	GameState.achievement_unlocked.connect(_on_achievement_unlocked)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	GameState.notification_requested.connect(_on_notification_requested)

	shuffle_button.pressed.connect(_on_shuffle_pressed)

	# Initialize UI
	update_ui()
	update_collected_display()
	_setup_upgrade_panel()

	# Check for daily bonus
	if GameState.check_daily_bonus():
		await get_tree().create_timer(0.5).timeout
		_show_daily_bonus_prompt()

	# Restore dog if owned
	if GameState.has_dog:
		dog_3d.visible = true

func _process(_delta: float) -> void:
	# Auto-save every 30 seconds
	pass

func update_ui() -> void:
	money_label.text = "$%d" % GameState.money
	draws_label.text = "Draws: %d" % GameState.draws
	deck_label.text = "Deck: %d" % max(5, GameState.deck_size)

	var multiplier = GameState.get_current_multiplier()
	if multiplier > 0:
		combo_label.text = "Combo: %.1fx" % multiplier
	else:
		combo_label.text = "Combo: -"

func _on_money_changed(old_value: int, new_value: int) -> void:
	# Animate money change
	var tween = create_tween()
	var current = old_value
	tween.tween_method(func(value: int): money_label.text = "$%d" % value, old_value, new_value, 0.5)

	if new_value > old_value:
		AudioManager.play_sound("coin")
		# Pulse effect
		var original_scale = money_label.scale
		tween.parallel().tween_property(money_label, "scale", original_scale * 1.2, 0.1)
		tween.tween_property(money_label, "scale", original_scale, 0.1)

func _on_combo_changed(value: int) -> void:
	update_ui()

func _on_card_collected(card: String) -> void:
	update_collected_display()
	AudioManager.play_sound("coin")

func _on_card_reset() -> void:
	update_collected_display()

func _on_win_achieved() -> void:
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_sound("win")
	_show_win_modal()

func _on_achievement_unlocked(key: String, achievement: Dictionary) -> void:
	AudioManager.play_sound("achievement")
	show_notification("Achievement: %s" % achievement["name"])

func _on_upgrade_purchased(key: String) -> void:
	_setup_upgrade_panel()
	update_ui()

	if key == "dog":
		dog_3d.visible = true

func _on_notification_requested(message: String) -> void:
	show_notification(message)

# ============================================
# SHUFFLE AND CARD DISPLAY
# ============================================
func _on_shuffle_pressed() -> void:
	if GameState.is_shuffling or GameState.cards_laid_out:
		return

	GameState.is_shuffling = true
	shuffle_button.disabled = true

	AudioManager.play_sound("shuffle")

	# Show shuffling text
	result_label.text = "SHUFFLING..."

	# Wait for shuffle time
	var shuffle_time = GameState.get_shuffle_time()
	await get_tree().create_timer(shuffle_time).timeout

	GameState.is_shuffling = false
	GameState.cards_laid_out = true
	result_label.text = ""

	lay_out_cards()

func lay_out_cards() -> void:
	# Clear existing cards
	for card in active_cards:
		if is_instance_valid(card):
			card.queue_free()
	active_cards.clear()

	# Create deck and select 5 cards
	var deck = GameState.create_deck()
	var selected_cards: Array = []

	for i in range(5):
		var random_index = randi() % deck.size()
		selected_cards.append(deck[random_index])
		deck.remove_at(random_index)

	# Spawn 3D cards
	var card_spacing = 1.5
	var start_x = -3.0

	for i in range(selected_cards.size()):
		var card_data = selected_cards[i]
		var card_3d = Card3DScene.instantiate()
		card_spawn_area.add_child(card_3d)

		card_3d.position = Vector3(start_x + i * card_spacing, 0, 0)
		card_3d.setup(card_data)
		card_3d.card_clicked.connect(_on_card_selected.bind(card_3d, card_data))

		# Animate card appearing
		card_3d.scale = Vector3.ZERO
		var tween = create_tween()
		tween.tween_property(card_3d, "scale", Vector3.ONE, 0.2).set_delay(i * 0.1)

		active_cards.append(card_3d)

func _on_card_selected(card_node: Node3D, card_data: Dictionary) -> void:
	if not GameState.cards_laid_out:
		return

	GameState.cards_laid_out = false
	GameState.draws += 1
	GameState.stats["total_draws"] += 1

	AudioManager.play_sound("flip")

	# Flip the selected card
	card_node.flip_card()

	# Wait for flip animation
	await get_tree().create_timer(0.5).timeout

	# Check result
	var result = GameState.check_card_result(card_data)

	if result["success"]:
		result_label.add_theme_color_override("font_color", Color(0, 1, 0))
		_spawn_particles(card_node.global_position, Color(1, 0.84, 0))
	else:
		result_label.add_theme_color_override("font_color", Color(1, 0, 0))
		_screen_shake()

	result_label.text = result["message"]

	# Clear cards after delay
	await get_tree().create_timer(1.5).timeout
	_clear_active_cards()
	shuffle_button.disabled = false
	update_ui()

func _clear_active_cards() -> void:
	for card in active_cards:
		if is_instance_valid(card):
			var tween = create_tween()
			tween.tween_property(card, "scale", Vector3.ZERO, 0.2)
			tween.tween_callback(card.queue_free)
	active_cards.clear()

# ============================================
# COLLECTED CARDS DISPLAY
# ============================================
func update_collected_display() -> void:
	# Update 3D display of collected royal flush cards
	var card_positions = {
		"10": Vector3(-2, 0, 0),
		"J": Vector3(-1, 0, 0),
		"Q": Vector3(0, 0, 0),
		"K": Vector3(1, 0, 0),
		"A": Vector3(2, 0, 0)
	}

	for card in GameState.ROYAL_CARDS:
		var mesh_name = "Card_%s" % card

		# Remove existing mesh if any
		if collected_card_meshes.has(card):
			if is_instance_valid(collected_card_meshes[card]):
				collected_card_meshes[card].queue_free()
			collected_card_meshes.erase(card)

		# Create new mesh
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.6, 0.9, 0.02)
		mesh_instance.mesh = box_mesh

		var material = StandardMaterial3D.new()

		if GameState.royal_flush[card]["found"]:
			material.albedo_color = Color(1, 0.84, 0)  # Gold for collected
		else:
			material.albedo_color = Color(0.3, 0.3, 0.3)  # Gray for not collected

		mesh_instance.material_override = material
		mesh_instance.position = card_positions[card]
		mesh_instance.name = mesh_name

		collected_cards_display.add_child(mesh_instance)
		collected_card_meshes[card] = mesh_instance

		# Add label
		var label_3d = Label3D.new()
		label_3d.text = card
		label_3d.font_size = 64
		label_3d.position = Vector3(0, 0, 0.02)

		if GameState.royal_flush[card]["found"]:
			label_3d.modulate = Color(0.8, 0, 0)
			label_3d.text = "%s♥" % card
		else:
			label_3d.modulate = Color(0.5, 0.5, 0.5)

		mesh_instance.add_child(label_3d)

# ============================================
# UPGRADE PANEL
# ============================================
func _setup_upgrade_panel() -> void:
	var grid = upgrade_panel.get_node("ScrollContainer/UpgradeGrid")

	# Clear existing
	for child in grid.get_children():
		child.queue_free()

	# Create upgrade buttons
	for key in GameState.upgrades:
		var upgrade = GameState.upgrades[key]
		var btn = _create_upgrade_button(key, upgrade)
		grid.add_child(btn)

func _create_upgrade_button(key: String, upgrade: Dictionary) -> Button:
	var btn = Button.new()
	var cost = GameState.get_upgrade_cost(key)
	var maxed = upgrade["level"] >= upgrade["max_level"]

	btn.custom_minimum_size = Vector2(200, 80)

	if maxed:
		btn.text = "%s\n[MAXED]\n%d/%d" % [upgrade["name"], upgrade["level"], upgrade["max_level"]]
		btn.disabled = true
	else:
		btn.text = "%s\n$%d\n%d/%d" % [upgrade["name"], cost, upgrade["level"], upgrade["max_level"]]
		btn.disabled = not GameState.can_purchase_upgrade(key)

	btn.pressed.connect(func(): _on_upgrade_button_pressed(key))

	return btn

func _on_upgrade_button_pressed(key: String) -> void:
	if GameState.purchase_upgrade(key):
		AudioManager.play_sound("coin")

# ============================================
# WIN MODAL
# ============================================
func _show_win_modal() -> void:
	win_modal.visible = true

	var title = win_modal.get_node("Panel/VBox/Title")
	var play_again_btn = win_modal.get_node("Panel/VBox/PlayAgainButton")
	var prestige_btn = win_modal.get_node("Panel/VBox/PrestigeButton")

	title.text = "ROYAL FLUSH!\nWins: %d" % GameState.total_wins

	play_again_btn.pressed.connect(_on_play_again_pressed, CONNECT_ONE_SHOT)

	if GameState.can_prestige():
		prestige_btn.visible = true
		prestige_btn.text = "Prestige (+%d pts)" % GameState.get_prestige_points()
		prestige_btn.pressed.connect(_on_prestige_pressed, CONNECT_ONE_SHOT)
	else:
		prestige_btn.visible = false

func _on_play_again_pressed() -> void:
	win_modal.visible = false
	GameState.reset_for_new_round()
	update_ui()
	update_collected_display()

func _on_prestige_pressed() -> void:
	win_modal.visible = false
	GameState.prestige()
	update_ui()
	update_collected_display()
	_setup_upgrade_panel()
	dog_3d.visible = false

# ============================================
# DAILY BONUS
# ============================================
func _show_daily_bonus_prompt() -> void:
	# Simple confirmation for daily bonus
	var bonus = GameState.claim_daily_bonus()
	if bonus > 0:
		show_notification("Daily Bonus claimed: +$%d" % bonus)

# ============================================
# VISUAL EFFECTS
# ============================================
func show_notification(message: String) -> void:
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	notification_container.add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 2.0).set_delay(2.0)
	tween.tween_callback(label.queue_free)

func _screen_shake() -> void:
	var original_pos = camera.position
	var tween = create_tween()

	for i in range(5):
		var offset = Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), 0)
		tween.tween_property(camera, "position", original_pos + offset, 0.05)

	tween.tween_property(camera, "position", original_pos, 0.05)

func _spawn_particles(pos: Vector3, color: Color) -> void:
	# Create simple particle effect using GPUParticles3D
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.5
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.gravity = Vector3(0, -9.8, 0)
	material.color = color

	particles.process_material = material
	particles.amount = 20
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 1.0

	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh

	particles.position = pos
	add_child(particles)
	particles.emitting = true

	await get_tree().create_timer(2.0).timeout
	particles.queue_free()
