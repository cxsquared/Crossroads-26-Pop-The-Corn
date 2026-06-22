extends Control

@onready var score = $Score
@onready var target = $Target


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_level_score_updated(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_level_score_updated(new_score: int) -> void:
	score.text = "%d pieces popped" % new_score
	var peices_to_go = max(0, Global.current_run.get_current_wave_target() - new_score)
	if peices_to_go > 0:
		target.text = "%d popcorn pieces to go" % max(0, Global.current_run.get_current_wave_target() - new_score)
	else:
		target.text = "You've done it!"
