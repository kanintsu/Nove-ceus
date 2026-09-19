class_name V08HomeScreen
extends Control

signal navigate(key:String)
signal action(action_key:String)
signal follow_event(uid:String)

const CharacterFigureScript=preload("res://scripts/v08/character_figure.gd")
const LocationSceneScript=preload("res://scripts/v08/location_scene.gd")
const Visuals=preload("res://scripts/v08/game_visuals.gd")

var data:Dictionary={}
var accent:=Color("#d2b66d")

func setup(value:Dictionary)->void:
	data=value
	accent=value.get("accent",Color("#d2b66d"))
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var phase:int=int(data.get("phase_number",1))
	var location:Dictionary=data.get("location",{})
	var profile:Dictionary=data.get("profile",{})

	var scene:=LocationSceneScript.new()
	scene.setup(location,phase,accent)
	scene.position=Vector2(0,0)
	scene.size=Vector2(720,690)
	scene.custom_minimum_size=Vector2(720,690)
	add_child(scene)

	var top:=PanelContainer.new()
	top.position=Vector2(18,18); top.size=Vector2(684,138)
	top.add_theme_stylebox_override("panel",Visuals.panel(Color("#071b20",0.91),Color(accent,0.72),22,2))
	add_child(top)
	var tm:=MarginContainer.new()
	for k in ["margin_left","margin_right","margin_top","margin_bottom"]: tm.add_theme_constant_override(k,14)
	top.add_child(tm)
	var row:=HBoxContainer.new(); row.add_theme_constant_override("separation",14); tm.add_child(row)

	var med:=Control.new(); med.custom_minimum_size=Vector2(96,96); med.draw.connect(func(): _draw_medallion(med,profile))
	row.add_child(med)
	var info:=VBoxContainer.new(); info.size_flags_horizontal=Control.SIZE_EXPAND_FILL; info.add_theme_constant_override("separation",2); row.add_child(info)
	var phase_label:=Visuals.label("FASE %d / 5  ·  %s" % [phase,String(data.get("phase_name",""))],12,accent); info.add_child(phase_label)
	var title:=Visuals.label("VIDA %d  ·  %s" % [int(data.get("life_index",1)),String(data.get("realm","Mortal"))],25,Color("#f5e9c7")); info.add_child(title)
	var meta:=Visuals.label("Ano %d · Dia %d   |   %d anos   |   %s" % [int(data.get("year",1)),int(data.get("day",1)),int(data.get("age",16)),String(location.get("name",""))],13,Color("#d6e0d9")); info.add_child(meta)
	var res:=Visuals.label("◉ %d prata   ◆ %d pedras   ◇ %.0f Dao   ▤ %.0f%% conhecimento" % [int(profile.get("silver",0)),int(profile.get("spirit_stones",0)),float(profile.get("dao_insight",0.0)),float(profile.get("worldly_knowledge",0.0))],12,Color("#a8d0c3")); info.add_child(res)

	var char:=CharacterFigureScript.new()
	char.setup(int(profile.get("realm_index",0)),phase,accent)
	char.position=Vector2(220,155); char.size=Vector2(280,500)
	add_child(char)

	# left quick actions
	var left:=VBoxContainer.new(); left.position=Vector2(18,188); left.size=Vector2(116,310); left.add_theme_constant_override("separation",10); add_child(left)
	left.add_child(_quick("✦","EVENTOS","missions"))
	left.add_child(_quick("門","SEITA","sect"))
	left.add_child(_quick("⌂","BASE","base"))
	left.add_child(_quick("◎","LEGADO","legacy"))

	# right quick actions
	var right:=VBoxContainer.new(); right.position=Vector2(586,188); right.size=Vector2(116,310); right.add_theme_constant_override("separation",10); add_child(right)
	right.add_child(_quick("天","REINOS","realms"))
	right.add_child(_quick("山","MAPA","map"))
	right.add_child(_quick("人","PESSOAS","people"))
	right.add_child(_quick("冊","BOLSA","inventory"))

	# current path
	var path:=Button.new(); path.position=Vector2(120,558); path.size=Vector2(480,74)
	path.text="CAMINHO DESTA VIDA  ·  %s" % String(data.get("goal","Sobreviver e escolher um caminho."))
	path.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; path.add_theme_font_size_override("font_size",14); path.focus_mode=Control.FOCUS_NONE
	path.add_theme_stylebox_override("normal",Visuals.panel(Color("#0b242a",0.95),Color(accent,0.84),24,2))
	path.pressed.connect(func(): navigate.emit("chronicle")); add_child(path)

	# event and mission strips
	var event:Dictionary=data.get("event",{})
	var ev:=Button.new(); ev.position=Vector2(18,648); ev.size=Vector2(332,112); ev.focus_mode=Control.FOCUS_NONE
	var ev_title="Nenhum evento urgente"; var ev_desc="O mundo continua se movendo."
	if not event.is_empty():
		ev_title=String(event.get("title","Evento"))
		ev_desc=String(event.get("text",""))
		if ev_desc.length()>70: ev_desc=ev_desc.left(67)+"..."
	ev.text="EVENTO DO MUNDO\n%s\n%s" % [ev_title,ev_desc]; ev.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; ev.add_theme_font_size_override("font_size",12)
	ev.add_theme_stylebox_override("normal",Visuals.panel(Color("#10272e"),Color("#74bcc6"),16,1))
	ev.pressed.connect(func():
		if event.is_empty(): navigate.emit("missions")
		else: follow_event.emit(String(event.get("uid","")))
	); add_child(ev)

	var mission:=Button.new(); mission.position=Vector2(370,648); mission.size=Vector2(332,112); mission.focus_mode=Control.FOCUS_NONE
	mission.text="MISSÃO MARCADA\n%s\n%s" % [String(data.get("mission_title","Sem missão marcada")),String(data.get("mission_progress","Escolha uma missão."))]
	mission.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; mission.add_theme_font_size_override("font_size",12)
	mission.add_theme_stylebox_override("normal",Visuals.panel(Color("#10272e"),Color("#8e9ec7"),16,1))
	mission.pressed.connect(func(): navigate.emit("missions")); add_child(mission)

	# four major playable systems
	var mods=[
		["CULTIVO","Meridianos · Técnicas · Dao","cultivation",Color("#69cddd")],
		["PESSOAS","Vínculos · Família · Discípulos","people",Color("#c58ca5")],
		["CASA E BASE","Oficina · Jardim · Biblioteca","base",Color("#8bb37c")],
		["SEITA","Mérito · Missões · Política","sect",Color("#d1b96c")]
	]
	for i in range(mods.size()):
		var b:=Button.new()
		b.position=Vector2(18+(i%2)*352,780+int(i/2)*108); b.size=Vector2(332,94); b.focus_mode=Control.FOCUS_NONE
		b.text="%s\n%s" % [mods[i][0],mods[i][1]]; b.add_theme_font_size_override("font_size",13)
		b.add_theme_stylebox_override("normal",Visuals.panel(Color("#0d2228",0.97),mods[i][3],16,1))
		var key:String=mods[i][2]; b.pressed.connect(func(): navigate.emit(key)); add_child(b)

	# location actions are gameplay, not menu decoration
	var loc_actions:Array=location.get("actions",[])
	var action_bar:=HBoxContainer.new(); action_bar.position=Vector2(18,1000); action_bar.size=Vector2(684,56); action_bar.add_theme_constant_override("separation",6); add_child(action_bar)
	for i in range(mini(4,loc_actions.size())):
		var act:String=String(loc_actions[i])
		var b:=Button.new(); b.text=_short_action(act); b.custom_minimum_size=Vector2(165,52); b.focus_mode=Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal",Visuals.panel(Color("#112d32"),Color(accent,0.48),14,1))
		b.pressed.connect(func(): action.emit(act)); action_bar.add_child(b)

