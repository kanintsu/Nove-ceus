class_name MobileControls
extends Control

signal move_changed(value: Vector2)
signal attack_pressed
signal interact_pressed
signal sprint_changed(active: bool)
signal chronicle_pressed

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_controls()

func _build_controls() -> void:
	var joystick := VirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.offset_left = 24.0
	joystick.offset_top = -200.0
	joystick.offset_right = 194.0
	joystick.offset_bottom = -30.0
	joystick.vector_changed.connect(func(value: Vector2) -> void: move_changed.emit(value))
	add_child(joystick)

	var attack := _button("ATACAR", Control.PRESET_BOTTOM_RIGHT, Vector2(-142.0, -142.0), Vector2(-24.0, -30.0))
	attack.pressed.connect(func() -> void: attack_pressed.emit())
	add_child(attack)

	var interact := _button("INTERAGIR", Control.PRESET_BOTTOM_RIGHT, Vector2(-275.0, -114.0), Vector2(-157.0, -30.0))
	interact.pressed.connect(func() -> void: interact_pressed.emit())
	add_child(interact)

	var sprint := _button("CORRER", Control.PRESET_BOTTOM_RIGHT, Vector2(-142.0, -238.0), Vector2(-24.0, -154.0))
	sprint.button_down.connect(func() -> void: sprint_changed.emit(true))
	sprint.button_up.connect(func() -> void: sprint_changed.emit(false))
	add_child(sprint)

	var chronicle := _button("CRÔNICA", Control.PRESET_TOP_RIGHT, Vector2(-156.0, 22.0), Vector2(-24.0, 70.0))
	chronicle.pressed.connect(func() -> void: chronicle_pressed.emit())
	add_child(chronicle)

func _button(text_value: String, preset: int, top_left: Vector2, bottom_right: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.set_anchors_preset(preset)
	button.offset_left = top_left.x
	button.offset_top = top_left.y
	button.offset_right = bottom_right.x
	button.offset_bottom = bottom_right.y
	button.focus_mode = Control.FOCUS_NONE
	button.modulate = Color(1.0, 1.0, 1.0, 0.84)
	return button
