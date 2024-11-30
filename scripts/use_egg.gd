extends Usable

# Define the 'use' function with no implementation (interface-like)
func use(manager: Interactions) -> void:
	var egg = get_parent() as Egg
	# Create a new instance of the object
	var small_hen = egg.small_hen.instantiate()
	
	# Set the position and rotation of the new object to match the current egg
	small_hen.global_transform = egg.global_transform
	get_tree().root.add_child(small_hen)

	manager.release_object()
	manager.grab_object(small_hen as Grabbable)

	egg.queue_free()
