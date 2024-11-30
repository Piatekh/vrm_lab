extends Interactable

class_name Puttable

@export var capacity: int = 3 # Maximum capacity of the tray
var stored_items: Array = [] # Items stored in the tray

func interact(manager: Interactions) -> void:
	if (manager.is_holding):
		var obj = manager.held_object
		manager.release_object()
		if (!add_item(obj)):
			manager.grab_object(obj)

# Function to add an item to the tray
func add_item(item: Node3D) -> bool:
	if stored_items.size() < capacity:
		stored_items.append(item)
		# Change parent to the tray
		item.get_parent().remove_child(item)
		item.transform.origin = transform.origin
		self.add_child(item)
		
		# If it's a RigidBody3D, freeze it to stop physics
		if item is RigidBody3D:
			item.freeze = true

		return true
	else:
		print("Tray is full!")
		return false
