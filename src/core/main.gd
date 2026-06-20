class_name Main
extends Node

@export var start_scene: PackedScene

var current_scene = null

var _queued_scene_path: String = ""
var _queued_scene: PackedScene = null
var _queue_scene_timer := 0.0
var _queue_scene_start_time := 0.0
var _queue_save_current_scene = false
var _is_scene_queued = false

var _is_transitioning = false
var _deferred_scene = false

var _last_scene: Node = null
var _should_save_current_scene = false

@onready var transition = preload("res://src/core/transition.tscn")
@onready var world_root = %World as Node
@onready var hud_root = %HudRoot as Control
@onready var transition_root = %TransitionRoot as Control
@onready var debug_root = %DebugRoot as Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.hud = hud_root
	Global.main = self

	if start_scene:
		goto_scene(start_scene)


func _process(delta: float) -> void:
	if _is_scene_queued:
		_queue_scene_timer -= delta
		if _queue_scene_timer <= 0:
			if _queued_scene != null:
				goto_scene(_queued_scene, _queue_save_current_scene)
			else:
				goto_scenep(_queued_scene_path, _queue_save_current_scene)

			_queued_scene_path = ""
			_queued_scene = null
			_is_scene_queued = false
			_queue_save_current_scene = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)


## Scene Management
func goto_scene_queued(scene: PackedScene, delay: float, save_current_scene: bool = false):
	_check_existing_scene_change()
	_is_scene_queued = true
	_queued_scene = scene
	_queue_scene_start_time = delay
	_queue_scene_timer = delay
	_should_save_current_scene = save_current_scene


func goto_scenep_queued(path: String, delay: float, save_current_scene: bool = false):
	_check_existing_scene_change()
	_is_scene_queued = true
	_queued_scene_path = path
	_queue_scene_timer = delay
	_queue_scene_start_time = delay
	_should_save_current_scene = save_current_scene


func goto_scenep(path: String, save_current_scene: bool = false):
	_check_existing_scene_change()
	_deferred_scene = true
	_should_save_current_scene = save_current_scene
	_deferred_goto_scenep.call_deferred(path)


func goto_scene(scene: PackedScene, save_current_scene: bool = false):
	_check_existing_scene_change()
	_deferred_scene = true
	_should_save_current_scene = save_current_scene
	_deferred_goto_scene.call_deferred(scene)


func go_to_last_scene():
	assert(_last_scene, "Last scene doesn't exist")
	_deferred_scene = true
	_should_save_current_scene = false
	_transition_last_scene.call_deferred()


func _transition(anim_to_run: String, callback: Callable = Callable()):
	var trans = transition.instantiate()
	var anim = trans.find_child("Animation") as AnimationPlayer
	anim.autoplay = anim_to_run

	anim.animation_finished.connect(func(anim_name):
			_is_transitioning = false
			trans.queue_free()

			if callback:
				callback.call(anim_name)

	)
	transition_root.add_child(trans)


func _deferred_goto_scenep(path: String):
	assert(ResourceLoader.exists(path, "PackedScene"), "Path does not exist")
	var s = ResourceLoader.load(path, "PackedScene")

	_transition_to_new_scene(s)


func _deferred_goto_scene(scene: PackedScene):
	_transition_to_new_scene(scene)


func _free_current_scene():
	if not current_scene:
		return

	current_scene.queue_free()
	current_scene = null

	# wait for the scene to actually be freed
	await get_tree().process_frame


func _save_current_scene():
	if not current_scene:
		return

	_last_scene = current_scene
	current_scene = null

	# wait to be like freeing a scene
	await get_tree().process_frame


func _transition_to_new_scene(scene: PackedScene):
	_transition("out", func(_anim_name):
		if _should_save_current_scene:
			_should_save_current_scene = false
			_save_current_scene()
			if _last_scene:
				_last_scene.hide()
		else:
			_free_current_scene()

		_instantiate_new_scene(scene)
	)


func _transition_last_scene():
	_transition("out", func(_anim_name):
		_free_current_scene()

		current_scene = _last_scene
		_last_scene.show()

		_transition("in")
		_deferred_scene = false
	)


func _instantiate_new_scene(scene: PackedScene):
	current_scene = scene.instantiate()

	_transition("in")
	world_root.add_child(current_scene)

	_deferred_scene = false


func _check_existing_scene_change():
	if not _queued_scene:
		assert(_queued_scene_path == "" and _queue_scene_timer <= 0, "A scene is already queued")

	assert(not _deferred_scene, "A scene is already set to be deferred")
