class_name Popcorn
extends RigidBody2D

signal landed(position: Vector2, pops_left: int, iteration: int)
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
var _in_air = false
var _number_of_pops_left: int = 0
var _iteration: int = 0
var _collision_enabled = true
var _shadown_diff: Vector2 = Vector2.ZERO
var _flavors: Array[Flavor]

@onready var sprite: Sprite2D = $Sprite2D
@onready var popped_collider = $Popped
@onready var unpopped_collider = $Unpopped


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
	if z <= floor_z:
		if not get_viewport_rect().has_point(global_position):
			global_position.y = -64
			z = floor_z * .5

	if z >= 1 or _is_falling:
		var sprite_y = -z
		var sprite_scale = remap(z, floor_z, max_height, floor_scale, max_scale)

		sprite.global_position = global_position + Vector2(0, sprite_y)
		sprite.z_index = clamp(z, -25, 50)
		sprite.scale = Vector2(sprite_scale, sprite_scale)

		var shadow_scale = remap(z, 0, max_height, .8, .2)
		$Shadow.scale = Vector2(shadow_scale, shadow_scale)


func _physics_process(delta: float) -> void:
	sprite.global_position = global_position
	sprite.rotation = rotation

	if z <= floor_z:
		return

	if $Shadow.visible:
		pass
		$Shadow.global_position = global_position + _shadown_diff
		$Shadow.rotation = -rotation

	if _is_falling:
		z -= gravity * delta
		# check if we are off the level
		if z < floor_z:
			z = floor_z
			sprite.scale = Vector2(floor_scale, floor_scale)
			_is_falling = false
			hit_floor.emit(self)

		return

	if z < 1 and _in_air:
		land()
	elif z >= 1:
		z += z_velocity
		z_velocity = max(z_velocity * z_friction, .5)
		z -= gravity * delta

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
	z = 0
	sprite.position = Vector2(0, 0)
	enable_collision()
	landed.emit(global_position, _number_of_pops_left, _iteration + 1)
	_in_air = false
	var sprite_scale = remap(0, floor_z, max_height, floor_scale, max_scale)
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.z_index = 0

	$Shadow.hide()


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
	z = 2
	_in_air = true


func add_flavor(flavor: Flavor):
	_flavors.push_back(flavor)
	popped.connect(flavor._on_popped)
	flavor.on_added(self)

	if flavor.decoration:
		var flavor_sprite = flavor.decoration.instantiate() as Sprite2D
		flavor_sprite.modulate = flavor.color_override
		flavor_sprite.rotate(randf_range(-TAU, TAU))

		sprite.add_child(flavor_sprite)


func pop(global_impact_point: Vector2, extra_pops_left: int = 0, iteration: int = 0, recovery_pop: bool = false):
	var adjusted_z_impulse = z_impulse
	var adjusted_pop_force = pop_force
	if recovery_pop:
		adjusted_z_impulse = adjusted_z_impulse * .3
		pop_force = pop_force * .5
	elif has_popped:
		adjusted_z_impulse = adjusted_z_impulse * .7
		pop_force = pop_force * .3

	has_popped = true
	z_velocity += adjusted_z_impulse * remap(iteration, 0, 4, 1, .2)
	z = 2
	$Shadow.show()

	sprite.texture = popped_sprite
	popped_collider.disabled = false
	unpopped_collider.disabled = true

	var direction = global_impact_point.direction_to(global_position) # random = randf_range(0, TAU)
	var impulse = direction * adjusted_pop_force # random = Vector2(pop_force * cos(direction), pop_force * sin(direction))
	apply_impulse(impulse)

	_iteration = iteration
	_number_of_pops_left = extra_pops_left
	if _number_of_pops_left < 0 or extra_pops > 0:
		_number_of_pops_left = extra_pops
	_in_air = true
	popped.emit(self, global_impact_point, _number_of_pops_left, iteration)


func _on_body_exited(body: Node) -> void:
	var speed = linear_velocity.abs().length()
	if not _can_post_pop or speed < post_pop_min_speed:
		return

	if body is Popcorn:
		body.post_pop_pop(linear_velocity.abs().length())


func _on_spawn_delay_post_pop_timeout() -> void:
	_can_post_pop = true
