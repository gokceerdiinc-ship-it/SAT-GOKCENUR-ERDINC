# res://Scripts/Components/Card.gd
extends Area2D

# Kartın ID'si (eşleşmeyi kontrol etmek için)
export var card_id = ""

# Kart durumları (Kapalı, Açık, Eşleşti)
enum State {CLOSED, OPENED, MATCHED}
var current_state = State.CLOSED

# Düğümlere erişim için Godot 3.x syntax'ı
onready var card_front = get_node("CardFront")
onready var card_back = get_node("CardBack")

# Oyun yöneticisine göndermek için sinyal
signal card_flipped

# Kartın ön yüz resmini ayarlar
func set_card_texture(texture):
	card_front.texture = texture

# Kartı Açma
func flip():
	if current_state == State.CLOSED:
		current_state = State.OPENED
		card_front.visible = true
		card_back.visible = false
		# Sinyali tetikle (self'i argüman olarak gönder)
		emit_signal("card_flipped", self)

# Kartı Kapatma (Eşleşmediğinde)
func close():
	if current_state == State.OPENED:
		current_state = State.CLOSED
		card_front.visible = false
		card_back.visible = true

# Kartı Eşleşti Olarak İşaretleme
func match():
	current_state = State.MATCHED

# Tıklama algılama (Area2D'nin 'input_event' sinyaline bağlanmalıdır!)
func _on_Card_input_event(viewport, event, shape_idx):
	# Farenin sol tuşu basılıysa
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if current_state == State.CLOSED:
			flip()

# NOT: Card.tscn sahnenizin Card (Area2D) düğümünden
# 'input_event' sinyalini alıp bu _on_Card_input_event() fonksiyonuna bağlamanız GEREKİR.
