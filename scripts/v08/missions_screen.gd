class_name V08MissionsScreen
extends Control

signal follow_event(uid:String)
signal claim_contract(uid:String)
signal accept_sect(uid:String)
signal claim_sect(uid:String)

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var data:Dictionary={}
var tab:="principais"

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var accent:Color=data.get("accent",Color("#d2b66d"))
	var title:=Visuals.label("MISSÕES E EVENTOS",25,Color("#f1e4be")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var tabs:=HBoxContainer.new(); tabs.position=Vector2(18,66); tabs.size=Vector2(684,48); tabs.add_theme_constant_override("separation",5); add_child(tabs)
	for t in [["principais","PRINCIPAIS"],["sect","SEITA"],["contracts","CONTRATOS"],["world","MUNDO"]]:
		var b:=Button.new(); b.text=t[1]; b.custom_minimum_size=Vector2(167,46); b.disabled=tab==t[0]; var key:String=t[0]; b.pressed.connect(func():tab=key; _build()); tabs.add_child(b)
	var scroll:=ScrollContainer.new(); scroll.position=Vector2(18,128); scroll.size=Vector2(684,912); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var v:=VBoxContainer.new(); v.custom_minimum_size=Vector2(660,0); v.add_theme_constant_override("separation",10); scroll.add_child(v)
	match tab:
		"world":
			for e in data.get("events",[]): v.add_child(_event_card(e))
		"contracts":
			for c in data.get("contracts",[]): v.add_child(_contract_card(c))
		"sect":
			for m in data.get("sect_missions",[]): v.add_child(_sect_card(m))
		_:
			v.add_child(_story_card("O DESPERTAR","Descubra se esta vida possui um caminho espiritual.","Em andamento",Color("#70b6cc")))
			v.add_child(_story_card("SINAIS DO VALE","Investigue movimentações incomuns perto da Nascente.","Opcional",Color("#c5a45f")))
			v.add_child(_story_card("PROVA DA SEITA","Conquiste mérito suficiente para mudar sua posição.","Longo prazo",Color("#9c78c9")))
			v.add_child(_story_card("RUÍNAS ANCESTRAIS","Descubra o que restou de Lianshi.","Perigoso",Color("#c46e62")))
			v.add_child(_story_card("O CAMINHO CELESTIAL","Alcance o topo dos Nove Céus.","Destino",Color("#d6bb68")))

func _story_card(title:String,desc:String,state:String,col:Color)->Control:
	var p:=PanelContainer.new(); p.custom_minimum_size=Vector2(0,108); p.add_theme_stylebox_override("panel",Visuals.panel(Color("#0d252c"),Color(col,0.55),16,1))
	var row:=HBoxContainer.new(); p.add_child(row)
	var icon:=Label.new(); icon.text="◇"; icon.custom_minimum_size=Vector2(70,0); icon.add_theme_font_size_override("font_size",32); icon.modulate=col; icon.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; icon.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; row.add_child(icon)
	var box:=VBoxContainer.new(); box.size_flags_horizontal=Control.SIZE_EXPAND_FILL; row.add_child(box)
	box.add_child(Visuals.label(title,17,Color("#eee2c3"))); box.add_child(Visuals.label(desc,13,Color("#c7d3ce"))); box.add_child(Visuals.label(state,11,col))
	return p

func _event_card(e:Dictionary)->Control:
	var p:=_story_card(String(e.get("title","Evento")),String(e.get("text","")),str(e.get("remaining",""))+" dias",Color("#76bdc8"))
	var b:=Button.new(); b.text="ACOMPANHAR"; b.custom_minimum_size=Vector2(130,44); var uid:String=String(e.get("uid","")); b.pressed.connect(func():follow_event.emit(uid)); p.add_child(b); return p

func _contract_card(c:Dictionary)->Control:
	var state:="%d/%d" % [int(c.get("progress",0)),int(c.get("goal",1))]
	var p:=_story_card(String(c.get("title","Contrato")),String(c.get("text","")),state,Color("#8ea3c7"))
	if bool(c.get("completed",false)) and not bool(c.get("claimed",false)):
		var b:=Button.new(); b.text="RECEBER"; var uid:String=String(c.get("uid","")); b.pressed.connect(func():claim_contract.emit(uid)); p.add_child(b)
	return p

func _sect_card(m:Dictionary)->Control:
	var p:=_story_card(String(m.get("title","Missão da Seita")),String(m.get("text","")),"%d/%d" % [int(m.get("progress",0)),int(m.get("goal",1))],Color("#d1b568"))
	var uid:String=String(m.get("uid",""))
	if bool(m.get("completed",false)) and not bool(m.get("claimed",false)):
		var b:=Button.new(); b.text="RECEBER MÉRITO"; b.pressed.connect(func():claim_sect.emit(uid)); p.add_child(b)
	elif not bool(m.get("accepted",false)):
		var b:=Button.new(); b.text="ACEITAR"; b.pressed.connect(func():accept_sect.emit(uid)); p.add_child(b)
	return p
