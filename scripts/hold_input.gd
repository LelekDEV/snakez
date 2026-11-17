extends Control
class_name HoldInput

@onready var fill_draw: Node2D = $FillDraw
@onready var label: Label = $Label

@export var glyph_text: String = "X"

enum Behavior {NONE, READY, CRATE}
@export var behavior: Behavior

var is_active: bool = true
var progress: float = 0
var input_mode: Global.InputMode
@export var input_action: JoyButton
var just_filled: bool = false

signal filled

func _draw() -> void:
	draw_circle(Vector2(9, 9), 9.5, Color("#676767"))

func _ready() -> void:
	label.text = glyph_text

func _process(delta: float) -> void:
	if input_mode == Global.InputMode.MOUSE:
		if Input.is_action_pressed("mouse_hold") and not just_filled and is_active:
			progress += delta
			if progress >= 1:
				filled.emit()
				just_filled = true
				progress = 0
		else:
			progress = 0
		
		if Input.is_action_just_released("mouse_hold"):
			just_filled = false
	
	elif input_mode <= Global.InputMode.JOY4:
		if Global.is_joy_button_just_pressed(input_mode, input_action):
			just_filled = false
		
		if Input.is_joy_button_pressed(input_mode, input_action) and not just_filled and is_active:
			progress += delta
			if progress >= 1:
				filled.emit()
				just_filled = true
				progress = 0
		else:
			progress = 0
	
	fill_draw.progress = progress
	fill_draw.queue_redraw()
