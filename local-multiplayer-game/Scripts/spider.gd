extends Node2D
@export var speed := 40
@export var left_distance := 75
@export var right_distance := 75
@onready var headed_left = true
@onready var starting_pos

@onready var marker_l = $L
@onready var marker_l2 = $L2

@onready var marker_r = $R
@onready var marker_r2 = $R2

@onready var spider = $SpiderBody
@onready var spider_sprite = $SpiderBody/AnimatedSprite2D
func _ready() -> void:
	starting_pos = global_position
	marker_l.global_position.x = starting_pos.x - left_distance
	marker_r.global_position.x = starting_pos.x + right_distance
	marker_l2.global_position.x = starting_pos.x - (left_distance/3)
	marker_r2.global_position.x = starting_pos.x + (right_distance/3)


func _physics_process(delta: float) -> void:
	if headed_left == true:
		spider.position.x -= speed * delta
		spider_sprite.flip_h = true
	elif headed_left == false: 
		spider.position.x += speed * delta
		spider_sprite.flip_h = false

	if spider.position.x <= marker_l.position.x:
		headed_left = false
	if spider.position.x >= marker_r.position.x:
		headed_left = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Body entering")
	if body.is_in_group("Player1") or body.is_in_group("Player2"):
		body._getStunned(2)
