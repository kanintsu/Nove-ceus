class_name RebornHomeScreen
extends Control

signal navigate(key:String)
signal world_action(action_key:String)
signal open_event(uid:String)

const UI=preload("res://scripts/ui/ui.gd")
const WorldArt=preload("res://scripts/ui/world_art.gd")

var state:RebornGameState
var accent:=Color("#d9bd72")

func setup(game_state:RebornGameState)->void:
	state=game_state
	accent=UI.accent_for_phase(state.current_phase())
	_build()

func _build()->void:
	for c in get_children():c.queue_free()

	var art:=WorldArt.new()
	art.setup(state.current_phase(),String(state.current_location()["kind"]))
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(art)

	var logo:=TextureRect.new()
	logo.texture=load("res://assets/logo.svg")
	logo.position=Vector2(24,18)
	logo.size=Vector2(270,96)
	logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(logo)

	var motto:=UI.label("PEQUENAS VIDAS TAMBÉM\nILUMINAM GRANDES CAMINHOS",11,Color("#d7ddd4",0.82))
	motto.position=Vector2(470,36); motto.size=Vector2(220,60); motto.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	add_child(motto)

	var profile:=PanelContainer.new()
	profile.position=Vector2(26,118); profile.size=Vector2(668,172)
	profile.add_theme_stylebox_override("panel",UI.panel(Color("#071b21",0.92),Color(accent,0.76),28,2))
	add_child(profile)
	var pm:=MarginContainer.new()
	for key in ["margin_left","margin_right","margin_top","margin_bottom"]:pm.add_theme_constant_override(key,16)
	profile.add_child(pm)
	var row:=HBoxContainer.new(); row.add_theme_constant_override("separation",14); pm.add_child(row)

	var portrait:=TextureRect.new()
	portrait.texture=load("res://assets/character_mortal.svg")
	portrait.custom_minimum_size=Vector2(112,132)
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(portrait)

	var info:=VBoxContainer.new(); info.size_flags_horizontal=Control.SIZE_EXPAND_FILL; info.add_theme_constant_override("separation",3); row.add_child(info)
	info.add_child(UI.label("FASE %d / 5  ·  %s" % [state.current_phase(),String(state.current_location()["name"])],12,accent))
	info.add_child(UI.label("VIDA %d  ·  %s" % [state.life_index,state.current_realm()],28,Color("#f2e5c2")))
	info.add_child(UI.label("Ano %d · Dia %d   |   %d anos" % [state.year,state.day,state.age],14,Color("#d0ddd7")))
	info.add_child(UI.label("◉ %d prata   ◆ %d pedras   ◇ %.0f Dao   ▤ %.0f%% conhecimento" % [state.silver,state.spirit_stones,state.dao,state.knowledge],13,Color("#a9cfc2")))

	var char:=TextureRect.new()
	char.texture=load("res://assets/character_mortal.svg")
	char.position=Vector2(180,275); char.size=Vector2(360,520)
	char.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	char.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(char)

	var aura:=Control.new()
	aura.position=Vector2(180,275); aura.size=Vector2(360,520)
	aura.mouse_filter=Control.MOUSE_FILTER_IGNORE
	aura.draw.connect(func():
		var cc:=Vector2(180,310)
		for r in [112.0,142.0,174.0]:
			aura.draw_arc(cc,r,0,TAU,64,Color(accent,0.08),1.5)
		if state.qi_awakened:
			aura.draw_arc(cc,126,-2.4,0.7,40,Color("#75dce6",0.42),2.5)
	)
	add_child(aura)
	move_child(aura,char.get_index())

	_build_side_actions()
	_build_lower_hud()

func _build_side_actions()->void:
	var left:=VBoxContainer.new(); left.position=Vector2(18,328); left.size=Vector2(128,332); left.add_theme_constant_override("separation",12); add_child(left)
	for item in [["✦","EVENTOS","missions"],["門","SEITA","sect"],["⌂","BASE","base"],["∞","LEGADO","legacy"]]:
		left.add_child(_side_button(item[0],item[1],item[2]))
	var right:=VBoxContainer.new(); right.position=Vector2(574,328); right.size=Vector2(128,332); right.add_theme_constant_override("separation",12); add_child(right)
	for item in [["天","REINOS","realms"],["山","MAPA","map"],["人","PESSOAS","people"],["袋","BOLSA","inventory"]]:
		right.add_child(_side_button(item[0],item[1],item[2]))

func _side_button(symbol:String,text_value:String,key:String)->Button:
	var b:=Button.new()
	b.text="%s\n%s" % [symbol,text_value]
	b.custom_minimum_size=Vector2(128,72)
	b.add_theme_font_size_override("font_size",12)
	b.focus_mode=Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal",UI.panel(Color("#081d23",0.91),Color(accent,0.42),20,1))
	b.add_theme_stylebox_override("pressed",UI.panel(Color("#15343a",0.98),accent,20,2))
	b.pressed.connect(func():navigate.emit(key))
	return b

func _build_lower_hud()->void:
	var path:=PanelContainer.new()
	path.position=Vector2(108,730); path.size=Vector2(504,94)
	path.add_theme_stylebox_override("panel",UI.panel(Color("#081d23",0.92),Color(accent,0.68),28,2))
	add_child(path)
	var pv:=VBoxContainer.new(); path.add_child(pv)
	var pt:=UI.label("CAMINHO DESTA VIDA",18,Color("#f0deb1")); pt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; pv.add_child(pt)
	var goal:=UI.label("Sobreviver, construir uma vida mortal e descobrir se existe um caminho além do corpo comum.",12,Color("#d2ddd6")); goal.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; pv.add_child(goal)

	var ev:=Button.new()
	ev.position=Vector2(22,844); ev.size=Vector2(326,126)
	var e:Dictionary=state.world_events[0] if not state.world_events.is_empty() else {}
	ev.text="EVENTO DO MUNDO\n%s\n%s" % [String(e.get("title","O mundo está quieto")),String(e.get("location",""))]
	ev.add_theme_font_size_override("font_size",13)
	ev.add_theme_stylebox_override("normal",UI.panel(Color("#0b242b",0.94),Color("#75bdc8",0.68),18,1))
	if not e.is_empty():
		var uid:String=String(e["uid"]); ev.pressed.connect(func():open_event.emit(uid))
	else:ev.disabled=true
	add_child(ev)

	var mission:=Button.new()
	mission.position=Vector2(372,844); mission.size=Vector2(326,126)
	var m:Dictionary=state.missions[0] if not state.missions.is_empty() else {}
	mission.text="MISSÃO MARCADA\n%s\n%d/%d · %d prata" % [String(m.get("title","Nenhuma")),int(m.get("progress",0)),int(m.get("goal",1)),int(m.get("reward",0))]
	mission.add_theme_font_size_override("font_size",13)
	mission.add_theme_stylebox_override("normal",UI.panel(Color("#0b242b",0.94),Color("#8d9fca",0.62),18,1))
	mission.pressed.connect(func():navigate.emit("missions"))
	add_child(mission)

	var actions:=HBoxContainer.new()
	actions.position=Vector2(22,986); actions.size=Vector2(676,68); actions.add_theme_constant_override("separation",8); add_child(actions)
	for entry in [["TRABALHAR","work"],["ESTUDAR","study"],["TREINAR","train"],["RUMORES","rumors"]]:
		var b:=UI.button(entry[0],accent,64)
		b.custom_minimum_size=Vector2(163,64)
		var action:String=entry[1]
		b.pressed.connect(func():world_action.emit(action))
		actions.add_child(b)
