extends Grabbable

class_name Chicken

@export var egg_prefab: PackedScene # Reference to the egg prefab (scene)
@export var egg_spawn_point: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	egg_spawn_point = $egg_spawn_point
	if egg_spawn_point == null:
		print("Egg spawn point node not found! Make sure a 'egg_spawn_point' node exists as a child of chicken.")
	
func spawn_egg() -> void:
	# Position the new egg next to the held egg
	var new_egg = egg_prefab.instantiate() # Create an instance of the egg prefab
	
	# Set the position of the new egg
	new_egg.global_transform.origin = egg_spawn_point.global_transform.origin
	
	# Add the new egg to the scene (root or a specific node)
	get_tree().root.add_child(new_egg)
