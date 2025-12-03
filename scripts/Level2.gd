extends Control

func _ready():
	pass


func _on_ExitButton_pressed():
	# Level 2'den ana menüye dön
	get_tree().change_scene("res://scenes/ui/MainMenu.tscn")
