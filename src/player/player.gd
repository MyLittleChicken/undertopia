class_name Player
extends Node2D
## Placeholder player: move / attack / dodge via InputMap actions only.
## Interact is read by the active RescueRule. Implements story 001 controls.

## Emitted when HP changes.
signal hp_changed(current: int, maximum: int)
## Emitted when HP reaches zero.
signal died
## Emitted on attack; the encounter resolves what it hits.
signal attacked(origin: Vector2, attack_range: float, damage: float)

var data: PlayerData
var hp: int = 0

var _attack_cd: float = 0.0
var _dodge_cd: float = 0.0
var _dodge_left: float = 0.0
var _dodge_elapsed: float = 0.0
var _dodge_dir: Vector2 = Vector2.ZERO
var _attack_flash: float = 0.0
var _facing: Vector2 = Vector2.RIGHT


## Assigns data, registers input actions and resets state.
func setup(player_data: PlayerData, start_position: Vector2) -> void:
	data = player_data
	InputSetup.register()
	reset(start_position)


## Full heal and clear timers (fight restart).
func reset(start_position: Vector2) -> void:
	position = start_position
	hp = data.max_hp
	_attack_cd = 0.0
	_dodge_cd = 0.0
	_dodge_left = 0.0
	_attack_flash = 0.0
	hp_changed.emit(hp, data.max_hp)
	queue_redraw()


## True while dodge i-frames are active.
func is_invulnerable() -> bool:
	return _dodge_left > 0.0 and _dodge_elapsed < data.dodge_iframes


## Applies damage unless invulnerable; emits died at zero.
func take_damage(amount: int) -> void:
	if is_invulnerable() or hp <= 0:
		return
	hp = maxi(hp - amount, 0)
	hp_changed.emit(hp, data.max_hp)
	if hp == 0:
		died.emit()


func _physics_process(delta: float) -> void:
	_attack_cd = maxf(_attack_cd - delta, 0.0)
	_dodge_cd = maxf(_dodge_cd - delta, 0.0)
	_attack_flash = maxf(_attack_flash - delta, 0.0)
	var dir: Vector2 = Input.get_vector(
		InputSetup.MOVE_LEFT, InputSetup.MOVE_RIGHT, InputSetup.MOVE_UP, InputSetup.MOVE_DOWN)
	if dir != Vector2.ZERO:
		_facing = dir
	if _dodge_left > 0.0:
		_dodge_left -= delta
		_dodge_elapsed += delta
		position += _dodge_dir * data.dodge_speed * delta
	else:
		position += dir * data.move_speed * delta
		if Input.is_action_just_pressed(InputSetup.DODGE) and _dodge_cd <= 0.0:
			_dodge_dir = _facing
			_dodge_left = data.dodge_duration
			_dodge_elapsed = 0.0
			_dodge_cd = data.dodge_cooldown
		elif Input.is_action_just_pressed(InputSetup.ATTACK) and _attack_cd <= 0.0:
			_attack_cd = data.attack_cooldown
			_attack_flash = 0.1
			attacked.emit(position, data.attack_range, data.attack_damage)
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)
	queue_redraw()


func _draw() -> void:
	if data == null:
		return
	var alpha: float = 0.4 if is_invulnerable() else 1.0
	draw_rect(Rect2(-14, -14, 28, 28), Color(0.3, 0.55, 1.0, alpha))
	if _attack_flash > 0.0:
		draw_arc(Vector2.ZERO, data.attack_range, 0.0, TAU, 32, Color(1, 1, 1, 0.8), 3.0)
