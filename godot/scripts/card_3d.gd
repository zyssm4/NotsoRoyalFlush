extends Node3D

# Royal Rush 3D - Card 3D Component
# Represents a single selectable card in 3D space

signal card_clicked

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var front_label: Label3D = $FrontLabel
@onready var back_label: Label3D = $BackLabel
@onready var collision_area: Area3D = $Area3D

var card_data: Dictionary = {}
var is_flipped: bool = false
var is_hovering: bool = false

const SUIT_COLORS: Dictionary = {
	"hearts": Color(0.9, 0.1, 0.1),
	"diamonds": Color(0.9, 0.1, 0.1),
	"clubs": Color(0.15, 0.15, 0.15),
	"spades": Color(0.15, 0.15, 0.15)
}

const SUIT_SYMBOLS: Dictionary = {
	"hearts": "♥",
	"diamonds": "♦",
	"clubs": "♣",
	"spades": "♠"
}

func _ready() -> void:
	collision_area.input_event.connect(_on_input_event)
	collision_area.mouse_entered.connect(_on_mouse_entered)
	collision_area.mouse_exited.connect(_on_mouse_exited)

func setup(data: Dictionary) -> void:
	card_data = data

	# Setup back (showing "?" initially)
	back_label.text = "?"
	back_label.visible = true
	front_label.visible = false

	# Setup front with card data
	front_label.text = "%s\n%s" % [card_data["rank"], SUIT_SYMBOLS[card_data["suit"]]]
	front_label.modulate = SUIT_COLORS[card_data["suit"]]

	# Set card back color (dark blue)
	var material = mesh_instance.get_active_material(0)
	if material:
		material.albedo_color = Color(0.1, 0.1, 0.3)

func flip_card() -> void:
	if is_flipped:
		return

	is_flipped = true

	# Flip animation
	var tween = create_tween()

	# First half - flip to 90 degrees
	tween.tween_property(self, "rotation_degrees:y", 90, 0.15)
	tween.tween_callback(func():
		back_label.visible = false
		front_label.visible = true
		# Change card color to white
		var mat = mesh_instance.get_active_material(0)
		if mat:
			mat.albedo_color = Color(0.95, 0.95, 0.95)
	)

	# Second half - flip to 180 degrees
	tween.tween_property(self, "rotation_degrees:y", 180, 0.15)

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("card_clicked")

func _on_mouse_entered() -> void:
	is_hovering = true
	if not is_flipped:
		# Hover effect - slight raise
		var tween = create_tween()
		tween.tween_property(self, "position:y", 0.3, 0.1)
		# Glow effect
		var material = mesh_instance.get_active_material(0)
		if material:
			material.emission_enabled = true
			material.emission = Color(0.3, 0.3, 0.5)

func _on_mouse_exited() -> void:
	is_hovering = false
	if not is_flipped:
		# Return to original position
		var tween = create_tween()
		tween.tween_property(self, "position:y", 0.0, 0.1)
		# Remove glow
		var material = mesh_instance.get_active_material(0)
		if material:
			material.emission_enabled = false
