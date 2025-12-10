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
				var icon = get_tree().get_first_node_in_group("superjump")
				icon.visible = true
				await get_tree().create_timer(2).timeout
				icon.visible = false
			#Double Jump function(Jump not working yet)
			ItemType.DoubleJump:
				body.jumps +=1
				body._updateData()
				var icon = get_tree().get_first_node_in_group("doublejump")
				icon.visible = true
				await get_tree().create_timer(2).timeout
				icon.visible = false
	print("Item Collected: " , itemType)
	
	queue_free()
