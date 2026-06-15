class_name Popcorn
extends RigidBody2D

signal popped(position:Vector2, pops_left:int, iteration:int)

@export var popped_sprite = preload("res://assets/textures/popcorn.png")
@export var on_pop_radius:float = 56
@export var pop_force:float = 50
@export var gravity:float = 980.0
@export var z_impulse: float = 100.0
@export var z_friction: float = 0.8
@export var max_scale: float = 2.0
@export var max_height : float = 300.0
@export var starting_pops: int = 4

var has_popped = false
var z:float = 0
var z_velocity: float = 0
var air_velocity = Vector2.ZERO

var _in_air = false
var _number_of_pops_left:int = 0
var _iteration: int = 0

@onready var sprite : Sprite2D = $Sprite2D
@onready var popped_collider = $Popped
@onready var unpopped_collider = $Unpopped


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popped_collider.disabled = true
	unpopped_collider.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if z > 1:
		sprite.global_position = global_position + Vector2(0, -max(z, 0))
		sprite.z_index = min(z, 50)
		var sprite_scale = remap(z, 0, max_height, 1, max_scale)
		sprite.scale = Vector2(sprite_scale, sprite_scale)
		var shadow_scale = remap(z, 0, max_height, 1, .5)
		$Shadow.scale = Vector2(shadow_scale, shadow_scale)


func _physics_process(delta: float) -> void:
	if z < 1 and _in_air:
		land()
	elif z >= 1:
		disable_collision()
		z += z_velocity
		z_velocity = max(z_velocity * z_friction, .5)
		z -= gravity * delta


func enable_collision():
	if has_popped:
		$Popped.disabled = true
		$Unpopped.disabled = false
	else:
		$Popped.disabled = false
		$Unpopped.disabled = true


func disable_collision():
	$Popped.disabled = false
	$Unpopped.disabled = false


func land():
	z = 0
	sprite.position = Vector2(0, 0)
	enable_collision()
	popped.emit(position, _number_of_pops_left - 1, _iteration + 1)
	_in_air = false
	sprite.scale = Vector2(1, 1)
	sprite.z_index = 0
	$Shadow.hide()


func pop(number_of_pops_left:int, iteration: int = 0):
	if has_popped:
		return
		
	has_popped = true
	z_velocity += z_impulse * remap(iteration, 0, starting_pops, 1, .2)
	z = 1
	$Shadow.show()
	
	sprite.texture = popped_sprite
	popped_collider.disabled = false
	unpopped_collider.disabled = true
	
	var direction = randf_range(0, TAU)
	var impulse = Vector2(pop_force * cos(direction), pop_force * sin(direction))
	apply_impulse(impulse)
	
	_iteration = iteration
	_number_of_pops_left = number_of_pops_left
	_in_air = true


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not has_popped and event.is_action_pressed("pop"):
		pop(starting_pops)
