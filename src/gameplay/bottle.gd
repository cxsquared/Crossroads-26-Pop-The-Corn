extends Node2D

signal fired(oil_drop: OilDrop)

@export var oil_drop_scene = preload("res://src/gameplay/oil_drop.tscn")
@export var show_distance = true
@export var direction = Vector2.UP
@export var power_distance: float = 100
@export var min_power = 200
@export var max_power = 800
@export var power_bar_speed: float = 2.5

var _firing = false
var _firing_time: float = 0

@onready var bottle_sprite = $Sprite2D
@onready var power_bar = $PowerBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	power_bar.max_value = max_power
	power_bar.min_value = min_power
	power_bar.value = min_power


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_look_at_mouse()

	if _firing:
		_firing_time += power_bar_speed * delta
		power_bar.value = min_power + (abs(sin(_firing_time)) * (max_power - min_power))
		power_distance = power_bar.value


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_firing_time = 0
		power_bar.value = min_power
		power_bar.show()
		_firing = true
	elif _firing and event.is_action_released("fire"):
		_firing = false
		power_bar.hide()
		_spawn_oil()


func _draw() -> void:
	if _firing and show_distance:
		pass
		# draw_line(bottle_sprite.position, bottle_sprite.position + (direction * max_power * .5), Color.BLACK, 5)


func _spawn_oil():
	var global_mouse_pos = _get_global_mouse_pos()
	direction = global_position.direction_to(global_mouse_pos)

	var drop = oil_drop_scene.instantiate() as OilDrop
	drop.spawn(direction, power_distance, Vector2.ZERO)
	add_child(drop)
	fired.emit(drop)


func _look_at_mouse():
	var global_mouse_pos = _get_global_mouse_pos()

	bottle_sprite.look_at(global_mouse_pos)
	bottle_sprite.rotate(PI * .5)

	direction = global_position.direction_to(global_mouse_pos)


func _get_global_mouse_pos():
	var viewport = get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()
