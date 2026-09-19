class_name RebornMoreScreen
extends Control

signal navigate(key:String)
signal base_action(action:String)

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState
var mode:="menu"

func setup(game_state:RebornGameState)->void:
	state=game_state
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	if mode=="base":_build_base();return
	if mode=="realms":_build_realms();return
	var title:=UI.label("OUTROS CAMINHOS",26,Color("#f2e4bd"));title.position=Vector2(20,20);title.size=Vector2(680,40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var items:Array[Array]=[["CASA E BASE","Residência, oficina, jardim e biblioteca","base"],["REINOS DE CULTIVO","Do corpo mortal ao além do céu","realms"],["CICLO DE VIDA","Nascimento, envelhecimento, morte e reencarnação","cycle"],["LEGADO","O que permanece depois de uma vida","legacy"],["SEITA DO VÉU CELESTE","Mérito, tarefas e política","sect"]]
	for i in range(items.size()):
		var b:=UI.button("%s\n%s" % [items[i][0],items[i][1]],Color("#d1b76c"),108);b.position=Vector2(36,98+i*132);b.size=Vector2(648,108);var key:String=items[i][2];b.pressed.connect(func():
			if key=="base" or key=="realms":mode=key;_build()
			else:navigate.emit(key)
		);add_child(b)

func _build_base()->void:
	var back:=UI.button("‹ VOLTAR",Color("#8bb37c"),48);back.position=Vector2(20,20);back.size=Vector2(140,48);back.pressed.connect(func():mode="menu";_build());add_child(back)
	var title:=UI.label("CASA E BASE",26,Color("#f2e4bd"));title.position=Vector2(180,20);title.size=Vector2(500,40);add_child(title)
	var buildings:Array[Array]=[["RESIDÊNCIA","rest",Vector2(65,220)],["OFICINA","train",Vector2(415,235)],["JARDIM","work",Vector2(75,500)],["ALQUIMIA","study",Vector2(420,520)],["SALA DE CULTIVO","meditate",Vector2(250,365)],["BIBLIOTECA","study",Vector2(250,720)]]
	for x:Array in buildings:
		var title_text:String=String(x[0])
		var pos:Vector2=x[2]
		var act:String=String(x[1])
		var b:=UI.button(title_text,Color("#8bb37c"),76);b.position=pos;b.size=Vector2(230,76);b.pressed.connect(func():base_action.emit(act));add_child(b)

func _build_realms()->void:
	var back:=UI.button("‹ VOLTAR",Color("#9c8bd2"),48);back.position=Vector2(20,20);back.size=Vector2(140,48);back.pressed.connect(func():mode="menu";_build());add_child(back)
	var title:=UI.label("REINOS DE CULTIVO",26,Color("#f2e4bd"));title.position=Vector2(180,20);title.size=Vector2(500,40);add_child(title)
	var scroll:=ScrollContainer.new();scroll.position=Vector2(24,88);scroll.size=Vector2(672,965);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	var v:=VBoxContainer.new();v.custom_minimum_size=Vector2(650,0);v.add_theme_constant_override("separation",7);scroll.add_child(v)
	for i in range(state.REALMS.size()):
		var p:=PanelContainer.new();p.custom_minimum_size=Vector2(0,56);var col:=Color("#d1b76c") if i==state.realm_index else Color("#687a82");p.add_theme_stylebox_override("panel",UI.panel(Color("#0e252c"),Color(col,0.50),13,2 if i==state.realm_index else 1));var row:=HBoxContainer.new();p.add_child(row);var idx:=UI.label("%02d" % i,12,col);idx.custom_minimum_size=Vector2(50,0);idx.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(idx);var name:=UI.label(state.REALMS[i],14,Color("#e2ddd0"));name.size_flags_horizontal=Control.SIZE_EXPAND_FILL;name.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(name);row.add_child(UI.label("ATUAL" if i==state.realm_index else ("SUPERADO" if i<state.realm_index else "—"),11,col));v.add_child(p)
