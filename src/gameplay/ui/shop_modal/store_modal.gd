extends Control

signal closed()

@export var available_flavors: Array[FlavorShopData] = []
@export var shop_tile_scene: PackedScene = preload("res://src/gameplay/ui/shop_modal/shop_tile.tscn")

var has_on_sale_item = false

var _tiles: Array[ShopTile] = []

@onready var flavor_options_container = $BG/Body/Body/Flavors/Choices
@onready var upgrade_options_container = $BG/Body/Body/Flavors/Choices
@onready var money_label = $BG/Money


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.level:
		money_label.text = "You've got $%d" % Global.current_run.money
		for _i in range(randi_range(1, 3)):
			var flavor = available_flavors.pick_random()
			add_flavor_option(flavor)

		show()
	else:
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func add_flavor_option(flavor: FlavorShopData):
	var tile = shop_tile_scene.instantiate() as ShopTile

	if not has_on_sale_item and randf() < .2:
		has_on_sale_item = true
		tile.on_sale = true

	tile.flavor = flavor
	tile.bought.connect(_on_bought)

	flavor_options_container.add_child(tile)

	if tile.price > Global.current_run.money:
		tile.disable()

	_tiles.push_back(tile)


func _on_bought(flavor_data: FlavorShopData, price: int):
	Global.current_run.flavors_bought.push_back(flavor_data)
	Global.current_run.money -= price
	money_label.text = "You've got $%d" % Global.current_run.money


	for tile in _tiles:
		if tile.price > Global.current_run.money:
			tile.disable()


func _get_rand_flavor() -> Flavor:
	var roll = randi_range(0, 3)

	match roll:
		0:
			return ChainReaction.new()
		1:
			return ExtraSpawn.new()
		2:
			return NearbyPop.new(Global.level.get_popcorn_in_level)
		3:
			return PopAfterPops.new()

	return null


func _on_close_pressed() -> void:
	hide()
	closed.emit()
