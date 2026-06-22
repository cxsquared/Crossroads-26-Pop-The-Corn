extends Control

signal summary_closed()

var tween_done = false
var tween: Tween
var og_position = Vector2.ZERO

@onready var popped_value = $Bg/VBoxContainer2/Popped/PoppedValue
@onready var target_value = $Bg/VBoxContainer2/Target/TargetValue
@onready var money_value = $Bg/VBoxContainer2/Money/TargetValue


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popped_value.text = ""
	target_value.text = ""
	money_value.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("pop"):
		Global.ui_sounds.play_confirm()
		if tween_done:
			hide()
			summary_closed.emit()
		else:
			tween.kill()
			tween_done = true
			self.position = og_position
			update_text(Global.current_run.previous_target, target_value, "%d")
			update_text(Global.current_run.popped, popped_value, "%d")
			update_text(Global.current_run.popped - Global.current_run.previous_target, money_value, "$%d")


func show_summary():
	Global.ui_sounds.play_slide()
	tween = create_tween()
	tween.tween_property(self, "position", og_position, .6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).from(Vector2(0, -1000))
	tween.tween_method(update_text.bind(popped_value), 0, Global.current_run.popped, 0.4).set_delay(0.2)
	tween.tween_method(update_text.bind(target_value), 0, Global.current_run.previous_target, 0.4)
	tween.tween_method(update_text.bind(money_value, "$%d"), 0, Global.current_run.popped - Global.current_run.previous_target, 0.2).set_delay(0.2)
	tween.tween_callback(func():
			tween_done = true
			if Global.current_run.popped - Global.current_run.previous_target > 0:
				Global.ui_sounds.play_buy()
	)
	tween.play()


func update_text(value: int, target: Label, text_string: String = "%d"):
	Global.ui_sounds.play_increase(value == 0)
	target.text = text_string % value
