extends Node2D



func _on_again_pressed() -> void:
	get_tree().change_scene_to_file("res://rooms/room_1.tscn")
