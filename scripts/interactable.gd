extends RigidBody3D

class_name Interactable

# Optional: A message or description for the interactable object
@export var interaction_message: String = "Interact"

# Whether the object can be grabbed
@export var is_grabbable: bool = true

func interact(manager: Interactions) -> void:
	pass

# Called when the player interacts with the object
func on_interact():
	print("Interacted with:", self.name)
