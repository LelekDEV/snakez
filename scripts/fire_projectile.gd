extends CharacterBody2D
class_name FireProjectile

static func instantiate() -> FireProjectile:
	return preload("res://scenes/fire_projectile.tscn").instantiate() as FireProjectile

var dir := Vector2.LEFT
var speed: float = 110
var damage: float = 10
var travelled: float = 0
var parent_snake: Snake

func _physics_process(_delta: float) -> void:
	travelled += speed
	if travelled > 100000:
		queue_free()
	
	velocity = dir * speed
	move_and_slide()
