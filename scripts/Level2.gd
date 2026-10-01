extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var zombies_node: Node2D = $Zombies
@onready var civilians_node: Node2D = $Civilians
@onready var score_label: Label = $UI/HUD/ScoreLabel
@onready var coins_label: Label = $UI/HUD/CoinsLabel
@onready var mission_label: Label = $UI/HUD/MissionLabel
@onready var health_label: Label = $UI/HUD/HealthLabel
@onready var wave_label: Label = $UI/HUD/WaveLabel
@onready var aim_button: Button = $UI/AimButton
@onready var shoot_button: Button = $UI/ShootButton
@onready var joystick: Control = $UI/VirtualJoystick
@onready var weapon_label: Label = $UI/HUD/WeaponLabel
@onready var allies_label: Label = $UI/HUD/AlliesLabel
@onready var game_over_panel: Panel = $UI/GameOverPanel
@onready var game_over_label: Label = $UI/GameOverPanel/VBoxContainer/GameOverLabel
@onready var retry_button: Button = $UI/GameOverPanel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $UI/GameOverPanel/VBoxContainer/MainMenuButton

var zombie_scene = preload("res://scenes/Zombie.tscn")
var civilian_scene = preload("res://scenes/Civilian.tscn")
var ally_manager: AllyManager
var weapon_system: WeaponSystem
var score: int = 0
var rescued: int = 0
var house_alive: bool = true
var level_complete: bool = false
var game_over: bool = false

# Sistema de oleadas - Más difícil que Level1
var current_wave: int = 1
var max_waves: int = 7
var zombies_per_wave: int = 7
var wave_in_progress: bool = false
var time_between_waves: float = 2.5
var wave_timer: float = 0.0

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
	
	game_over_panel.hide()
	retry_button.pressed.connect(_on_retry)
	main_menu_button.pressed.connect(_on_main_menu)

	_setup_level()
	_update_hud()

	# Agregar aliados según lo comprado
	if GameData.owned_allies.has("Medic"):
		ally_manager.spawn_ally("medic", Vector2(200, 450))
	if GameData.owned_allies.has("Sniper"):
		ally_manager.spawn_ally("sniper", Vector2(180, 450))
	if GameData.owned_allies.has("Tank"):
		ally_manager.spawn_ally("tank", Vector2(220, 450))
	
	_start_wave()

func _setup_level() -> void:
	for i in range(4):  # Más civiles que rescatar
		var civilian = civilian_scene.instantiate()
		civilian.position = Vector2(700 + i * 100, 360)
		civilians_node.add_child(civilian)

func _start_wave() -> void:
	if current_wave > max_waves:
		_complete_level()
		return
	
	wave_in_progress = true
	wave_timer = time_between_waves
	
	for i in range(zombies_per_wave + (current_wave - 1) * 2):
		var zombie = zombie_scene.instantiate()
		zombie.position = Vector2(500 + i * 60, 350)
		zombie.set_player(player)
		zombie.max_hp = 4 + current_wave
		zombie.hp = zombie.max_hp
		zombie.speed += current_wave * 15
		zombie.attack_damage = 12 + current_wave
		zombies_node.add_child(zombie)

func _process(_delta: float) -> void:
	if game_over:
		return
	
	wave_timer -= _delta
	
	var alive_zombies = 0
	for zombie in zombies_node.get_children():
		if is_instance_valid(zombie):
			alive_zombies += 1
	
	if alive_zombies == 0 and wave_in_progress:
		wave_in_progress = false
		current_wave += 1
		if current_wave <= max_waves:
			mission_label.text = "Preparándose para oleada " + str(current_wave)
			await get_tree().create_timer(time_between_waves).timeout
			_start_wave()
	
	_check_win_condition()
	_update_hud()

func _check_win_condition() -> void:
	if level_complete or game_over:
		return

	if player.health <= 0:
		_game_over(false)
		return

	var alive = 0
	for zombie in zombies_node.get_children():
		if is_instance_valid(zombie):
			alive += 1

	if alive == 0 and rescued >= 3 and current_wave > max_waves:
		_complete_level()

func _complete_level() -> void:
	level_complete = true
	mission_label.text = "✓ Nivel 2 completado!"
	if house_alive:
		GameData.add_coins(250 + current_wave * 75)
		GameData.add_score(score + 750)
		GameData.unlock_next_level()
		house_alive = false
		await get_tree().create_timer(2.0).timeout
		_show_game_over(true)

func _game_over(win: bool) -> void:
	game_over = true
	_show_game_over(win)

func _show_game_over(win: bool) -> void:
	game_over_panel.show()
	if win:
		game_over_label.text = "¡NIVEL 2 COMPLETADO!\n\nScore: " + str(score) + "\nOleadas: " + str(current_wave)
	else:
		game_over_label.text = "GAME OVER\n\nScore: " + str(score) + "\nOleadas alcanzadas: " + str(current_wave)

func _on_retry() -> void:
	get_tree().reload_current_scene()

func _on_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func rescue_civilian() -> void:
	rescued += 1
	score += 75
	GameData.add_coins(40)
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
	wave_label.text = "Oleada: " + str(current_wave) + "/" + str(max_waves)

	if not level_complete:
		mission_label.text = "Rescata " + str(4 - rescued) + " civiles - Oleada " + str(current_wave) + "/" + str(max_waves)
