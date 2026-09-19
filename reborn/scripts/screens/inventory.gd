class_name RebornInventoryScreen
extends Control

signal inspect(item:Dictionary)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var accent:=UI.accent_for_phase(state.current_phase())
	var title:=UI.label("INVENTÁRIO E EQUIPAMENTO",26,Color("#f0e3c0"));title.position=Vector2(20,18);title.size=Vector2(680,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)

	var equip:=PanelContainer.new();equip.position=Vector2(20,72);equip.size=Vector2(680,330);equip.add_theme_stylebox_override("panel",UI.panel(Color("#0a2229"),Color(accent,0.42),20,1));add_child(equip)
	var char:=TextureRect.new();char.texture=load("res://assets/character_mortal.svg");char.position=Vector2(220,74);char.size=Vector2(280,325);char.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;char.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;add_child(char)
	var slot_data=[["ARMA",Vector2(42,130)],["ARMADURA",Vector2(42,220)],["BOTAS",Vector2(42,310)],["ANEL",Vector2(570,130)],["TALISMÃ",Vector2(570,220)],["RELÍQUIA",Vector2(570,310)]]
	for entry in slot_data:
		var p:=PanelContainer.new();p.position=entry[1];p.size=Vector2(106,68);p.add_theme_stylebox_override("panel",UI.panel(Color("#133039"),Color(accent,0.42),13,1));add_child(p)
		var l:=UI.label(entry[0],10,Color("#d1d9d5"));l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;p.add_child(l)

	var scroll:=ScrollContainer.new();scroll.position=Vector2(20,430);scroll.size=Vector2(680,610);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	var grid:=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8);scroll.add_child(grid)
	for item in state.inventory:
		var b:=Button.new();b.custom_minimum_size=Vector2(216,132);b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.add_theme_font_size_override("font_size",12)
		var rarity:=String(item["rarity"]);var col:=_rarity(rarity)
		b.text="%s\n%s ×%d\n%s" % [_symbol(String(item["kind"])),String(item["name"]),int(item["qty"]),rarity]
		b.add_theme_stylebox_override("normal",UI.panel(Color("#102830"),Color(col,0.72),14,2))
		var captured:Dictionary=item;b.pressed.connect(func():inspect.emit(captured));grid.add_child(b)

func _rarity(r:String)->Color:
	match r:
		"Incomum":return Color("#71b48e")
		"Raro":return Color("#70a9db")
		"Épico":return Color("#a47bd2")
		"Lendário":return Color("#daa95d")
		_:return Color("#9ca9a4")

func _symbol(kind:String)->String:
	match kind:
		"Erva":return "❧"
		"Manual":return "冊"
		"Equipamento":return "⚔"
		"Comida":return "◌"
		_:return "◇"
