extends Node2D


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("C") or Input.is_action_just_pressed("N"):
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/main.tscn") 
