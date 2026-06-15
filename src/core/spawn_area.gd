class_name SpawnArea
extends Node2D

@export var radius:float = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	


func get_point() -> Vector2:
	var direction = randf_range(0, TAU)
	var distance = randf_range(0, radius)
	
	return position + Vector2(distance * cos(direction), distance * sin(direction))
