extends Node2D
class_name CupcakeSpawner

@onready var Cupcake: PackedScene = preload("res://scenes/cupcake.tscn")

var snakes: Array[Snake]
var valid_points: Array[Vector2i]
var SPAWN_MARGIN: int = 30

'''func _draw() -> void:
	for pos in valid_points:
		draw_rect(Rect2(pos, Vector2.ONE), Color.GREEN)'''

func spawn_cupcake() -> void:
	valid_points.clear()
	
	# TODO: spawn it away from all segments, not just head
	for x in range(-239 + SPAWN_MARGIN, 240 - SPAWN_MARGIN, 4):
		for y in range(-134 + SPAWN_MARGIN, 135 - SPAWN_MARGIN, 4):
			var pos := Vector2i(x, y)
			var is_valid: bool = true
			
			for snake in snakes:
				if snake and snake.global_position.distance_squared_to(pos) < 6400:
					is_valid = false
					break
			
			if is_valid:
				valid_points.append(pos)
	
	var cupcake: Area2D = Cupcake.instantiate()
	cupcake.global_position = valid_points.pick_random()
	call_deferred("add_child", cupcake)
	
	#queue_redraw()
