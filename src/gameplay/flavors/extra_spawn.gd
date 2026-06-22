class_name ExtraSpawn
extends Flavor

var popcorn_scene = preload("res://src/gameplay/popcorn.tscn")


func _init() -> void:
	color_override = Color.YELLOW_GREEN


func copy() -> Flavor:
	var new_flavor = ExtraSpawn.new()
	return new_flavor


func _on_popped(og_popcorn: Popcorn, global_impact_point: Vector2, number_of_pops_left: int, iteration: int):
	var new_corn = popcorn_scene.instantiate() as Popcorn
	new_corn.position = og_popcorn.position + og_popcorn.global_position.direction_to(global_impact_point) * 2
	new_corn.name = "%s-%s-ExtraCorn" % [og_popcorn.name, name]
	new_corn.landed.connect(func(landed_popcorn:Popcorn, landed_position: Vector2, landed_pops_left: int, landed_iteration: int):
			og_popcorn.landed.emit(landed_popcorn, landed_position, landed_pops_left, landed_iteration)
	)
	new_corn.floor_z = og_popcorn.floor_z
	new_corn.collision_enabled.connect(func(collision_enabled_corn: Popcorn):
			og_popcorn.collision_enabled.emit(collision_enabled_corn)
	)
	new_corn.hit_floor.connect(func(hit_floor_corn: Popcorn):
			og_popcorn.hit_floor.emit(hit_floor_corn)
	)
	og_popcorn.get_parent().add_child(new_corn)

##	for flavor in og_popcorn._flavors:
##		if flavor is not ExtraSpawn:
##			new_corn.add_flavor(flavor.copy())

	new_corn.pop(og_popcorn.global_position, number_of_pops_left, iteration + 1)
