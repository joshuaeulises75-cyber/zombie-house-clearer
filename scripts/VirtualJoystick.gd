extends Control

var value: Vector2 = Vector2.ZERO
var active: bool = false
var radius: float = 50.0
var center: Vector2 = Vector2.ZERO

@onready var base: ColorRect = $Base
@onready var knob: ColorRect = $Knob

func _ready() -> void:
	center = base.position + base.size / 2.0
	knob.position = center - knob.size / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_inside_base(event.position):
				active = true
				_update_from_position(event.position)
		else:
			active = false
			value = Vector2.ZERO
			_reset_knob()
	elif event is InputEventScreenDrag and active:
		_update_from_position(event.position)

func _is_inside_base(screen_pos: Vector2) -> bool:
	var local = screen_pos - global_position
	return local.distance_to(base.position + base.size / 2.0) <= radius + 10.0

func _update_from_position(screen_pos: Vector2) -> void:
	var local = screen_pos - global_position
	var delta = local - (base.position + base.size / 2.0)
	var dist = delta.length()
	if dist > radius:
		delta = delta.normalized() * radius
	var knob_pos = base.position + base.size / 2.0 + delta - knob.size / 2.0
	knob.position = knob_pos
	value = Vector2(clamp(delta.x / radius, -1.0, 1.0), clamp(delta.y / radius, -1.0, 1.0))

func _reset_knob() -> void:
	knob.position = base.position + base.size / 2.0 - knob.size / 2.0

func get_value() -> Vector2:
	return value
