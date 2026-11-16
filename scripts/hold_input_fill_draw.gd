extends Node2D

var progress: float = 0
const STEPS: int = 60

func _draw() -> void:
	for i in range(0, STEPS * progress):
		var angle: float = i / float(STEPS) * TAU - PI / 2
		# rather inefficient, but who gives a
		draw_line(Vector2(8, 9), Vector2(8 + cos(angle) * 9, 9 + sin(angle) * 9), Color("#FFFFFF"), 1)
		draw_line(Vector2(10, 9), Vector2(10 + cos(angle) * 9, 9 + sin(angle) * 9), Color("#FFFFFF"), 1)
	
	draw_circle(Vector2(9, 9), 8, Color("#969696"))
