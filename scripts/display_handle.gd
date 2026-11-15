extends Control
class_name DisplayHandle

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_click") and is_mouse_on:
		clicked.emit()

signal clicked
var is_mouse_on: bool = false
func _on_mouse_entered() -> void: is_mouse_on = true
func _on_mouse_exited() -> void: is_mouse_on = false
