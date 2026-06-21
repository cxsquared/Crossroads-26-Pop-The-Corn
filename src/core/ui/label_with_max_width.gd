@tool
class_name LabelWithMaxWidth
extends RichTextLabel

@export var max_width: float

func _ready() -> void:
	resized.connect(_on_label_resized)
	autowrap_mode = TextServer.AUTOWRAP_OFF
	custom_minimum_size = Vector2.ZERO
	_on_label_resized()

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_TRANSLATION_CHANGED:
		_on_label_resized()

func set_text_and_adjust_width(_text: String) -> void:
	text = _text
	_on_label_resized()

func _on_label_resized() -> void:
	autowrap_mode = TextServer.AUTOWRAP_OFF
	custom_minimum_size = Vector2.ZERO

	var font := get_theme_font("font")
	if font == null:
		return

	var font_size := get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = get_theme_font_size("font_size")

	var display_text := tr(text)
	var text_width := font.get_string_size(display_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

	if text_width > max_width:
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		custom_minimum_size = Vector2(max_width, 0.0)
