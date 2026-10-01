extends Area2D

var speed: float = 600.0
var direction: Vector2 = Vector2(0, -1)
var damage: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	visible = true

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("zombie"):
		body.take_damage(damage)
		queue_free()
