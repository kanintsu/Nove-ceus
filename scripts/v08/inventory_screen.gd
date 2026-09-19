class_name V08InventoryScreen
extends Control

signal inspect(item:Dictionary)

const Visuals=preload("res://scripts/v08/game_visuals.gd")
const Tile=preload("res://scripts/mobile/inventory_tile.gd")
const Character=preload("res://scripts/v08/character_figure.gd")

var data:Dictionary={}

func setup(value:Dictionary)->void:
	data=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var accent:Color=data.get("accent",Color("#d2b66d"))
	var title:=Visuals.label("INVENTÁRIO E EQUIPAMENTO",25,Color("#f1e5c2")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)

	var equipment:=PanelContainer.new(); equipment.position=Vector2(18,66); equipment.size=Vector2(684,350); equipment.add_theme_stylebox_override("panel",Visuals.panel(Color("#0b2228"),Color(accent,0.45),20,1)); add_child(equipment)
	var char:=Character.new(); char.setup(int(data.get("realm_index",0)),int(data.get("phase",1)),accent); char.position=Vector2(210,-70); char.size=Vector2(260,420); add_child(char)
	var slots=[Vector2(30,90),Vector2(30,180),Vector2(30,270),Vector2(574,90),Vector2(574,180),Vector2(574,270)]
	var labels=["ARMA","ARMADURA","BOTAS","ANEL","TALISMÃ","RELÍQUIA"]
	for i in range(slots.size()):
		var p:=PanelContainer.new(); p.position=Vector2(18,66)+slots[i]; p.size=Vector2(80,70); p.add_theme_stylebox_override("panel",Visuals.panel(Color("#143039"),Color(accent,0.38),12,1)); add_child(p)
		var l:=Visuals.label(labels[i],10,Color("#cbd7d2")); l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; p.add_child(l)

	var tabs:=HBoxContainer.new(); tabs.position=Vector2(18,432); tabs.size=Vector2(684,48); tabs.add_theme_constant_override("separation",5); add_child(tabs)
	for t in ["TODOS","EQUIP.","ERVAS","MANUAIS","TESOUROS"]:
		var b:=Button.new(); b.text=t; b.custom_minimum_size=Vector2(132,46); tabs.add_child(b)

	var scroll:=ScrollContainer.new(); scroll.position=Vector2(18,492); scroll.size=Vector2(684,558); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var grid:=GridContainer.new(); grid.columns=3; grid.add_theme_constant_override("h_separation",8); grid.add_theme_constant_override("v_separation",8); scroll.add_child(grid)
	for item in data.get("items",[]):
		var tile:=Tile.new(); tile.setup(item); tile.inspect_requested.connect(func(x):inspect.emit(x)); grid.add_child(tile)
