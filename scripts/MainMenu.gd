extends Control

@onready var play_button: Button = $Panel/VBoxContainer/PlayButton
@onready var shop_button: Button = $Panel/VBoxContainer/ShopButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var level_label: Label = $Panel/VBoxContainer/LevelLabel

func _ready() -> void:
	title_label.text = "ZOMBIE HOUSE CLEARER"
	score_label.text = "Score Total: " + str(GameData.total_score)
	level_label.text = "Nivel Desbloqueado: " + str(GameData.current_level)
	
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	if GameData.current_level == 1:
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Level2.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
