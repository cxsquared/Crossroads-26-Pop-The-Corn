extends Node

@export var debug = false

var main: Main
var hud: Control
var level: Level
var current_run: RunState = null
var default_theme : Theme = preload("res://assets/themes/default_ui_theme.theme")


func new_run():
	level = null
	current_run = RunState.new()


func rand_bool(d: int = 2):
	var rand_array = [true]
	for _i in range(d):
		rand_array.push_back(false)

	return rand_array.pick_random()
