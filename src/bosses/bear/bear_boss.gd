class_name BearBoss
extends Boss
## Bear baker (story 002, design/game-brief.md MVP 3, wish phrase "배부르고").
## Overflow rule: the oven never stops, so bread walks. A loaf touching the player hugs them
## (heavier = slower, stacking to a cap, wears off, dodging shakes all off).
## Placeholder visuals only; bread are plain round loaves, the bear never loses body parts.

## Emitted right after the rescue with the wish phrase.
signal wish_revealed(phrase: String)
## Emitted when the number of hugs on the player changes.
signal hug_changed(hugs: int)

## BAKING: oven on, bread walking. RESIDENT: overflow gone, holding out a slice.
## EATING: slice handed over, bear eating. FULL: oven turned off, own plate loaded.
enum Phase { BAKING, RESIDENT, EATING, FULL }

class Loaf:
	var pos: Vector2

	func _init(p: Vector2) -> void:
		pos = p

var phase: Phase = Phase.BAKING
## Loaves currently walking (world positions, parent space). Use loaves.size() for the count.
var loaves: Array[Loaf] = []
## Hugs currently on the player.
var hugs: int = 0
## True once the wish phrase has been revealed.
var wish_shown: bool = false

var _bear: BearData
var _player: Player
var _spawn_cd: float = 0.0
var _hug_left: float = 0.0
var _eat_left: float = 0.0


func _ready() -> void:
	_player = get_node("../Player") as Player
	_player.attacked.connect(_on_player_attacked)
	overflow_cleared.connect(_on_cleared)
	rescued.connect(_on_rescued)


## Assigns data (must be a BearData) and starts the fight.
func setup(boss_data: BossData) -> void:
	_bear = boss_data as BearData
	assert(_bear != null, "BearBoss needs a BearData resource")
	super(boss_data)


## Fight restart: oven back on, bread and hugs gone.
func reset() -> void:
	super()
	phase = Phase.BAKING
	loaves.clear()
	wish_shown = false
	_spawn_cd = 0.0
	_eat_left = 0.0
	_set_hugs(0)


## Name of the current phase, for HUD/drivers.
func phase_name() -> String:
	return Phase.keys()[phase]


func _physics_process(delta: float) -> void:
	if phase == Phase.BAKING:
		_run_oven(delta)
		_move_loaves(delta)
		_run_hugs(delta)
	elif phase == Phase.EATING:
		_eat_left -= delta
		if _eat_left <= 0.0:
			phase = Phase.FULL
	queue_redraw()


func _run_oven(delta: float) -> void:
	_spawn_cd -= delta
	if _spawn_cd > 0.0 or loaves.size() >= _bear.bread_count_cap:
		return
	_spawn_cd = _bear.bread_spawn_interval
	var jitter := Vector2.from_angle(randf() * TAU) * randf() * _bear.oven_spread
	loaves.append(Loaf.new(position + _bear.oven_offset + jitter))


func _move_loaves(delta: float) -> void:
	var shaken: bool = _player.is_invulnerable()
	for i in range(loaves.size() - 1, -1, -1):
		var loaf: Loaf = loaves[i]
		loaf.pos = loaf.pos.move_toward(_player.position, _bear.bread_speed * delta)
		# A loaf cannot hug a player who is dodging (i-frames).
		if not shaken and loaf.pos.distance_to(_player.position) <= _bear.hug_range:
			loaves.remove_at(i)
			_set_hugs(mini(hugs + 1, _bear.hug_cap))
			_hug_left = _bear.hug_duration


func _run_hugs(delta: float) -> void:
	if hugs == 0:
		return
	if _player.is_invulnerable():
		_set_hugs(0)
		return
	_hug_left -= delta
	if _hug_left <= 0.0:
		_set_hugs(hugs - 1)
		_hug_left = _bear.hug_duration


func _set_hugs(count: int) -> void:
	var changed: bool = count != hugs
	hugs = count
	if _bear != null:
		_player.speed_multiplier = pow(_bear.hug_slow_factor, hugs)
	if changed:
		hug_changed.emit(hugs)


