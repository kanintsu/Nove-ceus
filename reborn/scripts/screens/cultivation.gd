class_name RebornCultivationScreen
extends Control

signal meditate(mode:String)
signal breakthrough()
signal open_realms()

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var accent:=Color("#75d3df")
	var title:=UI.label("SISTEMA DE CULTIVO",27,Color("#f1e2b8"));title.position=Vector2(20,20);title.size=Vector2(680,42);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var realm:=UI.label(state.current_realm(),20,accent);realm.position=Vector2(20,76);realm.size=Vector2(680,34);realm.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(realm)

	var stats:=PanelContainer.new();stats.position=Vector2(28,590);stats.size=Vector2(664,138);stats.add_theme_stylebox_override("panel",UI.panel(Color("#0a222a",0.96),Color(accent,0.44),18,1));add_child(stats)
	var sv:=VBoxContainer.new();stats.add_child(sv)
	sv.add_child(UI.label("Meridianos %.0f%%  ·  Dantian %s  ·  Progresso %.1f%%" % [state.meridian_integrity*100.0,"Estável" if state.qi_awakened else "Adormecido",state.cultivation_progress],14,Color("#d4e0db")))
	sv.add_child(UI.label("Dao %.0f  ·  Qi local %.2f  ·  Vontade %.0f" % [state.dao,float(state.current_location()["qi"]),state.willpower],13,Color("#9fcac2")))
	sv.add_child(UI.label("Cultivar rápido demais pode ferir sua base. Avançar não é um clique sem consequência.",12,Color("#b9c6c1")))

	var modes=[["CIRCULAÇÃO SEGURA","safe"],["COMPRIMIR QI","compress"],["TEMPERAR MERIDIANOS","temper"],["CONTEMPLAR DAO","insight"],["ABSORÇÃO IMPRUDENTE","reckless"]]
	for i in range(modes.size()):
		var b:=UI.button(modes[i][0],accent,64);b.position=Vector2(28+(i%2)*340,750+int(i/2)*74);b.size=Vector2(324,62);var key:String=modes[i][1];b.pressed.connect(func():meditate.emit(key));add_child(b)
	var realms:=UI.button("VER TODOS OS REINOS",Color("#9b8cd2"),66);realms.position=Vector2(28,980);realms.size=Vector2(324,66);realms.pressed.connect(func():open_realms.emit());add_child(realms)
	var br:=UI.button("ROMPER O GARGALO",Color("#d7b668"),66);br.position=Vector2(368,980);br.size=Vector2(324,66);br.disabled=state.cultivation_progress<100.0;br.pressed.connect(func():breakthrough.emit());add_child(br)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#081d2a"),true)
	var c:=Vector2(size.x*0.5,335)
	for r in [185.0,150.0,118.0]:
		draw_circle(c,r,Color("#65d2df",0.018));draw_arc(c,r,0,TAU,64,Color("#76d9e4",0.08),1)
	# seated silhouette
	draw_circle(c+Vector2(0,-102),28,Color("#caa081"))
	draw_colored_polygon(PackedVector2Array([c+Vector2(-34,-104),c+Vector2(-18,-145),c+Vector2(10,-151),c+Vector2(37,-111),c+Vector2(18,-82)]),Color("#162129"))
	draw_colored_polygon(PackedVector2Array([c+Vector2(-78,115),c+Vector2(-48,-54),c+Vector2(-18,-62),c+Vector2(0,-30),c+Vector2(18,-62),c+Vector2(48,-54),c+Vector2(78,115)]),Color("#315b70"))
	draw_arc(c+Vector2(-78,110),62,3.2,5.9,28,Color("#5e899a"),17)
	draw_arc(c+Vector2(78,110),62,3.5,6.0,28,Color("#5e899a"),17)
	var nodes=[c+Vector2(0,-62),c+Vector2(-28,-18),c+Vector2(28,-18),c+Vector2(-38,35),c+Vector2(38,35),c+Vector2(0,78),c+Vector2(0,16)]
	var links=[[0,1],[0,2],[1,3],[2,4],[3,5],[4,5],[1,6],[2,6],[6,5]]
	for link in links:draw_line(nodes[link[0]],nodes[link[1]],Color("#71dae4",0.50),2)
	for i in range(nodes.size()):
		var col:=Color("#efcf6e") if i==6 else Color("#76dce5")
		draw_circle(nodes[i],7,Color(col,0.22));draw_circle(nodes[i],3.5,col)
	var angle:=TAU*(state.cultivation_progress/100.0)
	draw_arc(nodes[6],34,-PI/2,-PI/2+angle,48,Color("#efcf6e"),3)
