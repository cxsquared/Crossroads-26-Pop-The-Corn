class_name FlavorSideBar
extends Control

signal flavor_item_clicked(flavor_data: FlavorShopData)
signal extended()
signal retracted()

@export var side_item_scene = preload("res://src/gameplay/ui/flavor_side_bar/flavor_side_item.tscn")
@export var hide_offset = -25
@export var extend_sound: AudioStream
@export var retract_sound: AudioStream

var side_bar_tween: Tween
var auto_hide_tween: Tween
var fully_extended = false
var fully_retracted = true

var _initial_pos
var _flavors: Dictionary[String, FlavorItem] = {}
var _item_hover = false

@onready var side_bar: NinePatchRect = $NinePatchRect
@onready var flavor_container: VBoxContainer = $NinePatchRect/MarginContainer/FlavorContainer
@onready var hide_timer: Timer = $HideTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_pos = side_bar.position
	side_bar.position.x = _initial_pos.x + side_bar.size.x + hide_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update_flavor_items():
	while not Global.current_run.flavors_bought.is_empty():
		var flavor: FlavorShopData = Global.current_run.flavors_bought.pop_back()

		var flavor_item = _flavors.get(flavor.name) as FlavorItem

		if not flavor_item:
			flavor_item = side_item_scene.instantiate()
			flavor_item.flavor_data = flavor
			flavor_container.add_child(flavor_item)
			flavor_item.flavor_item_clicked.connect(_on_flavor_item_clicked)
			flavor_item.mouse_entered.connect(_on_mouse_entered)
			flavor_item.mouse_exited.connect(_on_mouse_exited)
			_flavors.set(flavor.name, flavor_item)
		else:
			flavor_item.amount += 1
			if flavor_item.amount > 0:
				flavor_item.enable()

	for item_key in _flavors:
		var item = _flavors.get(item_key)
		if item.amount <= 0:
			_flavors.erase(item_key)
			item.queue_free()

	if _flavors.is_empty():
		$NinePatchRect/Empty.show()
	else:
		$NinePatchRect/Empty.hide()


func extend(auto_hide = false, play_sound = true):
	fully_retracted = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	hide_timer.stop()

	if side_bar_tween and side_bar_tween.is_running():
		side_bar_tween.kill()

	side_bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	side_bar_tween.tween_property(side_bar, "position", Vector2(_initial_pos.x, side_bar.position.y), .2)
	side_bar_tween.tween_callback(func():
			fully_extended = true
	)
	side_bar_tween.play()

	extended.emit()

	if not fully_extended and play_sound:
		audio_player.stream = extend_sound
		audio_player.play()

	if auto_hide:
		$AutoHide.start()


func retract():
	hide_timer.stop()
	side_bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	side_bar_tween.tween_property(side_bar, "position", Vector2(_initial_pos.x + side_bar.size.x + hide_offset, side_bar.position.y), .2)
	side_bar_tween.tween_callback(func():
			retracted.emit()
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			fully_retracted = true

	)
	side_bar_tween.play()

	if fully_extended:
		audio_player.stream = retract_sound
		audio_player.play()

	fully_extended = false


func _on_item_mouse_entered() -> void:
	_item_hover = true


func _on_item_mouse_exited() -> void:
	_item_hover = false


func _on_mouse_entered() -> void:
	$AutoHide.stop()

	extend()


func _on_mouse_exited() -> void:
	hide_timer.start()


func _on_hide_timer_timeout() -> void:
	if not _item_hover:
		retract()


func _on_flavor_item_clicked(flavor_data: FlavorShopData):
	Global.ui_sounds.play_confirm()
	fully_extended = false
	flavor_item_clicked.emit(flavor_data)
	_item_hover = false
	retract()


func _on_auto_hide_timeout() -> void:
	retract()
