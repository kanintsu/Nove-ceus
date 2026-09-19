class_name V08BaseScreen
extends Control

signal action(action_key:String)

const Visuals=preload("res://scripts/v08/game_visuals.gd")

var accent:=Color("#8bb37c")

func setup(value:Dictionary)->void:
	accent=value.get("accent",Color("#8bb37c"))
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("CASA E BASE",25,Color("#f2e4bf")); title.position=Vector2(18,16); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var buildings=[
		["RESIDÊNCIA","rest",Vector2(72,305)],
		["OFICINA","forge",Vector2(390,312)],
		["JARDIM","gather",Vector2(80,580)],
		["ALQUIMIA","alchemy",Vector2(408,555)],
		["SALA DE CULTIVO","meditate",Vector2(225,180)],
		["BIBLIOTECA","study",Vector2(235,720)]
	]
	for x in buildings:
		var b:=Button.new(); b.position=x[2]; b.size=Vector2(220,74); b.text=x[0]; b.add_theme_stylebox_override("normal",Visuals.panel(Color("#0e292c",0.95),Color(accent,0.58),16,1)); var a:String=x[1]; b.pressed.connect(func():action.emit(a)); add_child(b)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#18312c"),true)
	# ground / courtyard
	draw_colored_polygon(PackedVector2Array([Vector2(0,450),Vector2(720,400),Vector2(720,1060),Vector2(0,1060)]),Color("#2f4737"))
	# pond
	draw_ellipse(Vector2(530,770),Vector2(105,52),Color("#466d71"))
	# paths
	draw_line(Vector2(350,1020),Vector2(340,540),Color("#a89d78",0.35),42)
	draw_line(Vector2(340,540),Vector2(160,350),Color("#a89d78",0.25),26)
	draw_line(Vector2(340,540),Vector2(510,350),Color("#a89d78",0.25),26)
	# mountains
	for x in [50.0,200.0,500.0,660.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(x-120,340),Vector2(x,100+fmod(x,90)),Vector2(x+130,340)]),Color("#31514b",0.55))

func draw_ellipse(c:Vector2,r:Vector2,col:Color)->void:
	var pts:=PackedVector2Array()
	for i in range(40):
		var a:=TAU*float(i)/40.0
		pts.append(c+Vector2(cos(a)*r.x,sin(a)*r.y))
	draw_colored_polygon(pts,col)
