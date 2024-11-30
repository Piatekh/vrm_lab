extends Usable

# Define the 'use' function with no implementation (interface-like)
func use(manager: Interactions) -> void:
	var chicken = get_parent() as Chicken
	chicken.spawn_egg()
