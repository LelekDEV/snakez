extends Attachment
class_name AttachmentSaw

static func instantiate() -> AttachmentSaw:
	return preload("res://scenes/attachments/attachment_saw.tscn").instantiate() as AttachmentSaw

var segments: Array[CollisionShape2D]
@onready var hurt_area: Area2D = $HurtArea

@onready var immunity_timer_root: Node = $ImmunityTimerRoot
var immunity_timers: Array[Timer] = []

func _ready() -> void:
	for i in range(20):
		var segment := preload("res://scenes/attachments/attachment_saw_segment.tscn").instantiate()
		segments.append(segment)
		hurt_area.add_child(segment)
	
	var i: int = 0
	for timer: Timer in immunity_timer_root.get_children():
		timer.timeout.connect(on_immunity_timer_timeout.bind(i))
		immunity_timers.append(timer)
		i += 1

func custom_process(_delta: float) -> void:
	var i: int = 0
	for segment in segments:
		if snake.segment_pos.size() <= placement + i:
			continue
		
		var angle: float = snake.segment_angle[placement + i] + (PI if is_left_side else 0.0)
		segment.global_position = snake.segment_pos[placement + i] + Vector2(0, 5).rotated(angle)
		segment.global_rotation = angle
		
		i += 1

func _on_hurt_area_area_entered(area: Area2D) -> void:
	if not area.get_parent() is Snake:
		return
	
	var enemy_snake: Snake = area.get_parent()
	
	if enemy_snake == snake:
		return
	
	if not immunity_timers[enemy_snake.id].is_stopped():
		return
	
	enemy_snake.take_damage(3)
	immunity_timers[enemy_snake.id].start()

func on_immunity_timer_timeout(id: int) -> void:
	for area in hurt_area.get_overlapping_areas():
		if not area.get_parent() is Snake:
			continue
		
		var enemy_snake: Snake = area.get_parent()
		
		if enemy_snake == snake:
			continue
		
		if not immunity_timers[enemy_snake.id].is_stopped():
			continue
		
		enemy_snake.take_damage(3)
		immunity_timers[enemy_snake.id].start()
