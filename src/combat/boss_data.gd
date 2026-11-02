class_name BossData
extends Resource
## Tunable boss numbers. Contact fields drive only the placeholder demo pattern;
## real boss patterns (stories 002, 005-007) replace them.

@export var resident_id: StringName = &"placeholder"
@export var overflow_max: float = 100.0
@export var radius: float = 48.0
@export var contact_damage: int = 1
@export var contact_interval: float = 1.0
@export var contact_range: float = 90.0
