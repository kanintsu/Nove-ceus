class_name PhaseMapVisual
extends Control

signal location_selected(location_key: String)

var phase := 1
var location_keys: Array[String] = []
var current_location := ""
var selected_location := ""
var unlocked := true
var node_positions: Dictionary = {}

func setup(phase_value: int, keys: Array[String], current_key: String, selected_key: String, is_unlocked: bool) -> void:
	phase = clampi(phase_value,1,5)
	location_keys = keys.duplicate()
	current_location = current_key
	selected_location = selected_key
	unlocked = is_unlocked
	custom_minimum_size = Vector2(650,470)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rebuild_positions()
	queue_redraw()

func _rebuild_positions() -> void:
	node_positions.clear()
	var positions := [
		Vector2(82,390),Vector2(202,330),Vector2(115,245),Vector2(280,205),
		Vector2(440,270),Vector2(535,185),Vector2(430,105),Vector2(585,65)
	]
	for i in range(mini(location_keys.size(),positions.size())):
		node_positions[location_keys[i]] = positions[i]

func _draw() -> void:
	var palette := _palette()
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.02,0.04,0.055,0.68)
	panel.corner_radius_top_left = 24
	panel.corner_radius_top_right = 24
	panel.corner_radius_bottom_left = 24
	panel.corner_radius_bottom_right = 24
	panel.border_width_left = 1
	panel.border_width_right = 1
	panel.border_width_top = 1
	panel.border_width_bottom = 1
	panel.border_color = palette[0].darkened(0.25)
	draw_style_box(panel,Rect2(Vector2.ZERO,size))

	for i in range(location_keys.size()-1):
		var a: Vector2 = node_positions.get(location_keys[i],Vector2.ZERO)
		var b: Vector2 = node_positions.get(location_keys[i+1],Vector2.ZERO)
		draw_line(a,b,Color(palette[1],0.42),5.0)
		draw_line(a,b,Color(palette[2],0.24),1.5)

	for i in range(location_keys.size()):
		var key := location_keys[i]
		var p: Vector2 = node_positions.get(key,Vector2.ZERO)
		var is_current := key == current_location
		var is_selected := key == selected_location
		var radius := 23.0 if is_selected else 18.0
		if is_current:
			radius = 26.0
		var outer := palette[2] if unlocked else Color(0.35,0.37,0.38)
		var inner := palette[0] if unlocked else Color(0.16,0.18,0.19)
		draw_circle(p,radius+6.0,Color(0.01,0.02,0.025,0.76))
		draw_circle(p,radius,outer)
		draw_circle(p,radius-5.0,inner)
		if is_current:
			draw_arc(p,radius+10.0,0.0,TAU,40,palette[3],3.0)
		elif is_selected:
			draw_arc(p,radius+8.0,0.0,TAU,36,palette[3],2.0)

		var n := "%d" % (i+1)
		draw_string(ThemeDB.fallback_font,p+Vector2(-5,6),n,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color(0.96,0.94,0.84))

	if not unlocked:
		draw_rect(Rect2(0,0,size.x,size.y),Color(0.02,0.025,0.03,0.48),true)
		draw_string(ThemeDB.fallback_font,Vector2(210,240),"FASE AINDA INACESSÍVEL",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color(0.82,0.78,0.70))

func _gui_input(event: InputEvent) -> void:
	if not unlocked:
		return
	var pos := Vector2.ZERO
	var pressed := false
	if event is InputEventScreenTouch and event.pressed:
		pos = event.position
		pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pos = event.position
		pressed = true
	if not pressed:
		return
	var best_key := ""
	var best_distance := 99999.0
	for key in location_keys:
		var p: Vector2 = node_positions.get(key,Vector2.ZERO)
		var d := pos.distance_to(p)
		if d < best_distance:
			best_distance = d
			best_key = key
	if best_distance <= 48.0 and not best_key.is_empty():
		selected_location = best_key
		location_selected.emit(best_key)
		queue_redraw()

func _palette() -> Array[Color]:
	match phase:
		1:return [Color("#6e9b87"),Color("#b4ac73"),Color("#d8cf92"),Color("#ecdfa8")]
		2:return [Color("#a75e48"),Color("#c08a51"),Color("#e0b66a"),Color("#f4dda1")]
		3:return [Color("#4d8eaa"),Color("#739fca"),Color("#85d6eb"),Color("#d2f3ff")]
		4:return [Color("#763f58"),Color("#a65360"),Color("#c97176"),Color("#e5a174")]
		_:return [Color("#7569a2"),Color("#b39a65"),Color("#e3ca78"),Color("#a9e7f2")]
