extends ColorRect
class_name PlayerContainer

@export var id: int
var order: int

@onready var snake_root: Control = $SnakeRoot
@onready var handle_root: HBoxContainer = $SnakeRoot/HandleRoot
@onready var item_container: HBoxContainer = $ColorRect/ItemContainer
@onready var handles: Array[DisplayHandle] = []

@onready var hold_inputs: Dictionary[StringName, HoldInput] = {
	"ready": $MarginContainer/ReadyContainer/HoldInput
}
@onready var labels: Dictionary[StringName, Label] = {
	"ready": $MarginContainer/ReadyContainer/Label
}

var selected_item: int = 0
var selected_handle: int = 0

var is_ready: bool = false

signal became_ready

func _ready() -> void:
	handles.assign(handle_root.find_children("Handle*", "DisplayHandle", true))
	
	for handle in handles:
		handle.clicked.connect(handle_clicked.bind(handle))
	
	hold_inputs.ready.filled.connect(toggle_ready)

func setup(new_id: Global.InputMode) -> void:
	id = new_id
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	
	for hold_input in hold_inputs.values():
		hold_input.input_mode = new_id
	
	if new_id == Global.InputMode.DUMMY:
		is_ready = true
		labels.ready.text = "Ready (dummy)"
	
	Global.player_items[id] = []
	for i in range(3):
		add_random_item()
	
	update_items()
	update_handles()

func add_random_item() -> void:
	var item := Global.AttachmentItem.new()
	item.id = randi_range(0, 3)
	Global.player_items[id].append(item)
	
	var display_item := DisplayItem.instantiate()
	display_item.item = item
	
	if id == Global.InputMode.MOUSE:
		display_item.clicked.connect(item_clicked.bind(display_item))
	
	item_container.add_child(display_item)

func use_item_on_handle(items: Array[Global.AttachmentItem]) -> void:
	for item in Global.player_items[id]:
		if item.handle == selected_handle:
			if not items:
				selected_item = 0
			
			item.handle = -1
			
			var display_item := DisplayItem.instantiate()
			display_item.item = item
			
			if id == Global.InputMode.MOUSE:
				display_item.clicked.connect(item_clicked.bind(display_item))
			
			item_container.add_child(display_item)
			
			update_items()
			update_handles()
			
			return
	
	if not items:
		return
	
	item_container.get_child(selected_item).queue_free()
	items[selected_item].handle = selected_handle
	if selected_item >= items.size() - 1: selected_item = items.size() - 2
	
	update_items()
	update_handles()

func _process(delta: float) -> void:
	if not Global.player_input_modes.has(id):
		return
	
	if id == Global.InputMode.MOUSE:
		mouse_process(delta)
	elif id <= Global.InputMode.JOY4:
		joy_process(delta)

# TODO: find a nice and intuitive way for mouse input ui
func toggle_ready() -> void:
	is_ready = not is_ready
	
	if is_ready:
		labels.ready.text = "Ready"
		became_ready.emit()
	else:
		labels.ready.text = "Not ready"

func handle_clicked(handle: DisplayHandle) -> void:
	var items: Array[Global.AttachmentItem]
	for display_item in item_container.get_children():
		items.append(display_item.item)
	
	selected_handle = handles.find(handle)
	
	use_item_on_handle(items)

func item_clicked(item: DisplayItem) -> void:
	var items: Array[Global.AttachmentItem]
	for display_item in item_container.get_children():
		items.append(display_item.item)
	
	selected_item = items.find(item.item)
	update_items()

func mouse_process(delta: float) -> void:
	var scroll_y: float = Input.get_axis("scroll_up", "scroll_down")
	var scroll_x: float = Input.get_axis("scroll_left", "scroll_right")
	
	snake_root.offset_transform_position.y -= scroll_y * delta * 200
	item_container.offset_transform_position.x -= scroll_x * delta * 100

func joy_process(delta: float) -> void:
	var scroll_y: float = Input.get_joy_axis(id, JOY_AXIS_LEFT_Y)
	if abs(scroll_y) < 0.1: scroll_y = 0
	
	snake_root.offset_transform_position.y -= scroll_y * delta * 200
	
	var items: Array[Global.AttachmentItem]
	for display_item in item_container.get_children():
		items.append(display_item.item)
	
	# item next
	if Global.is_joy_button_just_pressed(id, JOY_BUTTON_RIGHT_SHOULDER) and items:
		selected_item = (selected_item + 1) % items.size()
		update_items()
	
	# item prev
	if Global.is_joy_button_just_pressed(id, JOY_BUTTON_LEFT_SHOULDER) and items:
		selected_item = selected_item - 1 + items.size() * int(selected_item == 0)
		update_items()
	
	# handle next
	if Global.is_joy_trigger_just_pressed(id, true):
		selected_handle = (selected_handle + 1) % 4
		update_handles()
	
	# handle prev
	if Global.is_joy_trigger_just_pressed(id, false):
		selected_handle = selected_handle - 1 + 4 * int(selected_handle == 0)
		update_handles()
	
	# place / remove attachment
	if Global.is_joy_button_just_pressed(id, JOY_BUTTON_A):
		use_item_on_handle(items)
		# TODO: remove comment if works on controller
		'''for item in Global.player_items[id]:
			if item.handle == selected_handle:
				if not items:
					selected_item = 0
				
				item.handle = -1
				
				var display_item := DisplayItem.instantiate()
				display_item.item = item
				item_container.add_child(display_item)
				
				update_items()
				update_handles()
				
				return
		
		if not items:
			return
		
		item_container.get_child(selected_item).queue_free()
		items[selected_item].handle = selected_handle
		if selected_item >= items.size() - 1: selected_item = items.size() - 2
		
		update_items()
		update_handles()'''

func update_items() -> void:
	var i: int = 0
	for item in item_container.get_children():
		if item.is_queued_for_deletion():
			continue
		
		item.get_node("SelectOutlineDraw").is_on = i == selected_item
		i += 1

func update_handles() -> void:
	var i: int = 0
	for handle in handles:
		handle.get_node("SelectOutlineDraw").is_on = i == selected_handle
		handle.get_node("AttachmentSprite").visible = false
		
		for item in Global.player_items[id]:
			if item.handle == i:
				handle.get_node("AttachmentSprite").frame = item.id
				handle.get_node("AttachmentSprite").visible = true
		
		i += 1
