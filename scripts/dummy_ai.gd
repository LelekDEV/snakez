extends Node
class_name AI

static func instantiate() -> AI:
	return preload("res://scenes/dummy_ai.tscn").instantiate() as AI

var snake: Snake

var points: Array[Vector2] = [
	Vector2(-200, -100),
	Vector2(-200, 100),
	Vector2(200, 100),
	Vector2(200, -100)
]
var target_point_idx: int
var dist_target_tres_sq: float = 50 ** 2

func _ready() -> void:
	var min_dist_sq: float = INF
	var min_idx: int
	var i: int = 0
	
	for point in points:
		var new_dist: float = point.distance_squared_to(snake.global_position)
		
		if new_dist < min_dist_sq:
			min_dist_sq = new_dist
			min_idx = i
		
		i += 1
	
	target_point_idx = min_idx

func get_input_pos() -> Vector2:
	if snake.global_position.distance_squared_to(points[target_point_idx]) < dist_target_tres_sq:
		target_point_idx = (target_point_idx + 1) % points.size()
	
	return snake.to_local(points[target_point_idx])
