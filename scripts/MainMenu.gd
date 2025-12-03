extends Control

func _ready():
	# Şimdilik burada bir şey yapmıyoruz
	pass


func _on_PlayButton_pressed():
	# Play'e basılınca LevelSelect sahnesine geç
	get_tree().change_scene("res://scenes/ui/LevelSelect.tscn")
