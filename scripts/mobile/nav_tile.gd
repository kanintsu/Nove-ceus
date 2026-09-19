class_name NavTile
extends BaseButton

var key := "life"
var label_text := "VIDA"
var selected := false
var accent := Color("#d8bd72")

func setup(key_value:String,label_value:String,accent_value:Color) -> void:
	key = key_value
	label_text = label_value
	accent = accent_value
	custom_minimum_size = Vector2(112,126)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	queue_redraw()

func set_selected(value:bool) -> void:
	selected = value
	disabled = value
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_tile()

func _draw_tile() -> void:
	var bg := Color("#102329")
	bg.a = 0.96 if selected else 0.88
	var border := accent if selected else Color("#6e847f")
	border.a = 0.95 if selected else 0.52
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_left = 2 if selected else 1
	style.border_width_right = 2 if selected else 1
	style.border_width_top = 2 if selected else 1
	style.border_width_bottom = 2 if selected else 1
	style.border_color = border
	draw_style_box(style,Rect2(Vector2.ZERO,size))
	if selected:
		var glow := accent
		glow.a = 0.16
		draw_circle(Vector2(size.x*0.5,42.0),31.0,glow)

	_draw_icon(Vector2(size.x*0.5,42.0),accent if selected else Color("#d5d4c5"))
	var tc := accent if selected else Color("#dddccf")
	draw_string(ThemeDB.fallback_font,Vector2(0.0,101.0),label_text,HORIZONTAL_ALIGNMENT_CENTER,size.x,14,tc)

func _draw_icon(c:Vector2,color:Color) -> void:
	var line := 3.0
	match key:
		"life":
			draw_line(c+Vector2(-20,8),c+Vector2(0,-13),color,line)
			draw_line(c+Vector2(0,-13),c+Vector2(20,8),color,line)
			draw_line(c+Vector2(-15,8),c+Vector2(15,8),color,line)
			draw_line(c+Vector2(-10,8),c+Vector2(-10,21),color,line)
			draw_line(c+Vector2(10,8),c+Vector2(10,21),color,line)
			draw_line(c+Vector2(-16,21),c+Vector2(16,21),color,line)
		"map":
			var pts := PackedVector2Array([c+Vector2(-25,18),c+Vector2(-8,-13),c+Vector2(3,5),c+Vector2(15,-19),c+Vector2(28,18)])
			draw_polyline(pts,color,line)
			draw_circle(c+Vector2(12,-6),3.0,color)
		"cultivation":
			for i in range(6):
				var a := deg_to_rad(float(i)*60.0-90.0)
				var p := c+Vector2(cos(a),sin(a))*15.0
				draw_circle(p,8.0,Color(color,0.20))
				draw_arc(p,8.0,0.0,TAU,22,color,1.5)
			draw_circle(c,7.0,color)
		"people":
			draw_circle(c+Vector2(-10,-6),8.0,Color(color,0.25))
			draw_arc(c+Vector2(-10,-6),8.0,0.0,TAU,24,color,2.0)
			draw_circle(c+Vector2(10,-4),8.0,Color(color,0.25))
			draw_arc(c+Vector2(10,-4),8.0,0.0,TAU,24,color,2.0)
			draw_arc(c+Vector2(-10,18),14.0,PI,TAU,24,color,2.2)
			draw_arc(c+Vector2(10,18),14.0,PI,TAU,24,color,2.2)
		"inventory":
			var pts2 := PackedVector2Array([c+Vector2(-18,-8),c+Vector2(18,-8),c+Vector2(23,21),c+Vector2(-23,21)])
			draw_colored_polygon(pts2,Color(color,0.12))
			draw_polyline(PackedVector2Array([pts2[0],pts2[1],pts2[2],pts2[3],pts2[0]]),color,2.2)
			draw_arc(c+Vector2(0,-8),12.0,PI,TAU,20,color,2.2)
		"chronicle":
			draw_rect(Rect2(c+Vector2(-18,-20),Vector2(36,40)),Color(color,0.10),true)
			draw_rect(Rect2(c+Vector2(-18,-20),Vector2(36,40)),color,false,2.0)
			for yy in [-9,0,9]:
				draw_line(c+Vector2(-10,yy),c+Vector2(10,yy),color,1.6)
