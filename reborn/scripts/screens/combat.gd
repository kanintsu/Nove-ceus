class_name RebornCombatScreen
extends Control

signal act(action:String)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	if state.combat.is_empty():return
	var title:=UI.label(String(state.combat["enemy"]),24,Color("#f0ddbd"));title.position=Vector2(20,20);title.size=Vector2(680,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var hp:=ProgressBar.new();hp.position=Vector2(90,70);hp.size=Vector2(540,24);hp.max_value=float(state.combat["enemy_max_hp"]);hp.value=float(state.combat["enemy_hp"]);add_child(hp)
	var intent:=UI.label("A criatura prepara o próximo movimento. Observe antes de agir.",13,Color("#e8a28a"));intent.position=Vector2(60,105);intent.size=Vector2(600,50);intent.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(intent)
	var actions=[["ATACAR","strike"],["DEFENDER","guard"],["OBSERVAR","observe"],["TÉCNICA","technique"],["FUGIR","flee"]]
	for i in range(actions.size()):
		var b:=UI.button(actions[i][0],Color("#c78669"),66);b.position=Vector2(20+(i%3)*226,820+int(i/3)*78);b.size=Vector2(214,66);var key:String=actions[i][1];b.pressed.connect(func():act.emit(key));add_child(b)
	var stat:=PanelContainer.new();stat.position=Vector2(20,985);stat.size=Vector2(680,78);stat.add_theme_stylebox_override("panel",UI.panel(Color("#091d24"),Color("#7c938c",0.44),14,1));add_child(stat)
	stat.add_child(UI.label("HP %d/%d · Foco %d · Qi %d\n%s" % [int(state.combat["player_hp"]),int(state.combat["player_max_hp"]),int(state.combat["focus"]),int(state.combat["qi"]),String(state.combat["log"])],13,Color("#d4ded9")))

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#101923"),true)
	for layer in range(3):
		var base:=470.0+layer*75.0
		draw_colored_polygon(PackedVector2Array([Vector2(0,base),Vector2(150,190+layer*35),Vector2(300,base-30),Vector2(520,145+layer*50),Vector2(720,base),Vector2(720,760),Vector2(0,760)]),Color("#273442",0.30+0.12*layer))
	var c:=Vector2(360,470)
	draw_circle(c+Vector2(0,-110),48,Color("#10161d"))
	draw_colored_polygon(PackedVector2Array([c+Vector2(-125,150),c+Vector2(-75,-75),c+Vector2(0,-45),c+Vector2(75,-75),c+Vector2(125,150)]),Color("#10161d"))
	draw_circle(c+Vector2(-17,-116),5,Color("#6aaeff"));draw_circle(c+Vector2(17,-116),5,Color("#6aaeff"))
	for r in [95.0,132.0,165.0]:draw_arc(c+Vector2(0,-45),r,-2.7,-0.3,30,Color("#6e8fff",0.10),2)
