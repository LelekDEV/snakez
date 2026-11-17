extends Node2D
class_name Snake

static func instantiate() -> Snake:
	return preload("res://scenes/snake.tscn").instantiate() as Snake

@export var id: int

var segment_pos: Array[Vector2]
var segment_angle: Array[float]

var dir_angle: float = 0
var turn_speed: float = 3.5
var speed: float = 65

var length: int = 100
const MAX_LENGTH: int = 400

var max_health: float = 100
var health: float
@export var healthbar: Healthbar

var player_id: int
@export var input_mode: Global.InputMode

@onready var collider: Area2D = $Collider
var CollisionSegment: PackedScene = preload("res://scenes/snake_collision_segment.tscn")
var collision_segments: Array[CollisionShape2D]

@onready var attachment_root: Node = $AttachmentRoot
@onready var cupcake_spawner: CupcakeSpawner = get_tree().get_first_node_in_group("cupcake_spawner")

var ai: AI

signal death

func _ready() -> void:
	#input_mode = Global.player_input_modes[id]
	
	for i in range(MAX_LENGTH):
		var segment := CollisionSegment.instantiate()
		segment.disabled = i > length
		collision_segments.append(segment)
		collider.add_child(segment)
	
	'''var placement: int = int(randf_range(1, 3) * 20)
	while placement < 100:
		var roll: int = randi_range(0, 3)
		var attachment: Attachment
		
		match roll:
			0:
				attachment = AttachmentTurret.instantiate()
			1:
				attachment = AttachmentSaw.instantiate()
			2:
				attachment = AttachmentLaser.instantiate()
				attachment.snake_collider = collider
			3:
				attachment = AttachmentField.instantiate()
		
		attachment.snake = self
		attachment.placement = placement
		attachment.is_left_side = randf_range(0, 1)
		attachment_root.add_child(attachment)
		
		placement += int(randf_range(1, 3) * 20)'''
	
	'''var attachment := AttachmentField.instantiate()
	attachment.snake = self
	attachment.placement = 40
	attachment_root.add_child(attachment)'''
	
	health = max_health

func setup() -> void:
	if not Global.player_items.has(input_mode):
		return
	
	for item in Global.player_items[input_mode]:
		if item.handle == -1:
			continue
		
		var attachment: Attachment
		
		match item.id:
			0:
				attachment = AttachmentTurret.instantiate()
			1:
				attachment = AttachmentSaw.instantiate()
			2:
				attachment = AttachmentLaser.instantiate()
				attachment.snake_collider = collider
			3:
				attachment = AttachmentField.instantiate()
		
		attachment.snake = self
		attachment.placement = (item.handle % 2 + 1) * 20
		attachment.is_left_side = item.handle < 2
		attachment_root.add_child(attachment)

func _draw() -> void:
	for pos in segment_pos:
		draw_circle(pos - global_position, 6, Color.LAWN_GREEN)

func _physics_process(delta: float) -> void:
	if input_mode == Global.InputMode.KEYS:
		var input: float = Input.get_axis("turn_left", "turn_right")
		dir_angle += input * turn_speed * delta
	
	elif input_mode == Global.InputMode.MOUSE:
		var dot: float = Vector2.DOWN.rotated(dir_angle).dot(get_local_mouse_position().normalized())
		
		if abs(dot) > 0.05:
			var input: float = sign(dot)
			dir_angle += input * turn_speed * delta
	
	elif input_mode <= Global.InputMode.JOY4:
		#var input: float = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var input_vector := Vector2(
			Input.get_joy_axis(input_mode, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(input_mode, JOY_AXIS_LEFT_Y)
		)
		
		if input_vector.length() > 0.2:
			var dot: float = Vector2.DOWN.rotated(dir_angle).dot(input_vector.normalized())
			
			if abs(dot) > 0.05:
				var input: float = sign(dot)
				dir_angle += input * turn_speed * delta
	
	elif ai:
		var dot: float = Vector2.DOWN.rotated(dir_angle).dot(ai.get_input_pos().normalized())
		
		if abs(dot) > 0.05:
			var input: float = sign(dot)
			dir_angle += input * turn_speed * delta
	
	global_position += Vector2.RIGHT.rotated(dir_angle) * speed * delta
	
	segment_pos.push_front(global_position)
	segment_angle.push_front(dir_angle)
	
	if segment_pos.size() > length:
		segment_pos.pop_back()
		segment_angle.pop_back()
	
	var i: int = 0
	for pos in segment_pos:
		collision_segments[i].global_position = pos
		i += 1
	
	queue_redraw()

func take_damage(amount: float) -> void:
	health -= amount
	
	if healthbar:
		healthbar.update_state(max_health, health)
	
	if health <= 0:
		if not Global.round_ranking.has(player_id):
			Global.round_ranking.append(player_id)
		
		if not is_queued_for_deletion():
			death.emit()
			queue_free()

func _on_collider_body_entered(body: Node2D) -> void:
	if body is FireProjectile:
		if body.parent_snake == self:
			return
		
		take_damage(body.damage)
		body.queue_free()

func _on_cupcake_collect_area_entered(area: Area2D) -> void:
	if not area.is_in_group("cupcake"):
		return
	
	if length < MAX_LENGTH:
		for i in range(20):
			collision_segments[i + length].set_deferred("disabled", false)
		length += 20
	
	area.queue_free()
	cupcake_spawner.spawn_cupcake()
