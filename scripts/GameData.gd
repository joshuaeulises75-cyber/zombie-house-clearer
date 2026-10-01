extends Node

var coins: int = 250
var owned_weapons: Array = ["Pistol"]
var owned_allies: Array = []
var current_weapon: String = "Pistol"

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
