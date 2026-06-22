extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ui.reparent(Global.hud)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pop"):
		Global.new_run()
		Global.main.goto_scenep("res://src/gameplay/lobby.tscn", false)
