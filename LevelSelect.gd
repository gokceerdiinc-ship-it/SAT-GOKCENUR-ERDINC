extends Control

func _ready():
	pass


func _on_Level1Button_pressed():
	get_tree().change_scene("res://scenes/levels/Level1.tscn")


func _on_Level2Button_pressed():
	get_tree().change_scene("res://scenes/levels/Level2.tscn")


func _on_Level3Button_pressed():
	get_tree().change_scene("res://scenes/levels/Level3.tscn")
