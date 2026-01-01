extends Control

export(float) var speed := 150.0
onready var label: Label = $NameLabel

func _ready():
	# Başlangıçta yazıyı sağdan başlat
	label.rect_position.x = rect_size.x
	# Dikeyde ortala (şerit yüksekliğine göre)
	label.rect_position.y = (rect_size.y - label.rect_size.y) / 2

func _process(delta):
	label.rect_position.x -= speed * delta

	# Yazı tamamen soldan çıktıysa tekrar sağa al
	var w = label.get_combined_minimum_size().x
	if label.rect_position.x + w < 0:
		label.rect_position.x = rect_size.x
