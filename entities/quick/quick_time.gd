extends Area2D

signal sequence_completed

@export var sequence_length := 4
var key_sequence: Array[String] = []
var input_index := 0
var player_inside := false

var valid_keys := ["w", "a", "s", "d"]
@onready var sequence_label: Label = $CanvasLayer/SequencePanel.get_node("SequenceLabel")
@onready var sequence_panel: Panel = $CanvasLayer.get_node("SequencePanel")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	# Get the label from the scene (adjust the path if needed)
	sequence_label.text = ""
	sequence_panel.visible = false
	sequence_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	sequence_panel.visible = true
	sequence_label.visible = true
	var center_position = global_position
	body.move_to_center(center_position)
	generate_sequence()
	input_index = 0
	player_inside = true
	update_ui()
	$SequenceTimer.start()
	
	if not is_connected("sequence_completed", Callable(body, "on_sequence_success")):
		connect("sequence_completed", Callable(body, "on_sequence_success"))
	body.disable_movement()  # Custom method in player to disable control
	
	
func _on_body_exited(body):	
	print("saliiiiii")
	player_inside = false
	input_index = 0
	sequence_label.text = ""
	sequence_label.visible = false
	$SequenceTimer.stop()
	
	#if not is_connected("sequence_completed", Callable(body, "on_sequence_success")):
	#	connect("sequence_completed", Callable(body, "on_sequence_success"))
	#body.disable_movement()
	
func _unhandled_input(event):
	if not player_inside or key_sequence.is_empty():
		return

	if event is InputEventKey and event.pressed:
		var key = OS.get_keycode_string(event.keycode).to_lower()
		if key == key_sequence[input_index]:
			input_index += 1
			update_ui()
			if input_index >= key_sequence.size():
				print("Sequence complete!")
				emit_signal("sequence_completed")
				sequence_label.visible = false
				queue_free()
				player_inside = false
		else:
			print("Wrong key! Restarting sequence.")
			input_index = 0
			update_ui()

func generate_sequence():
	key_sequence = []
	for i in sequence_length:
		key_sequence.append(valid_keys[randi() % valid_keys.size()])
	update_ui()

func update_ui():
	var display = ""
	for i in key_sequence.size():
		if i < input_index:
			display += "[✓ " + key_sequence[i].to_upper() + "] "
		else:
			display += "[  " + key_sequence[i].to_upper() + "] "
	sequence_label.text = display
	


func _on_sequence_timer_timeout() -> void:
	if player_inside:
		print("Time ran out!")
		input_index = 0
		update_ui()
		sequence_label.text = "[FAILED] Time ran out!\n" + sequence_label.text
		await get_tree().create_timer(1.5).timeout  # Optional pause
		sequence_label.visible = false
		player_inside = false
