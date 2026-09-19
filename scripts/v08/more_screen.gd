class_name V08MoreScreen
extends Control

signal navigate(key:String)

const Visuals=preload("res://scripts/v08/game_visuals.gd")

func setup(_data:Dictionary)->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("OUTROS CAMINHOS",25,Color("#f2e4bd")); title.position=Vector2(18,18); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var items=[
		["MISSÕES E EVENTOS","Contratos, acontecimentos e objetivos","missions",Color("#79bdc7")],
		["SEITA DO CÉU VELADO","Mérito, cargos e política","sect",Color("#d1b568")],
		["CASA E BASE","Residência, jardim, oficina e biblioteca","base",Color("#8bb37c")],
		["REINOS DE CULTIVO","Do corpo mortal ao além do céu","realms",Color("#9a8bd0")],
		["CICLO DE VIDA","Nascimento, envelhecimento, morte e retorno","lifecycle",Color("#c58ca5")],
		["LEGADO","O que atravessa as encarnações","legacy",Color("#d1986b")],
		["CRÔNICA DO MUNDO","Guerras, descobertas e nomes esquecidos","chronicle",Color("#8da3b3")]
	]
	for i in range(items.size()):
		var b:=Button.new(); b.position=Vector2(35,90+i*128); b.size=Vector2(650,108); b.text="%s\n%s" % [items[i][0],items[i][1]]; b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.add_theme_font_size_override("font_size",14)
		b.add_theme_stylebox_override("normal",Visuals.panel(Color("#0e252b"),items[i][3],18,1))
		var key:String=items[i][2]; b.pressed.connect(func():navigate.emit(key)); add_child(b)
