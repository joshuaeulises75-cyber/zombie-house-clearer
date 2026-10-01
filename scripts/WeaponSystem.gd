extends Node
class_name WeaponSystem

var current_weapon: String = "Pistol"
var weapon_stats = {
	"Pistol": {
		"damage": 1,
		"fire_rate": 0.2,
		"bullet_speed": 600.0,
		"spread": 0.0
	},
	"Rifle": {
		"damage": 2,
		"fire_rate": 0.3,
		"bullet_speed": 700.0,
		"spread": 0.05
	},
	"Shotgun": {
		"damage": 3,
		"fire_rate": 0.5,
		"bullet_speed": 500.0,
		"spread": 0.3
	}
}

func get_weapon_stats(weapon: String) -> Dictionary:
	if weapon_stats.has(weapon):
		return weapon_stats[weapon]
	return weapon_stats["Pistol"]

func get_damage(weapon: String) -> int:
	return get_weapon_stats(weapon)["damage"]

func get_fire_rate(weapon: String) -> float:
	return get_weapon_stats(weapon)["fire_rate"]

func get_bullet_speed(weapon: String) -> float:
	return get_weapon_stats(weapon)["bullet_speed"]

func get_spread(weapon: String) -> float:
	return get_weapon_stats(weapon)["spread"]
