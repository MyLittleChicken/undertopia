class_name InputSetup
## Registers the combat InputMap actions from code (project.godot is not edited).
## Gameplay code only ever refers to the action names below, never key codes.

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const MOVE_UP: StringName = &"move_up"
const MOVE_DOWN: StringName = &"move_down"
const ATTACK: StringName = &"attack"
const DODGE: StringName = &"dodge"
const INTERACT: StringName = &"interact"


## Adds any missing action with its default keyboard/mouse bindings. Idempotent.
static func register() -> void:
	_add(MOVE_LEFT, [KEY_A, KEY_LEFT])
	_add(MOVE_RIGHT, [KEY_D, KEY_RIGHT])
	_add(MOVE_UP, [KEY_W, KEY_UP])
	_add(MOVE_DOWN, [KEY_S, KEY_DOWN])
	_add(ATTACK, [KEY_J], MOUSE_BUTTON_LEFT)
	_add(DODGE, [KEY_SPACE, KEY_SHIFT])
	_add(INTERACT, [KEY_E])


static func _add(action: StringName, keys: Array[Key], mouse_button: MouseButton = MOUSE_BUTTON_NONE) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		InputMap.action_add_event(action, ev)
	if mouse_button != MOUSE_BUTTON_NONE:
		var mb := InputEventMouseButton.new()
		mb.button_index = mouse_button
		InputMap.action_add_event(action, mb)
