extends Attachment
class_name AttachmentTurret

static func instantiate() -> AttachmentTurret:
	return preload("res://scenes/attachments/attachment_turret.tscn").instantiate() as AttachmentTurret

@onready var cooldown_timer: Timer = $CooldownTimer

func custom_process(_delta: float) -> void:
	pass

func _on_cooldown_timer_timeout() -> void:
	var projectile := FireProjectile.instantiate()
	
	projectile.global_position = global_position + Vector2(4, 0).rotated(global_rotation)
	projectile.dir = Vector2.DOWN.rotated(global_rotation)
	projectile.parent_snake = snake
	
	projectile_root.add_child(projectile)
