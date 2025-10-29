# res://Scripts/UI/MainMenu.gd
# Godot 3.6 uyumlu.
extends Control

# Oyun sahnesini önceden yükle
const GameScene = preload("res://Scenes/Game.tscn")

func _on_Button_2x2_pressed():
	start_game(2)

func _on_Button_4x4_pressed():
	start_game(4)

func _on_Button_8x8_pressed():
	start_game(8)

func start_game(board_size):
	# Yeni Game sahnesini oluştur (instance() Godot 3.x'te kullanılır)
	var game_instance = GameScene.instance()
	
	# 1. Mevcut sahne ağacından kendini (MainMenu) kaldır
	self.queue_free()
	
	# 2. Yeni sahneyi (Game) sahne ağacına ekle
	get_tree().get_root().add_child(game_instance)
	
	# 3. Seviyeyi başlat
	game_instance.start_level(board_size) 

# NOT: MainMenu.tscn sahnesindeki butonların 'pressed()' sinyallerini
# bu script'teki _on_Button_X_pressed() fonksiyonlarına bağlamanız GEREKİR.
