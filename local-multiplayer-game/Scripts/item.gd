extends Area2D

enum ItemType {
	SuperJump,
	DoubleJump,
}

@export var itemType: ItemType
@export var jumpMultiplier := 1.5
@export var duration := 2.0   # 持续时间（秒）

	

func _on_body_entered(body: Node2D) -> void:
	var sprite = $AnimatedSprite2D
	if body is Player1:
		match itemType:
			ItemType.SuperJump:
				# 记录原始数值
				var original_jump_height :float= body.jumpHeight

				# 增强跳跃
				body.jumpHeight *= jumpMultiplier
				body._updateData()

				var icon = get_tree().get_first_node_in_group("superjump")
				sprite.visible = false
				icon.visible = true

				await get_tree().create_timer(duration).timeout

				# 恢复原始数值
				body.jumpHeight = original_jump_height
				body._updateData()
				icon.visible = false

			ItemType.DoubleJump:
				# 记录原始 jumps
				var original_jumps :int= body.jumps

				body.jumps += 1
				body._updateData()

				var icon = get_tree().get_first_node_in_group("doublejump")
				sprite.visible = false
				icon.visible = true
				await get_tree().create_timer(5).timeout
				icon.visible = false
	if body is Player2:
		match itemType:
			#Super Jump function, 1.5 * jump height
			ItemType.SuperJump:
				body.jumpHeight *= jumpMultiplier
				body._updateData()
				var icon = get_tree().get_first_node_in_group("superjump2")
				sprite.visible = false
				icon.visible = true
				await get_tree().create_timer(5).timeout
				icon.visible = false
			#Double Jump function(Jump not working yet)
			ItemType.DoubleJump:
				var original_jumps :int= body.jumps
				body.jumps +=1
				body._updateData()
				var icon = get_tree().get_first_node_in_group("doublejump2")
				sprite.visible = false
				#icon.visible = true # aint workin!

				await get_tree().create_timer(duration).timeout

				# 恢复原始 jumps
				body.jumps = original_jumps
				body._updateData()
				#icon.visible = false # THIS JUST aint working yet!

	print("Item Collected: ", itemType)
	queue_free()