func _quick(symbol:String,text_value:String,key:String)->Button:
	var b:=Button.new(); b.text="%s\n%s" % [symbol,text_value]; b.custom_minimum_size=Vector2(116,66); b.focus_mode=Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size",11); b.add_theme_stylebox_override("normal",Visuals.panel(Color("#0a2025",0.94),Color(accent,0.46),17,1))
	b.pressed.connect(func(): navigate.emit(key)); return b

func _short_action(a:String)->String:
	var m={"work":"TRABALHAR","study":"ESTUDAR","research":"PESQUISAR","train":"TREINAR","spar":"DUELO","rumors":"RUMORES","travel":"VIAJAR","encounter":"ENCONTROS","relationships":"VÍNCULOS","gather":"COLETAR","meditate":"MEDITAR","hunt":"CAÇAR","explore":"EXPLORAR","trade":"NEGOCIAR","spirit_test":"TESTE QI","auction":"LEILÃO","forge":"FORJAR","rest":"DESCANSAR","sect":"SEITA","trial":"PROVAÇÃO","technique":"TÉCNICAS","alchemy":"ALQUIMIA","comprehend":"DAO"}
	return String(m.get(a,a.to_upper()))

func _draw_medallion(node:Control,p:Dictionary)->void:
	var c:=Vector2(48,48)
	node.draw_circle(c,44,Color("#07161b")); node.draw_arc(c,43,0,TAU,64,accent,2)
	node.draw_circle(c+Vector2(0,-8),15,Color("#c99e7d"))
	node.draw_colored_polygon(PackedVector2Array([c+Vector2(-19,-10),c+Vector2(-8,-30),c+Vector2(8,-31),c+Vector2(20,-10),c+Vector2(9,-1),c+Vector2(-10,-2)]),Color("#172127"))
	node.draw_colored_polygon(PackedVector2Array([c+Vector2(-27,35),c+Vector2(-17,8),c+Vector2(0,17),c+Vector2(17,8),c+Vector2(27,35)]),Color("#526f70"))
	node.draw_string(ThemeDB.fallback_font,Vector2(34,92),str(int(p.get("realm_index",0))),HORIZONTAL_ALIGNMENT_CENTER,28,11,accent)
