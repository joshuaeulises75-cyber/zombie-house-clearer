extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var shop_button: Button = $VBoxContainer/ShopButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

var audio_player: AudioStreamPlayer

func _ready():
	title_label.text = "ZOMBIE HOUSE CLEARER"
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Música de menú
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Estilo visual
	modulate = Color.WHITE
	update_theme()

func update_theme():
	# Colores del menú
	$VBoxContainer.add_theme_color_override("font_color", Color.WHITE)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_settings_pressed():
	# Próximamente
	print("Configuración - Próximamente")

func _on_quit_pressed():
	get_tree().quit()
