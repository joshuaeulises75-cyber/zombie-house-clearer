extends Control

@onready var play_button: Button = $Panel/VBoxContainer/PlayButton
@onready var shop_button: Button = $Panel/VBoxContainer/ShopButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

func _ready() -> void:
	title_label.text = "ZOMBIE HOUSE CLEARER"
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
