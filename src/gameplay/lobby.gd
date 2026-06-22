extends Node2D

var transitioning = false

@onready var store_modal = $LobbyUi/StoreModal
@onready var pieces_label = $LobbyUi/PiecesNeeded
@onready var continue_label = $LobbyUi/Continue
@onready var summary = $LobbyUi/SummaryModal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LobbyUi.reparent(Global.hud)

	if not Global.current_run:
		Global.new_run()

	Global.current_run.next_wave()
	store_modal.hide()
	summary.hide()

	if not Global.level:
		$Customers.show_new_customers()
	else:
		summary.show()
		summary.show_summary()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not summary.visible and not store_modal.visible and not transitioning and Input.is_action_pressed("pop"):
		transitioning = true
		if Global.current_run.wave <= 1:
			Global.main.goto_scenep("res://src/gameplay/level.tscn")
		else:
			Global.level.reset_pops()
			Global.main.go_to_last_scene()


func _on_store_modal_closed() -> void:
	$Customers.show_new_customers()


func _on_customers_all_customers_added() -> void:
	pieces_label.text = "You need %d Popcorn Pieces" % Global.current_run.get_current_wave_target()
	pieces_label.show()
	continue_label.show()


func _on_summary_modal_summary_closed() -> void:
	store_modal.show()
