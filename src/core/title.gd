extends Control

@export var min_tween_time = .9
@export var max_tween_time = 1.2
@export_range(-180, 180, 0.001, "radians_as_degrees") var min_wobble: float = deg_to_rad(-10)
@export_range(-180, 180, 0.001, "radians_as_degrees") var max_wobble: float = deg_to_rad(10)
@export var min_scale: float = 1
@export var max_scale: float = 1.1

var title_scale: float = 1.0
var title_rotation: float = 0
var scale_timer: float = 0
var scale_start_time: float = 0
var scale_start: float = 1.0
var wobble_timer: float = 0
var wobble_start_time: float = 0
var wobble_start: float = 1

@onready var label = $LabelParent as Control


func _ready() -> void:
	title_rotation = label.rotation
	wobble_start = 0
	title_scale = label.scale.x
	scale_start = 0

	_reset_wobble()
	_reset_scale()


func _physics_process(delta: float) -> void:
	_update_scale(delta)
	_update_wobble(delta)


func _update_wobble(delta: float):
	wobble_timer = max(wobble_timer - delta, 0)
	label.rotation = lerpf(wobble_start, title_rotation, remap(wobble_timer, wobble_start_time, 0, 0, 1))

	if wobble_timer <= 0:
		_reset_wobble()


func _reset_wobble():
	wobble_start_time = _get_tween_time()
	wobble_timer = wobble_start_time
	wobble_start = label.rotation
	var half = abs((max_wobble + min_wobble) / 2.0)
	var quarter = half / 2.0
	if title_rotation < half:
		title_rotation = randf_range(min_wobble + half + quarter, max_wobble)
	else:
		title_rotation = randf_range(min_wobble, max_wobble - half - quarter)


func _update_scale(delta: float):
	scale_timer = max(scale_timer - delta, 0)
	var new_scale = lerpf(scale_start, title_scale, remap(scale_timer, scale_start_time, 0, 0, 1))
	label.scale = Vector2(new_scale, new_scale)

	if scale_timer <= 0:
		_reset_scale()


func _reset_scale():
	scale_start_time = _get_tween_time()
	scale_timer = scale_start_time
	scale_start = label.scale.x
	var half = abs((max_scale - min_scale) / 2.0)
	var quarter = half / 2.0
	if title_scale < half:
		title_scale = randf_range(min_scale + half + quarter, max_scale)
	else:
		title_scale = randf_range(min_scale, max_scale - half - quarter)


func _get_tween_time():
	return randf_range(min_tween_time, max_tween_time)