# Popping loaves near a hit also strips overflow. Connected before the encounter's own
# handler, so the bear's own hit-test still runs afterwards.
func _on_player_attacked(origin: Vector2, attack_range: float, _damage: float) -> void:
	if phase != Phase.BAKING:
		return
	var popped: int = 0
	for i in range(loaves.size() - 1, -1, -1):
		if loaves[i].pos.distance_to(origin) <= attack_range + _bear.bread_radius:
			loaves.remove_at(i)
			popped += 1
	# Strip once after the loop: clearing the overflow empties `loaves` via _on_cleared.
	if popped > 0:
		strip_overflow(popped * _bear.bread_pop_strip)


func _on_cleared() -> void:
	phase = Phase.RESIDENT
	loaves.clear()
	_set_hugs(0)


func _on_rescued(_resident_id: StringName) -> void:
	phase = Phase.EATING
	_eat_left = _bear.eat_duration
	wish_shown = true
	wish_revealed.emit(_bear.wish_phrase)


func _draw() -> void:
	if data == null:
		return
	var r: float = data.radius
	var font: Font = ThemeDB.fallback_font
	var crust := Color(0.85, 0.62, 0.3)
	if phase == Phase.BAKING:
		_draw_bear(r, Vector2.ZERO)
		draw_rect(Rect2(_bear.oven_offset - Vector2(24, 24), Vector2(48, 48)), Color(0.45, 0.2, 0.15))
		draw_circle(_bear.oven_offset, 10.0, Color(1.0, 0.55, 0.1))
	else:
		_draw_bear(r * 0.7, Vector2(0, 10))
		draw_rect(Rect2(_bear.oven_offset - Vector2(24, 24), Vector2(48, 48)), Color(0.25, 0.25, 0.28))
	match phase:
		Phase.RESIDENT:
			draw_rect(Rect2(-82, -2, 22, 16), crust)
			draw_rect(Rect2(-82, -2, 22, 5), Color(0.6, 0.4, 0.2))
		Phase.EATING, Phase.FULL:
			draw_circle(Vector2(0, r * 0.7 + 14), 26.0, Color(0.9, 0.9, 0.95))
			draw_circle(Vector2(-8, r * 0.7 + 12), 9.0, crust)
			if phase == Phase.FULL:
				draw_circle(Vector2(8, r * 0.7 + 12), 9.0, crust)
	for loaf in loaves:
		draw_circle(loaf.pos - position, _bear.bread_radius, crust)
		draw_circle(loaf.pos - position + Vector2(0, -4), _bear.bread_radius * 0.6, Color(0.95, 0.78, 0.5))
	for i in hugs:
		var spot: Vector2 = _player.position - position + Vector2.from_angle(i * TAU / maxf(_bear.hug_cap, 1)) * 18.0
		draw_circle(spot, _bear.bread_radius * 0.7, crust)
	var hud: Vector2 = -position + Vector2(20, 90)
	draw_string(font, hud, "Bear: %s | bread %d/%d | hugs %d/%d" % [phase_name(), loaves.size(), _bear.bread_count_cap, hugs, _bear.hug_cap])
	if wish_shown:
		draw_string(font, Vector2(-60, -r - 50), _bear.wish_phrase, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.GOLD)


func _draw_bear(r: float, offset: Vector2) -> void:
	var fur := Color(0.55, 0.38, 0.22)
	draw_circle(offset + Vector2(-r * 0.7, -r * 0.8), r * 0.3, fur)
	draw_circle(offset + Vector2(r * 0.7, -r * 0.8), r * 0.3, fur)
	draw_circle(offset, r, fur)
	draw_circle(offset + Vector2(0, r * 0.3), r * 0.4, Color(0.85, 0.7, 0.5))
	draw_circle(offset + Vector2(-r * 0.35, -r * 0.2), r * 0.08, Color.BLACK)
	draw_circle(offset + Vector2(r * 0.35, -r * 0.2), r * 0.08, Color.BLACK)
