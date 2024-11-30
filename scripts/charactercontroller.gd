extends CharacterBody3D

# Movement variables
@export var speed: float = 5.0
@export var jump_velocity: float = 10.0
@export var gravity: float = 20.0

# Camera control variables
@export var mouse_sensitivity: float = 0.1
var rotation_x: float = 0.0
var mouse_delta: Vector2

# Reference to the camera (drag in the inspector or get by name)
@onready var camera: Camera3D = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Lock the mouse to the screen

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _physics_process(delta):
	# Rotate the camera based on mouse motion
	rotation_x -= mouse_delta.y * mouse_sensitivity
	rotation_x = clamp(rotation_x, -90, 90) # Limit vertical rotation to avoid flipping
	rotate_y(-mouse_delta.x * mouse_sensitivity * (PI / 180))
	camera.rotation_degrees.x = rotation_x
	mouse_delta = Vector2.ZERO
	
	# Input for movement
	var input_direction = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		input_direction.z -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.z += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1

	# Normalize direction to avoid faster diagonal movement
	input_direction = input_direction.normalized()

	# Convert input to movement in world space
	var movement_direction = (transform.basis * input_direction).normalized() * speed
	velocity.x = movement_direction.x
	velocity.z = movement_direction.z

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# Move the character
	move_and_slide()
