extends Node2D

@export var size: float = 32
var current_size: Vector2
var anim_progress: float = 0
@export var is_on: bool = false

func _draw() -> void:
	if not is_on:
		return
	
	draw_rect(Rect2(Vector2.ONE * 16 - current_size / 2, current_size), Color.WHITE, false, 2)

func _process(delta: float) -> void:
	anim_progress = fmod(anim_progress + delta * 0.75, 1)
	current_size = Vector2.ONE * (size + sin(anim_progress * TAU) * 2)
	queue_redraw()
