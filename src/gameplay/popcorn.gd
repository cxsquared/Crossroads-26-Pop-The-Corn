class_name Popcorn
extends RigidBody2D

signal popped(position: Vector2, pops_left: int, iteration: int)
signal collision_enabled(popcorn: Popcorn)

@export var popped_sprite = preload("res://assets/textures/popcorn.png")
@export var pop_force: float = 100
@export var collision_height: float = 50
@export var gravity: float = 980.0
@export var z_impulse: float = 100.0
@export var z_friction: float = 0.8
@export var max_scale: float = 2.0
@export var max_height: float = 300.0
@export var starting_pops: int = 4

var has_popped = false
var z: float = 0
var z_velocity: float = 0
var air_velocity = Vector2.ZERO

var _is_falling = false
var _in_air = false
var _number_of_pops_left: int = 0
var _iteration: int = 0
var _collision_enabled = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var popped_collider = $Popped
@onready var unpopped_collider = $Unpopped


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popped_collider.disabled = true
	unpopped_collider.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if z > 1 or _is_falling:
		var sprite_y = -max(z, 0)
		var sprite_scale = remap(z, 0, max_height, 1, max_scale)
		if _is_falling and z <= 0:
			sprite_y = -z
			sprite_scale = remap(z, -max_height, max_height, 0, max_scale)
			if sprite_scale <= 0:
				queue_free()

		sprite.global_position = global_position + Vector2(0, sprite_y)
		sprite.z_index = min(z, 50)
		sprite.scale = Vector2(sprite_scale, sprite_scale)

		var shadow_scale = remap(z, 0, max_height, 1, .5)
		$Shadow.scale = Vector2(shadow_scale, shadow_scale)


func _physics_process(delta: float) -> void:
	if _is_falling:
		z -= gravity * delta
		# check if we are off the level
		if z < -get_viewport_rect().size.y + 20:
			queue_free()

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


func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not has_popped and event.is_action_pressed("pop"):
		pop(viewport.get_mouse_position(), starting_pops)


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
	popped.emit(global_position, _number_of_pops_left - 1, _iteration + 1)
	_in_air = false
	sprite.scale = Vector2(1, 1)
	sprite.z_index = 0
	$Shadow.hide()


func get_active_shape() -> Shape2D:
	if has_popped:
		return popped_collider.shape

	return unpopped_collider.shape


func fall():
	disable_collision()
	_is_falling = true
	$Shadow.hide()


func pop(global_impact_point: Vector2, number_of_pops_left: int, iteration: int = 0, recovery_pop: bool = false):
	if has_popped and not recovery_pop:
		return

	var adjusted_z_impulse = z_impulse
	var adjusted_pop_force = pop_force
	if recovery_pop:
		adjusted_z_impulse = adjusted_z_impulse * .5
		pop_force = pop_force * .5

	has_popped = true
	z_velocity += adjusted_z_impulse * remap(iteration, 0, starting_pops, 1, .2)
	z = 1
	$Shadow.show()

	sprite.texture = popped_sprite
	popped_collider.disabled = false
	unpopped_collider.disabled = true

	var direction = global_impact_point.direction_to(global_position) # random = randf_range(0, TAU)
	var impulse = direction * adjusted_pop_force # random = Vector2(pop_force * cos(direction), pop_force * sin(direction))
	apply_impulse(impulse)

	_iteration = iteration
	_number_of_pops_left = number_of_pops_left
	_in_air = true
