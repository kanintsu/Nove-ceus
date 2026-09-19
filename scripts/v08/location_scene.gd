class_name LocationScene
extends Control

var location:Dictionary={}
var phase:=1
var accent:=Color("#d2b66d")

func setup(loc:Dictionary,phase_value:int,accent_value:Color)->void:
	location=loc
	phase=phase_value
	accent=accent_value
	custom_minimum_size=Vector2(668,560)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what:int)->void:
	if what==NOTIFICATION_DRAW:
		_draw_scene()

func _draw_scene()->void:
	var bg:=GameVisuals.phase_bg(phase)
	draw_rect(Rect2(Vector2.ZERO,size),bg,true)
	var top:=bg.lightened(0.38)
	for i in range(24):
		var t:=float(i)/23.0
		draw_rect(Rect2(0,size.y*t,size.x,size.y/24.0+1),top.lerp(bg,t),true)

	# moon/sun
	var orb:=Vector2(size.x*0.78,92)
	draw_circle(orb,54,Color(accent,0.08))
	draw_circle(orb,25,Color(accent,0.72))

	# mountains
	for layer in range(3):
		var base_y:=260.0+layer*80.0
		var c:=Color("#2f555b").lerp(Color("#132a30"),float(layer)/2.0)
		var pts:=PackedVector2Array([Vector2(0,size.y),Vector2(0,base_y)])
		for i in range(8):
			var x:=float(i)*size.x/7.0
			var peak:=base_y-(70.0+float((i*37+phase*19+layer*23)%110))
			pts.append(Vector2(x,peak))
		pts.append(Vector2(x+size.x/14.0,base_y-18.0))
		pts.append(Vector2(size.x,size.y))
		draw_colored_polygon(pts,Color(c,0.50+layer*0.16))

	# location-specific structure
	var tags:Array=location.get("tags",[])
	var tag:=String(tags[0]) if not tags.is_empty() else ""
	match tag:
		"city","village","sect","celestial":
			_draw_temple(Vector2(size.x*0.53,360),1.7)
		"forest","herbs":
			for x in [120.0,240.0,365.0,510.0]:
				_draw_tree(Vector2(x,405),1.1+fmod(x,3.0)*0.12)
		"ruin","grave","ancient":
			_draw_ruins(Vector2(size.x*0.52,395))
		"beasts","battlefield":
			_draw_banners(Vector2(size.x*0.50,390))
		_:
			_draw_temple(Vector2(size.x*0.54,380),1.0)

	# foreground terrace
	draw_colored_polygon(PackedVector2Array([
		Vector2(0,492),Vector2(size.x,470),Vector2(size.x,size.y),Vector2(0,size.y)
	]),Color("#0b1d22",0.95))
	draw_arc(Vector2(size.x*0.5,530),132,PI,TAU,44,Color(accent,0.30),3)

func _draw_temple(p:Vector2,s:float)->void:
	var dark:=Color("#13292e")
	var light:=Color(accent,0.48)
	draw_rect(Rect2(p+Vector2(-55,-20)*s,Vector2(110,52)*s),dark,true)
	draw_colored_polygon(PackedVector2Array([
		p+Vector2(-80,-20)*s,p+Vector2(0,-70)*s,p+Vector2(80,-20)*s
	]),light)
	draw_line(p+Vector2(-98,-17)*s,p+Vector2(98,-17)*s,Color(accent,0.62),4*s)
	draw_rect(Rect2(p+Vector2(-30,-108)*s,Vector2(60,40)*s),dark,true)
	draw_colored_polygon(PackedVector2Array([
		p+Vector2(-48,-108)*s,p+Vector2(0,-142)*s,p+Vector2(48,-108)*s
	]),Color(accent,0.38))

func _draw_tree(p:Vector2,s:float)->void:
	draw_line(p,p+Vector2(0,-100)*s,Color("#33291f"),12*s)
	for q in [Vector2(-28,-95),Vector2(20,-112),Vector2(0,-135)]:
		draw_circle(p+q*s,42*s,Color("#42644f",0.88))

func _draw_ruins(p:Vector2)->void:
	var stone:=Color("#53605d")
	draw_rect(Rect2(p+Vector2(-80,-90),Vector2(24,110)),stone,true)
	draw_rect(Rect2(p+Vector2(50,-120),Vector2(28,140)),stone,true)
	draw_line(p+Vector2(-70,-95),p+Vector2(65,-125),Color(accent,0.30),4)
	draw_circle(p+Vector2(0,-40),34,Color("#6fcad4",0.10))

func _draw_banners(p:Vector2)->void:
	for x in [-90.0,0.0,90.0]:
		draw_line(p+Vector2(x,30),p+Vector2(x,-130),Color("#352927"),5)
		draw_colored_polygon(PackedVector2Array([
			p+Vector2(x,-128),p+Vector2(x+50,-112),p+Vector2(x+10,-72),p+Vector2(x,-80)
		]),Color("#8d4c4d"))
