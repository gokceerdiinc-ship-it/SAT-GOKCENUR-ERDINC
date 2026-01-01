extends TextureButton

signal card_clicked(card)  # Level1’e haber vereceğimiz sinyal

# Inspector’dan ayarladığın resimler
export(Texture) var front_texture  # ön yüz
export(Texture) var back_texture   # arka yüz

var is_open := false      # şu anda açık mı?
var is_matched := false   # eşleşmiş kart mı?


func _ready():
	# Oyun başında kartların hepsi kapalı olsun
	show_back()


func _pressed():
	# Eşleşmiş kart tekrar tıklanmasın
	if is_matched:
		return

	# Zaten açıksa tekrar kendi kendine kapanmasın,
	# kapanma işini Level1 yapacak
	if is_open:
		return

	# Parent Level scriptinden kontrol et: 2'den fazla kart açık mı?
	var parent_level = null
	var current = get_parent()
	# CardsGrid'den Level scriptine ulaş
	while current != null:
		if current.has_method("can_open_card"):
			parent_level = current
			break
		current = current.get_parent()
	
	if parent_level != null:
		if not parent_level.can_open_card():
			return

	flip_open()
	emit_signal("card_clicked", self)


func show_back():
	is_open = false
	if back_texture:
		texture_normal = back_texture


func flip_open():
	is_open = true
	if front_texture:
		texture_normal = front_texture


func flip_close():
	# Eşleşmiş kartları kapatmayalım
	if is_matched:
		return
	show_back()


func set_matched():
	# Artık bu kart bulundu, açık kalsın, tıklanmasın
	is_matched = true
	disabled = true
