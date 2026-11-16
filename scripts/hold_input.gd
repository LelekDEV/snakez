extends Control
class_name HoldInput

@onready var fill_draw: Node2D = $FillDraw

var progress: float = 0
var input_mode: Global.InputMode
var just_filled: bool = false

signal filled

func _draw() -> void:
	draw_circle(Vector2(9, 9), 9.5, Color("#676767"))

func _process(delta: float) -> void:
	if input_mode == Global.InputMode.MOUSE:
		if Input.is_action_pressed("mouse_ready") and not just_filled:
			progress += delta
			if progress >= 1:
				filled.emit()
				just_filled = true
				progress = 0
		else:
			progress = 0
		
		if Input.is_action_just_released("mouse_ready"):
			just_filled = false
	
	fill_draw.progress = progress
	fill_draw.queue_redraw()
