extends Node

@export var debug = true

var hud: Control
var level: Level


func rand_bool(d: int = 2):
	var rand_array = [true]
	for _i in range(d):
		rand_array.push_back(false)

	return rand_array.pick_random()
