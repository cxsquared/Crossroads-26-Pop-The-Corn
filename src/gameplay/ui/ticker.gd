extends MarginContainer

@export var label_font : LabelSettings = preload("res://assets/ui_settings/credits_label_settings.tres")
@export var speed:float = 50.0
@export var messages: Array[TickerMessage] = []
@export var hide_time: float = 5.0

var _current_messages: Array[Label]
var _next_messages_index = 0
var _hide_timer = 0
var _hidden = true
var original_pos : Vector2
var _transitioning = false

@onready var background = $Background/ColorRect
@onready var label_parent = $Labels


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hide_timer = hide_time
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_hide_timer = max(_hide_timer - delta, 0)
	
	if _hide_timer > 0:
		return
		
	if not _transitioning and _hidden:
		enter()
		return
	
	if _transitioning:
		return
	
	if _current_messages.size() <= 0:
		add_next_message()
	elif _is_message_fully_on_screen(_current_messages[-1]) and _next_messages_index < messages.size():
		add_next_message()
	
	var index = 0
	for message in _current_messages:
		message.position.x -= speed * delta
		
		if message.position.x <= -message.size.x:
			_current_messages.remove_at.call_deferred(index)
			message.queue_free()
			if _current_messages.size() <= 1:
				exit()
	
		index += 1


func enter():
	_transitioning = true
	original_pos = background.position
	
	_next_messages_index = 0
	for message in _current_messages:
		message.queue_free()
		
	_current_messages.clear()

	background.position.y = size.y
	show()
	
	var tween = create_tween()
	tween.tween_property(background, "position", original_pos, .5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		_hidden = false
		_transitioning = false
	)
	tween.play()


func exit():
	_transitioning = true
	var tween = create_tween()
	tween.tween_property(background, "position", Vector2(background.position.x, background.size.y), 0.5)
	tween.tween_callback(func():
		_hidden = true
		_transitioning = false
		_hide_timer = hide_time
		hide()
		background.position = original_pos
	)
	tween.play()


func add_next_message():
	var text = messages[_next_messages_index].message
	var new_label = Label.new()
	new_label.text = text
	new_label.label_settings = label_font
	new_label.name = text
	new_label.custom_minimum_size.y = size.y
	new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	new_label.position.x = position.x + size.x
	label_parent.add_child(new_label)
	_current_messages.push_back(new_label)
	
	_next_messages_index += 1


func _is_message_fully_on_screen(message:Label):
	if _next_messages_index == 0:
		return false
		
	return message.position.x + messages[_next_messages_index - 1].trailing_padding < size.x - message.size.x
	
