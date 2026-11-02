class_name PlayerData
extends Resource
## Tunable player combat numbers (seconds, pixels, pixels/second).

@export var max_hp: int = 5
@export var move_speed: float = 220.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 0.35
@export var dodge_speed: float = 520.0
@export var dodge_duration: float = 0.2
## Invulnerable window at the start of a dodge; should be <= dodge_duration.
@export var dodge_iframes: float = 0.15
@export var dodge_cooldown: float = 0.6
