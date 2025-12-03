extends Control

func _ready():
	pass


func _on_ExitButton_pressed():
	get_tree().change_scene("res://scenes/ui/MainMenu.tscn")
	# veya LevelSelect'e dönmek istiyorsan:
	# get_tree().change_scene("res://scenes/ui/LevelSelect.tscn")
