@tool
class_name Pointer
extends Node2D

signal clicked(pointer: Pointer)

@export var can_click = true

@export var radius: float = 30:
	set(new_radius):
		radius = new_radius
		_shape.radius = radius
		queue_redraw()

var _shape: Shape2D = CircleShape2D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	global_position = get_viewport().get_mouse_position()
	if can_click and Input.is_action_pressed("pop"):
		clicked.emit(self)

	queue_redraw()


func getShape() -> Shape2D:
	return _shape


func _draw() -> void:
	if Engine.is_editor_hint() or Global.debug:
		draw_circle(Vector2.ZERO, radius, Color.PINK, false, 5)
