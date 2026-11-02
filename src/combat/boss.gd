class_name Boss
extends Node2D
## Boss state machine: OVERFLOW -> ORIGINAL -> RESCUED (no other transitions).
## Implements design/game-brief.md Core loop: strip overflow, then rescue.

## Emitted whenever overflow changes.
signal overflow_changed(current: float, maximum: float)
## Emitted once when overflow reaches zero and the original resident shows.
signal overflow_cleared
## Emitted once when the rescue completes.
signal rescued(resident_id: StringName)

enum State { OVERFLOW, ORIGINAL, RESCUED }

var data: BossData
var state: State = State.OVERFLOW
var overflow: float = 0.0


## Assigns data and starts in the overflow state.
func setup(boss_data: BossData) -> void:
	data = boss_data
	reset()


## Back to full overflow (fight restart).
func reset() -> void:
	state = State.OVERFLOW
	overflow = data.overflow_max
	overflow_changed.emit(overflow, data.overflow_max)
	queue_redraw()


## Removes overflow; at zero switches to ORIGINAL. Ignored outside OVERFLOW.
func strip_overflow(amount: float) -> void:
	if state != State.OVERFLOW:
		return
	overflow = maxf(overflow - amount, 0.0)
	overflow_changed.emit(overflow, data.overflow_max)
	if overflow <= 0.0:
		state = State.ORIGINAL
		overflow_cleared.emit()
	queue_redraw()


## Marks the boss rescued. Only valid from ORIGINAL.
func complete_rescue() -> void:
	if state != State.ORIGINAL:
		return
	state = State.RESCUED
	rescued.emit(data.resident_id)
	queue_redraw()


func _draw() -> void:
	if data == null:
		return
	match state:
		State.OVERFLOW: draw_circle(Vector2.ZERO, data.radius, Color(0.85, 0.2, 0.2))
		State.ORIGINAL: draw_circle(Vector2.ZERO, data.radius * 0.7, Color(0.9, 0.8, 0.5))
		State.RESCUED: draw_circle(Vector2.ZERO, data.radius * 0.7, Color(0.4, 0.85, 0.5))
