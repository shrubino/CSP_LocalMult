extends Area2D
@onready var PlayerSprite := $Sprite2D
@export_category("Animations (Check Box if has animation)")
@export var default: bool
var anim

func _ready():
	anim = PlayerSprite

# Called when the node enters the scene tree for the first time.
func _on_body_entered(body: Node2D) -> void:
	if body is Player1 or body is Player2:
		anim.play("default")
		$CollisionShape2D.disabled = true
	queue_free()
