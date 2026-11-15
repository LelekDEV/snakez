extends Node2D
class_name Healthbar

var max_health: float
var health: float

func _ready() -> void:
	SignalBus.start_game.connect(update_state.bind(1, 1))

func _draw() -> void:
	var width: float = health / max_health * 120
	draw_rect(Rect2(0, 0, width, 16), Color.RED)
	draw_rect(Rect2(width, 0, 120 - width, 16), Color("#222"))

func update_state(max_health_: float, health_: float) -> void:
	max_health = max_health_
	health = max(health_, 0)
	queue_redraw()
