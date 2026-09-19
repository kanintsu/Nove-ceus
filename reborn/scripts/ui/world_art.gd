class_name RebornWorldArt
extends Control

var phase:=1
var kind:="village"
var t:=0.0
var accent:=Color("#d9bd72")

func setup(phase_value:int,kind_value:String)->void:
	phase=phase_value
	kind=kind_value
	accent=RebornUI.accent_for_phase(phase)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta:float)->void:
	t+=delta
	if fmod(t,0.12)<delta:queue_redraw()

func _notification(what:int)->void:
	if what==NOTIFICATION_DRAW:_draw_world()

func _draw_world()->void:
	var dark:=RebornUI.dark_for_phase(phase)
	var sky_top:=dark.lightened(0.48)
	var sky_bottom:=dark.lightened(0.05)
	for i in range(32):
		var k:=float(i)/31.0
		draw_rect(Rect2(0,size.y*k,size.x,size.y/32.0+1),sky_top.lerp(sky_bottom,k),true)

	var sun:=Vector2(size.x*0.77,size.y*0.14)
	for r in [90.0,66.0,46.0]:
		draw_circle(sun,r,Color(accent,0.025))
	draw_circle(sun,28,Color(accent,0.68))
	for r in [55.0,78.0,108.0]:
		draw_arc(sun,r,0,TAU,64,Color(accent,0.16),1.2)

	_draw_mountain_layer(size.y*0.38,Color("#5c7472",0.44),0)
	_draw_mountain_layer(size.y*0.53,Color("#37545a",0.72),1)
	_draw_mountain_layer(size.y*0.68,Color("#1a343c",0.92),2)

	for i in range(8):
		var x:=fmod(float(i)*127.0+sin(t*0.07+i)*38.0,size.x+160)-80
		var y:=size.y*(0.22+float(i%4)*0.10)
		var c:=Color("#eaf1eb",0.045+0.012*float(i%3))
		draw_circle(Vector2(x,y),50+float(i%3)*18,c)
		draw_circle(Vector2(x+42,y+7),36,c)
		draw_circle(Vector2(x-38,y+12),32,c)

	match kind:
		"village": _draw_village()
		"city": _draw_city()
		"sect": _draw_sect()
		"ruins": _draw_ruins()
		"celestial": _draw_celestial()
		_: _draw_village()

	# foreground terrace
	draw_colored_polygon(PackedVector2Array([
		Vector2(0,size.y*0.80),Vector2(size.x,size.y*0.77),Vector2(size.x,size.y),Vector2(0,size.y)
	]),Color("#07171d",0.97))
	for x in range(0,8):
		var px:=55.0+float(x)*95.0
		draw_line(Vector2(px,size.y*0.80),Vector2(px+20,size.y),Color(accent,0.03),2)

func _draw_mountain_layer(base_y:float,c:Color,seed:int)->void:
	var pts:=PackedVector2Array([Vector2(0,size.y),Vector2(0,base_y)])
	for i in range(10):
		var x:=float(i)*size.x/9.0
		var peak:=base_y-(60.0+float((i*41+seed*29+phase*17)%130))
		pts.append(Vector2(x,peak))
		pts.append(Vector2(x+size.x/18.0,base_y-12.0-float((i*19)%45)))
	pts.append(Vector2(size.x,size.y))
	draw_colored_polygon(pts,c)

func _draw_pagoda(p:Vector2,s:float,glow:Color)->void:
	var body:=Color("#142a30")
	draw_rect(Rect2(p+Vector2(-34,-5)*s,Vector2(68,58)*s),body,true)
	for level in range(3):
		var y:=-10.0-float(level)*42.0
		var w:=55.0-float(level)*9.0
		draw_rect(Rect2(p+Vector2(-w*0.45,y-27)*s,Vector2(w*0.9,28)*s),body,true)
		draw_colored_polygon(PackedVector2Array([
			p+Vector2(-w,y)*s,p+Vector2(0,y-25)*s,p+Vector2(w,y)*s
		]),Color(glow,0.48-float(level)*0.08))
		draw_line(p+Vector2(-w-10,y+2)*s,p+Vector2(w+10,y+2)*s,Color(glow,0.56),3*s)

func _draw_village()->void:
	_draw_pagoda(Vector2(size.x*0.68,size.y*0.69),0.85,accent)
	_draw_pagoda(Vector2(size.x*0.28,size.y*0.73),0.55,accent)
	draw_line(Vector2(size.x*0.12,size.y*0.76),Vector2(size.x*0.88,size.y*0.74),Color("#c4a66a",0.24),8)

func _draw_city()->void:
	for i in range(5):
		_draw_pagoda(Vector2(100+i*125,size.y*0.72-float(i%2)*42),0.6+0.08*float(i%3),accent)

func _draw_sect()->void:
	for p in [Vector2(150,470),Vector2(360,370),Vector2(570,500)]:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-100,70),p+Vector2(-55,0),p+Vector2(0,-24),p+Vector2(75,12),p+Vector2(110,74)]),Color("#36555d",0.78))
		_draw_pagoda(p,0.62,Color("#75d4e2"))
	draw_line(Vector2(140,525),Vector2(560,445),Color("#a8dfe5",0.16),5)

func _draw_ruins()->void:
	for x in [160.0,290.0,430.0,570.0]:
		draw_rect(Rect2(x,size.y*0.58-fmod(x,80),26,170),Color("#49565a",0.68),true)
	draw_arc(Vector2(size.x*0.5,size.y*0.63),100,PI,TAU,40,Color(accent,0.28),7)

func _draw_celestial()->void:
	for p in [Vector2(170,450),Vector2(360,360),Vector2(560,470)]:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-100,55),p+Vector2(-55,0),p+Vector2(0,-18),p+Vector2(75,8),p+Vector2(110,58)]),Color("#6e6d91",0.45))
		_draw_pagoda(p,0.7,Color("#f0d88c"))
	var c:=Vector2(size.x*0.5,size.y*0.25)
	for r in [70.0,95.0,125.0]:
		draw_arc(c,r,0,TAU,64,Color("#f4d77e",0.16),1.5)
