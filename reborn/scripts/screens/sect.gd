class_name RebornSectScreen
extends Control

signal serve()
signal open_missions()

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("SEITA DO VÉU CELESTE",27,Color("#f0e0b8"))
	title.position=Vector2(20,18);title.size=Vector2(680,42);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var status:=PanelContainer.new()
	status.position=Vector2(24,82);status.size=Vector2(672,172)
	status.add_theme_stylebox_override("panel",UI.panel(Color("#0a2229",0.96),Color("#d5b86c",0.55),20,1))
	add_child(status)
	var v:=VBoxContainer.new();status.add_child(v)
	v.add_child(UI.label(state.sect_status,23,Color("#f0ddb4")))
	v.add_child(UI.label("Mérito %d" % state.sect_merit,14,Color("#d1bb78")))
	v.add_child(UI.label("Mortais podem servir e aprender. O despertar do Qi muda sua posição, não sua dignidade.",12,Color("#c7d3ce")))
	var ladder=[["Servo da Seita",0],["Discípulo Externo",8],["Discípulo Interno",45],["Discípulo Central",120],["Discípulo Herdeiro",240],["Ancião",500]]
	for i in range(ladder.size()):
		var p:=PanelContainer.new();p.position=Vector2(76,292+i*90);p.size=Vector2(568,72)
		var reached:=state.sect_merit>=int(ladder[i][1])
		var col:=Color("#d5b86c") if reached else Color("#586f71")
		p.add_theme_stylebox_override("panel",UI.panel(Color("#10272e"),Color(col,0.42),15,2 if String(ladder[i][0])==state.sect_status else 1))
		add_child(p)
		var row:=HBoxContainer.new();p.add_child(row)
		var orb:=UI.label("◈",24,col);orb.custom_minimum_size=Vector2(58,0);orb.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;orb.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(orb)
		var name:=UI.label(String(ladder[i][0]),16,Color("#e4deca"));name.size_flags_horizontal=Control.SIZE_EXPAND_FILL;name.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(name)
		row.add_child(UI.label("Mérito %d" % int(ladder[i][1]),11,Color("#9fb0aa")))
	var work:=UI.button("CUMPRIR DEVERES DA SEITA",Color("#d5b86c"),68)
	work.position=Vector2(70,860);work.size=Vector2(280,68);work.pressed.connect(func():serve.emit());add_child(work)
	var missions:=UI.button("QUADRO DE MISSÕES",Color("#7ba9c7"),68)
	missions.position=Vector2(370,860);missions.size=Vector2(280,68);missions.pressed.connect(func():open_missions.emit());add_child(missions)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#0d232a"),true)
	draw_colored_polygon(PackedVector2Array([Vector2(0,1000),Vector2(155,560),Vector2(280,790),Vector2(480,360),Vector2(720,1000)]),Color("#244047",0.46))
	for p in [Vector2(170,500),Vector2(470,410)]:
		draw_rect(Rect2(p+Vector2(-28,-12),Vector2(56,45)),Color("#13272c"),true)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-48,-12),p+Vector2(0,-40),p+Vector2(48,-12)]),Color("#d5b86c",0.28))
