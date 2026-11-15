extends Attachment
class_name AttachmentLaser

static func instantiate() -> AttachmentLaser:
	return preload("res://scenes/attachments/attachment_laser.tscn").instantiate() as AttachmentLaser

var snake_collider: Area2D
var is_draw_on: bool = false
var draw_lines: Array[Array]
@onready var game_world: World2D = get_viewport().find_world_2d()

func _draw() -> void:
	if not is_draw_on:
		return
	
	draw_line(Vector2.ZERO, Vector2(0, 400), Color.AQUA, 1)
	
	for line in draw_lines:
		draw_line(Vector2(0, line[0]), Vector2(0, line[1]), Color.RED)

func custom_process(_delta: float) -> void:
	pass

func _on_cooldown_timer_timeout() -> void:
	var hits: Array[int] = [0, 0, 0, 0]
	var snake_refs: Array[Snake] = [null, null, null, null]
	var dist: float = 0
	var last_collision: bool = false
	
	var query := PhysicsPointQueryParameters2D.new()
	query.collision_mask = 1
	query.collide_with_bodies = false
	query.collide_with_areas = true
	
	draw_lines.clear()
	
	while dist < 400:
		dist += 1
		query.position = to_global(Vector2(0, dist))
		var collisions = game_world.direct_space_state.intersect_point(query)
		
		if not collisions.is_empty():
			for collision in collisions:
				if not collision.collider.get_parent() is Snake:
					continue
				
				if collision.collider.get_parent() == snake:
					continue
				
				var id: int = collision.collider.get_parent().id
				if not snake_refs[id]:
					snake_refs[id] = collision.collider.get_parent()
				hits[id] += 1
			
			if not last_collision:
				draw_lines.append([dist])
		elif last_collision:
			draw_lines[-1].append(dist)
		
		last_collision = not collisions.is_empty()
	
	for enemy_snake in snake_refs:
		if not enemy_snake:
			continue
		
		enemy_snake.take_damage(hits[enemy_snake.id] / 15.0)
	
	#print(hits)
	#print(snake_refs)
	
	is_draw_on = true
	queue_redraw()
	
	await get_tree().create_timer(0.1).timeout
	
	is_draw_on = false
	queue_redraw()
