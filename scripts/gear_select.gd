extends Node2D

@onready var player_containers: Array[PlayerContainer]

func _ready() -> void:
	SignalBus.end_game.connect(game_ended)
	
	for player_container: PlayerContainer in $MainContainer.get_children():
		player_container.became_ready.connect(check_ready)
		player_containers.append(player_container)

func _process(_delta: float) -> void:
	for id in Global.MAX_JOYS:
		if Global.is_joy_button_just_pressed(id, JOY_BUTTON_START) and not Global.player_input_modes.has(id):
			add_player(id)
	
	if Input.is_action_just_pressed("add_dummy_player"):
		add_player(Global.InputMode.DUMMY)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if not (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	if not event.double_click:
		return
	
	add_player(Global.InputMode.MOUSE)

func game_ended() -> void:
	for container in player_containers:
		if not container.visible:
			continue
		
		if container.id == Global.InputMode.DUMMY:
			continue
		
		container.toggle_ready()

func add_player(input_id: int) -> void:
	if input_id in Global.player_input_modes:
		return
	
	Global.player_input_modes.append(input_id)
	
	var player_id: int = Global.player_input_modes.size() - 1
	var player_container: PlayerContainer = player_containers[player_id]
	
	player_container.order = player_id
	player_container.move_to_front()
	
	player_container.setup(input_id)

func check_ready() -> void:
	if Global.player_input_modes.size() < 2:
		return
	
	for player_container in player_containers:
		if not player_container.visible:
			continue
		
		if not player_container.is_ready:
			return
	
	SignalBus.start_game.emit()
