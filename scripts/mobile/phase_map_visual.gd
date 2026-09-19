class_name PhaseMapVisual
extends Control

signal location_selected(location_key: String)

const GameContentScript = preload("res://scripts/mobile/game_content.gd")

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
	custom_minimum_size = Vector2(650,500)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rebuild_positions()
	queue_redraw()

func _rebuild_positions() -> void:
	node_positions.clear()
	var positions := [
		Vector2(82,410),Vector2(190,346),Vector2(116,250),Vector2(274,206),
		Vector2(438,278),Vector2(540,192),Vector2(430,110),Vector2(584,70)
	]
	for i in range(mini(location_keys.size(),positions.size())):
		node_positions[location_keys[i]] = positions[i]

func _draw() -> void:
	var palette := _palette()
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#10272d")
	panel.bg_color.a = 0.92
	panel.corner_radius_top_left = 26
	panel.corner_radius_top_right = 26
	panel.corner_radius_bottom_left = 26
	panel.corner_radius_bottom_right = 26
	panel.border_width_left = 1
	panel.border_width_right = 1
	panel.border_width_top = 1
	panel.border_width_bottom = 1
	panel.border_color = Color(palette[2],0.48)
	draw_style_box(panel,Rect2(Vector2.ZERO,size))

	# terrain drawn at runtime
	_draw_terrain(palette)

	# route ribbon
	for i in range(location_keys.size()-1):
		var a: Vector2 = node_positions.get(location_keys[i],Vector2.ZERO)
		var b: Vector2 = node_positions.get(location_keys[i+1],Vector2.ZERO)
		draw_line(a,b,Color("#07161b"),9.0)
		draw_line(a,b,Color(palette[1],0.68),5.0)
		draw_line(a,b,Color(palette[2],0.42),1.5)

	for i in range(location_keys.size()):
		var key := location_keys[i]
		var p: Vector2 = node_positions.get(key,Vector2.ZERO)
		var is_current := key == current_location
		var is_selected := key == selected_location
		var radius := 21.0 if is_selected else 17.0
		if is_current:
			radius = 25.0

		draw_circle(p,radius+8.0,Color("#07161b"))
		draw_circle(p,radius+5.0,Color(palette[2],0.42 if is_selected or is_current else 0.18))
		draw_circle(p,radius,Color("#16383d"))
		draw_arc(p,radius,0.0,TAU,36,palette[2],2.0)
		_draw_location_icon(p,key,palette[3])

		if is_current:
			draw_arc(p,radius+11.0,0.0,TAU,44,palette[3],3.0)
			draw_string(ThemeDB.fallback_font,p+Vector2(-35,-33),"VOCÊ",HORIZONTAL_ALIGNMENT_CENTER,70,10,Color("#f0d783"))
		elif is_selected:
			draw_arc(p,radius+9.0,0.0,TAU,40,Color("#f2d88a"),2.0)

		if is_selected or is_current:
			var name := String(GameContentScript.LOCATIONS.get(key,{}).get("name",key))
			if name.length() > 25:
				name = name.left(23)+"…"
			var label_pos := p+Vector2(-86,44)
			draw_rect(Rect2(label_pos,Vector2(172,25)),Color("#07161b",0.80),true)
			draw_string(ThemeDB.fallback_font,label_pos+Vector2(6,18),name,HORIZONTAL_ALIGNMENT_CENTER,160,11,Color("#e7e2cc"))

func _draw_terrain(palette:Array[Color]) -> void:
	# distant peaks
	var c1 := Color(palette[0],0.16)
	var c2 := Color(palette[1],0.22)
	var mountains := [
		[Vector2(0,230),Vector2(70,125),Vector2(130,215)],
		[Vector2(95,235),Vector2(175,105),Vector2(245,230)],
		[Vector2(330,210),Vector2(410,70),Vector2(485,215)],
		[Vector2(465,235),Vector2(555,120),Vector2(650,240)]
	]
	for tri in mountains:
		draw_colored_polygon(PackedVector2Array(tri),c1)
	# river/cloud path
	var river := Color(palette[3],0.10)
	draw_polyline(PackedVector2Array([
		Vector2(0,450),Vector2(110,390),Vector2(240,380),Vector2(335,325),
		Vector2(460,335),Vector2(650,260)
	]),river,22.0)
	draw_polyline(PackedVector2Array([
		Vector2(0,450),Vector2(110,390),Vector2(240,380),Vector2(335,325),
		Vector2(460,335),Vector2(650,260)
	]),Color(palette[3],0.26),2.0)
	# cloud terraces
	for pos in [Vector2(100,170),Vector2(315,125),Vector2(515,350)]:
		draw_circle(pos,42.0,Color(palette[2],0.045))
		draw_circle(pos+Vector2(38,5),30.0,Color(palette[2],0.045))
		draw_circle(pos+Vector2(-34,8),27.0,Color(palette[2],0.045))
	# ornate compass
	var cc := Vector2(64,64)
	draw_arc(cc,31,0.0,TAU,40,Color(palette[2],0.38),1.5)
	draw_line(cc+Vector2(0,-25),cc+Vector2(0,25),Color(palette[2],0.30),1.0)
	draw_line(cc+Vector2(-25,0),cc+Vector2(25,0),Color(palette[2],0.30),1.0)
	draw_colored_polygon(PackedVector2Array([cc+Vector2(0,-18),cc+Vector2(5,0),cc+Vector2(0,5),cc+Vector2(-5,0)]),Color(palette[3],0.65))

func _draw_location_icon(p:Vector2,key:String,color:Color) -> void:
	var data: Dictionary = GameContentScript.LOCATIONS.get(key,{})
	var tags: Array = data.get("tags",[])
	var tag := String(tags[0]) if not tags.is_empty() else ""
	match tag:
		"city","village","sect","celestial":
			draw_line(p+Vector2(-9,5),p+Vector2(0,-7),color,2.0)
			draw_line(p+Vector2(0,-7),p+Vector2(9,5),color,2.0)
			draw_rect(Rect2(p+Vector2(-7,5),Vector2(14,7)),color,false,1.5)
		"forest","herbs":
			draw_line(p+Vector2(0,-10),p+Vector2(0,11),color,2.0)
			draw_line(p,p+Vector2(-8,-5),color,2.0)
			draw_line(p+Vector2(0,3),p+Vector2(8,-3),color,2.0)
		"ruin","grave","ancient":
			draw_rect(Rect2(p+Vector2(-8,-8),Vector2(16,17)),color,false,1.8)
			draw_line(p+Vector2(-11,-8),p+Vector2(11,-8),color,2.0)
		"beasts","battlefield":
			draw_line(p+Vector2(-9,-8),p+Vector2(9,8),color,2.0)
			draw_line(p+Vector2(9,-8),p+Vector2(-9,8),color,2.0)
		_:
			draw_circle(p,6.0,color)

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
