# res://Scripts/Managers/GameManager.gd
# Godot 3.6 uyumlu.
extends Node2D

const Card = preload("res://Scenes/Components/Card.tscn")
# Hata Çözümü: TextureLoader'ı yüklüyoruz.
const TextureLoaderScript = preload("res://Scripts/Managers/TextureLoader.gd")
var ALL_TEXTURES # Bu değişken _ready() içinde atanacak

onready var card_grid = get_node("CardGrid") 

var board_columns = 4
var board_size = 16
var pair_count = 8

var card_deck = []
var opened_cards = []
var game_locked = false

func _ready():
	# Hata Çözümü: Godot 3'te Resource veya Reference'ı bir kez instance etmemiz gerekir.
	ALL_TEXTURES = TextureLoaderScript.new()

# Yeni bir seviyeyi başlatmak için ana fonksiyon
func start_level(columns):
	# Eski kartları temizle (queue_free() Godot 3.x'te de çalışır)
	for child in card_grid.get_children():
		child.queue_free()
	
	# Yeni seviye değişkenlerini ayarla
	board_columns = columns
	board_size = columns * columns
	pair_count = board_size / 2
	
	card_grid.columns = board_columns
	
	var required_textures = ALL_TEXTURES.get_textures(pair_count)
	if required_textures.size() < pair_count:
		print("HATA: Level %dx%d için yeterli resim yok! Yüklenen: %d, Gerekli: %d" % 
				[columns, columns, required_textures.size(), pair_count])
		return

	setup_deck(required_textures)
	create_board(required_textures)

func setup_deck(textures):
	card_deck.clear()
	for i in range(pair_count):
		card_deck.append(i)
		card_deck.append(i)
	
	card_deck.shuffle()

func create_board(textures):
	for i in range(board_size):
		var card_instance = Card.instance() # Godot 3'te instance()
		
		var card_id = card_deck[i]
		
		card_instance.card_id = str(card_id)
		card_instance.set_card_texture(textures[card_id])
		
		# Sinyal Bağlantısı
		card_instance.connect("card_flipped", self, "on_card_flipped")
		
		card_grid.add_child(card_instance)

# Eşleşme Kontrolü
func on_card_flipped(card_instance):
	if game_locked or card_instance in opened_cards:
		return

	opened_cards.append(card_instance)
	
	if opened_cards.size() == 2:
		game_locked = true 
		var card1 = opened_cards[0]
		var card2 = opened_cards[1]
		
		if card1.card_id == card2.card_id:
			match_found(card1, card2)
		else:
			mismatch_found(card1, card2)
			
		# 1 saniye bekleme süresi (Godot 3 yield kullanımı)
		yield(get_tree().create_timer(1.0), "timeout") 
		
		opened_cards.clear()
		game_locked = false
		check_win_condition()

func match_found(card1, card2):
	card1.match()
	card2.match()

func mismatch_found(card1, card2):
	card1.close()
	card2.close()

# Seviye Atlama Mantığı
func check_win_condition():
	var all_matched = true
	for card in card_grid.get_children():
		if card.current_state != card.State.MATCHED:
			all_matched = false
			break
			
	if all_matched:
		print("Seviye %dx%d tamamlandı!" % [board_columns, board_columns])
		
		var next_columns = 0
		if board_columns == 2:
			next_columns = 4
		elif board_columns == 4:
			next_columns = 8
		elif board_columns == 8:
			print("Tebrikler, oyunu bitirdiniz!")
			# Ana menüye dön
			get_tree().change_scene("res://Scenes/Main_Menu.tscn")
			return
			
		if next_columns > 0:
			print("Sonraki seviyeye geçiliyor: %dx%d" % [next_columns, next_columns])
			start_level(next_columns)
