extends Node2D

var exiting = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ui.reparent(Global.hud)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if not exiting and event.is_action_pressed("pop"):
		Global.ui_sounds.play_confirm()
		exiting = true
		Global.new_run()
		Global.main.goto_scenep("res://src/gameplay/lobby.tscn", false)
