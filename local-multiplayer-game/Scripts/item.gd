extends Area2D

enum ItemType {
	SuperJump,
	DoubleJump,
}

@export var itemType: ItemType
@export var jumpMultiplier = 1.5

func _on_body_entered(body: Node2D) -> void:
	if body is Player1 or body is Player2:
		
		match itemType:
			#Super Jump function, 1.5 * jump height
			ItemType.SuperJump:
				body.jumpHeight *= jumpMultiplier
				body._updateData()
			
			#Double Jump function(Jump not working yet)
			ItemType.DoubleJump:
				body.jumps +=1
				body._updateData()
	
	print("Item Collected: " , itemType)
	
	queue_free()
