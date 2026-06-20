extends Node2D

@export var bucket_texture = preload("res://assets/textures/bucket.png")

@export var small_bucket_scale = Vector2(0.5, .5)
@export var medium_bucket_scale = Vector2(.8, .7)
@export var large_bucket_scale = Vector2(0, 0)
@export var far_x = 1280 * .75
@export var bucket_padding = 20

var transitioning = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.current_run:
		Global.new_run()

	Global.current_run.next_wave()
	
	if Global.level:
		Global.level.reset_pops()

	var texture_width = bucket_texture.get_width()
	var last_x_end: float = -1
	var last_bucket_scale = Vector2.ZERO
	var i = 1
	for customer in Global.current_run.current_customers:
		var new_customer = Sprite2D.new()
		new_customer.texture = bucket_texture

		match customer.size:
			0:
				new_customer.scale = small_bucket_scale
			1:
				new_customer.scale = medium_bucket_scale
			2:
				new_customer.scale = large_bucket_scale

		new_customer.position.x = -texture_width
		new_customer.position.y = get_viewport_rect().size.y / 2

		add_child(new_customer)

		var end_x = far_x
		if last_x_end > 0:
			end_x = last_x_end - (texture_width * last_bucket_scale.x) - bucket_padding

		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(new_customer, "position", Vector2(end_x, new_customer.position.y), .8).set_delay(i * .3)
		tween.play()

		last_x_end = end_x
		last_bucket_scale = new_customer.scale
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not transitioning and Input.is_action_pressed("pop"):
		transitioning = true
		if Global.current_run.wave <= 1:
			Global.main.goto_scenep("res://src/gameplay/level.tscn")
		else:
			Global.main.go_to_last_scene()
