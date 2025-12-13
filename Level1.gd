extends Control

onready var grid            = $CardsGrid
onready var close_timer     = $CloseTimer
onready var clicks_label    = $ClicksLabel
onready var gameover_label  = $GameOverLabel
onready var retry_button    = $RetryButton

export(int) var clicks_start := 8
export(PackedScene) var next_level_scene    # Inspector’dan Level2.tscn’i buraya sürükle-bırak

var clicks_left := 0
var opened_cards = []
var lock_input = false


func _ready():
	randomize()

	clicks_left = clicks_start
	_update_clicks_ui()

	# Timer
	close_timer.one_shot = true
	close_timer.wait_time = 0.8
	if not close_timer.is_connected("timeout", self, "_on_close_timer_timeout"):
		close_timer.connect("timeout", self, "_on_close_timer_timeout")

	# UI başlangıç
	if gameover_label:
		gameover_label.visible = false
	if retry_button:
		retry_button.visible = false

	# Kart sinyalleri (CardsGrid içindeki Card'ları yakala)
	for c in grid.get_children():
		if _is_card(c) and not c.is_connected("card_clicked", self, "_on_card_clicked"):
			c.connect("card_clicked", self, "_on_card_clicked")


func _on_card_clicked(card):
	# oyun kilitliyse veya tıklama bittiyse hiçbir şey yapma
	if lock_input or clicks_left <= 0:
		return

	# aynı kartı tekrar alma
	if card in opened_cards:
		return

	# tıklama düş
	clicks_left -= 1
	_update_clicks_ui()

	# tıklama bitti -> açık kartları kapat -> game over
	if clicks_left <= 0:
		for c in opened_cards:
			if is_instance_valid(c):
				c.flip_close()
		opened_cards.clear()
		_game_over()
		return

	opened_cards.append(card)

	# 2 kart olduysa kontrol
	if opened_cards.size() == 2:
		lock_input = true

		var a = opened_cards[0]
		var b = opened_cards[1]

		if a.front_texture == b.front_texture:
			a.set_matched()
			b.set_matched()

			opened_cards.clear()
			lock_input = false

			_check_level_complete()   # <-- geçiş burada tetikleniyor
		else:
			close_timer.stop()
			close_timer.start()


func _on_close_timer_timeout():
	for c in opened_cards:
		if is_instance_valid(c):
			c.flip_close()

	opened_cards.clear()
	lock_input = false


func _check_level_complete():
	# SADECE Card olanları kontrol et
	for c in grid.get_children():
		if not _is_card(c):
			continue
		if not c.is_matched:
			return

	# Buraya geldiysek hepsi matched -> sonraki level
	lock_input = true
	close_timer.stop()

	if next_level_scene:
		get_tree().change_scene_to(next_level_scene)
	else:
		print("LEVEL TAMAMLANDI ama next_level_scene boş!")
		# İstersen fallback:
		# get_tree().change_scene("res://scenes/ui/LevelSelect.tscn")


func _game_over():
	lock_input = true
	close_timer.stop()
	opened_cards.clear()

	# Kartları kilitle
	for c in grid.get_children():
		if _is_card(c):
			c.disabled = true

	if gameover_label:
		gameover_label.visible = true
	if retry_button:
		retry_button.visible = true


func _on_RetryButton_pressed():
	get_tree().reload_current_scene()


func _update_clicks_ui():
	if clicks_label:
		clicks_label.text = "Tıklama: " + str(clicks_left)


# --- yardımcı: gerçekten Card mı? ---
func _is_card(n):
	# Card.tscn senin projende TextureButton + card_clicked sinyali + flip_close fonksiyonu var
	return (n != null
		and n.has_signal("card_clicked")
		and n.has_method("flip_close")
		and n.has_method("set_matched"))


func _on_ExitButton_pressed():
	pass # Replace with function body.


func _on_CloseTimer_timeout():
	pass # Replace with function body.
