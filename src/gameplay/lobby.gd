extends Node2D

var transitioning = false

@onready var store_modal = $StoreModal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	store_modal.reparent(Global.hud)

	if not Global.current_run:
		Global.new_run()

	Global.current_run.next_wave()

	if Global.level:
		Global.level.reset_pops()
	else:
		$Customers.show_new_customers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not store_modal.visible and not transitioning and Input.is_action_pressed("pop"):
		transitioning = true
		if Global.current_run.wave <= 1:
			Global.main.goto_scenep("res://src/gameplay/level.tscn")
		else:
			Global.main.go_to_last_scene()


func _on_store_modal_closed() -> void:
	$Customers.show_new_customers()
