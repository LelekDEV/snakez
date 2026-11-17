extends Node

const MAX_JOYS: int = 4
const MAX_PLAYERS: int = 4

var points: Array[int] = []
var round_ranking: Array[InputMode] = []

const JOY_TRIGGER_TRESHOLD: float = 0.1

enum InputMode {JOY1, JOY2, JOY3, JOY4, KEYS, MOUSE, DUMMY}
var player_input_modes: Array[InputMode] = []

var last_joy_buttons: Dictionary[int, Dictionary]
var last_joy_lt_values: Dictionary[int, float]
var last_joy_rt_values: Dictionary[int, float]

func is_joy_button_just_pressed(device: int, button: JoyButton) -> bool:
	var is_pressed: bool = Input.is_joy_button_pressed(device, button)
	
	if not last_joy_buttons.has(device):
		last_joy_buttons[device] = {}
		last_joy_buttons[device][button] = is_pressed
		if is_pressed: return true
	
	if not last_joy_buttons[device].has(button) or not last_joy_buttons[device][button]:
		last_joy_buttons[device][button] = is_pressed
		return is_pressed
	
	last_joy_buttons[device][button] = is_pressed
	return false

func is_joy_trigger_just_pressed(device: int, is_right: bool) -> bool:
	var value: float = Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT + int(is_right))
	
	if is_right:
		if not last_joy_rt_values.has(device):
			last_joy_rt_values[device] = 0
		
		if value >= JOY_TRIGGER_TRESHOLD and last_joy_rt_values[device] < JOY_TRIGGER_TRESHOLD:
			last_joy_rt_values[device] = value
			return true
		
		last_joy_rt_values[device] = value
	else:
		if not last_joy_lt_values.has(device):
			last_joy_lt_values[device] = 0
		
		if value >= JOY_TRIGGER_TRESHOLD and last_joy_lt_values[device] < JOY_TRIGGER_TRESHOLD:
			last_joy_lt_values[device] = value
			return true
		
		last_joy_lt_values[device] = value
	
	return false

class AttachmentItem:
	var handle: int = -1
	var id: int

var player_items: Dictionary[int, Array]
