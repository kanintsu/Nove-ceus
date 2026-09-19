class_name CharacterFigure
extends Control

var realm_index:=0
var phase:=1
var gender_variant:=0
var accent:=Color("#d2b66d")

func setup(realm:int,phase_value:int,accent_value:Color,variant:int=0)->void:
	realm_index=realm
	phase=phase_value
	accent=accent_value
	gender_variant=variant
	custom_minimum_size=Vector2(280,500)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what:int)->void:
	if what==NOTIFICATION_DRAW:
		_draw_figure()

func _draw_figure()->void:
	var c:=Vector2(size.x*0.5,size.y*0.47)
	for r in [120.0,95.0,70.0]:
		draw_circle(c+Vector2(0,35),r,Color(accent,0.018))
		draw_arc(c+Vector2(0,35),r,0,TAU,64,Color(accent,0.08),1.0)
	if realm_index>0:
		draw_arc(c+Vector2(0,20),118,-2.7,0.2,40,Color("#72d7df",0.38),2.0)
	if realm_index>=10:
		draw_arc(c+Vector2(0,20),130,0.3,2.5,40,Color("#e2c46f",0.38),2.0)

	var skin:=Color("#c99e7d")
	var hair:=Color("#172127")
	var robe_dark:=Color("#172d34")
	var robe_mid:=_robe_color()
	var robe_light:=robe_mid.lightened(0.18)

	# legs / robe skirt
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-66,168),c+Vector2(-45,34),c+Vector2(-18,12),
		c+Vector2(0,24),c+Vector2(18,12),c+Vector2(45,34),c+Vector2(66,168)
	]),robe_dark)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-48,160),c+Vector2(-30,42),c+Vector2(-7,26),c+Vector2(0,48),
		c+Vector2(10,25),c+Vector2(31,42),c+Vector2(49,160)
	]),robe_mid)

	# shoulders and arms
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-91,34),c+Vector2(-45,-15),c+Vector2(-21,0),c+Vector2(-48,55)
	]),robe_mid)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(91,34),c+Vector2(45,-15),c+Vector2(21,0),c+Vector2(48,55)
	]),robe_mid)
	draw_line(c+Vector2(-80,44),c+Vector2(-112,111),robe_light,18)
	draw_line(c+Vector2(80,44),c+Vector2(112,111),robe_light,18)
	draw_circle(c+Vector2(-116,116),10,skin)
	draw_circle(c+Vector2(116,116),10,skin)

	# torso
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-42,-25),c+Vector2(-18,-45),c+Vector2(0,-34),c+Vector2(18,-45),
		c+Vector2(42,-25),c+Vector2(31,59),c+Vector2(-31,59)
	]),robe_mid)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-5,-40),c+Vector2(18,-45),c+Vector2(6,54),c+Vector2(-6,54)
	]),robe_light)
	draw_rect(Rect2(c+Vector2(-39,48),Vector2(78,13)),Color("#332d25"),true)
	draw_rect(Rect2(c+Vector2(-7,46),Vector2(14,17)),accent,true)

	# head
	draw_rect(Rect2(c+Vector2(-9,-76),Vector2(18,20)),skin,true)
	draw_circle(c+Vector2(0,-105),28,skin)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(-30,-108),c+Vector2(-24,-139),c+Vector2(-7,-154),c+Vector2(12,-150),
		c+Vector2(30,-125),c+Vector2(25,-94),c+Vector2(15,-122),c+Vector2(-2,-113),c+Vector2(-19,-91)
	]),hair)
	draw_line(c+Vector2(5,-151),c+Vector2(30,-184),hair,8)
	draw_line(c+Vector2(30,-184),c+Vector2(13,-206),hair,5)

	# face hints
	draw_line(c+Vector2(-13,-108),c+Vector2(-4,-108),Color("#3b302c"),2)
	draw_line(c+Vector2(5,-108),c+Vector2(14,-108),Color("#3b302c"),2)

	# aura nodes
	if realm_index>0:
		for p in [Vector2(0,-20),Vector2(0,14),Vector2(0,48)]:
			draw_circle(c+p,5,Color("#78e0e8"))
	if realm_index>=14:
		draw_circle(c+Vector2(0,5),18,Color("#f1cf6c",0.16))
		draw_arc(c+Vector2(0,5),18,0,TAU,32,Color("#f1cf6c"),2)

func _robe_color()->Color:
	match phase:
		1:return Color("#486b69")
		2:return Color("#7a5157")
		3:return Color("#466e8d")
		4:return Color("#68445e")
		_:return Color("#6b6796")
