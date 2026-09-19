class_name RebornMissionsScreen
extends Control

signal event_selected(uid:String)
signal mission_selected(uid:String)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState
var tab:="story"

func setup(game_state:RebornGameState)->void:
	state=game_state
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("MISSÕES E EVENTOS",26,Color("#f1e3bc"));title.position=Vector2(20,18);title.size=Vector2(680,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var tabs:=HBoxContainer.new();tabs.position=Vector2(20,72);tabs.size=Vector2(680,50);tabs.add_theme_constant_override("separation",6);add_child(tabs)
	for entry in [["story","PRINCIPAIS"],["mission","CONTRATOS"],["world","MUNDO"],["sect","SEITA"]]:
		var b:=Button.new();b.text=entry[1];b.custom_minimum_size=Vector2(165,46);b.disabled=tab==entry[0];var key:String=entry[0];b.pressed.connect(func():tab=key;_build());tabs.add_child(b)
	var scroll:=ScrollContainer.new();scroll.position=Vector2(20,140);scroll.size=Vector2(680,900);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	var v:=VBoxContainer.new();v.custom_minimum_size=Vector2(656,0);v.add_theme_constant_override("separation",10);scroll.add_child(v)
	if tab=="world":
		for e in state.world_events:v.add_child(_event_card(e))
	elif tab=="mission":
		for m in state.missions:v.add_child(_mission_card(m))
	elif tab=="sect":
		v.add_child(_story("PROVA DA SEITA","Alcance Qinghe, descubra seu potencial e procure o Véu Celeste.","Mérito e posição"))
		v.add_child(_story("SERVIÇO DO PAVILHÃO","Até um mortal pode trabalhar, estudar e criar vínculos dentro da seita.","Acesso aberto"))
	else:
		v.add_child(_story("O DESPERTAR","Descubra se esta vida consegue sentir Qi.","Em andamento"))
		v.add_child(_story("SINAIS NO VALE","Investigue acontecimentos fora da rotina da Vila da Nascente.","Opcional"))
		v.add_child(_story("O CAMINHO CELESTIAL","Chegue vivo ao Palácio dos Nove Céus.","Destino distante"))

func _story(t:String,d:String,s:String)->Control:
	var p:=PanelContainer.new();p.custom_minimum_size=Vector2(0,118);p.add_theme_stylebox_override("panel",UI.panel(Color("#0d252c"),Color("#d1b76c",0.42),18,1));var v:=VBoxContainer.new();p.add_child(v);v.add_child(UI.label(t,18,Color("#eee1be")));v.add_child(UI.label(d,13,Color("#c6d2cd")));v.add_child(UI.label(s,11,Color("#d1b76c")));return p

func _event_card(e:Dictionary)->Control:
	var p:=_story(String(e["title"]),String(e["text"]),"Local: %s · %d dias" % [String(e["location"]),int(e["days"])])
	var b:=UI.button("ACOMPANHAR EVENTO",Color("#70b8c7"),46);var uid:String=String(e["uid"]);b.pressed.connect(func():event_selected.emit(uid));p.add_child(b);return p

func _mission_card(m:Dictionary)->Control:
	var p:=_story(String(m["title"]),String(m["desc"]),"Progresso %d/%d · %d prata" % [int(m["progress"]),int(m["goal"]),int(m["reward"])])
	var b:=UI.button("MARCAR MISSÃO",Color("#8d9fca"),46);var uid:String=String(m["uid"]);b.pressed.connect(func():mission_selected.emit(uid));p.add_child(b);return p
