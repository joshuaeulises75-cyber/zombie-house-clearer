extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var zombies_node: Node2D = $Zombies
@onready var civilians_node: Node2D = $Civilians
@onready var score_label: Label = $UI/HUD/ScoreLabel
@onready var coins_label: Label = $UI/HUD/CoinsLabel
@onready var mission_label: Label = $UI/HUD/MissionLabel
@onready var health_label: Label = $UI/HUD/HealthLabel
@onready var aim_button: Button = $UI/AimButton
@onready var shoot_button: Button = $UI/ShootButton
@onready var joystick: Control = $UI/VirtualJoystick
@onready var weapon_label: Label = $UI/HUD/WeaponLabel
@onready var allies_label: Label = $UI/HUD/AlliesLabel

var zombie_scene = preload("res://scenes/Zombie.tscn")
var civilian_scene = preload("res://scenes/Civilian.tscn")
var ally_manager: AllyManager
var weapon_system: WeaponSystem
var score: int = 0
var rescued: int = 0
var house_alive: bool = true
var level_complete: bool = false

func _ready() -> void:
	ally_manager = AllyManager.new()
	add_child(ally_manager)
	ally_manager._ready()

	weapon_system = WeaponSystem.new()
	add_child(weapon_system)

	player.register_joystick(joystick)
	player.set_aim_button(aim_button)
	player.set_shoot_button(shoot_button)
	player.set_weapon_system(weapon_system)

	_setup_level()
	_update_hud()

	# Agregar aliados según lo comprado
	if GameData.owned_allies.has("Medic"):
		ally_manager.spawn_ally("medic", Vector2(200, 450))
	if GameData.owned_allies.has("Sniper"):
		ally_manager.spawn_ally("sniper", Vector2(180, 450))
	if GameData.owned_allies.has("Tank"):
		ally_manager.spawn_ally("tank", Vector2(220, 450))

func _setup_level() -> void:
	for i in range(7):
		var zombie = zombie_scene.instantiate()
		zombie.position = Vector2(500 + i * 80, 350)
		zombie.set_player(player)
		zombies_node.add_child(zombie)

	for i in range(3):
		var civilian = civilian_scene.instantiate()
		civilian.position = Vector2(700 + i * 120, 360)
		civilians_node.add_child(civilian)

func _process(_delta: float) -> void:
	_check_win_condition()
	_update_hud()

func _check_win_condition() -> void:
	if level_complete:
		return

	var alive = 0
	for zombie in zombies_node.get_children():
		if is_instance_valid(zombie):
			alive += 1

	if alive == 0 and rescued >= 2:
		level_complete = true
		mission_label.text = "✓ Objetivo cumplido: casa limpia"
		if house_alive:
			GameData.add_coins(150)
			house_alive = false
			print("Nivel completado. +150 coins")
			get_tree().create_timer(3.0).timeout.connect(_next_level)

func _next_level() -> void:
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")

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
	health_label.text = "HP: " + str(player.health) + "/" + str(player.max_health)
	weapon_label.text = "Arma: " + GameData.current_weapon
	allies_label.text = "Aliados: " + str(ally_manager.get_alive_allies_count())

	if not level_complete:
		mission_label.text = "Rescata " + str(3 - rescued) + " civiles y limpia la casa"
