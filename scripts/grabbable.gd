extends Interactable

class_name Grabbable

@export var weight: float = 5.0
@export var usable: Usable

func interact(manager: Interactions) -> void:
	manager.grab_object(self)
	on_grab()

# Optional: You can override the grab/release behavior
func on_grab():
	print("You grabbed it!")

func on_release():
	print("You released it!")
