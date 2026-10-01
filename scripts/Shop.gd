extends Control

@onready var coins_label: Label = $Panel/CoinsLabel
@onready var weapon_list: VBoxContainer = $Panel/WeaponList
@onready var ally_list: VBoxContainer = $Panel/AllyList
@onready var back_button: Button = $Panel/BackButton

var shop_items = [
	{"name": "Pistol", "cost": 0, "type": "weapon"},
	{"name": "Rifle", "cost": 120, "type": "weapon"},
	{"name": "Shotgun", "cost": 220, "type": "weapon"},
	{"name": "Medic", "cost": 90, "type": "ally"},
	{"name": "Sniper", "cost": 180, "type": "ally"},
	{"name": "Tank", "cost": 260, "type": "ally"}
]

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_build_shop()
	_update_ui()

func _build_shop() -> void:
	for child in weapon_list.get_children():
		child.queue_free()
	for child in ally_list.get_children():
		child.queue_free()
	
	for item in shop_items:
		var button = Button.new()
		button.text = item["name"] + " - " + str(item["cost"]) + " coins"
		button.pressed.connect(_buy.bind(item))
		if item["type"] == "weapon":
			weapon_list.add_child(button)
		else:
			ally_list.add_child(button)

func _buy(item: Dictionary) -> void:
	if item["type"] == "weapon":
		if GameData.buy_weapon(item["name"], item["cost"]):
			print("Compraste arma: ", item["name"])
		else:
			print("No tienes monedas suficientes o ya la tienes")
	else:
		if GameData.buy_ally(item["name"], item["cost"]):
			print("Compraste aliado: ", item["name"])
		else:
			print("No tienes monedas suficientes o ya lo tienes")
	_update_ui()

func _update_ui() -> void:
	coins_label.text = "Coins: " + str(GameData.coins)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
