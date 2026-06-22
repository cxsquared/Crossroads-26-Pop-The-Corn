extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label2.text = "You served %d customers" % Global.current_run.previous_customers.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
