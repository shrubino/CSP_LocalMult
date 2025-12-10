extends Area2D

@onready var win_panel: Control = get_tree().get_first_node_in_group("win_panel")
@onready var win_label: Label = win_panel.get_node("WinLabel")

#@onready var hBox: HBoxContainer = get_tree().get_first_node_in_group("HBoxContainer")
#@onready var win_bg: AnimatedSprite2D = hBox.get_node("WinBG")
@onready var win_bg: AnimatedSprite2D = get_tree().get_first_node_in_group("win_bg")
@onready var win_bf: AnimatedSprite2D = get_tree().get_first_node_in_group("win_bf")
@onready var win_rf: AnimatedSprite2D = get_tree().get_first_node_in_group("win_rf")

@onready var p1_dist_lbl: Label = get_tree().get_first_node_in_group("p1_distance")
@onready var p2_dist_lbl: Label = get_tree().get_first_node_in_group("p2_distance")

@onready var winSound = get_tree().get_first_node_in_group("Winsound")

var player1_win := false
var player2_win := false

var game_ended := false

func _on_body_entered(body: Node2D) -> void:
	if game_ended:
		return

	var win_text := ""

	if body is Player1:
		win_text = "Player 1 wins!"
		player1_win = true
	elif body is Player2:
		win_text = "Player 2 wins!"
		player2_win = true
	else:
		return
	winSound.play()
	game_ended = true
	_show_end_screen(win_text)

func _show_end_screen(text: String) -> void:
	win_label.text = text
	win_panel.visible = true
	win_bg.visible = true
	
	if player1_win:
		win_bf.visible = true
	if player2_win:
		win_rf.visible = true
		
	# Hide DIstance Label
	if is_instance_valid(p1_dist_lbl):
		p1_dist_lbl.visible = false
	if is_instance_valid(p2_dist_lbl):
		p2_dist_lbl.visible = false
	
	get_tree().paused = true
	monitoring = false
