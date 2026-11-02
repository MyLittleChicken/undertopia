extends Node
## Scripted semi-automatic playthrough of the story-002 bear-baker fight.
##
## Drives the real InputMap actions frame by frame, asserts on observable state and
## saves screenshots. It checks that the fight WORKS; it cannot judge how it FEELS or
## how it LOOKS (open the screenshots for that).
## Do not touch the keyboard or mouse while it runs: real input mixes with the script.
##
## Run (windowed, so the screenshots contain real frames):
##   godot --path . --windowed --resolution 1280x720 \
##     res://tests/playtest/bear/bear_flow_playthrough.tscn -- --out=<dir>
## Exit code 0 = every check passed. Also scan the output for SCRIPT ERROR: a runtime
## error inside a signal handler does not stop the game, so only the log shows it.

const DEMO_SCENE: PackedScene = preload("res://src/bosses/bear/bear_demo.tscn")
const SHARED_RULE_PATH: String = "res://src/bosses/bear/bear_rescue_rule.tres"
const ACTIONS: Array[StringName] = [
	InputSetup.MOVE_LEFT, InputSetup.MOVE_RIGHT, InputSetup.MOVE_UP, InputSetup.MOVE_DOWN,
	InputSetup.ATTACK, InputSetup.DODGE, InputSetup.INTERACT,
]

## Emitted at the top of every physics tick, before the demo's own nodes run, so input
## pressed here is seen as "just pressed" by the player in the same tick.
signal tick

var _out_dir: String = ""
var _lines: Array[String] = []
var _failed: int = 0
var _demo: CombatEncounter
var _player: Player
var _boss: BearBoss
var _bear: BearData
var _won_ids: Array[StringName] = []
var _wish: String = ""


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out_dir = arg.trim_prefix("--out=")
	_run()


func _physics_process(_delta: float) -> void:
	tick.emit()


func _run() -> void:
	await _scenario_fight()
	await _scenario_final_hit_with_loaves_in_reach()
	await _scenario_rule_isolation()
	var summary: String = "SEMI-TEST RESULT: %s (%d checks, %d failed)" % [
		"PASS" if _failed == 0 else "FAIL", _lines.size(), _failed]
	print(summary)
	if _out_dir != "":
		var f: FileAccess = FileAccess.open(_out_dir.path_join("bear-playthrough-result.txt"), FileAccess.WRITE)
		if f != null:
			f.store_string("\n".join(_lines) + "\n" + summary + "\n")
	get_tree().quit(0 if _failed == 0 else 1)


## Bread, hugs, dodge, strip overflow, original resident, hand over the bread, eat, wish.
func _scenario_fight() -> void:
	await _spawn()
	var data: PlayerData = _player.data

	# The oven makes bread (the bear's one overflow rule).
	for i: int in 5:
		await tick
	_check("oven makes bread right away", _boss.loaves.size() >= 1, "loaves=%d" % _boss.loaves.size())
	_check("starts BAKING in OVERFLOW at full overflow",
		_boss.phase == BearBoss.Phase.BAKING and _boss.state == Boss.State.OVERFLOW
		and is_equal_approx(_boss.overflow, _boss.data.overflow_max))
	await _shot("09-bear-bread-walking.png")

	# Stand still: bread walks to the player and hugs, up to the caps.
	var max_loaves: int = 0
	var max_hugs: int = 0
	var shot_hug: bool = false
	var ticks: int = 0
	while ticks < 1800 and max_hugs < _bear.hug_cap:
		await tick
		ticks += 1
		max_loaves = maxi(max_loaves, _boss.loaves.size())
		max_hugs = maxi(max_hugs, _boss.hugs)
		if not shot_hug and _boss.hugs >= 2:
			shot_hug = true
			await _shot("10-bear-hugged.png")
	_check("bread walks to the player and hugs", max_hugs >= 1, "max hugs=%d" % max_hugs)
	_check("hugs stack up to the cap and no further", max_hugs == _bear.hug_cap,
		"max hugs=%d cap=%d" % [max_hugs, _bear.hug_cap])
	_check("walking bread never exceeds its cap", max_loaves <= _bear.bread_count_cap,
		"max loaves=%d cap=%d" % [max_loaves, _bear.bread_count_cap])

	# Hugs make the player heavier: slower walking.
	var hugs_now: int = _boss.hugs
	_check("hugs set the speed multiplier from data",
		is_equal_approx(_player.speed_multiplier, pow(_bear.hug_slow_factor, hugs_now)),
		"hugs=%d mult=%.3f" % [hugs_now, _player.speed_multiplier])
	var before: float = _player.position.x
	await _hold(InputSetup.MOVE_LEFT, 10)
	var walked: float = before - _player.position.x
	var normal: float = data.move_speed * 10.0 / 60.0
	_check("hugged player walks slower than normal", walked < normal * 0.9,
		"walked=%.1f normal=%.1f" % [walked, normal])

	# Dodging shakes every hug off.
	if _boss.hugs == 0:
		await _wait_for_hug()
	Input.action_press(InputSetup.MOVE_RIGHT)
	Input.action_press(InputSetup.DODGE)
	await tick
	Input.action_release(InputSetup.DODGE)
	await tick
	await tick
	Input.action_release(InputSetup.MOVE_RIGHT)
	_check("dodge shakes all hugs off and restores speed",
		_boss.hugs == 0 and is_equal_approx(_player.speed_multiplier, 1.0),
		"hugs=%d mult=%.3f" % [_boss.hugs, _player.speed_multiplier])

	# Strip the overflow: attacks (and popped bread) bring it to zero.
	await _walk_to_distance(100.0)
	var hits: int = 0
	var last: float = _boss.overflow
	var monotonic: bool = true
	while _boss.state == Boss.State.OVERFLOW and hits < 40:
		await _tap(InputSetup.ATTACK)
		for i: int in 21:
			await tick
		hits += 1
		if _boss.overflow > last:
			monotonic = false
		last = _boss.overflow
	var most_hits: int = ceili(_boss.data.overflow_max / data.attack_damage)
	_check("attacks strip overflow, never add it", monotonic and hits > 0, "hits=%d" % hits)
	_check("popped bread can only make it faster than attacks alone", hits <= most_hits,
		"hits=%d at most %d" % [hits, most_hits])
	_check("overflow 0 -> original resident: no bread, no hugs, normal speed",
		_boss.state == Boss.State.ORIGINAL and _boss.phase == BearBoss.Phase.RESIDENT
		and _boss.loaves.is_empty() and _boss.hugs == 0 and is_equal_approx(_player.speed_multiplier, 1.0))
	await _shot("11-bear-resident.png")

	# Hand over the bread: a partial hold resets, a full hold completes.
	Input.action_press(InputSetup.INTERACT)
	for i: int in 20:
		await tick
	var partial: float = _demo.rescue_rule.progress
	Input.action_release(InputSetup.INTERACT)
	for i: int in 3:
		await tick
	_check("holding interact fills the hand-over progress", partial > 0.2 and partial < 0.6,
		"progress after 20 ticks=%.2f" % partial)
	_check("releasing interact resets progress", is_zero_approx(_demo.rescue_rule.progress))
	Input.action_press(InputSetup.INTERACT)
	ticks = 0
	while _boss.state != Boss.State.RESCUED and ticks < 200:
		await tick
		ticks += 1
	Input.action_release(InputSetup.INTERACT)
	var expected_ticks: int = ceili(_demo.rescue_rule.hold_time * 60.0)
	_check("handing over the bread rescues the bear", _boss.state == Boss.State.RESCUED, "ticks=%d" % ticks)
	_check("hand-over takes about hold_time", absi(ticks - expected_ticks) <= 6,
		"ticks=%d expected=%d" % [ticks, expected_ticks])
	_check("the bear sits down to eat", _boss.phase == BearBoss.Phase.EATING)
	_check("the wish phrase is revealed right after the rescue",
		_boss.wish_shown and _wish == _bear.wish_phrase, "wish='%s'" % _wish)
	_check("rescue is recorded for the bear", _demo.rescued_ids == [&"bear"] and _won_ids == [&"bear"])
	await _shot("12-bear-eating-wish.png")

	# After eating the oven is off and the bear has its own plate.
	var wait: int = ceili(_bear.eat_duration * 60.0) + 10
	for i: int in wait:
		await tick
	_check("after eating the bear is FULL (oven off)", _boss.phase == BearBoss.Phase.FULL)
	await _shot("13-bear-full.png")
	_check("the fight dealt no damage (hugs only slow)", _player.hp == data.max_hp, "hp=%d" % _player.hp)
	await _despawn()


