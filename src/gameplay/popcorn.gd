class_name Popcorn
extends RigidBody2D

signal landed(landed_popcorn:Popcorn, position: Vector2, pops_left: int, iteration: int)
signal collision_enabled(popcorn: Popcorn)
signal hit_floor(popcorn: Popcorn)
signal popped(popcorn: Popcorn, global_impact_point: Vector2, number_of_pops_left: int, iteration: int)

@export var popped_sprite = preload("res://assets/textures/popcorn.png")
@export var testing_flavors: Array[Flavor]

@export_category("Stats")
@export var pop_force: float = 1500.0
@export var extra_pops: int = 0 # by default we only pop ourselves
@export var post_pop_min_speed: float = 100

@export_category("Z Collision")
@export var collision_height: float = 125.0
@export var gravity: float = 980.0
@export var z_impulse: float = 100.0
@export var z_friction: float = 0.8
@export var max_scale: float = 2.0
@export var max_height: float = 300.0
@export var floor_z = -10
@export var floor_scale = .8

var has_popped = false
var z: float = 0
var z_velocity: float = 0
var air_velocity = Vector2.ZERO

var _can_post_pop = false
var _is_falling = false
var _has_fallen = false
var _in_air = false
var _number_of_pops_left: int = 0
var _iteration: int = 0
var _collision_enabled = true
var _shadown_diff: Vector2 = Vector2.ZERO
var _flavors: Array[Flavor]

@onready var sprite: Sprite2D = $Sprite2D
@onready var popped_collider = $Popped
@onready var unpopped_collider = $Unpopped
@onready var score_label: Label = $Score


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popped_collider.disabled = true
	unpopped_collider.disabled = false
	_shadown_diff = $Shadow.position

	var sprite_scale = remap(0, floor_z, max_height, floor_scale, max_scale)
	sprite.scale = Vector2(sprite_scale, sprite_scale)

	for flavor in testing_flavors:
		add_flavor(flavor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	sprite.global_position = global_position
	sprite.rotation = rotation

	if $Shadow.visible:
		$Shadow.global_position = global_position + _shadown_diff
		$Shadow.rotation = -rotation

	if z >= floor_z:
		var sprite_y = -z
		var sprite_scale = remap(z, floor_z, max_height, floor_scale, max_scale)

		sprite.global_position = global_position + Vector2(0, sprite_y)
		sprite.z_index = clamp(z, -25, 50)
		sprite.scale = Vector2(sprite_scale, sprite_scale)

		var shadow_scale = remap(z, 0, max_height, .8, .2)
		$Shadow.scale = Vector2(shadow_scale, shadow_scale)


func _physics_process(delta: float) -> void:
	if _is_falling:
		_handle_falling(delta)
		return

	# Fix issue if we go down to fast
	if _in_air and not _has_fallen and z < 1:
		land()
		return

	if _has_fallen:
		z = floor_z
		z_velocity = 0
		_is_falling = false
		_in_air = false
		return

	z += z_velocity
	z_velocity = max(z_velocity * z_friction, 0)
	if z >= 1:
		z = max(z - gravity * delta, 0)

	if z > collision_height:
		disable_collision()
	else:
		enable_collision()


func enable_collision():
	if _collision_enabled:
		return

	_collision_enabled = true
	if has_popped:
		$Popped.disabled = true
		$Unpopped.disabled = false
	else:
		$Popped.disabled = false
		$Unpopped.disabled = true

	collision_enabled.emit(self)


func disable_collision():
	if not _collision_enabled:
		return

	_collision_enabled = false
	$Popped.disabled = true
	$Unpopped.disabled = true


func land():
	# Reset z physics
	z = 0
	z_velocity = 0

	# we probably already landed
	if not _in_air:
		return

	_in_air = false

	# Reset graphics
	sprite.position = Vector2(0, 0)
	var sprite_scale = remap(0, floor_z, max_height, floor_scale, max_scale)
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.z_index = 0
	$Shadow.hide()

	# Enable collision and let people know we landed
	enable_collision()
	landed.emit(self, global_position, _number_of_pops_left, _iteration + 1)


func get_active_shape() -> Shape2D:
	if has_popped:
		return popped_collider.shape

	return unpopped_collider.shape


func fall():
	_is_falling = true
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)
	$Shadow.hide()


func post_pop_pop(hitter_speed: float):
	if not has_popped or _in_air or z < 0 or linear_velocity.abs().length() > 2:
		return

	z_velocity += z_impulse * remap(hitter_speed, post_pop_min_speed, post_pop_min_speed * 2, .25, .8)
	z = 1
	_in_air = true


func add_flavor(flavor: Flavor):
	_flavors.push_back(flavor)
	popped.connect(flavor._on_popped)
	flavor.on_added(self)
	sprite.add_child(flavor)


func pop(global_impact_point: Vector2, extra_pops_left: int = 0, iteration: int = 0, recovery_pop: bool = false):
	if iteration > 10 or z >= 1:
		return

	# Swap out texture and colliders from unpopped to popped
	sprite.texture = popped_sprite
	popped_collider.disabled = false
	unpopped_collider.disabled = true
	$Shadow.show()

	# Move the popcorn on the x/y axix using godot physics
	var adjusted_pop_force = pop_force

	var direction = global_impact_point.direction_to(global_position) # random = randf_range(0, TAU)
	var impulse = direction * adjusted_pop_force # random = Vector2(pop_force * cos(direction), pop_force * sin(direction))
	apply_impulse(impulse)

	# Apply z impulse using our physics 
	var adjusted_z_impulse = z_impulse

	if recovery_pop:
		adjusted_z_impulse = adjusted_z_impulse * .3
		pop_force = pop_force * .5

	z_velocity += adjusted_z_impulse * remap(min(iteration, 4), 0, 4, 1, .3)
	z = 1

	has_popped = true
	_in_air = true
	_is_falling = false

	# Figure out if we should pop other things
	_iteration = iteration
	_number_of_pops_left = extra_pops_left
	if _number_of_pops_left < 0 or extra_pops > 0:
		_number_of_pops_left = extra_pops

	# Let the everyone know we popped
	popped.emit(self, global_impact_point, _number_of_pops_left, iteration)


func _handle_falling(delta: float):
	if _has_fallen:
		return

	# check if we are off the level
	if z <= floor_z:
		z = floor_z
		_is_falling = false
		_trigger_score()
		_has_fallen = true
		hit_floor.emit(self)
	else:
		z = max(z - gravity * delta, floor_z)


func _trigger_score():
	if score_label:
		score_label.show()
		var s_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		s_tween.tween_property(score_label, "position", sprite.global_position + Vector2(0, -75), .6).from(sprite.global_position)
		s_tween.parallel().tween_property(score_label, "modulate", Color.TRANSPARENT, 1.6).set_delay(.4)
		s_tween.tween_callback(func():
				score_label.queue_free()
		)
		s_tween.play()


func _on_body_exited(body: Node) -> void:
	var speed = linear_velocity.abs().length()
	if not _can_post_pop or speed < post_pop_min_speed:
		return

	if body is Popcorn:
		body.post_pop_pop(linear_velocity.abs().length())


func _on_spawn_delay_post_pop_timeout() -> void:
	_can_post_pop = true
