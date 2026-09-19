class_name RebornPeopleScreen
extends Control

signal interact(index:int,action:String)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState
var selected:=0

func setup(game_state:RebornGameState)->void:
	state=game_state
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("PERSONAGENS E RELAÇÕES",26,Color("#f2e4c0"));title.position=Vector2(20,18);title.size=Vector2(680,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	if state.people.is_empty():return
	selected=clampi(selected,0,state.people.size()-1)
	var p:Dictionary=state.people[selected]
	var portrait:=TextureRect.new();portrait.texture=load("res://assets/character_mortal.svg");portrait.position=Vector2(18,105);portrait.size=Vector2(320,540);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;add_child(portrait)
	var panel:=PanelContainer.new();panel.position=Vector2(330,105);panel.size=Vector2(370,410);panel.add_theme_stylebox_override("panel",UI.panel(Color("#0c242b"),Color("#c88eaa",0.55),20,1));add_child(panel)
	var v:=VBoxContainer.new();panel.add_child(v)
	v.add_child(UI.label(String(p["name"]),24,Color("#f0dec0")))
	v.add_child(UI.label("%d anos · %s" % [int(p["age"]),String(p["role"])],13,Color("#c6d2cd")))
	v.add_child(UI.label("Caminho: %s" % String(p["path"]),13,Color("#d2b8c6")))
	v.add_child(UI.label("Vínculo %d · Confiança %d" % [int(p["bond"]),int(p["trust"])],13,Color("#e1a9c2")))
	v.add_child(UI.label("\n"+String(p["story"]),13,Color("#d4dbd7")))
	for i in range(4):
		var acts=[["CONVERSAR","talk"],["ENSINAR","teach"],["TREINAR JUNTO","train"],["APOIAR","support"]]
		var b:=UI.button(acts[i][0],Color("#c88eaa"),62);b.position=Vector2(350+(i%2)*174,545+int(i/2)*74);b.size=Vector2(160,62);var idx:=selected;var act:String=acts[i][1];b.pressed.connect(func():interact.emit(idx,act));add_child(b)
	var strip:=HBoxContainer.new();strip.position=Vector2(20,740);strip.size=Vector2(680,110);strip.add_theme_constant_override("separation",8);add_child(strip)
	for i in range(state.people.size()):
		var b:=UI.button(String(state.people[i]["name"]),Color("#c88eaa"),80);b.custom_minimum_size=Vector2(160,80);b.disabled=i==selected;var idx:=i;b.pressed.connect(func():selected=idx;_build());strip.add_child(b)
