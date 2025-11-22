extends Node3D

# Royal Rush 3D - Dog Companion (Detailed CSG Model)
# Irish Setter made from CSG primitives

@onready var body: CSGBox3D = $Body
@onready var collision_area: Area3D = $Area3D

var velocity: Vector3 = Vector3(1, 0, 0)
var speed: float = 2.0
var bounds: Vector2 = Vector2(-4, 4)
var is_happy: bool = false
var walk_animation_time: float = 0.0

# Leg references for animation
@onready var front_left_leg: CSGCylinder3D = $Body/FrontLeftLeg
@onready var front_right_leg: CSGCylinder3D = $Body/FrontRightLeg
@onready var back_left_leg: CSGCylinder3D = $Body/BackLeftLeg
@onready var back_right_leg: CSGCylinder3D = $Body/BackRightLeg
@onready var tail: CSGCylinder3D = $Body/Tail

func _ready() -> void:
	collision_area.input_event.connect(_on_input_event)
	velocity.x = [-1, 1][randi() % 2] * speed

func _process(delta: float) -> void:
	if not visible:
		return

	# Move dog
	position.x += velocity.x * delta

	# Bounce off bounds
	if position.x <= bounds.x or position.x >= bounds.y:
		velocity.x *= -1
		scale.x = sign(velocity.x)

	# Random direction change
	if randf() < 0.01:
		velocity.x = randf_range(-1, 1) * speed
		if velocity.x != 0:
			scale.x = sign(velocity.x)

	# Walk animation
	if not is_happy and abs(velocity.x) > 0.1:
		walk_animation_time += delta * 10

		# Leg animation
		var leg_angle = sin(walk_animation_time) * 20
		if front_left_leg:
			front_left_leg.rotation_degrees.x = leg_angle
		if front_right_leg:
			front_right_leg.rotation_degrees.x = -leg_angle
		if back_left_leg:
			back_left_leg.rotation_degrees.x = -leg_angle
		if back_right_leg:
			back_right_leg.rotation_degrees.x = leg_angle

		# Tail wag
		if tail:
			tail.rotation_degrees.z = sin(walk_animation_time * 2) * 15

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pet_dog()

func pet_dog() -> void:
	if is_happy:
		return

	is_happy = true
	_spawn_heart()

	# Jump animation
	var tween = create_tween()
	var original_y = position.y
	tween.tween_property(self, "position:y", original_y + 0.5, 0.2)
	tween.tween_property(self, "position:y", original_y, 0.2)

	# Excited tail wag
	if tail:
		var tail_tween = create_tween()
		tail_tween.set_loops(4)
		tail_tween.tween_property(tail, "rotation_degrees:z", 30, 0.1)
		tail_tween.tween_property(tail, "rotation_degrees:z", -30, 0.1)

	await get_tree().create_timer(0.8).timeout
	is_happy = false

func _spawn_heart() -> void:
	var heart_label = Label3D.new()
	heart_label.text = "❤"
	heart_label.font_size = 48
	heart_label.modulate = Color(1, 0.3, 0.3)
	heart_label.position = Vector3(0, 0.8, 0)
	heart_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(heart_label)

	var tween = create_tween()
	tween.tween_property(heart_label, "position:y", 1.5, 1.0)
	tween.parallel().tween_property(heart_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(heart_label.queue_free)
