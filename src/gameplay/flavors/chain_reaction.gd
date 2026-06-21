class_name ChainReaction
extends Flavor


func _init() -> void:
	color_override = Color.CRIMSON


func on_added(popcorn: Popcorn):
	popcorn.extra_pops += 1


func copy() -> Flavor:
	var new_flavor = ChainReaction.new()
	return new_flavor
