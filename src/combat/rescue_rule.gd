class_name RescueRule
extends Resource
## Per-boss rescue condition. The encounter calls update() every physics frame
## while the boss is in its original-resident state; return true to rescue.
## Subclass and override for each animal (stories 002, 005-007).

## Text shown while the rescue is available.
@export var prompt_text: String = "Rescue"

## 0..1 progress for the prompt UI.
var progress: float = 0.0


## Return true on the frame the rescue succeeds.
func update(_player: Player, _boss: Boss, _delta: float) -> bool:
	return false


## Called when the fight restarts.
func reset() -> void:
	progress = 0.0
