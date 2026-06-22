@tool
class_name Pointer
extends Node2D

signal clicked(pointer: Pointer, flavor: FlavorShopData)

@export var can_click = true
@export var sprite_width = 400
@export var radius: float = 30:
	set(new_radius):
		radius = new_radius
		_shape.radius = radius
		update_sprite_scale()
		queue_redraw()

var flavor: FlavorShopData = null

var _shape: Shape2D = CircleShape2D.new()

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flavor_sprite: Sprite2D = $FlavorSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		sprite.play("default")
		update_sprite_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	global_position = get_viewport().get_mouse_position()
	if can_click and Input.is_action_pressed("pop"):
		clicked.emit(self, flavor)
		can_click = false
		$ClickCooldown.start()
		if flavor:
			flavor = null
			flavor_sprite.hide()
			sprite.show()

	queue_redraw()


func update_sprite_scale():
	if sprite:
		var sprite_scale = radius / sprite_width
		sprite.scale = Vector2(sprite_scale, sprite_scale)


func getShape() -> Shape2D:
	return _shape


func _draw() -> void:
	if Engine.is_editor_hint() or Global.debug:
		draw_circle(Vector2.ZERO, radius, Color.PINK, false, 5)


func _on_click_cooldown_timeout() -> void:
	can_click = true


func _on_flavor_side_bar_flavor_item_clicked(flavor_data: FlavorShopData) -> void:
	flavor = flavor_data
	flavor_sprite.show()
	flavor_sprite.texture = flavor.picture
	flavor_sprite.modulate = flavor_data.color_override
	var sprite_scale = radius / flavor.picture.get_width() * 1.5
	flavor_sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.hide()


func _on_flavor_side_bar_extended() -> void:
	can_click = false


func _on_flavor_side_bar_retracted() -> void:
	if $ClickCooldown.is_stopped():
		can_click = true
