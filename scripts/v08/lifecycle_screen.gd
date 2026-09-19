class_name V08LifecycleScreen
extends Control

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var data:Dictionary={}

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	queue_redraw()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("CICLO DE VIDA",25,Color("#f1e4bd")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var age:int=int(data.get("age",16))
	var stages=[["Nascimento",0],["Infância",5],["Juventude",13],["Vida Adulta",20],["Maturidade",40],["Velhice",65],["Morte",999],["Reencarnação",1000]]
	for i in range(stages.size()):
		var y:=100+i*102
		var reached:=age>=int(stages[i][1]) and i<6
		var p:=PanelContainer.new(); p.position=Vector2(105,y); p.size=Vector2(510,74)
		p.add_theme_stylebox_override("panel",Visuals.panel(Color("#0e252b"),Color("#d1b568",0.60 if reached else 0.18),16,2 if reached and (i==2 or i==3) else 1)); add_child(p)
		var row:=HBoxContainer.new(); p.add_child(row)
		var orb:=Label.new(); orb.text="●" if reached else "○"; orb.custom_minimum_size=Vector2(60,0); orb.modulate=Color("#d1b568") if reached else Color("#60716d"); orb.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; orb.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; row.add_child(orb)
		var l:=Visuals.label(stages[i][0],17,Color("#e6dfc9")); l.size_flags_horizontal=Control.SIZE_EXPAND_FILL; l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; row.add_child(l)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#111f2a"),true)
	draw_line(Vector2(78,126),Vector2(78,870),Color("#d1b568",0.28),3)
