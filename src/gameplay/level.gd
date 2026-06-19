extends Node2D

signal score_updated(new_score: int)

@export var popcorn: PackedScene = preload("res://src/gameplay/popcorn.tscn")
@export var number_to_spawn = 10
@export var pop_radius: float = 56
@export var reset_force_delay: float = .2
@export var max_reset_iterations = 3
@export var starting_pops = 2
@export var floor_z = -10
@export var score: int = 0

var popcorns: Array[Popcorn] = []

@onready var spawnable_area = $Pan/SpawnArea as SpawnArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelHud.reparent(Global.hud)

	var pans = find_children("Pan*")

	for pan in pans:
		for i in range(number_to_spawn):
			var point = spawnable_area.get_point()

			var new_corn = popcorn.instantiate() as Popcorn
			new_corn.position = point
			new_corn.name = "Popcorn%d" % i
			new_corn.landed.connect(_on_landed)
			new_corn.starting_pops = starting_pops
			new_corn.floor_z = self.floor_z
			new_corn.collision_enabled.connect(_on_popcorn_collision_enabled)
			new_corn.hit_floor.connect(func(_corn: Popcorn):
					score += 1
					score_updated.emit(score)
			)
			pan.add_child(new_corn)
			popcorns.push_back(new_corn)


func _on_landed(corn_position: Vector2, pops_left: int, iteration: int):
	if pops_left > 0:
		for corn in popcorns:
			if corn_position.distance_to(corn.global_position) <= pop_radius:
				corn.pop(corn_position, pops_left, iteration)


func _on_popcorn_collision_enabled(corn: Popcorn, iteration: int = 0):
	if iteration >= max_reset_iterations:
		return

	iteration += 1
	var overlap_query := PhysicsShapeQueryParameters2D.new()

	overlap_query.exclude.push_back(corn.get_rid())
	overlap_query.collide_with_areas = true
	overlap_query.collide_with_bodies = false
	overlap_query.transform = corn.global_transform
	overlap_query.shape = corn.get_active_shape()

	var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_query)

	if overlaps.size() <= 0:
		var corn_index = popcorns.find(corn)
		popcorns.remove_at(corn_index)
		corn.fall()
		return

	for overlap in overlaps:
		var collider = overlap.collider as Area2D

		if collider.get_collision_layer_value(4):
			# this is just the full pan we use to detect if we left the level
			continue

		corn.pop(corn.global_position.direction_to(collider.global_position) * 5, 0, 0, true)
		if iteration < max_reset_iterations:
			var check_tween = create_tween()
			check_tween.tween_callback(func():
					_on_popcorn_collision_enabled(corn, iteration)
			).set_delay(reset_force_delay)
			check_tween.play()

		break


func _on_bottle_fired(oil_drop: OilDrop) -> void:
	oil_drop.dropped.connect(_on_oil_dropped)


func _on_oil_dropped(oil_drop: OilDrop):
	for corn in popcorns:
		if oil_drop.global_position.distance_to(corn.global_position) <= pop_radius:
			corn.pop(oil_drop.global_position, starting_pops, 0)

	oil_drop.queue_free()


func _on_pointer_clicked(pointer: Pointer) -> void:
	var overlap_query := PhysicsShapeQueryParameters2D.new()

	overlap_query.collide_with_bodies = true
	overlap_query.transform = pointer.transform
	overlap_query.shape = pointer.getShape()

	var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_query)

	for overlap in overlaps:
		var collider = overlap.collider

		if not collider or collider is not RigidBody2D or not collider.get_collision_layer_value(2) or collider is not Popcorn:
			# we only care about popcorn aka layer 2
			continue

		var corn = collider as Popcorn
		corn.pop(pointer.global_position, starting_pops, 0)
