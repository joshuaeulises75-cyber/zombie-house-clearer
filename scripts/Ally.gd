extends CharacterBody2D
class_name Ally

@export var ally_name: String = "Medic"
@export var ally_type: String = "medic"  # medic, sniper, tank
@export var move_speed: float = 150.0
@export var max_hp: int = 50
@export var personality: String = "brave"  # brave, cautious, coward

var hp: int = max_hp
var morale: int = 100  # Moral del aliado (0-100)
var fear_level: int = 0  # Nivel de miedo (0-100)
var abandoned: bool = false
var player: Node2D
var target_zombie: Node2D
var messages: Array = []
var last_message_time: float = 0.0
var message_cooldown: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var speech_bubble: Label = $SpeechBubble

var bullet_scene = preload("res://scenes/Bullet.tscn")
var fire_timer: float = 0.0

func _ready() -> void:
	add_to_group("allies")
	_setup_messages()
	_setup_personality()

func _setup_personality() -> void:
	match personality:
		"brave":
			messages = [
				"¡Vamos a limpiar esta casa!",
				"No hay zombies que nos detengan",
				"¡A POR ELLOS!",
				"Esto será fácil",
				"¡CARGAAAA!"
			]
		"cautious":
			messages = [
				"Hay que tener cuidado...",
				"Cubramos esto bien",
				"Vigilemos los flancos",
				"Esto es peligroso...",
				"Preparados para lo peor"
			]
		"coward":
			messages = [
				"¿Seguro que esto es seguro?",
				"Hay... hay demasiados",
				"No creo que pueda más...",
				"¡AY QUE MIEDO!",
				"Prefiero estar en otro lado"
			]
func _setup_messages() -> void:
	if messages.is_empty():
		messages = ["Vamos", "Cuidado", "¡Atacan!", "Ayuda!"]

func _physics_process(delta: float) -> void:
	if abandoned:
		velocity.x = 0
		return

	fire_timer = max(0.0, fire_timer - delta)
	last_message_time += delta

	if player == null:
		return

	# Actualizar miedo basado en zombies cercanos
	var nearby_zombies = 0
	for zombie in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(zombie):
			if global_position.distance_to(zombie.global_position) < 200.0:
				nearby_zombies += 1

	fear_level = min(100, fear_level + nearby_zombies * 5)

	# Chequear si debe abandonar
	if _should_abandon():
		_abandon_mission()
		return

	# Comportamiento según tipo de aliado
	match ally_type:
		"medic":
			_medic_ai(delta, nearby_zombies)
		"sniper":
			_sniper_ai(delta, nearby_zombies)
		"tank":
			_tank_ai(delta, nearby_zombies)

func _medic_ai(delta: float, nearby_zombies: int) -> void:
	# El médico intenta proteger al jugador
	var direction = player.global_position - global_position
	var distance = direction.length()

	if distance > 100.0:
		velocity.x = sign(direction.x) * move_speed
	else:
		velocity.x = 0

	# Curar al jugador si está herido
	if player.health < player.max_health and distance < 50.0:
		if last_message_time > message_cooldown:
			_speak("¡Aguanta, te curo!")
			last_message_time = 0.0
		player.health += 2

	# Intentar disparar a zombies cercanos
	if nearby_zombies > 0 and fire_timer <= 0.0:
		_shoot_at_nearest_zombie()
		fire_timer = 0.8

	move_and_slide()

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _sniper_ai(delta: float, nearby_zombies: int) -> void:
	# El francotirador se mantiene a distancia y dispara
	var nearest_zombie = _find_nearest_zombie()

	if nearest_zombie:
		var direction = nearest_zombie.global_position - global_position
		var distance = direction.length()

		# Mantenerse a distancia
		if distance < 150.0:
			velocity.x = -sign(direction.x) * move_speed
		elif distance > 250.0:
			velocity.x = sign(direction.x) * move_speed
		else:
			velocity.x = 0

		# Disparar
		if fire_timer <= 0.0:
			if last_message_time > message_cooldown and randf() > 0.7:
				_speak("Punto de mira adquirido")
				last_message_time = 0.0
			_shoot_at(nearest_zombie.global_position)
			fire_timer = 1.2
	else:
		velocity.x = 0

	move_and_slide()

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _tank_ai(delta: float, nearby_zombies: int) -> void:
	# El tanque carga contra los zombies
	var nearest_zombie = _find_nearest_zombie()

	if nearest_zombie:
		var direction = nearest_zombie.global_position - global_position
		velocity.x = sign(direction.x) * move_speed * 1.3

		# Disparar con más frecuencia
		if fire_timer <= 0.0:
			if nearby_zombies > 2 and randf() > 0.6:
				_speak("¡CARGAAA!")
			_shoot_at(nearest_zombie.global_position)
			fire_timer = 0.6
	else:
		velocity.x = 0

	move_and_slide()

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _find_nearest_zombie() -> Node2D:
	var nearest = null
	var min_distance = INF

	for zombie in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(zombie):
			var dist = global_position.distance_to(zombie.global_position)
			if dist < min_distance:
				min_distance = dist
				nearest = zombie

	return nearest

