class_name V08CultivationScreen
extends Control

signal cultivate(mode:String)
signal breakthrough()
signal open_realms()

const Diagram=preload("res://scripts/mobile/cultivation_diagram.gd")
const Visuals=preload("res://scripts/v08/game_visuals.gd")

var data:Dictionary={}

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var accent:Color=data.get("accent",Color("#75cedd"))
	var title:=Visuals.label("SISTEMA DE CULTIVO",25,Color("#f2e5bf")); title.position=Vector2(20,16); title.size=Vector2(680,40); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)

	var tabs:=HBoxContainer.new(); tabs.position=Vector2(18,66); tabs.size=Vector2(684,48); tabs.add_theme_constant_override("separation",4); add_child(tabs)
	for t in ["MERIDIANOS","TÉCNICAS","DAO","BREAKTHROUGH"]:
		var b:=Button.new(); b.text=t; b.custom_minimum_size=Vector2(168,46); b.disabled=t=="MERIDIANOS"; tabs.add_child(b)

	var diagram:=Diagram.new()
	diagram.setup(int(data.get("realm_index",0)),float(data.get("progress",0.0)),float(data.get("integrity",1.0)),float(data.get("dao",0.0)),accent)
	diagram.position=Vector2(26,132); diagram.size=Vector2(668,330); add_child(diagram)

	var state:=PanelContainer.new(); state.position=Vector2(18,478); state.size=Vector2(684,130); state.add_theme_stylebox_override("panel",Visuals.panel(Color("#0b2229"),Color(accent,0.48),18,1)); add_child(state)
	var v:=VBoxContainer.new(); state.add_child(v)
	v.add_child(Visuals.label(String(data.get("realm","Mortal")),20,Color("#f0e2bd")))
	v.add_child(Visuals.label("Progresso %.1f%%  ·  Dantian %s  ·  Pureza do Qi %.0f%%" % [float(data.get("progress",0.0)),String(data.get("dantian_state","Adormecido")),float(data.get("purity",0.0))],13,Color("#bed3cc")))
	v.add_child(Visuals.label("Qi local: %s  ·  Meridianos %.0f%%  ·  Dao %.0f" % [String(data.get("local_qi","fraca")),float(data.get("integrity",1.0))*100.0,float(data.get("dao",0.0))],13,Color("#9fc6bd")))

	var methods=[
		["CIRCULAÇÃO SEGURA","safe","Controle e estabilidade"],
		["COMPRIMIR QI","compress","Mais rápido, mais risco"],
		["TEMPERAR MERIDIANOS","temper","Fortalece a base"],
		["CONTEMPLAR DAO","insight","Mais compreensão"],
		["ABSORÇÃO IMPRUDENTE","reckless","Grande ganho, grande risco"]
	]
	for i in range(methods.size()):
		var b:=Button.new(); b.position=Vector2(18+(i%2)*344,628+int(i/2)*80); b.size=Vector2(332,68); b.text="%s\n%s" % [methods[i][0],methods[i][2]]; b.add_theme_font_size_override("font_size",12)
		var mode:String=methods[i][1]; b.pressed.connect(func(): cultivate.emit(mode)); b.add_theme_stylebox_override("normal",Visuals.panel(Color("#10282f"),Color(accent,0.40),15,1)); add_child(b)

	var realms:=Button.new(); realms.position=Vector2(18,878); realms.size=Vector2(332,72); realms.text="VER REINOS DE CULTIVO"; realms.pressed.connect(func():open_realms.emit()); realms.add_theme_stylebox_override("normal",Visuals.panel(Color("#182638"),Color("#899dd0"),16,1)); add_child(realms)
	var br:=Button.new(); br.position=Vector2(370,878); br.size=Vector2(332,72); br.text="ROMPER O GARGALO"; br.disabled=float(data.get("progress",0.0))<100.0; br.pressed.connect(func():breakthrough.emit()); br.add_theme_stylebox_override("normal",Visuals.panel(Color("#30251c"),Color("#d8b769"),16,1)); add_child(br)
