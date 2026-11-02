extends Node
## Scripted semi-automatic playthrough of the story-001 combat demo.
##
## Drives the real InputMap actions frame by frame (never calls game methods to
## fake an outcome), asserts on observable state, and saves screenshots.
## It checks that the flow WORKS; it cannot judge how it FEELS.
##
## Run (windowed, so the screenshots contain real frames):
##   godot --path . --windowed --resolution 1280x720 \
##     res://tests/playtest/combat/rescue_flow_playthrough.tscn -- --out=<dir>
## Exit code 0 = every check passed, 1 = at least one failed.

const DEMO_SCENE: PackedScene = preload("res://src/combat/combat_demo.tscn")
const ACTIONS: Array[StringName] = [
	InputSetup.MOVE_LEFT, InputSetup.MOVE_RIGHT, InputSetup.MOVE_UP, InputSetup.MOVE_DOWN,
	InputSetup.ATTACK, InputSetup.DODGE, InputSetup.INTERACT,
]

## Emitted at the top of every physics tick, before the demo's own nodes run, so
## input pressed here is seen as "just pressed" by the player in the same tick.
signal tick

var _out_dir: String = ""
var _lines: Array[String] = []
var _failed: int = 0
var _demo: CombatEncounter
var _player: Player
var _boss: Boss
var _won_ids: Array[StringName] = []
var _restarts: int = 0


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out_dir = arg.trim_prefix("--out=")
	_run()


func _physics_process(_delta: float) -> void:
	tick.emit()


func _run() -> void:
	await _scenario_fight_and_rescue()
	await _scenario_restart_on_death()
	var summary: String = "SEMI-TEST RESULT: %s (%d checks, %d failed)" % [
		"PASS" if _failed == 0 else "FAIL", _lines.size(), _failed]
	print(summary)
	if _out_dir != "":
		var f: FileAccess = FileAccess.open(_out_dir.path_join("playthrough-result.txt"), FileAccess.WRITE)
		if f != null:
			f.store_string("\n".join(_lines) + "\n" + summary + "\n")
	get_tree().quit(0 if _failed == 0 else 1)


## AC-1 (controls), AC-2 (strip overflow), AC-3 (original resident), AC-5 (rescue).
func _scenario_fight_and_rescue() -> void:
	await _spawn()
	var data: PlayerData = _player.data

	# AC-1: move
	var start: Vector2 = _player.position
	await _hold(InputSetup.MOVE_RIGHT, 30)
	_check("AC-1 move right changes position", _player.position.x > start.x + 60.0,
		"dx=%.1f" % (_player.position.x - start.x))
	await _hold(InputSetup.MOVE_LEFT, 30)
	_check("AC-1 move left changes position", absf(_player.position.x - start.x) < 30.0,
		"back to dx=%.1f" % (_player.position.x - start.x))

	# AC-1: dodge (i-frames at the start, faster than walking, i-frames end)
	var before: Vector2 = _player.position
	Input.action_press(InputSetup.MOVE_RIGHT)
	Input.action_press(InputSetup.DODGE)
	await tick
	Input.action_release(InputSetup.DODGE)
	await tick
	_check("AC-1 dodge grants i-frames", _player.is_invulnerable())
	var frames: int = 14
	for i: int in frames - 2:
		await tick
	Input.action_release(InputSetup.MOVE_RIGHT)
	var walked: float = data.move_speed * frames / 60.0
	var moved: float = _player.position.x - before.x
	_check("AC-1 dodge moves farther than walking", moved > walked + 30.0,
		"moved=%.1f walk-only=%.1f" % [moved, walked])
	_check("AC-1 i-frames end", not _player.is_invulnerable())

	# Walk next to the boss: inside attack reach, outside the placeholder contact range.
	await _walk_to_distance(100.0)
	var dist: float = _player.position.distance_to(_boss.position)
	_check("setup: player stands within attack reach, outside contact range",
		dist > _boss.data.contact_range and dist <= data.attack_range + _boss.data.radius,
		"dist=%.1f" % dist)
	_check("AC-2 boss starts in OVERFLOW at full overflow",
		_boss.state == Boss.State.OVERFLOW and is_equal_approx(_boss.overflow, _boss.data.overflow_max))
	await _shot("02-overflow-full.png")

	# AC-1 attack + AC-2 strip overflow
	var hits: int = 0
	var last: float = _boss.overflow
	var monotonic: bool = true
	var shot_half: bool = false
	while _boss.state == Boss.State.OVERFLOW and hits < 30:
		await _tap(InputSetup.ATTACK)
		for i: int in 21:
			await tick
		hits += 1
		if _boss.overflow > last:
			monotonic = false
		last = _boss.overflow
		if not shot_half and _boss.overflow <= _boss.data.overflow_max * 0.5:
			shot_half = true
			await _shot("03-overflow-half.png")
	var expected_hits: int = ceili(_boss.data.overflow_max / data.attack_damage)
	_check("AC-1 attack strips overflow", hits > 0 and monotonic, "hits=%d" % hits)
	_check("AC-2 hit count matches data (overflow_max / attack_damage)", hits == expected_hits,
		"hits=%d expected=%d" % [hits, expected_hits])

	# AC-3: overflow 0 -> original resident, rescue prompt
	_check("AC-3 overflow reaches 0 and boss becomes ORIGINAL",
		_boss.state == Boss.State.ORIGINAL and is_zero_approx(_boss.overflow))
	await _shot("04-original-prompt.png")

	# AC-1 interact + AC-5 rescue: a partial hold must reset
	Input.action_press(InputSetup.INTERACT)
	for i: int in 20:
		await tick
	var partial: float = _demo.rescue_rule.progress
	Input.action_release(InputSetup.INTERACT)
	for i: int in 3:
		await tick
	_check("AC-1 interact (hold) fills rescue progress", partial > 0.2 and partial < 0.6,
		"progress after 20 ticks=%.2f" % partial)
	_check("AC-5 releasing interact resets progress", is_zero_approx(_demo.rescue_rule.progress))
	_check("AC-5 no rescue before the hold completes", _boss.state == Boss.State.ORIGINAL)

	# AC-5: full hold completes the rescue
	Input.action_press(InputSetup.INTERACT)
	var ticks: int = 0
	var shot_taken: bool = false
	while _boss.state != Boss.State.RESCUED and ticks < 200:
		await tick
		ticks += 1
		if not shot_taken and ticks == 30:
			shot_taken = true
			await _shot("05-rescue-in-progress.png")
	Input.action_release(InputSetup.INTERACT)
	var expected_ticks: int = ceili(_demo.rescue_rule.hold_time * 60.0)
	_check("AC-5 holding interact completes the rescue", _boss.state == Boss.State.RESCUED, "ticks=%d" % ticks)
	_check("AC-5 rescue takes about hold_time", absi(ticks - expected_ticks) <= 6,
		"ticks=%d expected=%d" % [ticks, expected_ticks])
	_check("AC-5 rescue is recorded and fight_won fired",
		_demo.rescued_ids == [_boss.data.resident_id] and _won_ids == [_boss.data.resident_id])
	await _shot("06-rescued.png")
	await _despawn()


