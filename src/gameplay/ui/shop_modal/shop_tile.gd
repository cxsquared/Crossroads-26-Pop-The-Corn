class_name ShopTile
extends NinePatchRect

signal bought(flavor: FlavorShopData, price: int)

@export var flavor: FlavorShopData:
	set(new_flavor):
		flavor = new_flavor

var on_sale = false
var price: int = 0

@onready var name_label: Label = $Margin/Body/Name
@onready var description_label: Label = $Margin/Body/HBoxContainer/MarginContainer/Description
@onready var price_label: Label = $Margin/Body/Price
@onready var picture_rect: TextureRect = $Margin/Body/HBoxContainer/Picture
@onready var buy_button: Button = $Buy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_tile()
	$Bougth.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func disable():
	buy_button.disabled = true


func enable():
	buy_button.disabled = false


func update_tile():
	name_label.text = flavor.name
	description_label.text = flavor.description
	price = flavor.price
	if on_sale:
		price = floor(price * .5)

	price_label.text = "$%d" % price
	picture_rect.texture = flavor.picture


func _on_buy_pressed() -> void:
	$Bougth.show()
	disable()
	bought.emit(flavor, price)
