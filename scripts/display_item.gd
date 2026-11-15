extends ColorRect
class_name DisplayItem

static func instantiate() -> DisplayItem:
	return preload("res://scenes/display_item.tscn").instantiate() as DisplayItem

var item: Global.AttachmentItem
@onready var sprite: Sprite2D = $Control/Sprite2D

func _ready() -> void:
	sprite.frame = item.id

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_click") and is_mouse_on:
		clicked.emit()

signal clicked
var is_mouse_on: bool = false
func _on_mouse_entered() -> void: is_mouse_on = true
func _on_mouse_exited() -> void: is_mouse_on = false
