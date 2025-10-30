# res://Scripts/Managers/TextureLoader.gd
# Godot 3.6 uyumlu.
extends Reference 

const MAX_PAIRS = 32 # 8x8 tahta için maksimum gerekli çift sayısı
var all_card_textures = []

# Yeni bir örnek oluşturulduğunda otomatik çalışır
func _init():
	# Tüm resimleri (img_01'den img_32'ye kadar) yükle
	for i in range(1, MAX_PAIRS + 1):
		# NOT: Resim uzantınızı .jpg olarak varsayıyorum.
		var path = "res://Assets/Cards/img_%02d.jpg" % i 
		var texture = load(path)
		if texture:
			all_card_textures.append(texture)
		else:
			push_warning("Kart resmi yüklenemedi: " + path)

# Belirli sayıda resim döndüren fonksiyon
func get_textures(count):
	if count > all_card_textures.size():
		count = all_card_textures.size()
	
	var textures_to_use = []
	for i in range(count):
		textures_to_use.append(all_card_textures[i])
		
	return textures_to_use
