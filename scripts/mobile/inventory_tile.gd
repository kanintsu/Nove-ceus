class_name InventoryTile
extends BaseButton

signal inspect_requested(item:Dictionary)

var item: Dictionary = {}
var accent := Color("#9aa9a4")

func setup(item_value:Dictionary) -> void:
	item = item_value
	custom_minimum_size = Vector2(214,136)
	focus_mode = Control.FOCUS_NONE
	accent = _rarity_color(String(item.get("rarity","Comum")))
	pressed.connect(func() -> void: inspect_requested.emit(item))
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_tile()

func _draw_tile() -> void:
	var bg := Color("#12282e")
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(accent,0.78)
	draw_style_box(style,Rect2(Vector2.ZERO,size))

	var glow := Color(accent,0.12)
	draw_circle(Vector2(size.x*0.5,43),28,glow)
	draw_arc(Vector2(size.x*0.5,43),25,0.0,TAU,36,Color(accent,0.60),1.5)
	_draw_kind_icon(Vector2(size.x*0.5,43),String(item.get("kind","Objeto")))

	var name := String(item.get("name","Item"))
	if name.length() > 23:
		name = name.left(21)+"…"
	draw_string(ThemeDB.fallback_font,Vector2(8,92),name,HORIZONTAL_ALIGNMENT_CENTER,size.x-16,12,Color("#e3e1d4"))
	draw_string(ThemeDB.fallback_font,Vector2(8,112),"×%d" % int(item.get("qty",1)),HORIZONTAL_ALIGNMENT_LEFT,60,13,Color("#f1d487"))
	draw_string(ThemeDB.fallback_font,Vector2(70,112),String(item.get("rarity","Comum")),HORIZONTAL_ALIGNMENT_RIGHT,size.x-78,11,accent)

func _draw_kind_icon(c:Vector2,kind:String) -> void:
	match kind:
		"Erva":
			for i in range(5):
				var a := deg_to_rad(-90.0+float(i-2)*27.0)
				draw_line(c,c+Vector2(cos(a),sin(a))*17.0,accent,3.0)
			draw_circle(c,5.0,accent)
		"Minério","Material":
			var pts := PackedVector2Array([c+Vector2(-14,8),c+Vector2(-6,-14),c+Vector2(10,-10),c+Vector2(16,7),c+Vector2(2,15)])
			draw_colored_polygon(pts,Color(accent,0.28))
			draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[4],pts[0]]),accent,2.0)
		"Manual":
			draw_rect(Rect2(c+Vector2(-15,-17),Vector2(30,34)),Color(accent,0.16),true)
			draw_rect(Rect2(c+Vector2(-15,-17),Vector2(30,34)),accent,false,2.0)
			draw_line(c+Vector2(-8,-7),c+Vector2(8,-7),accent,1.5)
			draw_line(c+Vector2(-8,1),c+Vector2(8,1),accent,1.5)
		"Tesouro","Dao":
			var pts2 := PackedVector2Array([c+Vector2(0,-18),c+Vector2(14,0),c+Vector2(0,18),c+Vector2(-14,0)])
			draw_colored_polygon(pts2,Color(accent,0.30))
			draw_polyline(PackedVector2Array([pts2[0],pts2[1],pts2[2],pts2[3],pts2[0]]),accent,2.0)
		"Equipamento":
			draw_line(c+Vector2(-12,14),c+Vector2(10,-13),accent,4.0)
			draw_line(c+Vector2(-16,8),c+Vector2(-6,18),accent,3.0)
		_:
			draw_circle(c,13.0,Color(accent,0.20))
			draw_arc(c,13.0,0.0,TAU,28,accent,2.0)

func _rarity_color(rarity:String) -> Color:
	match rarity:
		"Incomum": return Color("#70b493")
		"Raro": return Color("#6aa9d8")
		"Épico": return Color("#a47ad5")
		"Lendário": return Color("#dda85e")
		"Mítico": return Color("#e77a86")
		_: return Color("#9da9a5")
