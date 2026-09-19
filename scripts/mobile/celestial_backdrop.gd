class_name CelestialBackdrop
extends Control

var phase := 1
var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()

func set_phase(value:int) -> void:
	phase = clampi(value,1,5)
	queue_redraw()

func _process(delta:float) -> void:
	time += delta
	if fmod(time,0.10) < delta:
		queue_redraw()

func _draw() -> void:
	var palette := _palette()
	var sky_top: Color = palette[0]
	var sky_bottom: Color = palette[1]
	var bands := 36
	for i in range(bands):
		var t := float(i)/float(bands-1)
		var c := sky_top.lerp(sky_bottom,t)
		draw_rect(Rect2(0.0,size.y*t,size.x,size.y/float(bands)+2.0),c,true)

	var celestial := palette[2]
	var orb_pos := Vector2(size.x*0.76,size.y*0.12)
	for r in range(120,12,-12):
		var cc := celestial
		cc.a = 0.012+float(120-r)/5000.0
		draw_circle(orb_pos,float(r),cc)
	var core := celestial
	core.a = 0.78
	draw_circle(orb_pos,34.0,core)

	_draw_mountains(size.y*0.38,palette[3],0.58,0.22)
	_draw_mountains(size.y*0.49,palette[4],0.78,0.48)
	_draw_mountains(size.y*0.61,palette[5],0.96,0.80)

	_draw_pavilion(Vector2(size.x*0.16,size.y*0.46),0.72,palette[6])
	_draw_pavilion(Vector2(size.x*0.70,size.y*0.40),0.52,palette[6])

	var cloud := palette[7]
	for i in range(7):
		var x := fmod(float(i)*137.0+sin(time*0.08+float(i))*42.0+size.x,size.x+180.0)-90.0
		var y := size.y*(0.29+float(i%3)*0.105)
		var c := cloud
		c.a = 0.08+float(i%3)*0.025
		draw_circle(Vector2(x,y),76.0+float(i%2)*28.0,c)
		draw_circle(Vector2(x+65.0,y+11.0),52.0,c)
		draw_circle(Vector2(x-58.0,y+18.0),46.0,c)

	var mist := palette[7]
	for i in range(5):
		var yy := size.y*(0.58+float(i)*0.08)
		var c := mist
		c.a = 0.045+float(i)*0.012
		draw_rect(Rect2(0.0,yy,size.x,70.0),c,true)

	var floor_color := palette[8]
	draw_rect(Rect2(0.0,size.y*0.78,size.x,size.y*0.22),floor_color,true)

	# faint celestial geometry: actual rendered decoration, not a background image
	var rune := palette[2]
	rune.a = 0.11
	var center := Vector2(size.x*0.5,size.y*0.22)
	draw_arc(center,72.0,0.0,TAU,72,rune,1.0)
	draw_arc(center,105.0,0.0,TAU,72,rune,1.0)
	for a in range(0,360,45):
		var rad := deg_to_rad(float(a))
		draw_line(center+Vector2(cos(rad),sin(rad))*78.0,center+Vector2(cos(rad),sin(rad))*99.0,rune,1.0)

func _draw_mountains(base_y:float,color:Color,alpha:float,offset_seed:float) -> void:
	var c := color
	c.a = alpha
	var points := PackedVector2Array()
	points.append(Vector2(0.0,size.y))
	points.append(Vector2(0.0,base_y))
	var segments := 9
	for i in range(segments+1):
		var x := size.x*float(i)/float(segments)
		var wave := sin(float(i)*1.73+offset_seed*7.0)*0.5+0.5
		var peak := base_y-(60.0+wave*150.0)*(0.68+0.32*sin(float(i)*0.9+1.2))
		if i%2==0:
			points.append(Vector2(x,peak))
		else:
			points.append(Vector2(x,base_y-28.0-wave*68.0))
	points.append(Vector2(size.x,size.y))
	draw_colored_polygon(points,c)

func _draw_pavilion(pos:Vector2,scale_value:float,color:Color) -> void:
	var c := color
	c.a = 0.64
	draw_rect(Rect2(pos.x-48.0*scale_value,pos.y,96.0*scale_value,11.0*scale_value),c,true)
	draw_rect(Rect2(pos.x-30.0*scale_value,pos.y-38.0*scale_value,60.0*scale_value,40.0*scale_value),c,true)
	var roof := PackedVector2Array([
		Vector2(pos.x-58.0*scale_value,pos.y-38.0*scale_value),
		Vector2(pos.x,pos.y-72.0*scale_value),
		Vector2(pos.x+58.0*scale_value,pos.y-38.0*scale_value)
	])
	draw_colored_polygon(roof,c)
	draw_line(Vector2(pos.x-70.0*scale_value,pos.y-35.0*scale_value),Vector2(pos.x+70.0*scale_value,pos.y-35.0*scale_value),c,4.0*scale_value)

func _palette() -> Array[Color]:
	match phase:
		1:
			return [Color("#d9dfd0"),Color("#78939a"),Color("#e7c778"),Color("#8aa4a0"),Color("#587473"),Color("#2d494d"),Color("#233739"),Color("#edf1e6"),Color("#0f1f22")]
		2:
			return [Color("#e5c7a2"),Color("#8d6171"),Color("#f0d07a"),Color("#a78378"),Color("#6e5158"),Color("#3c3442"),Color("#3b2f35"),Color("#f4dfc6"),Color("#241d27")]
		3:
			return [Color("#c6e6ef"),Color("#476d91"),Color("#9ee9ff"),Color("#789cad"),Color("#4a7187"),Color("#28445d"),Color("#213748"),Color("#e6f7fb"),Color("#15283a")]
		4:
			return [Color("#b9909f"),Color("#4e3044"),Color("#ef8e76"),Color("#7b5368"),Color("#56384f"),Color("#30243a"),Color("#2a202e"),Color("#d9bdc7"),Color("#1b131e")]
		_:
			return [Color("#efe3bc"),Color("#69649b"),Color("#f4dc8f"),Color("#a29db8"),Color("#77789d"),Color("#42466e"),Color("#303657"),Color("#f6edcf"),Color("#181b31")]
