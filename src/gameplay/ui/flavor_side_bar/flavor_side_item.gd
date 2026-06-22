class_name FlavorItem
extends Control

signal flavor_item_clicked(flavor_data: FlavorShopData)

@export var flavor_data: FlavorShopData
@export var amount: int = 1:
	set (new_amount):
		amount = new_amount
		if amount_label:
			amount_label.text = "%d" % amount

var enabled = true

@onready var name_label: Label = $Name
@onready var picture_rect: TextureRect = $Picture
@onready var amount_label: Label = $Amount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_label.text = flavor_data.name
	picture_rect.texture = flavor_data.picture
	name_label.add_theme_color_override("font_outline_color", flavor_data.color_override)
	picture_rect.modulate = flavor_data.color_override


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func enable():
	enabled = true
	modulate = Color.WHITE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP


func disable():
	enabled = false
	modulate = Color("666666")
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_gui_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed("pop"):
		amount -= 1
		amount_label.text = "%d" % amount
		if amount <= 0:
			disable()

		flavor_item_clicked.emit(flavor_data)
