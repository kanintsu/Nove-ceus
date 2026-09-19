class_name V08LegacyScreen
extends Control

signal open_cycle()

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var data:Dictionary={}

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("LEGADO ENTRE VIDAS",25,Color("#f2e4bd")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var quote:=Visuals.label("Suas escolhas moldam o mundo. Mesmo após a morte, sua história continua.",15,Color("#c9d2cd")); quote.position=Vector2(90,80); quote.size=Vector2(540,70); quote.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(quote)
	var items=[
		["DEIXE TÉCNICAS","Manuais e artes podem sobreviver ao corpo."],
		["DEIXE ITENS","Armas, relíquias e propriedades permanecem no mundo."],
		["FORME UMA LINHAGEM","Filhos, discípulos e clãs continuam sem você."],
		["INFLUENCIE FACÇÕES","Seitas e cidades lembram antigas alianças."],
		["TORNE-SE UMA LENDA","A próxima vida pode ouvir histórias sobre a anterior."]
	]
	for i in range(items.size()):
		var p:=PanelContainer.new(); p.position=Vector2(70,190+i*126); p.size=Vector2(580,104); p.add_theme_stylebox_override("panel",Visuals.panel(Color("#0c242b"),Color("#d1b568",0.36),18,1)); add_child(p)
		var v:=VBoxContainer.new(); p.add_child(v); v.add_child(Visuals.label(items[i][0],17,Color("#e9ddb9"))); v.add_child(Visuals.label(items[i][1],12,Color("#b9cbc4")))
	var b:=Button.new(); b.position=Vector2(180,860); b.size=Vector2(360,74); b.text="VER CICLO DE VIDA"; b.pressed.connect(func():open_cycle.emit()); b.add_theme_stylebox_override("normal",Visuals.panel(Color("#172d33"),Color("#d1b568"),18,1)); add_child(b)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#121d29"),true)
	for i in range(5):
		draw_arc(Vector2(600,180+i*170),90+float(i)*10,2.2,4.8,30,Color("#d1b568",0.05),2)
