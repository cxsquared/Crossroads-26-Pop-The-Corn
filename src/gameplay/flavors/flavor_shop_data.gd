class_name FlavorShopData
extends Resource

@export var name: String = "FlavorBase"
@export var description: String = "You shouldn't see this.\nThis is the base description"
@export var price: int = 5
@export var picture: Texture2D = preload("res://assets/textures/flavor_dots.png")
@export var flavor_script: Script


func _init(name, description, flavor_script: Script) -> void:
	self.name = name
	self.description = description
	self.flavor_script = flavor_script
