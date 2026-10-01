extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var zombies_node: Node2D = $Zombies
@onready var civilians_node: Node2D = $Civilians
@onready var score_label: Label = $UI/HUD/ScoreLabel
@onready var coins_label: Label = $UI/HUD/CoinsLabel
@onready var mission_label: Label = $UI/HUD/MissionLabel
@onready var aim_button: Button = $UI/AimButton
@onready var shoot_button: Button = $UI/ShootButton
@onready var joystick: Control = $UI/VirtualJoystick

var zombie_scene = preload("res://scenes/Zombie.tscn")
var civilian_scene = preload("res://scenes/Civilian.tscn")
var score: int = 0
var rescued: int = 0
var house_alive: bool = true

func _ready() -> void:
	player.register_joystick(joystick)
	player.set_aim_button(aim_button)
	player.set_shoot_button(shoot_button)
	_setup_level()
	_update_hud()

func _setup_level() -> void:
	for i in range(5):
		var zombie = zombie_scene.instantiate()
		zombie.position = Vector2(500 + i * 120, 350)
		zombie.set_player(player)
		zombies_node.add_child(zombie)

	for i in range(2):
		var civilian = civilian_scene.instantiate()
		civilian.position = Vector2(700 + i * 140, 360)
		civilians_node.add_child(civilian)

func _process(_delta: float) -> void:
	_check_win_condition()
	_update_hud()

func _check_win_condition() -> void:
	var alive = 0
	for zombie in zombies_node.get_children():
		if is_instance_valid(zombie):
			alive += 1
	if alive == 0 and rescued >= 1:
		mission_label.text = "Objetivo cumplido: casa limpia"
		if house_alive:
			GameData.add_coins(150)
			house_alive = false
			print("Nivel completado. +150 coins")

func rescue_civilian() -> void:
	rescued += 1
	score += 50
	GameData.add_coins(25)
	_update_hud()

func update_score(value: int) -> void:
	score += value
	_update_hud()

func _update_hud() -> void:
	score_label.text = "Score: " + str(score)
	coins_label.text = "Coins: " + str(GameData.coins)
	mission_label.text = "Rescata civiles y limpia la casa"
