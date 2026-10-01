extends CharacterBody2D

@export var move_speed: float = 220.0
@export var fire_rate: float = 0.22
@export var max_health: int = 100

var health: int = max_health
var fire_timer: float = 0.0
var joystick: Control
var aim_button: Button
var shoot_button: Button
var aim_active: bool = false
var shoot_active: bool = false
var last_aim_direction: Vector2 = Vector2(0, -1)
var move_input: float = 0.0
var touch_move: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var gun_point: Marker2D = $GunPoint

var bullet_scene = preload("res://scenes/Bullet.tscn")

func _ready() -> void:
	if aim_button:
		aim_button.button_down.connect(func(): aim_active = true)
		aim_button.button_up.connect(func(): aim_active = false)
	if shoot_button:
		shoot_button.button_down.connect(func(): shoot_active = true)
		shoot_button.button_up.connect(func(): shoot_active = false)

func _physics_process(delta: float) -> void:
	fire_timer = max(0.0, fire_timer - delta)

	var move_axis = Input.get_axis("move_left", "move_right")
	if joystick != null:
		move_axis = joystick.get_value().x
		if abs(joystick.get_value().y) > 0.4:
			if joystick.get_value().y < 0:
				last_aim_direction = Vector2(0, -1)
			else:
				last_aim_direction = Vector2(0, 1)

	if aim_active:
		last_aim_direction = Vector2(0, -1)
		if Input.is_key_pressed(KEY_UP):
			last_aim_direction = Vector2(0, -1)
		if Input.is_key_pressed(KEY_DOWN):
			last_aim_direction = Vector2(0, 1)

	if move_axis != 0:
		move_input = move_axis
	else:
		move_input = Input.get_axis("move_left", "move_right")
	
	velocity.x = move_input * move_speed
	velocity.y = 0.0
	move_and_slide()

	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	if (shoot_active or Input.is_physical_key_pressed(KEY_SPACE)) and fire_timer <= 0.0:
		shoot()
		fire_timer = fire_rate

func register_joystick(value: Control) -> void:
	joystick = value

func set_aim_button(button: Button) -> void:
	aim_button = button

func set_shoot_button(button: Button) -> void:
	shoot_button = button

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = gun_point.global_position
	bullet.direction = last_aim_direction
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		get_tree().reload_current_scene()