## The popped-bread loop runs strip_overflow() mid-loop; the final strip clears the fight
## (and the bread array). Forced state, then a real attack: this must not error.
func _scenario_final_hit_with_loaves_in_reach() -> void:
	await _spawn()
	for i: int in 3:
		await tick
	var p: Vector2 = _player.position
	_boss.overflow = _bear.bread_pop_strip  # one popped loaf is enough to clear it
	_boss.loaves.clear()
	_boss.loaves.append(BearBoss.Loaf.new(p + Vector2(60.0, 0.0)))
	_boss.loaves.append(BearBoss.Loaf.new(p + Vector2(-60.0, 0.0)))
	print("FORCED-STATE: overflow=%.0f with 2 loaves in attack reach, then a real attack" % _boss.overflow)
	await _tap(InputSetup.ATTACK)
	for i: int in 3:
		await tick
	_check("final hit with two loaves in reach clears the fight",
		_boss.state == Boss.State.ORIGINAL and _boss.phase == BearBoss.Phase.RESIDENT
		and _boss.loaves.is_empty())
	await _despawn()


## Each encounter owns its rescue rule: the shared .tres must not keep fight progress.
func _scenario_rule_isolation() -> void:
	await _spawn()
	var shared: RescueRule = load(SHARED_RULE_PATH) as RescueRule
	_check("shared rescue-rule .tres progress is untouched after a full fight", is_zero_approx(shared.progress),
		"progress=%.2f" % shared.progress)
	_check("an encounter uses its own copy of the rule", _demo.rescue_rule != shared)
	_check("a new encounter starts with rescue progress 0", is_zero_approx(_demo.rescue_rule.progress))
	await _despawn()


func _spawn() -> void:
	_won_ids.clear()
	_wish = ""
	_demo = DEMO_SCENE.instantiate() as CombatEncounter
	add_child(_demo)
	_player = _demo.get_node("Player") as Player
	_boss = _demo.get_node("Boss") as BearBoss
	_bear = _boss.data as BearData
	_demo.fight_won.connect(func(id: StringName) -> void: _won_ids.append(id))
	_boss.wish_revealed.connect(func(phrase: String) -> void: _wish = phrase)
	await tick


func _despawn() -> void:
	_release_all()
	_demo.queue_free()
	await tick
	await tick


func _release_all() -> void:
	for action: StringName in ACTIONS:
		Input.action_release(action)


## Waits (standing still) until at least one hug is on the player.
func _wait_for_hug() -> void:
	for i: int in 1800:
		if _boss.hugs > 0:
			return
		await tick


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
	for i: int in 900:
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
