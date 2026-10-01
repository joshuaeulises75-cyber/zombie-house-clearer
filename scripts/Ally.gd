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
var stress_level: int = 0  # Estrés acumulado
var abandoned: bool = false
var last_action_time: float = 0.0
var decision_cooldown: float = 0.0
var player: Node2D
var target_zombie: Node2D
var last_message_time: float = 0.0
var message_cooldown: float = 2.0
var conversation_partner: Ally = null
var in_cover: bool = false
var cover_position: Vector2
var is_healing: bool = false
var is_reloading: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speech_bubble: Label = $SpeechBubble
@onready var emotion_indicator: Label = $EmotionIndicator

var bullet_scene = preload("res://scenes/Bullet.tscn")
var fire_timer: float = 0.0

# Diálogos por personalidad - MUCHO MAS CONTENIDO
var brave_messages: Array = [
	"¡Vamos a limpiar esta casa de monstruos!",
	"¡No hay zombies que nos detengan a nosotros!",
	"¡A POR ELLOS! ¡CARGAAAAAA!",
	"Esto será fácil, he visto cosas peores",
	"¡Hoy es un buen día para luchar!",
	"¡Conmigo al lado no te pasará nada!",
	"¡Adelante! ¡La victoria nos espera!",
	"¿Miedo? Eso no existe en mi diccionario",
	"¡Más zombies más diversión!",
	"¡ATACAAA! ¡NO LES DEMOS NI UN SEGUNDO!",
	"Este trabajo es pan comido",
	"¡Vamos a escribir historia hoy!",
	"La bravura corre por mis venas",
	"¡Que vengan de a cien! ¡No me importa!",
	"¡Juntos somos invencibles!"
]

var cautious_messages: Array = [
	"Hay que tener mucho cuidado aquí...",
	"Cubramos esto bien... muy bien",
	"Vigilemos los flancos, siempre",
	"Esto es peligroso... hay que ser estratégicos",
	"Preparados para lo peor, esperamos lo mejor",
	"Cada paso debe ser calculado",
	"No nos precipitemos... aún hay tiempo",
	"Creo que deberíamos reagruparnos",
	"La paciencia es la clave aquí",
	"Hay demasiados... debemos ser inteligentes",
	"Mantengamos las distancias de seguridad",
	"Una estrategia es mejor que la prisa",
	"Cuidado... sentí movimiento",
	"Mejor retroceder un poco",
	"La prudencia nos mantendrá vivos"
]

var coward_messages: Array = [
	"¿Seguro que es seguro? Porque no lo veo...",
	"Hay... hay demasiados para nosotros",
	"No creo que pueda con esto... en serio",
	"¡AY QUE MIEDO! ¡DEMASIADO MIEDO!",
	"¿Por qué no llamamos a alguien más?",
	"Prefiero estar en otro lado... en cualquier otro lado",
	"¿Eso fue un ruido? ¿Lo oíste?",
	"¡N-no me hagas esto!",
	"Mi instinto me dice que huya... rápido",
	"No sé si sea tan buena idea esto...",
	"Cada zombie parece MÁS grande de cerca",
	"¿Cuántos hay? ¿CUÁNTOS HAY?!",
	"Esto no es lo mío... para nada",
	"¡Quiero irme! ¡QUIERO IRME!",
	"¿Por qué nadie me escucha cuando digo que no vuelva?"
]

# Diálogos de interacción entre aliados
var interaction_brave: Array = [
	"¡Sigue adelante! ¡Tú puedes!",
	"Vamos juntos, no te dejaré",
	"¡Levanta esa moral! ¡Nos falta poco!",
	"¡El miedo es para los débiles!",
	"¡Confía en mí! ¡Todos saldremos de esta!",
]

var interaction_cautious: Array = [
	"Debemos ser más estratégicos",
	"Protejámonos mutuamente",
	"Juntos somos más fuertes",
	"No estás solo, estoy contigo",
]

var interaction_coward: Array = [
	"Está bien tener miedo... creo que yo también",
	"Quizás deberíamos esperar a que se calmen",
	"¿Crees que realmente podemos?",
	"No estamos solos en esto, al menos",
]

# Diálogos de crítica/conflicto
var conflict_messages: Array = [
	"¿Qué estás haciendo?",
	"¡No nos dejes solos!",
	"¡Trabajemos juntos!",
	"¡No seas tonto!",
	"¡Eso fue peligroso!",
]

# Diálogos cuando están heridos
var hurt_messages: Array = [
	"¡Ay! ¡Me duele!",
	"¡Eso dolió!",
	"¡Cuidado! ¡Atacan!",
	"¡No me hagas eso de nuevo!",
	"¡Necesito ayuda!",
]

