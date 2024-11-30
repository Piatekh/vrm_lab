extends Interactable

var closed_rotation: Quaternion 
var open_rotation: Quaternion = Basis(Vector3(0, 1, 0), PI/2).get_rotation_quaternion().normalized()

var is_door_open: bool = false

func _ready() -> void:
	closed_rotation = transform.basis.get_rotation_quaternion()

func interact(manager: Interactions) -> void:
	# Toggle the door position between open and closed
	if is_door_open:
		transform = Transform3D(closed_rotation, transform.origin)
	else:
		transform = Transform3D(open_rotation, transform.origin)
	
	# Toggle the door's open/closed state
	is_door_open = !is_door_open
