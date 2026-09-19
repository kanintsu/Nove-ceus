class_name RebornCycleScreen
extends Control

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("CICLO DE VIDA",27,Color("#f0e1bc"))
	title.position=Vector2(20,18);title.size=Vector2(680,42);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var stages=[["Nascimento",0],["Infância",5],["Juventude",13],["Vida Adulta",20],["Maturidade",40],["Velhice",65],["Morte",999],["Reencarnação",1000]]
	for i in range(stages.size()):
		var y:=105+i*104
		var reached:=state.age>=int(stages[i][1]) and i<6
		var p:=PanelContainer.new();p.position=Vector2(120,y);p.size=Vector2(500,76)
		p.add_theme_stylebox_override("panel",UI.panel(Color("#0d252c"),Color("#d2b76c",0.56 if reached else 0.18),16,2 if reached and i in [2,3,4,5] else 1))
		add_child(p)
		var row:=HBoxContainer.new();p.add_child(row)
		var orb:=UI.label("●" if reached else "○",20,Color("#d2b76c") if reached else Color("#60716d"))
		orb.custom_minimum_size=Vector2(60,0);orb.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;orb.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(orb)
		var l:=UI.label(String(stages[i][0]),17,Color("#e5dec9"));l.size_flags_horizontal=Control.SIZE_EXPAND_FILL;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(l)
		if i==2:row.add_child(UI.label("Você está aqui",11,Color("#c8a8b8")))

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#111f2a"),true)
	draw_line(Vector2(92,142),Vector2(92,870),Color("#d2b76c",0.25),3)
	for i in range(6):
		draw_circle(Vector2(92,142+i*104),7,Color("#d2b76c",0.45))
