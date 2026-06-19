class_name NearbyPop
extends Flavor

var get_popcorns_func: Callable
var radius: float = 56
var should_actually_run = true


func _init(get_popcorns_callable: Callable) -> void:


	# callables are weird
	get_popcorns_func = Callable(get_popcorns_callable)

	assert(get_popcorns_func, "Please pass in popcorn get func")

	var pop_corn_check = get_popcorns_func.call()
	assert(pop_corn_check is Array[Popcorn], "get_popcorns_func should return array of popcorn")

	decoration = preload("res://src/gameplay/flavors/flavor_dots.tscn")
	color_override = Color.PURPLE


func on_added(popcorn: Popcorn):
	# these stack and just pop in a larger radius. We only want 1 to pop though
	var total_nearbypops = 0
	var first_nearbypop: NearbyPop = null

	for flavor in popcorn._flavors:
		if flavor is NearbyPop:
			total_nearbypops += 1
			flavor.should_actually_run = false
			if not first_nearbypop:
				first_nearbypop = flavor

	if first_nearbypop:
		first_nearbypop.should_actually_run = true
		first_nearbypop.radius = radius * total_nearbypops


func _on_popped(popcorn: Popcorn, _global_impact_point: Vector2, number_of_pops_left: int, iteration: int):
	if not should_actually_run:
		return

	var popcorns = get_popcorns_func.call()

	for corn in popcorns:
		if popcorn.global_position.distance_to(corn.global_position) <= radius:
			corn.pop(popcorn.global_position, number_of_pops_left - 1, iteration + 1)
