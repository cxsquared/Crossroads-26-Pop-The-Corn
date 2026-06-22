class_name UiSounds
extends AudioStreamPlayer

@export var confirm_sounds: Array[AudioStream] = []
@export var cash_sound: AudioStream
@export var slide_sounds: Array[AudioStream] = []
@export var rise_pitch_increment = 0.02

var rise_pitch: float = 1
var rise_sound: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_confirm():
	stream = confirm_sounds.pick_random()
	pitch_scale = randf_range(.98, 1.02)
	play()


func play_buy():
	stream = cash_sound
	pitch_scale = randf_range(.98, 1.02)
	play()
	
func play_slide():
	stream = slide_sounds.pick_random()
	pitch_scale = 1
	play()


func play_increase(reset = false):
	if not rise_sound or reset:
		rise_sound = confirm_sounds.pick_random()
		rise_pitch = 1

	stream = rise_sound
	pitch_scale = rise_pitch
	play()
	rise_pitch += rise_pitch_increment
