extends AnimatableBody2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = 0.1
@onready var canflip = true
var startingPoint
func _ready() -> void:
	sprite.flip_h = true
	startingPoint = global_position

func _process(delta: float) -> void:
	
	if position.x < (startingPoint.x - 55) or position.x > (startingPoint.x + 55):
		if canflip == true:
			canflip = false
			sprite.flip_h = not sprite.flip_h
			await get_tree().create_timer(timer).timeout
			canflip = true 
