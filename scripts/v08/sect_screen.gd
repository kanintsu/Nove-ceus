class_name V08SectScreen
extends Control

signal request_rank()
signal open_missions()

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var data:Dictionary={}

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var accent:=Color("#d1b568")
	var title:=Visuals.label("SEITA DO CÉU VELADO",25,Color("#f2e5bf")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var status:=PanelContainer.new(); status.position=Vector2(18,70); status.size=Vector2(684,165); status.add_theme_stylebox_override("panel",Visuals.panel(Color("#0c242b"),Color(accent,0.55),20,1)); add_child(status)
	var v:=VBoxContainer.new(); status.add_child(v)
	v.add_child(Visuals.label(String(data.get("status","Sem vínculo formal")),23,Color("#efdfb7")))
	v.add_child(Visuals.label("Mérito %d   ·   Reputação %d" % [int(data.get("merit",0)),int(data.get("reputation",0))],14,Color("#ccb87e")))
	v.add_child(Visuals.label("Mortais podem servir, estudar e criar vínculos. Qi altera sua posição, não sua existência.",12,Color("#bdccc6")))
	var rank:=Button.new(); rank.text="PEDIR ENTRADA / PROMOÇÃO"; rank.pressed.connect(func():request_rank.emit()); v.add_child(rank)

	var ladder=[["Servo da Seita",0],["Discípulo Externo",1],["Discípulo Interno",45],["Discípulo Central",120],["Discípulo Herdeiro",240],["Ancião",500]]
	for i in range(ladder.size()):
		var y:=270+i*92
		var p:=PanelContainer.new(); p.position=Vector2(70,y); p.size=Vector2(580,76); p.add_theme_stylebox_override("panel",Visuals.panel(Color("#10272e"),Color(accent,0.32),15,1)); add_child(p)
		var row:=HBoxContainer.new(); p.add_child(row)
		var orb:=Label.new(); orb.text="◈"; orb.custom_minimum_size=Vector2(62,0); orb.add_theme_font_size_override("font_size",26); orb.modulate=accent; orb.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; orb.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; row.add_child(orb)
		var name:=Visuals.label(ladder[i][0],16,Color("#e5dfc9")); name.size_flags_horizontal=Control.SIZE_EXPAND_FILL; name.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; row.add_child(name)
		row.add_child(Visuals.label("Mérito %d" % ladder[i][1],12,Color("#9eb1aa")))
	var missions:=Button.new(); missions.position=Vector2(160,850); missions.size=Vector2(400,76); missions.text="ABRIR QUADRO DE MISSÕES"; missions.pressed.connect(func():open_missions.emit()); missions.add_theme_stylebox_override("normal",Visuals.panel(Color("#172d33"),Color(accent,0.62),18,1)); add_child(missions)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#10252c"),true)
	# sect mountain and gate
	draw_colored_polygon(PackedVector2Array([Vector2(0,920),Vector2(160,520),Vector2(300,780),Vector2(470,350),Vector2(720,920)]),Color("#203e45",0.55))
	draw_line(Vector2(360,850),Vector2(360,280),Color("#cdb86d",0.09),4)
