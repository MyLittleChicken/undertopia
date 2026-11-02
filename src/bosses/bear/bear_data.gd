class_name BearData
extends BossData
## Tunables for the bear baker (story 002, design/game-brief.md MVP 3).
## Set contact_damage to 0 in the .tres: the bear's only pressure is the bread.

## Wish phrase revealed right after the rescue.
@export var wish_phrase: String = "배부르고"
## Seconds between loaves while the oven runs.
@export var bread_spawn_interval: float = 1.5
## Loaf walking speed, px/s.
@export var bread_speed: float = 70.0
## Most loaves walking at once.
@export var bread_count_cap: int = 6
@export var bread_radius: float = 14.0
## Loaf spawn point relative to the bear, and random spread around it.
@export var oven_offset: Vector2 = Vector2(80, 20)
@export var oven_spread: float = 20.0
## Distance between loaf and player centres that counts as a hug.
@export var hug_range: float = 26.0
## Walk-speed multiplier per hug; stacks multiplicatively (0.8 ^ hugs).
@export_range(0.05, 1.0) var hug_slow_factor: float = 0.8
## Most hugs that can stack.
@export var hug_cap: int = 4
## Seconds until one hug wears off (the timer restarts after each wear-off and each new hug).
@export var hug_duration: float = 4.0
## Overflow stripped for every loaf the player pops with an attack.
@export var bread_pop_strip: float = 5.0
## Seconds the bear eats after the hand-over before it turns the oven off.
@export var eat_duration: float = 2.0
