extends Area2D

var rescued: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if rescued:
		return
	if body.is_in_group("player"):
		rescued = true
		get_tree().current_scene.rescue_civilian()
		queue_free()
