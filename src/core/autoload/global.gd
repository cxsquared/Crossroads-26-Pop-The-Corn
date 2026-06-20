extends Node

@export var debug = true

var main: Main
var hud: Control
var level: Level
var current_run: RunState = null


func new_run():
	current_run = RunState.new()


func rand_bool(d: int = 2):
	var rand_array = [true]
	for _i in range(d):
		rand_array.push_back(false)

	return rand_array.pick_random()
