extends Area2D

var rescued: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.self_modulate = Color.LIGHT_BLUE

func _on_body_entered(body: Node2D) -> void:
	if rescued:
		return

	if body.is_in_group("player"):
		rescued = true
		if sprite:
			sprite.play("rescued") if sprite.has_method("play") else null
		get_tree().current_scene.rescue_civilian()
		get_tree().create_timer(0.2).timeout.connect(queue_free)
