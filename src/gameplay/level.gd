class_name Level
extends Node2D

signal score_updated(new_score: int)
signal on_any_pop(popcorn: Popcorn)

@export var popcorn_scene: PackedScene = preload("res://src/gameplay/popcorn.tscn")

@export_category("Each Round")
@export var base_wave_spawn = 10
@export var initial_spawn_number = 50
@export var score: int = 0
@export var target = 15
@export var starting_pop_attempts = 5

@export_category("Collision Quirks")
@export var reset_force_delay: float = .2
@export var max_reset_iterations = 3
@export var floor_z = -10

@export_category("Probably not needed")
@export var pop_radius: float = 56

var popcorns: Array[Popcorn] = []
var player_pops_left = 0

@onready var spawnable_area = $Popper/SpawnArea as SpawnArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.level = self
	$LevelHud.reparent(Global.hud)
	player_pops_left = starting_pop_attempts

	spawn_corn(initial_spawn_number)


func reset_pops():
	var number_to_spawn = (Global.current_run.wave - 1) * base_wave_spawn
	score = 0
	score_updated.emit(score)
	target = Global.current_run.get_current_wave_target()
	player_pops_left = starting_pop_attempts

	spawn_corn(number_to_spawn, true)


func spawn_corn(amount: int, add_test_flavors = false):
	var poppers = find_children("Popper*")

	var existing_corn_num = popcorns.size()

	for popper in poppers:
		for i in range(amount):
			var point = spawnable_area.get_point()

			var new_corn = popcorn_scene.instantiate() as Popcorn
			new_corn.position = point
			new_corn.name = "Popcorn%d" % [existing_corn_num + i]
			new_corn.landed.connect(_on_landed)
			new_corn.popped.connect(_on_popped)
			new_corn.floor_z = self.floor_z
			new_corn.collision_enabled.connect(_on_popcorn_collision_enabled)
			new_corn.hit_floor.connect(func(_corn: Popcorn):
					score += 1
					score_updated.emit(score)
			)

			popper.add_child(new_corn)
			popcorns.push_back(new_corn)

			if add_test_flavors:
				_add_test_flavor(new_corn)


func _add_test_flavor(new_popcorn: Popcorn):
	if Global.rand_bool(3):
		var flavors: Array[Flavor]
		if Global.rand_bool(5):
			if Global.rand_bool(2):
				flavors.push_back(ExtraSpawn.new())
			if Global.rand_bool(2):
				flavors.push_back(ChainReaction.new())
			if Global.rand_bool(2):
				flavors.push_back(NearbyPop.new(func():
						return popcorns
				))
			if Global.rand_bool(2):
				var pop_after_pop = PopAfterPops.new()
				on_any_pop.connect(pop_after_pop._on_any_pop)
				flavors.push_back(pop_after_pop)
		else:
			var new_flavor = [
				PopAfterPops.new(),
				ExtraSpawn.new(),
				ChainReaction.new(),
				NearbyPop.new(func(): return popcorns)].pick_random()

			if new_flavor is PopAfterPops:
				on_any_pop.connect(new_flavor._on_any_pop)

			flavors.push_back(new_flavor)

		for flavor in flavors:
			new_popcorn.add_flavor(flavor)


func _on_landed(corn_position: Vector2, pops_left: int, iteration: int):
	if pops_left > 0:
		for corn in popcorns:
			if corn_position.distance_to(corn.global_position) <= pop_radius:
				corn.pop(corn_position, pops_left - 1, iteration)


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


func _on_pointer_clicked(pointer: Pointer) -> void:
	if player_pops_left <= 0:
		Global.main.goto_scenep("res://src/gameplay/lobby.tscn", true)
		return

	var overlap_query := PhysicsShapeQueryParameters2D.new()

	overlap_query.collide_with_bodies = true
	overlap_query.transform = pointer.transform
	overlap_query.shape = pointer.getShape()

	var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_query)
	var hit_corn = false

	for overlap in overlaps:
		var collider = overlap.collider

		if not collider or collider is not RigidBody2D or not collider.get_collision_layer_value(2) or collider is not Popcorn:
			# we only care about popcorn aka layer 2
			continue

		var corn = collider as Popcorn
		corn.pop(pointer.global_position)
		hit_corn = true

	if hit_corn:
		player_pops_left -= 1


func _on_popped(popcorn: Popcorn, _global_impact_point: Vector2, _number_of_pops_left: int, _iteration: int):
	on_any_pop.emit(popcorn)
