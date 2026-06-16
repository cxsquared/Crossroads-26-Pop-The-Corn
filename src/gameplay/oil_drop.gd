class_name OilDrop
extends Node2D

signal dropped(oil_drop: OilDrop)

@export var direction = Vector2.UP
@export var distance: float = 100
@export var distance_per_second = 50
@export var distance_moved = 0
@export var starting_pos: Vector2
@export var max_scale:float = 2

var _has_dropped = false

@onready var sprite = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if distance_moved < distance:
		distance_moved += distance_per_second * delta

		position = starting_pos + direction * distance_moved

		var half_distance = distance * .5

		var sprite_scale: float = 1
		if distance_moved > half_distance:
			sprite_scale = remap(distance_moved, half_distance, distance, max_scale, 1.0)
		else:
			sprite_scale = remap(distance_moved, 0, half_distance, 1.0, max_scale)

		sprite.scale = Vector2(sprite_scale, sprite_scale)

		if not _has_dropped and distance_moved >= distance:
			_has_dropped = true
			dropped.emit(self)


func spawn(fire_dir: Vector2, total_distance: float, fired_from: Vector2):
	direction = fire_dir
	distance = total_distance
	starting_pos = fired_from
	distance_moved = 0
