extends Node

# Progresión del juego
var coins: int = 250
var current_level: int = 1
var owned_weapons: Array = ["Pistol"]
var owned_allies: Array = []
var current_weapon: String = "Pistol"
var total_score: int = 0

# Sistema de guardado
func _ready():
	add_to_group("autoload")

func buy_weapon(name: String, cost: int) -> bool:
	if coins >= cost and not owned_weapons.has(name):
		coins -= cost
		owned_weapons.append(name)
		current_weapon = name
		return true
	return false

func buy_ally(name: String, cost: int) -> bool:
	if coins >= cost and not owned_allies.has(name):
		coins -= cost
		owned_allies.append(name)
		return true
	return false

func add_coins(amount: int) -> void:
	coins += amount

func add_score(amount: int) -> void:
	total_score += amount

func reset_level_data() -> void:
	# Reinicia datos de nivel pero mantiene compras
	pass

func unlock_next_level() -> void:
	current_level += 1
