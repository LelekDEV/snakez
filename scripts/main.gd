extends Node2D

@onready var game: Game = $Game
@onready var gear_select: Node2D = $GearSelect

var ready_id: Array[Global.InputMode] = []

func _ready() -> void:
	SignalBus.start_game.connect(start_game)
	SignalBus.end_game.connect(end_game)
	
	game.set_deferred("process_mode", PROCESS_MODE_DISABLED)

func start_game() -> void:
	gear_select.visible = false
	gear_select.process_mode = PROCESS_MODE_DISABLED
	
	game.setup()
	
	game.visible = true
	game.process_mode = PROCESS_MODE_INHERIT

func end_game() -> void:
	gear_select.visible = true
	gear_select.process_mode = PROCESS_MODE_INHERIT
	
	game.clear()
	
	game.visible = false
	game.process_mode = PROCESS_MODE_DISABLED
