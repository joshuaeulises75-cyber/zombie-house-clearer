extends CharacterBody2D
class_name Zombie

@export var speed: float = 75.0
@export var max_hp: int = 3
@export var attack_damage: int = 10
@export var zombie_type: String = "common"  # common, runner, tank, spitter

var hp: int = max_hp
var player: Node2D
var attack_cooldown: float = 0.0
var aggression_level: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("zombie")
	_setup_zombie_type()

func _setup_zombie_type() -> void:
	match zombie_type:
		"common":
			speed = 75.0
			max_hp = 3
			attack_damage = 10
			sprite.self_modulate = Color.GREEN
		"runner":
			speed = 150.0
			max_hp = 2
			attack_damage = 15
			sprite.self_modulate = Color.YELLOW
		"tank":
			speed = 50.0
			max_hp = 8
			attack_damage = 20
			sprite.scale = Vector2(1.3, 1.3)
			sprite.self_modulate = Color.RED
		"spitter":
			speed = 60.0
			max_hp = 4
			attack_damage = 8
			sprite.self_modulate = Color.PURPLE
	hp = max_hp

func _physics_process(delta: float) -> void:
	if player == null:
		return
	attack_cooldown = max(0.0, attack_cooldown - delta)

	var direction = player.global_position - global_position
	var distance = direction.length()
	
	# Comportamiento especial por tipo
	match zombie_type:
		"common":
			_common_behavior(direction, distance)
		"runner":
			_runner_behavior(direction, distance)
		"tank":
			_tank_behavior(direction, distance)
		"spitter":
			_spitter_behavior(direction, distance)

	move_and_slide()
	_animate_zombie()

func _common_behavior(direction: Vector2, distance: float) -> void:
	var move_x = sign(direction.x)
	velocity.x = move_x * speed
	velocity.y = 0.0

	if distance < 24.0 and attack_cooldown <= 0.0:
		player.take_damage(attack_damage)
		attack_cooldown = 1.0

func _runner_behavior(direction: Vector2, distance: float) -> void:
	# El runner es rápido pero melee
	var move_x = sign(direction.x)
	velocity.x = move_x * speed
	velocity.y = 0.0

	if distance < 20.0 and attack_cooldown <= 0.0:
		player.take_damage(attack_damage)
		attack_cooldown = 0.8  # Ataca más rápido

func _tank_behavior(direction: Vector2, distance: float) -> void:
	# El tanque es lento pero fuerte
	var move_x = sign(direction.x)
	velocity.x = move_x * speed * 0.7
	velocity.y = 0.0

	if distance < 30.0 and attack_cooldown <= 0.0:
		player.take_damage(attack_damage)
		attack_cooldown = 1.5  # Ataca más lento

func _spitter_behavior(direction: Vector2, distance: float) -> void:
	# El spitter mantiene distancia y lanza
	var move_x = sign(direction.x)
	
	if distance < 80.0:
		# Retroceder
		velocity.x = -move_x * speed
	elif distance > 150.0:
		# Acercarse un poco
		velocity.x = move_x * speed * 0.5
	else:
		# Mantener posición
		velocity.x = 0

	velocity.y = 0.0

	# Lanzar proyectil
	if distance > 60.0 and distance < 150.0 and attack_cooldown <= 0.0:
		_spit_at_player()
		attack_cooldown = 2.0

func _animate_zombie() -> void:
	if sprite:
		if velocity.x != 0:
			sprite.play("walk")
			sprite.flip_h = velocity.x < 0
		else:
			sprite.play("idle")

func _spit_at_player() -> void:
	var bullet = preload("res://scenes/ZombieProjectile.tscn").instantiate()
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func set_player(target: Node2D) -> void:
	player = target

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		# Efecto de muerte
		if sprite:
			sprite.play("death")
		get_tree().create_timer(0.3).timeout.connect(queue_free)
