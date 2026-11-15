extends Attachment
class_name AttachmentField

static func instantiate() -> AttachmentField:
	return preload("res://scenes/attachments/attachment_field.tscn").instantiate() as AttachmentField

var radius: float = 35
var draw_alpha = 0.5

@onready var hurt_area: Area2D = $HurtArea

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.35, 1.0, 0.85, draw_alpha))

func custom_process(delta: float) -> void:
	draw_alpha = max(draw_alpha - delta * 2, 0.35)
	queue_redraw()

func _on_cooldown_timer_timeout() -> void:
	for area in hurt_area.get_overlapping_areas():
		if not area.get_parent() is Snake:
			continue
		
		if area.get_parent() == snake:
			continue
		
		area.get_parent().take_damage(10)
	
	draw_alpha = 1
