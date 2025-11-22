extends Node3D

# Royal Rush 3D - Card 3D Component
# Represents a single selectable card in 3D space with rounded corners

signal card_clicked

@onready var card_body: Node3D = $CardBody
@onready var main_body: CSGBox3D = $CardBody/MainBody
@onready var front_label: Label3D = $FrontLabel
@onready var back_label: Label3D = $BackLabel
@onready var collision_area: Area3D = $Area3D

# Store references to all card parts for material changes
var card_parts: Array = []

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

const CARD_BACK_COLOR: Color = Color(0.15, 0.05, 0.2)
const CARD_FRONT_COLOR: Color = Color(0.98, 0.98, 0.95)

func _ready() -> void:
	collision_area.input_event.connect(_on_input_event)
	collision_area.mouse_entered.connect(_on_mouse_entered)
	collision_area.mouse_exited.connect(_on_mouse_exited)

	# Collect all card body parts for material changes
	_collect_card_parts(card_body)

func _collect_card_parts(node: Node) -> void:
	if node is CSGPrimitive3D or node is MeshInstance3D:
		card_parts.append(node)
	for child in node.get_children():
		_collect_card_parts(child)

func setup(data: Dictionary) -> void:
	card_data = data

	# Setup back (showing full design initially)
	back_label.visible = true
	front_label.visible = false

	# Setup front with card data
	front_label.text = "%s\n%s" % [card_data["rank"], SUIT_SYMBOLS[card_data["suit"]]]
	front_label.modulate = SUIT_COLORS[card_data["suit"]]

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
		# Hide back patterns
		for i in range(1, 5):
			var pattern = get_node_or_null("BackPattern%d" % i)
			if pattern:
				pattern.visible = false
		# Change card color to white
		_set_card_color(CARD_FRONT_COLOR)
	)

	# Second half - flip to 180 degrees
	tween.tween_property(self, "rotation_degrees:y", 180, 0.15)

func _set_card_color(color: Color) -> void:
	for part in card_parts:
		if part is CSGPrimitive3D:
			if part.material:
				var mat = part.material.duplicate()
				mat.albedo_color = color
				part.material = mat
		elif part is MeshInstance3D:
			var mat = part.get_active_material(0)
			if mat:
				mat = mat.duplicate()
				mat.albedo_color = color
				part.set_surface_override_material(0, mat)

func _set_card_emission(enabled: bool, color: Color = Color.WHITE) -> void:
	for part in card_parts:
		if part is CSGPrimitive3D and part.material:
			var mat = part.material
			if mat is StandardMaterial3D:
				mat.emission_enabled = enabled
				if enabled:
					mat.emission = color
		elif part is MeshInstance3D:
			var mat = part.get_active_material(0)
			if mat is StandardMaterial3D:
				mat.emission_enabled = enabled
				if enabled:
					mat.emission = color

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
		_set_card_emission(true, Color(0.3, 0.3, 0.5))

func _on_mouse_exited() -> void:
	is_hovering = false
	if not is_flipped:
		# Return to original position
		var tween = create_tween()
		tween.tween_property(self, "position:y", 0.0, 0.1)
		# Remove glow
		_set_card_emission(false)