# Diálogos de victoria
var victory_messages: Array = [
	"¡Lo logramos! ¡GANAMOS!",
	"¡Casa limpia, misión cumplida!",
	"¡Eso fue épico!",
	"¡Excelente trabajo, equipo!",
	"¡Hemos salvado el día!",
]

func _ready() -> void:
	add_to_group("allies")
	_setup_personality_values()
	_initialize_animation()

func _setup_personality_values() -> void:
	match personality:
		"brave":
			move_speed = 180.0
			max_hp = 80
			hp = max_hp
		"cautious":
			move_speed = 130.0
			max_hp = 50
			hp = max_hp
		"coward":
			move_speed = 200.0  # Corre rápido cuando tiene miedo
			max_hp = 30
			hp = max_hp

func _initialize_animation() -> void:
	if sprite:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if abandoned:
		_handle_abandonment_animation(delta)
		return

	fire_timer = max(0.0, fire_timer - delta)
	last_message_time += delta
	decision_cooldown = max(0.0, decision_cooldown - delta)

	if player == null:
		return

	# Actualizar niveles psicológicos
	_update_psychological_state(delta)
	
	# Chequear si debe abandonar
	if _should_abandon():
		_abandon_mission()
		return

	# Comportamiento según tipo de aliado
	match ally_type:
		"medic":
			_medic_advanced_ai(delta)
		"sniper":
			_sniper_advanced_ai(delta)
		"tank":
			_tank_advanced_ai(delta)

func _update_psychological_state(delta: float) -> void:
	# Actualizar miedo basado en zombies cercanos
	var nearby_zombies = _count_nearby_zombies(200.0)
	var zombie_distance = _get_nearest_zombie_distance()

	# Aumentar miedo según proximidad
	if zombie_distance < 100.0:
		fear_level = min(100, fear_level + nearby_zombies * 8)
		stress_level = min(100, stress_level + 5)
	elif zombie_distance < 200.0:
		fear_level = min(100, fear_level + nearby_zombies * 3)
	else:
		fear_level = max(0, fear_level - 2)  # Disminuye cuando no hay peligro

	# La moral y estrés afectan
	stress_level = max(0, stress_level - 1)  # Disminuye lentamente
	morale = max(0, min(100, morale - (stress_level / 10)))
	
	_update_emotion_indicator()

func _update_emotion_indicator() -> void:
	if emotion_indicator:
		var emotion = ""
		match personality:
			"brave":
				if fear_level > 70:
					emotion = "😠 FURIOSO"
					sprite.self_modulate = Color.RED
				elif fear_level > 40:
					emotion = "💪 LISTO"
					sprite.self_modulate = Color.YELLOW
				else:
					emotion = "😊 CONFIADO"
					sprite.self_modulate = Color.GREEN
		"cautious":
			if fear_level > 75:
				emotion = "😰 ANSIOSO"
				sprite.self_modulate = Color.ORANGE
			elif fear_level > 40:
				emotion = "🤔 ATENTO"
				sprite.self_modulate = Color.YELLOW
			else:
				emotion = "😌 TRANQUILO"
				sprite.self_modulate = Color.CYAN
		"coward":
			if fear_level > 80:
				emotion = "😱 ATERRADO"
				sprite.self_modulate = Color.RED
			elif fear_level > 50:
				emotion = "😨 ASUSTADO"
				sprite.self_modulate = Color.PURPLE
			else:
				emotion = "😟 INQUIETO"
				sprite.self_modulate = Color.LIGHT_BLUE
		emotion_indicator.text = emotion

func _medic_advanced_ai(delta: float) -> void:
	var direction = player.global_position - global_position
	var distance = direction.length()
	var nearest_zombie = _find_nearest_zombie()
	var nearby_zombies = _count_nearby_zombies(150.0)

	# Decisión: quedarse cerca vs ir a posición de seguridad
	if nearby_zombies > 3 and distance < 80.0:
		# Posición defensiva
		if decision_cooldown <= 0:
			_speak(_get_personality_message("defensive"))
			decision_cooldown = 3.0
		velocity.x = 0
		in_cover = true
	else:
		in_cover = false

	# Mantener distancia óptima
	if distance > 120.0 and not in_cover:
		velocity.x = sign(direction.x) * move_speed * 0.7
	elif distance < 40.0 and not in_cover:
		velocity.x = -sign(direction.x) * move_speed * 0.5
	else:
		velocity.x = 0

	# Curar al jugador si está herido
	if player.health < player.max_health - 20 and distance < 60.0:
		if not is_healing:
			is_healing = true
			_speak(_get_healing_message())
		player.health = min(player.health + 3, player.max_health)
		if sprite:
			sprite.play("heal")
	elif is_healing:
		is_healing = false
		if sprite:
			sprite.play("idle")

	# Disparar si hay amenaza
	if nearest_zombie and nearby_zombies <= 2 and fire_timer <= 0.0:
		if randf() > 0.4:
			_shoot_at(nearest_zombie.global_position)
			fire_timer = 1.0

	move_and_slide()
	_animate_movement()

