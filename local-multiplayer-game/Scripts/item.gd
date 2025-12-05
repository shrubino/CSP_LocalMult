extends Area2D

enum ItemType {
	SuperJump,
	DoubleJump,
}

@export var itemType: ItemType
@export var jumpMultiplier = 1.5

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player := body as Player
		
		match itemType:
			#Super Jump function, 1.5 * jump height
			ItemType.SuperJump:
				player.jumpHeight *= jumpMultiplier
				player._updateData()
			
			#Double Jump function(Jump not working yet)
			ItemType.DoubleJump:
				player.jumps +=1
				player._updateData()
	
	print("Item Collected: " , itemType)
	
	queue_free()
