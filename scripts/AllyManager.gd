extends Node
class_name AllyManager

var current_allies: Array = []
var player: Node2D
var dialogue_history: Array = []

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _process(delta: float) -> void:
	for ally in current_allies:
		if is_instance_valid(ally):
			# Actualizar moral lentamente
			ally.morale = max(0, ally.morale - 0.5)
			
			# Interacción entre aliados
			for other_ally in current_allies:
				if is_instance_valid(other_ally) and ally != other_ally:
					ally.interact_with_ally(other_ally)

func spawn_ally(ally_type: String, position: Vector2) -> Ally:
	var ally_scene = load("res://scenes/Ally.tscn")
	var ally = ally_scene.instantiate()
	ally.position = position
	ally.ally_type = ally_type

	match ally_type:
		"medic":
			ally.ally_name = "Médico"
			ally.personality = ["brave", "cautious"].pick_random()
			ally.max_hp = 50
		"sniper":
			ally.ally_name = "Francotirador"
			ally.personality = "cautious"
			ally.max_hp = 40
		"tank":
			ally.ally_name = "Tanque"
			ally.personality = "brave"
			ally.max_hp = 80

	ally.set_player(player)
	get_tree().current_scene.add_child(ally)
	current_allies.append(ally)
	return ally

func get_alive_allies_count() -> int:
	var count = 0
	for ally in current_allies:
		if is_instance_valid(ally) and not ally.abandoned:
			count += 1
	return count

func speak_to_allies(message: String) -> void:
	for ally in current_allies:
		if is_instance_valid(ally) and not ally.abandoned:
			ally._speak(message)

func get_allies_by_personality(personality: String) -> Array:
	var result = []
	for ally in current_allies:
		if is_instance_valid(ally) and ally.personality == personality:
			result.append(ally)
	return result
