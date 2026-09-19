class_name MobileCard
extends VBoxContainer

var panel_color := Color("#10262b")
var border_color := Color("#b99f61")
var inner_glow := Color("#6aa8a0")

func _ready() -> void:
	add_theme_constant_override("separation",8)
	custom_minimum_size = Vector2(668,0)
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_card()

func _draw_card() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = panel_color
	style.bg_color.a = 0.94
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(border_color,0.72)
	draw_style_box(style,Rect2(Vector2.ZERO,size))

	# double frame
	var inner := Rect2(Vector2(7,7),size-Vector2(14,14))
	draw_style_box(_frame_box(Color(inner_glow,0.18),Color(border_color,0.24),15),inner)

	# ornamental top rail
	var rail_y := 8.0
	draw_line(Vector2(38,rail_y),Vector2(size.x*0.43,rail_y),Color(border_color,0.55),1.0)
	draw_line(Vector2(size.x*0.57,rail_y),Vector2(size.x-38,rail_y),Color(border_color,0.55),1.0)
	var cx := size.x*0.5
	var diamond := PackedVector2Array([
		Vector2(cx-8,rail_y),Vector2(cx,rail_y-8),
		Vector2(cx+8,rail_y),Vector2(cx,rail_y+8)
	])
	draw_colored_polygon(diamond,Color(border_color,0.80))
	var inner_diamond := PackedVector2Array([
		Vector2(cx-4,rail_y),Vector2(cx,rail_y-4),
		Vector2(cx+4,rail_y),Vector2(cx,rail_y+4)
	])
	draw_colored_polygon(inner_diamond,Color("#17383d"))

	_draw_corner(Vector2(15,15),Vector2(1,1))
	_draw_corner(Vector2(size.x-15,15),Vector2(-1,1))
	_draw_corner(Vector2(15,size.y-15),Vector2(1,-1))
	_draw_corner(Vector2(size.x-15,size.y-15),Vector2(-1,-1))

func _draw_corner(origin:Vector2,dir:Vector2) -> void:
	var c := Color(border_color,0.72)
	draw_line(origin,origin+Vector2(dir.x*25,0),c,2.0)
	draw_line(origin,origin+Vector2(0,dir.y*25),c,2.0)
	draw_line(origin+Vector2(dir.x*8,0),origin+Vector2(dir.x*8,dir.y*12),c,1.0)
	draw_line(origin+Vector2(0,dir.y*8),origin+Vector2(dir.x*12,dir.y*8),c,1.0)

func _frame_box(bg:Color,border:Color,radius:int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = border
	return s
