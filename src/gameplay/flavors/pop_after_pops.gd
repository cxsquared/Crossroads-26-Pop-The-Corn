class_name PopAfterPops
extends Flavor

static var starting_pops = 4

var pops_left = 5
var should_pop = true
var self_popcorn: Popcorn


func _init() -> void:
	decoration = preload("res://src/gameplay/flavors/flavor_dots.tscn")
	color_override = Color.ORANGE

func on_added(popcorn: Popcorn):
	self_popcorn = popcorn
	
	var total_pop_flavors = 0
	for flavor in popcorn._flavors:
		if flavor is PopAfterPops:
			total_pop_flavors += 1
			if total_pop_flavors <= 1:
				flavor.should_pop = true
			else:
				flavor.should_pop = false
	

func _on_any_pop(popcorn: Popcorn):
	if pops_left < 0:
		return

	pops_left -= 1
	if pops_left <= 0:
		self_popcorn.pop(popcorn.global_position)
