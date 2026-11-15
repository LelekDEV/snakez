extends Node2D
class_name Game

const SPAWN_DIST := Vector2(100, 56.25)

@export var healthbars: Array[Healthbar]
@onready var cupcake_root: CupcakeSpawner = $CupcakeRoot
@onready var projectile_root: Node2D = $ProjectileRoot

var alive_snakes: int
var snakes_ref: Array[Snake]

func setup() -> void:
	# TODO: consistify naming: input_mode, input_id
	cupcake_root.snakes.clear()
	alive_snakes = 0
	
	var angle: float = PI
	var step: float = TAU / float(Global.player_input_modes.size())
	var i: int = 0
	
	for input_mode in Global.player_input_modes:
		var snake := Snake.instantiate()
		
		snake.input_mode = input_mode
		snake.global_position = Vector2(cos(angle), sin(angle)) * SPAWN_DIST
		snake.healthbar = healthbars[i]
		
		if input_mode == Global.InputMode.DUMMY:
			var ai := AI.instantiate()
			snake.ai = ai
			ai.snake = snake
			snake.add_child(ai)
		
		snake.death.connect(on_snake_death)
		
		add_child(snake)
		move_child(snake, 0)
		
		snakes_ref.append(snake)
		cupcake_root.snakes.append(snake)
		snake.setup()
		
		alive_snakes += 1
		angle += step
		i += 1

func clear() -> void:
	for snake in snakes_ref:
		if snake and not snake.is_queued_for_deletion():
			snake.queue_free()
	
	for projectile: Node in projectile_root.get_children():
		if projectile and not projectile.is_queued_for_deletion():
			projectile.queue_free()

func on_snake_death() -> void:
	alive_snakes -= 1
	
	if alive_snakes < 2:
		await get_tree().create_timer(1).timeout
		SignalBus.end_game.emit()
