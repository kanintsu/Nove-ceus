class_name V08CombatScreen
extends Control

signal battle_action(action:String)
signal use_item()

const Visuals=preload("res://scripts/v08/game_visuals.gd")
var battle:Dictionary={}
var accent:=Color("#c96c62")

func setup(value:Dictionary)->void:
	battle=value
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var enemy:Dictionary=battle.get("enemy",{})
	var title:=Visuals.label(String(enemy.get("name","Inimigo")),22,Color("#f0dfc0")); title.position=Vector2(18,18); title.size=Vector2(684,40); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var hp:=ProgressBar.new(); hp.position=Vector2(90,66); hp.size=Vector2(540,24); hp.max_value=float(enemy.get("max_hp",100)); hp.value=float(enemy.get("hp",0)); add_child(hp)
	var intent:=Visuals.label(String(battle.get("intent_text","Intenção desconhecida")),14,Color("#e9a58c")); intent.position=Vector2(60,100); intent.size=Vector2(600,50); intent.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(intent)

	var actions=[["ATACAR","strike"],["DEFENDER","guard"],["FINTAR","feint"],["TÉCNICA","technique"],["OBSERVAR","observe"],["USAR ITEM","item"],["FUGIR","flee"]]
	for i in range(actions.size()):
		var b:=Button.new(); b.position=Vector2(18+(i%4)*171,780+int(i/4)*76); b.size=Vector2(162,64); b.text=actions[i][0]; b.add_theme_stylebox_override("normal",Visuals.panel(Color("#17252c"),Color("#c9906b",0.54),14,1))
		var act:String=actions[i][1]
		if act=="item": b.pressed.connect(func():use_item.emit())
		else: b.pressed.connect(func():battle_action.emit(act))
		add_child(b)

	var stat:=PanelContainer.new(); stat.position=Vector2(18,930); stat.size=Vector2(684,108); stat.add_theme_stylebox_override("panel",Visuals.panel(Color("#0a1d23"),Color("#8aa29b"),14,1)); add_child(stat)
	var l:=Visuals.label("HP %d/%d   ·   Fôlego %d/3   ·   Foco %d   ·   Qi %d/%d\n%s" % [int(battle.get("player_hp",0)),int(battle.get("player_max_hp",0)),int(battle.get("player_stamina",0)),int(battle.get("player_focus",0)),int(battle.get("player_qi",0)),int(battle.get("player_max_qi",0)),String(battle.get("last_text","Observe o inimigo e escolha."))],13,Color("#d4dfda")); stat.add_child(l)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#101923"),true)
	# hostile landscape
	for i in range(3):
		var base:=430.0+i*80
		draw_colored_polygon(PackedVector2Array([Vector2(0,base),Vector2(170,170+i*40),Vector2(300,base-20),Vector2(520,130+i*60),Vector2(720,base),Vector2(720,700),Vector2(0,700)]),Color("#263240",0.34+0.12*i))
	# enemy silhouette
	var c:=Vector2(360,440)
	draw_circle(c+Vector2(0,-115),48,Color("#14171e"))
	draw_colored_polygon(PackedVector2Array([c+Vector2(-115,140),c+Vector2(-70,-80),c+Vector2(0,-45),c+Vector2(70,-80),c+Vector2(115,140)]),Color("#14171e"))
	draw_circle(c+Vector2(-18,-120),5,Color("#6fb5ff")); draw_circle(c+Vector2(18,-120),5,Color("#6fb5ff"))
	for r in [90.0,125.0,160.0]: draw_arc(c+Vector2(0,-50),r,-2.7,-0.4,30,Color("#6c8fff",0.10),2)
