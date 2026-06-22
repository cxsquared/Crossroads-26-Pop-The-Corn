extends Node2D

var transitioning = false
var exiting = false
var tween: Tween

@onready var store_modal = $LobbyUi/StoreModal
@onready var pieces_label = $LobbyUi/PiecesNeeded
@onready var continue_label = $LobbyUi/Continue
@onready var summary = $LobbyUi/SummaryModal
@onready var target_offset_label = $LobbyUi/PiecesNeeded/TargetMod


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	$LobbyUi.reparent(Global.hud)

	if not Global.current_run:
		Global.new_run()

	Global.current_run.next_wave()
	store_modal.hide()
	summary.hide()

	if not Global.level:
		$Customers.show_new_customers()
	else:
		store_modal.show()
		summary.show()
		summary.show_summary()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if not exiting and not summary.visible and not store_modal.visible and not transitioning and Input.is_action_pressed("pop"):
		exiting = true
		transitioning = true
		Global.ui_sounds.play_confirm()

		if Global.current_run.wave <= 1:
			Global.main.goto_scenep("res://src/gameplay/level.tscn")
		else:
			if tween:
				tween.kill()

			Global.level.reset_pops()
			Global.main.go_to_last_scene()


func _on_store_modal_closed() -> void:
	$Customers.show_new_customers()


func _on_customers_all_customers_added() -> void:
	pieces_label.text = "You need %d Popcorn Pieces" % Global.current_run.get_current_wave_target()
	pieces_label.show()
	continue_label.show()

	if Global.current_run.upgrades_bought.has("Left Overs"):
		Global.current_run.upgrades_bought.erase("Left Overs")
		Global.current_run.target_offeset = -5

		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_callback(func():
				target_offset_label.show()
				pieces_label.text = "You need %d Popcorn Pieces" % Global.current_run.get_current_wave_target()
		).set_delay(.4)
		tween.tween_property(target_offset_label, "position", Vector2(target_offset_label.position.x, target_offset_label.position.y + 125), 1.5)
		tween.parallel().tween_property(target_offset_label, "modulate", Color.TRANSPARENT, 1).set_delay(.5)
		tween.play()


func _on_summary_modal_summary_closed() -> void:
	store_modal.show()
