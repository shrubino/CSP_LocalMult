extends Node

@onready var players: Array[Dictionary] = [
	{
		sub_viewport = %LeftSubViewport,
		camera = %LeftCamera2D,
		player = %Level1/Player1,
	},
	{
		sub_viewport = %RightSubViewport,
		camera = %RightCamera2D,
		player = %Level1/Player2,
	}
]
	

func _ready() -> void:
	players[1].sub_viewport.world_2d = players[0].sub_viewport.world_2d

	# For each player, we create a remote transform that pushes the character's
	# position to the corresponding camera.
	for info in players:
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = info.camera.get_path()
		info.player.add_child(remote_transform)