func _shoot_at_nearest_zombie() -> void:
	var target = _find_nearest_zombie()
	if target:
		_shoot_at(target.global_position)

func _shoot_at(target_pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, -10)
	bullet.direction = (target_pos - global_position).normalized()
	bullet.damage = 2 if ally_type == "sniper" else 1
	get_tree().current_scene.add_child(bullet)

func _should_abandon() -> bool:
	if abandoned:
		return false

	match personality:
		"coward":
			if fear_level > 70:
				return true
		"cautious":
			if fear_level > 85:
				return true
		"brave":
			if fear_level > 95:
				return true

	if hp < max_hp * 0.2:
		return true

	return false

func _abandon_mission() -> void:
	if abandoned:
		return

	abandoned = true
	match personality:
		"coward":
			_speak("¡NO! ¡DEMASIADO MIEDO! ¡ME VOY!")
		"cautious":
			_speak("Lo siento... no puedo más. Me voy.")
		"brave":
			_speak("¡Esto es una locura! ¡Rendirse es cobardía pero vivo!")

	# Desaparecer lentamente
	get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 2.0)
	get_tree().create_timer(2.1).timeout.connect(func(): queue_free())

func _speak(message: String) -> void:
	if speech_bubble:
		speech_bubble.text = message
		speech_bubble.show()
		get_tree().create_timer(2.0).timeout.connect(func(): 
			if speech_bubble:
				speech_bubble.hide()
		)
		print(ally_name + " (" + personality + "): " + message)

func set_player(target: Node2D) -> void:
	player = target

func take_damage(amount: int) -> void:
	hp -= amount
	fear_level += 10

	if last_message_time > message_cooldown:
		_speak("¡Ay! ¡Me dieron!")
		last_message_time = 0.0

	if hp <= 0:
		if randf() > 0.5:
			_speak("¡Noooo!")
		queue_free()

func interact_with_ally(other_ally: Ally) -> void:
	# Los aliados interactúan entre ellos
	if abandoned or other_ally.abandoned:
		return

	var distance = global_position.distance_to(other_ally.global_position)
	if distance < 80.0 and randf() > 0.95:
		_conversation_with_ally(other_ally)

func _conversation_with_ally(other_ally: Ally) -> void:
	var my_mood = "bien" if morale > 60 else "mal"
	var their_mood = "bien" if other_ally.morale > 60 else "mal"

	if personality == "brave" and other_ally.personality == "coward":
		_speak("¡Vamos! ¡Tú puedes!")
		other_ally._speak("Si... si tú lo dices...")
		other_ally.morale += 10
	elif personality == "coward" and other_ally.personality == "brave":
		_speak("Espero no morir...")
		other_ally._speak("No te preocupes, yo te cubro")
		morale += 15
	elif personality == "cautious":
		_speak("Hay que ser estratégicos")
		other_ally.morale += 5
	else:
		var random_message = messages[randi() % messages.size()]
		_speak(random_message)
