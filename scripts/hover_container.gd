extends HBoxContainer
class_name HoverContainer

@onready var parent_container: PlayerContainer = owner

func _draw() -> void:
	if parent_container.id != Global.InputMode.MOUSE:
		return
	
	if not is_mouse_on:
		return
	
	draw_rect(Rect2(Vector2.ZERO, size).grow(2), Color.WHITE, false, 1)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	queue_redraw()

var is_mouse_on: bool = false
func _on_mouse_entered() -> void: is_mouse_on = true
func _on_mouse_exited() -> void: is_mouse_on = false
