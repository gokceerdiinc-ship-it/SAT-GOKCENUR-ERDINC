extends Control

onready var grid            = $CardsGrid
onready var close_timer     = $CloseTimer
onready var clicks_label    = $ClicksLabel
onready var gameover_label  = $GameOverLabel
onready var retry_button    = $RetryButton

export(int) var clicks_start := 8
export(PackedScene) var next_level_scene    # Inspector’dan Level2.tscn

var clicks_left := 0
var opened_cards := []        # en fazla 2 kart
var lock_input := false


func _ready():
	randomize()

	# HER GİRİŞTE KARTLARI KARIŞTIR
	_shuffle_cards_in_grid()

	clicks_left = clicks_start
	_update_clicks_ui()

	# Timer ayarları
	close_timer.one_shot = true
	close_timer.wait_time = 0.8
	if not close_timer.is_connected("timeout", self, "_on_close_timer_timeout"):
		close_timer.connect("timeout", self, "_on_close_timer_timeout")

	# UI başlangıç
	if gameover_label:
		gameover_label.visible = false
	if retry_button:
		retry_button.visible = false

	# Kart sinyalleri
	for c in grid.get_children():
		if _is_card(c) and not c.is_connected("card_clicked", self, "_on_card_clicked"):
			c.connect("card_clicked", self, "_on_card_clicked")


# =========================
# KART KARIŞTIRMA
# =========================
func _shuffle_cards_in_grid():
	var cards := []
	for n in grid.get_children():
		if _is_card(n):
			cards.append(n)

	cards.shuffle()

	for c in cards:
		grid.remove_child(c)
	for c in cards:
		grid.add_child(c)


func _on_card_clicked(card):
	# oyun kilitliyse veya tıklama bittiyse hiçbir şey yapma
	if lock_input or clicks_left <= 0:
		return

	# aynı kartı iki kere alma
	if card in opened_cards:
		return

	# ZATEN 2 KART AÇIKSA YENİ KART AÇMA (kritik: kart eklenmeden önce kontrol)
	if opened_cards.size() >= 2:
		return

	# ✅ ÖNCE listeye ekle (kritik düzeltme)
	opened_cards.append(card)

	# tıklama düş
	clicks_left -= 1
	_update_clicks_ui()

	# tıklama bitti -> açık kartları (son tıklanan dahil) kapat -> game over
	if clicks_left <= 0:
		_close_opened_cards_now()
		_game_over()
		return

	# 2 kart olduysa kontrol
	if opened_cards.size() == 2:
		lock_input = true

		var a = opened_cards[0]
		var b = opened_cards[1]

		if _is_match(a, b):
			# EŞLEŞTİ -> açık kalsın
			a.set_matched()
			b.set_matched()

			opened_cards.clear()
			lock_input = false
			_check_level_complete()
		else:
			# EŞLEŞMEDİ -> timer ile kapat
			close_timer.stop()
			close_timer.start()


func _on_close_timer_timeout():
	# 2 kartı kapat (eşleşmişse zaten Card.gd kapatmaz, ekstra güvenlik de var)
	for c in opened_cards:
		if is_instance_valid(c) and (not c.is_matched):
			c.flip_close()

	opened_cards.clear()
	lock_input = false


func _close_opened_cards_now():
	close_timer.stop()
	for c in opened_cards:
		if is_instance_valid(c) and (not c.is_matched):
			c.flip_close()
	opened_cards.clear()
	lock_input = true


func _is_match(a, b) -> bool:
	# ✅ Texture instance problemi olmasın diye resource_path ile karşılaştırıyoruz
	if a == null or b == null:
		return false
	if a.front_texture == null or b.front_texture == null:
		return false

	var pa = a.front_texture.resource_path
	var pb = b.front_texture.resource_path
	return pa != "" and pa == pb


func _check_level_complete():
	for c in grid.get_children():
		if not _is_card(c):
			continue
		if not c.is_matched:
			return

	lock_input = true
	close_timer.stop()

	if next_level_scene:
		get_tree().change_scene_to(next_level_scene)
	else:
		print("LEVEL 1 tamamlandı ama next_level_scene boş!")


func _game_over():
	lock_input = true

	# kartları kilitle
	for c in grid.get_children():
		if _is_card(c):
			c.disabled = true

	if gameover_label:
		gameover_label.visible = true
	if retry_button:
		retry_button.visible = true

	print("GAME OVER")


func _on_RetryButton_pressed():
	get_tree().reload_current_scene()


func _update_clicks_ui():
	if clicks_label:
		clicks_label.text = "Tıklama: " + str(clicks_left)


func _is_card(n):
	return (n != null
		and n.has_signal("card_clicked")
		and n.has_method("flip_close")
		and n.has_method("set_matched"))


# Card.gd'den çağrılacak: kaç kart açık?
func can_open_card() -> bool:
	return opened_cards.size() < 2 and not lock_input


func _on_ExitButton_pressed():
	get_tree().change_scene("res://scenes/ui/LevelSelect.tscn")


func _on_CloseTimer_timeout():
	_on_close_timer_timeout()

