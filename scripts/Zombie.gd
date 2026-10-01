extends CharacterBody2D

@export var speed: float = 75.0
@export var max_hp: int = 3
@export var attack_damage: int = 10

var hp: int = max_hp
var player: Node2D
var attack_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("zombie")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	attack_cooldown = max(0.0, attack_cooldown - delta)

	var direction = player.global_position - global_position
	var move_x = sign(direction.x)
	velocity.x = move_x * speed
	velocity.y = 0.0
	move_and_slide()

	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	if global_position.distance_to(player.global_position) < 24.0 and attack_cooldown <= 0.0:
		player.take_damage(attack_damage)
		attack_cooldown = 1.0

func set_player(target: Node2D) -> void:
	player = target

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
