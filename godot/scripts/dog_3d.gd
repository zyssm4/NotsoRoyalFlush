extends Node3D

# Royal Rush 3D - Dog Companion
# Animated Irish Setter that walks around the scene

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_area: Area3D = $Area3D

var velocity: Vector3 = Vector3(1, 0, 0)
var speed: float = 2.0
var bounds: Vector2 = Vector2(-5, 5)  # X bounds for walking
var is_happy: bool = false
var walk_animation_time: float = 0.0

func _ready() -> void:
	collision_area.input_event.connect(_on_input_event)

	# Set initial direction randomly
	velocity.x = [-1, 1][randi() % 2] * speed

func _process(delta: float) -> void:
	if not visible:
		return

	# Move dog
	position.x += velocity.x * delta

	# Bounce off bounds
	if position.x <= bounds.x or position.x >= bounds.y:
		velocity.x *= -1
		# Flip mesh
		mesh_instance.scale.x = sign(velocity.x)

	# Random direction change
	if randf() < 0.01:
		velocity.x = randf_range(-1, 1) * speed
		if velocity.x != 0:
			mesh_instance.scale.x = sign(velocity.x)

	# Walk animation (bobbing)
	if not is_happy:
		walk_animation_time += delta * 8
		position.y = sin(walk_animation_time) * 0.05

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pet_dog()

func pet_dog() -> void:
	if is_happy:
		return

	is_happy = true

	# Show heart particle
	_spawn_heart()

	# Jump animation
	var tween = create_tween()
	var original_y = position.y
	tween.tween_property(self, "position:y", original_y + 0.5, 0.2)
	tween.tween_property(self, "position:y", original_y, 0.2)

	# Change color briefly
	var material = mesh_instance.get_active_material(0)
	if material:
		var original_color = material.albedo_color
		material.albedo_color = Color(1, 0.8, 0.6)  # Happy golden color

		await get_tree().create_timer(0.8).timeout
		material.albedo_color = original_color

	is_happy = false

func _spawn_heart() -> void:
	var heart_label = Label3D.new()
	heart_label.text = "❤"
	heart_label.font_size = 48
	heart_label.modulate = Color(1, 0.3, 0.3)
	heart_label.position = Vector3(0, 1, 0)
	heart_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(heart_label)

	# Animate heart floating up
	var tween = create_tween()
	tween.tween_property(heart_label, "position:y", 2.0, 1.0)
	tween.parallel().tween_property(heart_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(heart_label.queue_free)
