extends Node

@onready var players: Array[Dictionary] = [
	{
		sub_viewport = %LeftSubViewport,
		camera = %LeftCamera2D,
		player = $HBoxContainer/LeftViewportContainer/LeftSubViewport/Level1/Player1,
	},
	{
		sub_viewport = %RightSubViewport,
		camera = %RightCamera2D,
		player = $HBoxContainer/LeftViewportContainer/LeftSubViewport/Level1/Player2,
	}
]
	
# Distance Logic
@onready var level1      = $HBoxContainer/LeftViewportContainer/LeftSubViewport/Level1
@onready var player1     = level1.get_node("Player1")
@onready var player2     = level1.get_node("Player2")
@onready var end_zone    = level1.get_node("End")

@onready var p1_dist_lbl = $HBoxContainer/CanvasLayer/Player1DistanceLabel
@onready var p2_dist_lbl = $HBoxContainer/CanvasLayer/Player2DistanceLabel

const PIXELS_PER_METER := 16.0

func _ready() -> void:
	players[1].sub_viewport.world_2d = players[0].sub_viewport.world_2d

	# For each player, we create a remote transform that pushes the character's
	# position to the corresponding camera.
	for info in players:
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = info.camera.get_path()
		info.player.add_child(remote_transform)

# Distance Logic
func _process(_delta: float) -> void:
	if not is_instance_valid(level1):
		return
	if not (is_instance_valid(player1) and is_instance_valid(player2) and is_instance_valid(end_zone)):
		return

	var d1_pixels :float= (end_zone.global_position - player1.global_position).length()
	var d2_pixels :float= (end_zone.global_position - player2.global_position).length()

	var d1_m := d1_pixels / PIXELS_PER_METER
	var d2_m := d2_pixels / PIXELS_PER_METER

	p1_dist_lbl.text = " %.1fm" % d1_m
	p2_dist_lbl.text = " %.1fm" % d2_m


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()



func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
