extends Node2D

@export var popcorn : PackedScene = preload("res://src/gameplay/popcorn.tscn")
@export var number_to_spawn = 10
@export var pop_radius:float = 56

var popcorns: Array[Popcorn] = []

@onready var spawnable_area = $Pan/SpawnArea as SpawnArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(number_to_spawn):
		var point = spawnable_area.get_point()
		
		var new_corn = popcorn.instantiate() as Popcorn
		new_corn.position = point
		new_corn.name = "Popcorn%d" % i
		new_corn.popped.connect(_on_popped)
		$Pan.add_child(new_corn)
		popcorns.push_back(new_corn)


func _on_popped(corn_position:Vector2, pops_left:int, iteration:int):
	if pops_left > 0:
		for corn in popcorns:
			if corn_position.distance_to(corn.position) <= pop_radius:
				corn.pop(pops_left, iteration)
