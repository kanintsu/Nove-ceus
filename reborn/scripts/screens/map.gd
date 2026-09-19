class_name RebornMapScreen
extends Control

signal travel(index:int)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("MAPA DOS NOVE CÉUS",27,Color("#f1dfb5")); title.position=Vector2(20,22); title.size=Vector2(680,44); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var sub:=UI.label("Cinco grandes regiões. Nenhuma parede invisível.",12,Color("#adc4bd")); sub.position=Vector2(20,64); sub.size=Vector2(680,28); sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(sub)

	var positions=[Vector2(155,845),Vector2(510,730),Vector2(210,540),Vector2(525,380),Vector2(355,190)]
	for i in range(state.LOCATIONS.size()):
		var loc:Dictionary=state.LOCATIONS[i]
		var b:=Button.new(); b.position=positions[i]-Vector2(108,42); b.size=Vector2(216,84)
		b.text="%d · %s\n%s" % [i+1,String(loc["name"]),String(loc["danger"])]
		b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.add_theme_font_size_override("font_size",12)
		var accent:=UI.accent_for_phase(int(loc["phase"]))
		b.add_theme_stylebox_override("normal",UI.panel(Color("#0a2229",0.94),accent,20,2 if i==state.location_index else 1))
		var idx:=i;b.pressed.connect(func():travel.emit(idx));add_child(b)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	var bg:=Color("#0d2630");draw_rect(Rect2(Vector2.ZERO,size),bg,true)
	for i in range(26):
		var x:=float((i*149)%720);var y:=100.0+float((i*97)%920)
		draw_circle(Vector2(x,y),34+float(i%4)*12,Color("#eef3ed",0.035))
	var positions=[Vector2(155,845),Vector2(510,730),Vector2(210,540),Vector2(525,380),Vector2(355,190)]
	for i in range(5):
		var p:Vector2=positions[i];var col:=UI.accent_for_phase(i+1)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-120,38),p+Vector2(-70,-24),p+Vector2(-18,-62),p+Vector2(52,-45),p+Vector2(120,28),p+Vector2(58,70),p+Vector2(-62,66)]),Color(col,0.16))
		draw_arc(p,135,0,TAU,54,Color(col,0.12),1.5)
		# small pagoda silhouette
		draw_rect(Rect2(p+Vector2(-18,-28),Vector2(36,28)),Color("#10242a"),true)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-35,-28),p+Vector2(0,-48),p+Vector2(35,-28)]),Color(col,0.40))
		if i<4:draw_line(p,positions[i+1],Color("#d6c27c",0.23),3)
	var c:Vector2=positions[4]
	for r in [80.0,105.0,135.0]:draw_arc(c,r,0,TAU,64,Color("#ead17c",0.10),1)
