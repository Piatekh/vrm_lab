extends Camera3D

class_name Interactions

# Raycasting settings
@export var ray_length: float = 10.0 # Maximum distance for interactions
@export var interact_button: String = "interact" # Button to trigger interaction
@export var use_button: String = "use" # Button to trigger interaction
@export var put_button: String = "put"  # F key
@export var collision_mask: int = 1 # Define which layer(s) the ray interacts with
@export var hold_distance: float = 2.0 # How far the held object should be from the camera
@export var spawn_distance: float = 1.5 # Distance at which the new object will spawn

# References
var target_object: Interactable = null
var held_object: Grabbable = null
var is_holding: bool = false
var hand_node: Node3D = null # Reference to the "Hand" node

# Original collision layer and mask of the object (to revert it after release)
var original_layer: int = 1 
var original_mask: int = 2

# Reference to the chicken prefab (or the object to spawn)
@export var chicken_prefab: PackedScene

func _ready():
	# Find the "Hand" node (make sure to add a "Hand" Node3D as a child of this Camera3D)
	hand_node = $hand
	if hand_node == null:
		print("Hand node not found! Make sure a 'Hand' node exists as a child of Camera3D.")

func _physics_process(delta):
	# Perform raycasting every frame
	var ray_origin = global_transform.origin
	var ray_direction = -global_transform.basis.z # Forward direction of the camera
	var space_state = get_world_3d().direct_space_state
	
	# Raycast query
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * ray_length)
	query.collision_mask = collision_mask
	var result = space_state.intersect_ray(query)

	if result:
		# If the ray hits something, check if it's a RigidBody3D object
		var hit_object = result.collider

		if hit_object is RigidBody3D and hit_object is Interactable:
			target_object = hit_object
		else:
			target_object = null
	else:
		target_object = null

	# Check for interaction input
	if Input.is_action_just_pressed(interact_button):
		if is_holding:
			release_object()  # Release the object if we are already holding it
		elif target_object:
			(target_object as Interactable).interact(self)
						
	if Input.is_action_just_pressed(use_button):
		if is_holding && held_object is Grabbable:
			(held_object as Grabbable).usable.use(self)
			
	if Input.is_action_just_pressed(put_button):
		if target_object && target_object is Puttable:
			target_object.interact(self)


# Grab the object and make it a child of the "Hand" node
func grab_object(obj: Grabbable):
	if hand_node == null:
		return

	is_holding = true
	held_object = obj
	
	# Store the original layer
	original_layer = held_object.collision_layer
	original_mask = held_object.collision_mask
	
	# Change the object's layer to 3 (or any layer you want)
	held_object.collision_layer = 1 << 2
	held_object.collision_mask = original_mask & ~(1 << 1)

	# Set to kinematic mode
	held_object.freeze_mode = RigidBody3D.FreezeMode.FREEZE_MODE_KINEMATIC
	held_object.freeze = true
	held_object.linear_velocity = Vector3.ZERO
	held_object.angular_velocity = Vector3.ZERO

	# Preserve the global rotation
	var global_quaternion = held_object.global_transform.basis.get_rotation_quaternion()

	# Attach the object to the "Hand" node
	held_object.get_parent().remove_child(held_object)
	hand_node.add_child(held_object)

	# Convert the global transform to local for the new parent
	held_object.global_transform = Transform3D(global_quaternion, hand_node.global_transform.origin)


# Release the object and re-parent it to the scene
func release_object():
	if held_object:
		print("Released:", held_object.name)

		# Preserve the global transform before re-parenting
		var global_transform = held_object.global_transform

		# Reset the object's parent to the original scene root
		var scene_root = get_tree().root.get_child(0) # The root node of your scene
		
		held_object.get_parent().remove_child(held_object)
		scene_root.add_child(held_object)

		# Restore its global transform
		held_object.global_transform = global_transform

		# Reset the object's collision layer and mask
		held_object.collision_layer = original_layer
		held_object.collision_mask = original_mask

		held_object.freeze = false
		held_object.on_release()
		held_object = null
	is_holding = false

# Function to align the held object with the hand position and rotation
func align_held_object():
	if hand_node and held_object:
		# Align the position
		held_object.global_transform.origin = hand_node.global_transform.origin + hand_node.global_transform.basis.z * hold_distance

		# Align the rotation
		held_object.global_transform.basis = hand_node.global_transform.basis

# Function to spawn a new chicken (or any object) next to the held object
func spawn_new_object():
	if chicken_prefab:
		# Instantiate a new chicken object
		var new_chicken = chicken_prefab.instantiate()

		# Get the position to spawn the new chicken next to the held object
		var spawn_position = held_object.global_transform.origin + Vector3(0, 0, spawn_distance)

		# Set the new object's position
		new_chicken.global_transform.origin = spawn_position

		# Add the new chicken to the scene
		get_tree().current_scene.add_child(new_chicken)
		print("Spawned a new chicken at: ", spawn_position)
