@abstract
extends Node2D
class_name Attachment

var placement: int
var is_left_side: bool
var snake: Snake

@onready var projectile_root: Node2D = get_tree().get_first_node_in_group("projectile_root")

func _physics_process(delta: float) -> void:
	if snake and snake.segment_pos.size() > placement:
		visible = true
		
		var angle: float = snake.segment_angle[placement] + (PI if is_left_side else 0.0)
		global_position = snake.segment_pos[placement] + Vector2(0, 5).rotated(angle)
		global_rotation = angle
	else:
		visible = false
	
	custom_process(delta)

@abstract
func custom_process(delta: float) -> void
