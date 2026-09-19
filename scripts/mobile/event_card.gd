class_name EventCard
extends VBoxContainer

signal follow_requested(uid:String)

var uid := ""
var event_type := ""
var accent := Color("#d7bd72")
var title_text := ""
var body_text := ""
var location_text := ""
var meta_text := ""
var warning_text := ""

func setup(data:Dictionary,location_name:String,remaining:int,warning:String,accent_value:Color) -> void:
	uid = String(data.get("uid",""))
	event_type = String(data.get("type","event"))
	accent = accent_value
	title_text = String(data.get("title","Evento do Mundo"))
	body_text = String(data.get("text",""))
	location_text = location_name
	meta_text = "%d dias restantes" % remaining
	warning_text = warning
	custom_minimum_size = Vector2(668,0)
	add_theme_constant_override("separation",8)
	_build()
	queue_redraw()

func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",94)
	margin.add_theme_constant_override("margin_right",16)
	margin.add_theme_constant_override("margin_top",14)
	margin.add_theme_constant_override("margin_bottom",14)
	add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation",6)
	margin.add_child(v)

	var top := HBoxContainer.new()
	v.add_child(top)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size",19)
	title.modulate = Color("#f2e5bf")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var meta := Label.new()
	meta.text = meta_text
	meta.add_theme_font_size_override("font_size",13)
	meta.modulate = accent
	top.add_child(meta)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size",14)
	body.modulate = Color("#d9e0da")
	v.add_child(body)

	var loc := Label.new()
	loc.text = "◈  %s" % location_text
	loc.add_theme_font_size_override("font_size",13)
	loc.modulate = Color("#b9cfc6")
	v.add_child(loc)
	if not warning_text.is_empty():
		var warn := Label.new()
		warn.text = warning_text.strip_edges()
		warn.add_theme_font_size_override("font_size",13)
		warn.modulate = Color("#e7aa77")
		v.add_child(warn)

	var follow := Button.new()
	follow.text = "ACOMPANHAR  ›"
	follow.custom_minimum_size = Vector2(0,52)
	follow.focus_mode = Control.FOCUS_NONE
	follow.pressed.connect(func() -> void: follow_requested.emit(uid))
	v.add_child(follow)

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_card()

func _draw_card() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#10272d")
	style.bg_color.a = 0.93
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(accent,0.65)
	draw_style_box(style,Rect2(Vector2.ZERO,size))
	draw_rect(Rect2(0,0,6,size.y),accent,true)
	draw_circle(Vector2(48,55),29.0,Color("#07171b"))
	draw_circle(Vector2(48,55),27.0,Color(accent,0.16))
	draw_arc(Vector2(48,55),27.0,0.0,TAU,40,accent,2.0)
	_draw_icon(Vector2(48,55))

func _draw_icon(c:Vector2) -> void:
	match event_type:
		"spirit_rain":
			draw_arc(c+Vector2(0,-5),13.0,PI,TAU,24,accent,2.0)
			for x in [-10,0,10]:
				draw_line(c+Vector2(x,2),c+Vector2(x-4,13),accent,2.0)
		"plague":
			draw_circle(c,14.0,Color(accent,0.12))
			draw_line(c+Vector2(-12,0),c+Vector2(12,0),accent,4.0)
			draw_line(c+Vector2(0,-12),c+Vector2(0,12),accent,4.0)
		"eclipse":
			draw_circle(c,15.0,accent)
			draw_circle(c+Vector2(8,-3),15.0,Color("#10272d"))
		"faction_conflict","tournament","rogue_bounty":
			draw_line(c+Vector2(-14,-14),c+Vector2(14,14),accent,3.0)
			draw_line(c+Vector2(14,-14),c+Vector2(-14,14),accent,3.0)
		"beast_tide":
			var pts := PackedVector2Array([c+Vector2(-14,12),c+Vector2(-8,-8),c+Vector2(0,-15),c+Vector2(8,-8),c+Vector2(15,12)])
			draw_polyline(pts,accent,3.0)
		"herb_bloom":
			for i in range(6):
				var a := deg_to_rad(float(i)*60.0)
				draw_circle(c+Vector2(cos(a),sin(a))*10.0,6.0,Color(accent,0.28))
			draw_circle(c,5.0,accent)
		_:
			draw_circle(c,11.0,Color(accent,0.18))
			draw_arc(c,11.0,0.0,TAU,30,accent,2.0)
			draw_line(c+Vector2(0,-14),c+Vector2(0,14),accent,2.0)
