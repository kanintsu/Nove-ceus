class_name PortraitMedallion
extends Control

var phase := 1
var realm_index := 0
var accent := Color("#d7bd72")

func setup(phase_value:int,realm_value:int,accent_value:Color) -> void:
	phase = phase_value
	realm_index = realm_value
	accent = accent_value
	custom_minimum_size = Vector2(96,96)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		_draw_medallion()

func _draw_medallion() -> void:
	var c := Vector2(size.x*0.5,size.y*0.5)
	var glow := Color(accent,0.13)
	draw_circle(c,43.0,glow)
	draw_circle(c,38.0,Color("#0a1b20"))
	draw_arc(c,40.0,0.0,TAU,64,accent,2.4)
	draw_arc(c,34.0,0.0,TAU,64,Color(accent,0.38),1.0)

	# stylized living portrait drawn by the game itself
	var skin := Color("#c89f82")
	var hair := Color("#172126")
	var robe := _robe_color()
	draw_circle(c+Vector2(0,-12),14.0,skin)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-17,-18),c+Vector2(-7,-32),c+Vector2(7,-34),c+Vector2(18,-17),
		c+Vector2(12,-5),c+Vector2(7,-19),c+Vector2(-4,-12),c+Vector2(-13,-3)
	]),hair)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-29,31),c+Vector2(-20,7),c+Vector2(-7,1),c+Vector2(0,10),
		c+Vector2(8,1),c+Vector2(21,7),c+Vector2(30,31)
	]),robe)
	draw_line(c+Vector2(0,10),c+Vector2(0,32),Color(accent,0.7),2.0)

	# realm halo changes as cultivation advances
	if realm_index > 0:
		var qi := Color("#72d7df")
		qi.a = 0.55
		draw_arc(c,29.0,-2.5,0.5,24,qi,2.0)
	if realm_index >= 10:
		var gold := Color("#e4c36e")
		gold.a = 0.5
		draw_arc(c,46.0,0.2,2.4,24,gold,2.0)
	if realm_index >= 17:
		var purple := Color("#bba0f0")
		purple.a = 0.46
		draw_arc(c,47.0,3.2,5.9,28,purple,2.0)

func _robe_color() -> Color:
	match phase:
		1:return Color("#6d8581")
		2:return Color("#8c5f62")
		3:return Color("#527b96")
		4:return Color("#6d465a")
		_:return Color("#746f9c")
