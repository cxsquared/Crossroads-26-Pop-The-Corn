@tool
extends EditorPlugin

const SUCCESS: int = 0
const AUTO_RELOAD_SETTING: String = &"text_editor/behavior/files/auto_reload_scripts_on_external_change"
const FORMAT_ACTION = &"simple_gdscript_formatter/format"
const OPEN_EXTERNAL_ACTION = &"simple_gdscript_formatter/open_in_external_editor"

var format_key: InputEventKey
var open_external_key: InputEventKey

var original_auto_reload_setting: bool

func _enter_tree():
	add_tool_menu_item("Format GDScript", _on_format_code)
	if InputMap.has_action(FORMAT_ACTION):
		InputMap.erase_action(FORMAT_ACTION)
	InputMap.add_action(FORMAT_ACTION)

	#Setting to enable/disable the open_in_external_editor feature
	if not ProjectSettings.has_setting(OPEN_EXTERNAL_ACTION):
		ProjectSettings.set_setting(OPEN_EXTERNAL_ACTION, true)
		ProjectSettings.set_initial_value(OPEN_EXTERNAL_ACTION, true)

	format_key = InputEventKey.new()
	format_key.keycode = KEY_L
	format_key.ctrl_pressed = true
	format_key.alt_pressed = true
	InputMap.action_add_event(FORMAT_ACTION, format_key)

	add_tool_menu_item("Open In External Editor", _open_external)
	if InputMap.has_action(OPEN_EXTERNAL_ACTION):
		InputMap.erase_action(OPEN_EXTERNAL_ACTION)
	InputMap.add_action(OPEN_EXTERNAL_ACTION)

	open_external_key = InputEventKey.new()
	open_external_key.keycode = KEY_E
	open_external_key.ctrl_pressed = true
	InputMap.action_add_event(OPEN_EXTERNAL_ACTION, open_external_key)
	
	resource_saved.connect(on_resource_saved)


func _exit_tree():
	resource_saved.disconnect(on_resource_saved)
	
	remove_tool_menu_item("Format GDScript")
	InputMap.erase_action(FORMAT_ACTION)
	remove_tool_menu_item("Open In External Editor")
	InputMap.erase_action(OPEN_EXTERNAL_ACTION)


func _on_format_code():
	var current_editor := EditorInterface.get_script_editor().get_current_editor()
	if current_editor and current_editor.is_class("ScriptTextEditor"):
		var code_edit := current_editor.get_base_editor() as CodeEdit
		var code = code_edit.text
		var formatter = preload("formatter.gd").new()
		var formatted_code = formatter.format(code_edit)
		if formatted_code && code != formatted_code:
			var scroll_horizontal = code_edit.scroll_horizontal
			var scroll_vertical = code_edit.scroll_vertical
			var caret_column = code_edit.get_caret_column(0)
			var caret_line = code_edit.get_caret_line(0)
			code_edit.text = formatted_code
			code_edit.set_caret_line(caret_line)
			code_edit.set_caret_column(caret_column)
			code_edit.do_indent()
			code_edit.undo()
			code_edit.scroll_horizontal = scroll_horizontal
			code_edit.scroll_vertical = scroll_vertical


func _open_external() -> void:
	var script_editor := EditorInterface.get_script_editor()
	var current_editor := script_editor.get_current_editor()
	if current_editor and current_editor.is_class("ScriptTextEditor"):
		var file: String = ProjectSettings.globalize_path(script_editor.get_current_script().resource_path)
		var project: String = ProjectSettings.globalize_path("res://")
		var exec_path: String = EditorInterface.get_editor_settings().get_setting("text_editor/external/exec_path")
		var exec_flags: String = EditorInterface.get_editor_settings().get_setting("text_editor/external/exec_flags")
		if exec_path and exec_flags:
			var col = current_editor.get_base_editor().get_caret_column(0)
			var line = current_editor.get_base_editor().get_caret_line(0)
			if exec_path.contains("rider"):
				var tabs := RegEx.create_from_string("\t*").search(current_editor.get_base_editor().get_line(line).substr(0, col))
				if tabs:
					col += tabs.get_string().length() * 3
			var arguments: Array[String] = []
			for flag in exec_flags.split(" "):
				arguments.append(flag.format({ "project": project, "col": col, "line": line + 1, "file": file }))
			OS.execute_with_pipe(exec_path, arguments, false)


func _shortcut_input(event: InputEvent) -> void:
	#Format the script
	if Input.is_action_pressed(FORMAT_ACTION):
		_on_format_code()
		get_tree().root.set_input_as_handled()
	#Open in External Editor- uses ProjectSettings to enable or disable feature.
	if ProjectSettings.get_setting(OPEN_EXTERNAL_ACTION, true):
		if Input.is_action_pressed(OPEN_EXTERNAL_ACTION):
			if event is InputEventKey and event.get_keycode_with_modifiers() == Key.KEY_E | KeyModifierMask.KEY_MASK_CTRL:
				_open_external()
				get_tree().root.set_input_as_handled()


# CALLED WHEN A SCRIPT IS SAVED
func on_resource_saved(resource: Resource):
	if resource is Script:
		var script: Script = resource
		var current_script = get_editor_interface().get_script_editor().get_current_script()
		var text_edit: CodeEdit = (
			get_editor_interface().get_script_editor().get_current_editor().get_base_editor()
		)
		
		# Prevents other unsaved scripts from overwriting the active one
		if current_script == script:
			var filepath: String = ProjectSettings.globalize_path(resource.resource_path)

			# Run gdformat
			var code = text_edit.text
			var formatter = preload("formatter.gd").new()
			var formatted_code = formatter.format(text_edit)
			if formatted_code && code != formatted_code:
				var scroll_horizontal = text_edit.scroll_horizontal
				var scroll_vertical = text_edit.scroll_vertical
				var caret_column = text_edit.get_caret_column(0)
				var caret_line = text_edit.get_caret_line(0)
				text_edit.text = formatted_code
				text_edit.set_caret_line(caret_line)
				text_edit.set_caret_column(caret_column)
				text_edit.do_indent()
				text_edit.undo()
				text_edit.scroll_horizontal = scroll_horizontal
				text_edit.scroll_vertical = scroll_vertical
				text_edit.tag_saved_version()