func _sniper_advanced_ai(delta: float) -> void:
	var nearest_zombie = _find_nearest_zombie()
	var nearby_zombies = _count_nearby_zombies(250.0)

	if nearest_zombie:
		var direction = nearest_zombie.global_position - global_position
		var distance = direction.length()

		# IA de francotirador: posición defensiva
		if distance < 100.0 and nearby_zombies > 1:
			# Retroceder a posición segura
			if decision_cooldown <= 0:
				_speak("Necesito una mejor posición")
				decision_cooldown = 4.0
			velocity.x = -sign(direction.x) * move_speed * 0.9
			in_cover = true
		elif distance > 200.0:
			# Acercarse lentamente
			velocity.x = sign(direction.x) * move_speed * 0.4
			in_cover = false
		else:
			# Posición óptima: mantener distancia
			velocity.x = 0
			in_cover = true
		
		# Disparar con precisión
		if fire_timer <= 0.0 and distance > 80.0:
			if randf() > 0.3:
				_speak(_get_sniper_message())
			_shoot_at(nearest_zombie.global_position)
			fire_timer = 1.5
	else:
		velocity.x = 0

	move_and_slide()
	_animate_movement()

func _tank_advanced_ai(delta: float) -> void:
	var nearest_zombie = _find_nearest_zombie()
	var nearby_zombies = _count_nearby_zombies(200.0)
	var player_distance = player.global_position.distance_to(global_position)

	if nearest_zombie:
		var direction = nearest_zombie.global_position - global_position
		var distance = direction.length()

		# Proteger al jugador primero
		if player_distance > 150.0:
			var player_direction = player.global_position - global_position
			velocity.x = sign(player_direction.x) * move_speed
		elif nearby_zombies > 3:
			# Atacar frontal
			velocity.x = sign(direction.x) * move_speed * 1.2
			if decision_cooldown <= 0:
				_speak(_get_tank_message())
				decision_cooldown = 2.0
		else:
			# Ataque calculado
			velocity.x = sign(direction.x) * move_speed * 0.8

		# Disparar agresivamente
		if fire_timer <= 0.0:
			_shoot_at(nearest_zombie.global_position)
			fire_timer = 0.5
	else:
		velocity.x = 0

	move_and_slide()
	_animate_movement()

func _animate_movement() -> void:
	if not sprite:
		return

	if velocity.x != 0:
		if is_healing:
			sprite.play("heal")
		else:
			sprite.play("run")
		sprite.flip_h = velocity.x < 0
	else:
		if is_healing:
			sprite.play("heal")
		else:
			sprite.play("idle")

func _count_nearby_zombies(radius: float) -> int:
	var count = 0
	for zombie in get_tree().get_nodes_in_group("zombie"):
		if is_instance_valid(zombie):
			if global_position.distance_to(zombie.global_position) < radius:
				count += 1
	return count

func _get_nearest_zombie_distance() -> float:
	var nearest = _find_nearest_zombie()
	if nearest:
		return global_position.distance_to(nearest.global_position)
	return INF

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

func _shoot_at(target_pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, -10)
	bullet.direction = (target_pos - global_position).normalized()
	bullet.damage = 2 if ally_type == "sniper" else (3 if ally_type == "tank" else 1)
	get_tree().current_scene.add_child(bullet)

func _should_abandon() -> bool:
	if abandoned:
		return false

	match personality:
		"coward":
			if fear_level > 75 or (hp < max_hp * 0.3 and fear_level > 50):
				return true
		"cautious":
			if fear_level > 85 or hp < max_hp * 0.15:
				return true
		"brave":
			if fear_level > 95 or hp < 5:
				return true

	return false

