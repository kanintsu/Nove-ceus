class_name V08WorldMapScreen
extends Control

signal phase_selected(phase:int)
signal location_selected(key:String)

const Visuals=preload("res://scripts/v08/game_visuals.gd")

var data:Dictionary={}
var accent:=Color("#d2b66d")

func setup(value:Dictionary)->void:
	data=value
	accent=value.get("accent",Color("#d2b66d"))
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("MAPA DOS CINCO CAMINHOS",25,Color("#f3e6bf")); title.position=Vector2(24,18); title.size=Vector2(672,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var subtitle:=Visuals.label("Nenhuma região é bloqueada. O perigo não se adapta a você.",12,Color("#abc2ba")); subtitle.position=Vector2(24,58); subtitle.size=Vector2(672,30); subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(subtitle)

	var positions=[Vector2(155,760),Vector2(490,685),Vector2(205,505),Vector2(510,360),Vector2(340,180)]
	var names=["1. Vale da Nascente","2. Cidade Qinghe","3. Véu Celeste","4. Terras Ancestrais","5. Palácio dos Nove Céus"]
	for i in range(5):
		var b:=Button.new(); b.position=positions[i]-Vector2(105,38); b.size=Vector2(210,76); b.text=names[i]; b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.focus_mode=Control.FOCUS_NONE
		var col:=Visuals.phase_accent(i+1)
		b.add_theme_stylebox_override("normal",Visuals.panel(Color("#0b2229",0.95),col,18,2))
		b.pressed.connect(func(): phase_selected.emit(i+1)); add_child(b)

	var selected:int=int(data.get("selected_phase",1))
	var locs:Array=data.get("locations",[])
	var tray:=PanelContainer.new(); tray.position=Vector2(18,842); tray.size=Vector2(684,212); tray.add_theme_stylebox_override("panel",Visuals.panel(Color("#071a20",0.93),Visuals.phase_accent(selected),20,1)); add_child(tray)
	var grid:=GridContainer.new(); grid.columns=4; grid.add_theme_constant_override("h_separation",7); grid.add_theme_constant_override("v_separation",7); tray.add_child(grid)
	for loc in locs:
		var b:=Button.new(); b.text=String(loc.get("name","Local")); b.custom_minimum_size=Vector2(158,88); b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.add_theme_font_size_override("font_size",11); b.focus_mode=Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal",Visuals.panel(Color("#112c32"),Color(Visuals.phase_accent(selected),0.42),12,1))
		var key:String=String(loc.get("key","")); b.pressed.connect(func(): location_selected.emit(key)); grid.add_child(b)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	var bg:=Color("#102b35"); draw_rect(Rect2(Vector2.ZERO,size),bg,true)
	# clouds / floating continents
	for i in range(18):
		var x=float((i*137)%720); var y=110.0+float((i*83)%760)
		draw_circle(Vector2(x,y),35.0+float(i%4)*9.0,Color("#dbe9e7",0.035))
	var positions=[Vector2(155,760),Vector2(490,685),Vector2(205,505),Vector2(510,360),Vector2(340,180)]
	for i in range(5):
		var p:Vector2=positions[i]; var col:=Visuals.phase_accent(i+1)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-110,35),p+Vector2(-70,-25),p+Vector2(-15,-58),p+Vector2(60,-35),p+Vector2(112,24),p+Vector2(55,58),p+Vector2(-55,62)]),Color(col,0.20))
		draw_arc(p,126,0,TAU,44,Color(col,0.18),2)
		if i<4: draw_line(p,positions[i+1],Color("#d6c27c",0.25),3)
	# celestial ring
	var c:=Vector2(340,180)
	for r in [98.0,125.0,150.0]: draw_arc(c,r,0,TAU,60,Color("#e7d28a",0.10),1)
