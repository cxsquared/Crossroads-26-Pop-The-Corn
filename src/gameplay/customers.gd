extends Node2D

signal all_customers_added()

@export var bucket_texture = preload("res://assets/textures/bucket.png")

@export var small_bucket_scale = Vector2(0.5, .5)
@export var medium_bucket_scale = Vector2(.8, .7)
@export var large_bucket_scale = Vector2(0, 0)
@export var far_x = 1280 * .75
@export var bucket_padding = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func show_new_customers():
	var texture_width = bucket_texture.get_width()
	var last_x_end: float = -1
	var last_bucket_scale = Vector2.ZERO
	var i = 1
	var total_customers = Global.current_run.current_customers.size()
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
		new_customer.z_index = 1

		var target_label = Label.new()
		target_label.text = "+%d" % customer.popcorn_needed
		target_label.rotation_degrees = -20
		target_label.theme = Global.default_theme
		target_label.z_index = -1
		target_label.add_theme_font_size_override("font_size", 70)
		var target_tween = target_label.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		target_tween.tween_property(target_label, "position", Vector2(-40, -150), 0.6).set_delay(.6)
		target_tween.tween_property(target_label, "modulate", Color.TRANSPARENT, 1.6).set_delay(.6)

		add_child(new_customer)

		var end_x = far_x
		if last_x_end > 0:
			end_x = last_x_end - (texture_width * last_bucket_scale.x) - bucket_padding

		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(new_customer, "position", Vector2(end_x, new_customer.position.y), .8).set_delay(i * .3)
		tween.parallel().tween_callback(func():
				new_customer.add_child(target_label)
				target_tween.play()
		).set_delay(i * .1)
		if i >= total_customers - 1:
			tween.tween_callback(func():
					all_customers_added.emit()
			)

		tween.play()

		last_x_end = end_x
		last_bucket_scale = new_customer.scale
		i += 1
