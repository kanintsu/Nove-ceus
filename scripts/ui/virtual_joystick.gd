class_name TouchJoystick
extends Control

signal vector_changed(value: Vector2)

var value := Vector2.ZERO
var active_touch := -1
var mouse_active := false
var radius := 66.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and active_touch == -1:
			active_touch = event.index
			_update_value(event.position)
		elif not event.pressed and event.index == active_touch:
			active_touch = -1
			_set_value(Vector2.ZERO)
	elif event is InputEventScreenDrag and event.index == active_touch:
		_update_value(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_active = event.pressed
		if mouse_active:
			_update_value(event.position)
		else:
			_set_value(Vector2.ZERO)
	elif event is InputEventMouseMotion and mouse_active:
		_update_value(event.position)

func _update_value(local_position: Vector2) -> void:
	var center := size * 0.5
	var delta := local_position - center
	if delta.length() > radius:
		delta = delta.normalized() * radius
	_set_value(delta / radius)

func _set_value(new_value: Vector2) -> void:
	value = new_value
	vector_changed.emit(value)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, radius + 14.0, Color(0.03, 0.05, 0.05, 0.46))
	draw_circle(center, radius, Color(0.18, 0.25, 0.22, 0.38))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.62, 0.74, 0.65, 0.65), 2.0)
	var knob := center + value * radius
	draw_circle(knob, 28.0, Color(0.72, 0.80, 0.72, 0.78))
