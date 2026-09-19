class_name CultivationDiagram
extends Control

var realm_index := 0
var progress := 0.0
var integrity := 1.0
var dao := 0.0
var accent := Color("#7ed7df")

func setup(realm:int,progress_value:float,integrity_value:float,dao_value:float,accent_value:Color) -> void:
	realm_index = realm
	progress = clampf(progress_value,0.0,100.0)
	integrity = clampf(integrity_value,0.0,1.0)
	dao = dao_value
	accent = accent_value
	custom_minimum_size = Vector2(668,330)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_diagram()

func _draw_diagram() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#0d232a")
	panel.bg_color.a = 0.92
	panel.corner_radius_top_left = 24
	panel.corner_radius_top_right = 24
	panel.corner_radius_bottom_left = 24
	panel.corner_radius_bottom_right = 24
	panel.border_width_left = 1
	panel.border_width_right = 1
	panel.border_width_top = 1
	panel.border_width_bottom = 1
	panel.border_color = Color(accent,0.48)
	draw_style_box(panel,Rect2(Vector2.ZERO,size))

	var c := Vector2(size.x*0.5,164)
	var aura := accent
	aura.a = 0.08+minf(0.16,float(realm_index)*0.008)
	for r in [132.0,108.0,82.0]:
		draw_circle(c,r,Color(aura,0.025))
		draw_arc(c,r,0.0,TAU,64,Color(accent,0.12),1.0)

	# seated body silhouette
	var robe := Color("#43666f")
	var skin := Color("#c89e82")
	draw_circle(c+Vector2(0,-72),22.0,skin)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-29,-79),c+Vector2(-13,-108),c+Vector2(12,-110),c+Vector2(29,-78),
		c+Vector2(18,-59),c+Vector2(8,-84),c+Vector2(-10,-66),c+Vector2(-20,-55)
	]),Color("#182226"))
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-65,62),c+Vector2(-42,-45),c+Vector2(-16,-54),c+Vector2(0,-31),
		c+Vector2(16,-54),c+Vector2(42,-45),c+Vector2(65,62)
	]),robe)
	draw_arc(c+Vector2(-58,55),54.0,3.3,5.9,28,Color("#74939a"),16.0)
	draw_arc(c+Vector2(58,55),54.0,3.5,6.0,28,Color("#74939a"),16.0)

	var nodes := [
		c+Vector2(0,-48),c+Vector2(-24,-18),c+Vector2(24,-18),
		c+Vector2(-32,21),c+Vector2(32,21),c+Vector2(0,48),c+Vector2(0,4)
	]
	var links := [[0,1],[0,2],[1,3],[2,4],[3,5],[4,5],[1,6],[2,6],[6,5]]
	var line_color := Color(accent,0.36+integrity*0.34)
	for link in links:
		draw_line(nodes[link[0]],nodes[link[1]],line_color,2.3)
	for i in range(nodes.size()):
		var node_color := accent if i != 6 else Color("#f0d27a")
		draw_circle(nodes[i],8.0,Color(node_color,0.22))
		draw_circle(nodes[i],4.2,node_color)

	# dantian and progress ring
	var dantian: Vector2 = nodes[6]
	for rr in [27.0,20.0,13.0]:
		draw_arc(dantian,rr,0.0,TAU,48,Color("#72dce3",0.16),1.2)
	var angle := TAU*(progress/100.0)
	draw_arc(dantian,32.0,-PI/2.0,-PI/2.0+angle,48,Color("#f0cc6d"),3.2)

	# integrity bar
	var bx := 58.0
	var by := size.y-43.0
	var bw := size.x-116.0
	draw_rect(Rect2(bx,by,bw,8),Color("#20383d"),true)
	draw_rect(Rect2(bx,by,bw*integrity,8),Color("#6dc5a6") if integrity>0.55 else Color("#d27862"),true)
	draw_string(ThemeDB.fallback_font,Vector2(bx,by-9),"MERIDIANOS %.0f%%" % (integrity*100.0),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#c9d8d1"))
	draw_string(ThemeDB.fallback_font,Vector2(size.x-190,by-9),"DAO %.0f" % dao,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#d9c079"))
