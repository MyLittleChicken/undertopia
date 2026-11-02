class_name CombatEncounter
extends Node2D
## Shared combat + rescue frame (story 001). Wires player, boss and a per-boss
## RescueRule; restarts the fight when the player dies; records rescued residents.
## Also draws the placeholder HUD (HP, overflow meter, rescue prompt).

## Emitted when the fight ends with a successful rescue.
signal fight_won(resident_id: StringName)
## Emitted when the player died and the fight restarted.
signal fight_restarted

@export var player_data: PlayerData
@export var boss_data: BossData
@export var rescue_rule: RescueRule

## Residents rescued so far ("rescued" record).
var rescued_ids: Array[StringName] = []

var _player: Player
var _boss: Boss
var _contact_cd: float = 0.0
var _won: bool = false


func _ready() -> void:
	_player = $Player as Player
	_boss = $Boss as Boss
	_boss.position = get_viewport_rect().size * Vector2(0.5, 0.4)
	_player.setup(player_data, get_viewport_rect().size * Vector2(0.5, 0.8))
	_boss.setup(boss_data)
	_player.attacked.connect(_on_player_attacked)
	_player.died.connect(_restart)
	_boss.rescued.connect(_on_rescued)


func _physics_process(delta: float) -> void:
	if _won:
		return
	if _boss.state == Boss.State.OVERFLOW:
		# Placeholder boss pattern: periodic damage when the player is close.
		_contact_cd = maxf(_contact_cd - delta, 0.0)
		if _contact_cd <= 0.0 and _player.position.distance_to(_boss.position) <= boss_data.contact_range:
			_contact_cd = boss_data.contact_interval
			_player.take_damage(boss_data.contact_damage)
	elif _boss.state == Boss.State.ORIGINAL and rescue_rule.update(_player, _boss, delta):
		_boss.complete_rescue()
	queue_redraw()


func _on_player_attacked(origin: Vector2, attack_range: float, damage: float) -> void:
	if origin.distance_to(_boss.position) <= attack_range + boss_data.radius:
		_boss.strip_overflow(damage)


func _on_rescued(resident_id: StringName) -> void:
	_won = true
	rescued_ids.append(resident_id)
	fight_won.emit(resident_id)


func _restart() -> void:
	_boss.reset()
	rescue_rule.reset()
	_player.reset(get_viewport_rect().size * Vector2(0.5, 0.8))
	_contact_cd = 0.0
	fight_restarted.emit()


func _draw() -> void:
	if _boss == null:
		return
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(20, 30), "HP %d / %d" % [_player.hp, player_data.max_hp])
	draw_string(font, Vector2(20, 52), "Overflow")
	draw_rect(Rect2(90, 40, 200, 12), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(90, 40, 200.0 * _boss.overflow / boss_data.overflow_max, 12), Color(0.85, 0.2, 0.2))
	var label_pos: Vector2 = _boss.position + Vector2(-60, -boss_data.radius - 16)
	match _boss.state:
		Boss.State.ORIGINAL:
			draw_string(font, label_pos, "[E] %s" % rescue_rule.prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.YELLOW)
			draw_rect(Rect2(label_pos + Vector2(0, 6), Vector2(120.0 * rescue_rule.progress, 6)), Color.YELLOW)
		Boss.State.RESCUED:
			draw_string(font, label_pos, "RESCUED: %s" % boss_data.resident_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.LIGHT_GREEN)