func _abandon_mission() -> void:
	if abandoned:
		return

	abandoned = true
	match personality:
		"coward":
			_speak("¡NO! ¡DEMASIADO MIEDO! ¡ESTO NO ES PARA MI! ¡ME VOY!") 
		"cautious":
			_speak("Lo siento... he hecho todo lo que pude. Pero... no puedo más.")
		"brave":
			_speak("¡Nunca pensé que llegaría el día en que me rendira! ¡PERO HOY ES ESE DÍA!")

	# Desaparecer lentamente
	if sprite:
		sprite.play("run")
	velocity.x = -sign(velocity.x) * move_speed * 1.5  # Huir

	get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 3.0)
	get_tree().create_timer(3.1).timeout.connect(func(): queue_free())

func _speak(message: String) -> void:
	if speech_bubble:
		speech_bubble.text = message
		speech_bubble.show()
		get_tree().create_timer(3.0).timeout.connect(func(): 
			if is_instance_valid(self) and speech_bubble:
				speech_bubble.hide()
		)
		print("[" + ally_name + " (" + personality + ")]: " + message)

func _get_personality_message(context: String) -> String:
	var messages = []
	
	match personality:
		"brave":
			messages = brave_messages
		"cautious":
			messages = cautious_messages
		"coward":
			messages = coward_messages

	if messages.is_empty():
		return "Vamos"
	return messages[randi() % messages.size()]

func _get_healing_message() -> String:
	match personality:
		"brave":
			return "¡Aguanta! ¡Te haré un turbo médico de campeón!"
		"cautious":
			return "Quédate quieto... te estoy curando con cuidado"
		"coward":
			return "E-espero que esto funcione... cúrate rápido..."
	return "Te estoy curando"

func _get_sniper_message() -> String:
	match personality:
		"brave":
			return "¡PUNTO DE MIRA ADQUIRIDO! ¡FUEGO!"
		"cautious":
			return "Objetivo confirmado... línea clara... DISPARO"
		"coward":
			return "E-espero que esto funcione desde aquí..."
	return "Disparando"

func _get_tank_message() -> String:
	match personality:
		"brave":
			return "¡AQUÍ VOYYYY! ¡NADA ME DETIENE!"
		"cautious":
			return "Cubriendo al equipo... voy directo"
		"coward":
			return "¡Esto es una mala idea pero VAMOOOOS!"
	return "CARGAAA"

func _handle_abandonment_animation(delta: float) -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func set_player(target: Node2D) -> void:
	player = target

func take_damage(amount: int) -> void:
	hp -= amount
	fear_level += 15
	stress_level += 20

	if last_message_time > message_cooldown:
		var hurt_msg = hurt_messages[randi() % hurt_messages.size()]
		_speak(hurt_msg)
		last_message_time = 0.0

	if hp <= 0:
		if randf() > 0.5:
			_speak(_get_personality_message("death"))
		queue_free()

func interact_with_ally(other_ally: Ally) -> void:
	if abandoned or other_ally.abandoned:
		return

	var distance = global_position.distance_to(other_ally.global_position)
	if distance < 100.0 and randf() > 0.92:
		_conversation_with_ally(other_ally)

func _conversation_with_ally(other_ally: Ally) -> void:
	var their_fear = other_ally.fear_level

	if personality == "brave" and other_ally.personality == "coward":
		_speak("¡Vamos! ¡Tú puedes! ¡Conmigo no hay fracaso!")
		other_ally._speak("Si... si tú lo dices... confío en ti")
		other_ally.morale = min(100, other_ally.morale + 15)
		other_ally.fear_level = max(0, other_ally.fear_level - 10)
	elif personality == "brave" and other_ally.personality == "cautious":
		_speak("¡Juntos nos comemos a todos estos zombies!")
		other_ally._speak("Tu confianza me da seguridad")
		morale = min(100, morale + 10)
	elif personality == "coward" and other_ally.personality == "brave":
		_speak("Espero no morir aquí... ¿crees que lo logremos?")
		other_ally._speak("¡Claro que sí! ¡Yo te protego!")
		morale = min(100, morale + 20)
		fear_level = max(0, fear_level - 15)
	elif personality == "cautious" and other_ally.personality == "cautious":
		_speak("Debemos coordinar mejor")
		other_ally._speak("Totalmente de acuerdo, estrategia antes que acción")
		morale = min(100, morale + 8)
	elif personality == "coward" and other_ally.personality == "coward":
		_speak("¿Tú también estás asustado?")
		other_ally._speak("M-mucho... pero al menos no estamos solos")
		morale = min(100, morale + 5)
	else:
		var interaction_msg = interaction_cautious[randi() % interaction_cautious.size()]
		_speak(interaction_msg)

func speak_victory() -> void:
	var msg = victory_messages[randi() % victory_messages.size()]
	_speak(msg)
