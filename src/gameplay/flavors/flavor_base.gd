@abstract
class_name Flavor
extends Sprite2D

static var all_flavors_shop_data: Array[FlavorShopData] = [
	FlavorShopData.new("Cheese Powder", "Pops nearby popcorn when it lands back in the pan", ChainReaction),
	FlavorShopData.new("Salt", "Creates 2 pieces of popcorn when popped", ExtraSpawn),
	FlavorShopData.new("Original Flavor", "Pops other nearby popcorn when popped", NearbyPop),
	FlavorShopData.new("Red Paper Flakes", "Causes popcorn to pop itself after 4 other popcorn pop", PopAfterPops)
]

# What to show on popcorn
@export var decoration: Texture2D = preload("res://assets/textures/flavor_dots.png")
# Color to add to modulation
@export var color_override: Color = Color.TRANSPARENT
# Used to sort flavors before calling one time functions (modify_reward)
@export var resolve_order: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = decoration
	modulate = color_override
	rotate(randf_range(-TAU, TAU))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func copy() -> Flavor:
	assert(false, "Please override this")
	return self


func on_added(_popcorn: Popcorn):
	pass


func modify_reward(current: int, amount_being_added: int) -> int:
	return current + amount_being_added


#region Signal callbacks
func _on_popped(_popcorn: Popcorn, _global_impact_point: Vector2, _number_of_pops_left: int, _iteration: int):
	pass


func _on_any_pop(_popcorn: Popcorn):
	pass


func _on_body_exit(_popcorn: Popcorn):
	pass


func _on_landed(_popcorn: Popcorn):
	pass


func _on_scored(_popcorn: Popcorn):
	pass
