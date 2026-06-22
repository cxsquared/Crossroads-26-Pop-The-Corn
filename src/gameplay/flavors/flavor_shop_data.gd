class_name FlavorShopData
extends Resource

@export var name: String = "FlavorBase"
@export var description: String = "You shouldn't see this.\nThis is the base description"
@export var price: int = 5
@export var picture: Texture2D = preload("res://assets/textures/flavor_dots.png")
@export var flavor_script: Script
@export var color_override: Color = Color.WHITE
