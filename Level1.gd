extends Control

onready var grid            = $CardsGrid
onready var close_timer     = $CloseTimer
onready var clicks_label    = $ClicksLabel
onready var gameover_label  = $GameOverLabel
onready var retry_button    = $RetryButton

export(int) var clicks_start := 8
export(PackedScene) var next_level_scene   # Inspector’dan Level2.tscn

var clicks_left := 0
var opened_cards := []          # şu an açık (max 2)
var pending_close := []         # Timer bitince kapatılacak 2 kartın “snapshot”ı
var lock_input := false


func _ready():
	randomize()

	# HER GİRİŞTE KARTLARI KARIŞTIR
	_shuffle_cards_in_grid()

	# tıklama hakkı (Inspector’dan clicks_start değiştir)
	clicks_left = clicks_start
	_update_clicks_ui()

	# UI başlangıç
	if gameover_label:
		gameover_label.visible = false
	if retry_button:
		retry_button.visible = false

	# Timer
	close_timer.one_shot = true
	close_timer.wait_time = 0.8
	# Editörden bağlıysa zaten var olabilir; güvenli olsun:
	if not close_timer.is_connected("timeout", self, "_on_close_timer_timeout"):
		close_timer.connect("timeout", self, "_on_close_timer_timeout")

	# Kart sinyalleri
	for c in grid.get_children():
		if _is_card(c) and not c.is_connected("card_clicked", self, "_on_card_clicked"):
			c.connect("card_clicked", self, "_on_card_clicked")


# -------------------------
# KARTLARI KARIŞTIRMA
# -------------------------
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


# -------------------------
# KART TIKLAMA
# -------------------------
func _on_card_clicked(card):
	# oyun bitmiş/kilitliyse dokunma
	if lock_input or clicks_left <= 0:
		return

	# aynı kartı iki kez alma
	if card in opened_cards:
		return

	# ZATEN 2 KART AÇIKSA YENİ KART AÇMA (kritik: kart eklenmeden önce kontrol)
	if opened_cards.size() >= 2:
		return

	# TIKLAMA DÜŞ
	clicks_left -= 1
	_update_clicks_ui()

	# hak bitti -> açık kartları kapat -> game over
	if clicks_left <= 0:
		# o anda açık olanları kapat
		for c in opened_cards:
			if is_instance_valid(c):
				c.flip_close()
		opened_cards.clear()

		# ayrıca bekleyen timer kapatmasını iptal et
		close_timer.stop()
		pending_close.clear()

		_game_over()
		return

	opened_cards.append(card)

	if opened_cards.size() == 2:
		lock_input = true

		var a = opened_cards[0]
		var b = opened_cards[1]

		# EŞLEŞME
		if a.front_texture == b.front_texture:
			# önce bekleyen timer kapanmasını iptal et (kritik!)
			close_timer.stop()
			pending_close.clear()

			a.set_matched()
			b.set_matched()

			opened_cards.clear()
			lock_input = false

			_check_level_complete()
		else:
			# EŞLEŞMEDİ -> kapatılacak çifti snapshot al
			pending_close = opened_cards.duplicate()
			close_timer.stop()
			close_timer.start()


# -------------------------
# TIMER -> SADECE pending_close KAPATIR
# -------------------------
func _on_close_timer_timeout():
	# sadece “yanlış eşleşen” çifti kapat
	for c in pending_close:
		if is_instance_valid(c):
			c.flip_close()

	pending_close.clear()
	opened_cards.clear()
	lock_input = false


# -------------------------
# LEVEL TAMAMLANDI MI?
# -------------------------
func _check_level_complete():
	for c in grid.get_children():
		if not _is_card(c):
			continue
		if not c.is_matched:
			return

	lock_input = true
	close_timer.stop()
	pending_close.clear()

	if next_level_scene:
		get_tree().change_scene_to(next_level_scene)
	else:
		print("LEVEL 1 tamamlandı ama next_level_scene boş!")


# -------------------------
# GAME OVER
# -------------------------
func _game_over():
	lock_input = true

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


# Editörden yanlışlıkla bu isimle bağlı sinyal varsa sorun çıkmasın:
func _on_CloseTimer_timeout():
	_on_close_timer_timeout()
