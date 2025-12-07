extends Area2D

@export var win_panel: Control      
@export var win_label: Label        

var game_ended: bool = false


func _ready() -> void:
	if win_panel:
		win_panel.visible = false


func _on_body_entered(body: Node2D) -> void:
	if game_ended:
		return

	var win_text := ""

	if body is Player1:
		win_text = "Player 1 wins!"
	elif body is Player2:
		win_text = "Player 2 wins!"
	else:
		return

	game_ended = true
	_show_end_screen(win_text)


func _show_end_screen(text: String) -> void:
	if win_label:
		win_label.text = text
	if win_panel:
		win_panel.visible = true

	# Pause Game
	get_tree().paused = true
	monitoring = false  #prevent double trigger

# Restart Button
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Quit Button
func _on_QuitButton_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