## AC-6: HP 0 restarts only that fight (boss and player reset, earlier record kept).
func _scenario_restart_on_death() -> void:
	await _spawn()
	_demo.rescued_ids.append(&"earlier_rescue")  # stands in for a fight won earlier
	var start_pos: Vector2 = _player.position
	await _walk_to_distance(80.0)  # inside the placeholder contact range
	for i: int in 2:
		await _tap(InputSetup.ATTACK)
		for j: int in 21:
			await tick
	var damaged_overflow: float = _boss.overflow
	_check("AC-6 setup: boss lost some overflow before the player dies",
		damaged_overflow < _boss.data.overflow_max, "overflow=%.0f" % damaged_overflow)
	var guard: int = 0
	while _player.hp > 1 and guard < 900:
		await tick
		guard += 1
	_check("AC-6 setup: the boss hurts the player until HP is 1", _player.hp == 1, "hp=%d" % _player.hp)
	await _shot("07-low-hp.png")
	guard = 0
	while _restarts == 0 and guard < 900:
		await tick
		guard += 1
	await tick
	_check("AC-6 HP 0 triggers a restart", _restarts == 1, "restarts=%d" % _restarts)
	_check("AC-6 player HP restored", _player.hp == _player.data.max_hp, "hp=%d" % _player.hp)
	_check("AC-6 boss reset to OVERFLOW at full overflow",
		_boss.state == Boss.State.OVERFLOW and is_equal_approx(_boss.overflow, _boss.data.overflow_max))
	_check("AC-6 player back at the start position",
		_player.position.distance_to(start_pos) < 6.0, "off by %.1f" % _player.position.distance_to(start_pos))
	_check("AC-6 earlier rescue record untouched", _demo.rescued_ids == [&"earlier_rescue"])
	await _shot("08-after-restart.png")
	await _despawn()


func _spawn() -> void:
	_won_ids.clear()
	_restarts = 0
	_demo = DEMO_SCENE.instantiate() as CombatEncounter
	add_child(_demo)
	_player = _demo.get_node("Player") as Player
	_boss = _demo.get_node("Boss") as Boss
	_demo.fight_won.connect(func(id: StringName) -> void: _won_ids.append(id))
	_demo.fight_restarted.connect(func() -> void: _restarts += 1)
	await tick


func _despawn() -> void:
	_release_all()
	_demo.queue_free()
	await tick
	await tick


func _release_all() -> void:
	for action: StringName in ACTIONS:
		Input.action_release(action)


## Holds one action for a number of physics ticks.
func _hold(action: StringName, frames: int) -> void:
	Input.action_press(action)
	for i: int in frames:
		await tick
	Input.action_release(action)


## Presses an action for exactly one tick (so it counts as "just pressed" once).
func _tap(action: StringName) -> void:
	Input.action_press(action)
	await tick
	Input.action_release(action)


func _press_if(action: StringName, pressed: bool) -> void:
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


## Steers with the move actions until within max_dist of the boss and lined up on x.
func _walk_to_distance(max_dist: float) -> void:
	for i: int in 600:
		var d: Vector2 = _boss.position - _player.position
		var arrived: bool = d.length() <= max_dist and absf(d.x) <= 4.0
		_press_if(InputSetup.MOVE_LEFT, not arrived and d.x < -4.0)
		_press_if(InputSetup.MOVE_RIGHT, not arrived and d.x > 4.0)
		_press_if(InputSetup.MOVE_UP, not arrived and d.y < 0.0 and d.length() > max_dist)
		_press_if(InputSetup.MOVE_DOWN, not arrived and d.y > 0.0 and d.length() > max_dist)
		if arrived:
			break
		await tick
	_release_all()
	await tick


func _check(check_name: String, ok: bool, detail: String = "") -> void:
	var line: String = "%s: %s%s" % ["PASS" if ok else "FAIL", check_name, " (%s)" % detail if detail != "" else ""]
	print(line)
	_lines.append(line)
	if not ok:
		_failed += 1


## Saves what is on screen once the frame has really been drawn.
func _shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if _out_dir == "":
		return
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(_out_dir.path_join(file_name))
