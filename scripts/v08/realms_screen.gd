class_name V08RealmsScreen
extends Control

signal cultivate_requested()

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var realms:Array[String]=[]
var current:=0
var accent:=Color("#d2b66d")

func setup(realm_names:Array[String],current_index:int,accent_value:Color)->void:
	realms=realm_names; current=current_index; accent=accent_value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("REINOS DE CULTIVO",26,Color("#f1e4be")); title.position=Vector2(20,18); title.size=Vector2(680,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var sub:=Visuals.label("O reino mede transformação. Não garante vitória.",12,Color("#adc2bb")); sub.position=Vector2(20,58); sub.size=Vector2(680,26); sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(sub)

	var scroll:=ScrollContainer.new(); scroll.position=Vector2(18,100); scroll.size=Vector2(684,930); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var v:=VBoxContainer.new(); v.custom_minimum_size=Vector2(660,0); v.add_theme_constant_override("separation",7); scroll.add_child(v)
	var groups=[
		["REINOS MORTAIS",0,9,Color("#9fa9a4")],
		["REINOS DA FUNDAÇÃO",10,13,Color("#70a9c9")],
		["REINOS TERRESTRES",14,19,Color("#b990d5")],
		["REINOS CELESTIAIS",20,25,Color("#d3ad61")],
		["REINOS IMORTAIS",26,31,Color("#d97886")]
	]
	for g in groups:
		var from:int=int(g[1]); var to:int=mini(int(g[2]),realms.size()-1)
		if from>=realms.size(): continue
		var hdr:=Visuals.label(String(g[0]),14,g[3]); v.add_child(hdr)
		for i in range(from,to+1):
			var row:=PanelContainer.new(); row.custom_minimum_size=Vector2(0,58)
			var border:=accent if i==current else Color(g[3],0.28)
			row.add_theme_stylebox_override("panel",Visuals.panel(Color("#0d252c"),border,14,2 if i==current else 1))
			var h:=HBoxContainer.new(); row.add_child(h)
			var orb:=Control.new(); orb.custom_minimum_size=Vector2(54,54); var idx:=i; var col:Color=g[3]; orb.draw.connect(func(): _draw_orb(orb,idx,col)); h.add_child(orb)
			var name:=Visuals.label(String(realms[i]),15,Color("#e6e0ce")); name.size_flags_horizontal=Control.SIZE_EXPAND_FILL; name.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; h.add_child(name)
			var state:=Visuals.label("ATUAL" if i==current else ("SUPERADO" if i<current else "NÃO ALCANÇADO"),11,accent if i==current else Color("#7e918c")); state.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; h.add_child(state)
			v.add_child(row)

func _draw_orb(node:Control,index:int,col:Color)->void:
	var c:=Vector2(27,27); node.draw_circle(c,17,Color(col,0.12)); node.draw_arc(c,17,0,TAU,30,Color(col,0.72),2)
	if index>0: node.draw_circle(c,5+minf(6,float(index)/5.0),Color(col,0.65))
