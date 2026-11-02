class_name HoldInteractRule
extends RescueRule
## Placeholder rescue for the demo: hold the interact action near the boss.

@export var hold_time: float = 1.0
@export var interact_range: float = 110.0


func update(player: Player, boss: Boss, delta: float) -> bool:
	if Input.is_action_pressed(InputSetup.INTERACT) \
			and player.position.distance_to(boss.position) <= interact_range:
		progress = minf(progress + delta / hold_time, 1.0)
	else:
		progress = 0.0
	return progress >= 1.0
