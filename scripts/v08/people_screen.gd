class_name V08PeopleScreen
extends Control

signal interact(person:Dictionary,action:String)

const Visuals=preload("res://scripts/v08/game_visuals.gd")
const Character=preload("res://scripts/v08/character_figure.gd")

var people:Array=[]
var selected:=0
var accent:=Color("#c58ca5")

func setup(value:Dictionary)->void:
	people=value.get("people",[])
	selected=clampi(int(value.get("selected",0)),0,maxi(0,people.size()-1))
	accent=value.get("accent",Color("#c58ca5"))
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build()->void:
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("PERSONAGENS E RELAÇÕES",25,Color("#f2e3c1")); title.position=Vector2(18,14); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	if people.is_empty():
		var empty:=Visuals.label("Nenhuma pessoa importante atravessou seu caminho ainda.",16,Color("#c5d1cc")); empty.position=Vector2(70,260); empty.size=Vector2(580,100); empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(empty); return

	var p:Dictionary=people[selected]
	var char:=Character.new(); char.setup(int(p.get("realm_index",0)),1,accent,selected%2); char.position=Vector2(18,130); char.size=Vector2(320,520); add_child(char)

	var panel:=PanelContainer.new(); panel.position=Vector2(330,100); panel.size=Vector2(372,410); panel.add_theme_stylebox_override("panel",Visuals.panel(Color("#0b2229"),Color(accent,0.52),20,1)); add_child(panel)
	var v:=VBoxContainer.new(); panel.add_child(v)
	v.add_child(Visuals.label(String(p.get("name","Desconhecido")),24,Color("#f0dfbd")))
	v.add_child(Visuals.label("%d anos · %s" % [int(p.get("age",0)),String(p.get("role","mortal"))],13,Color("#bcd0c8")))
	v.add_child(Visuals.label("Relação: %s" % String(p.get("relation","conhecido")),13,Color("#c9b3c2")))
	v.add_child(Visuals.label("Caminho: %s" % String(p.get("path","mortal")),13,Color("#b7c8c4")))
	v.add_child(Visuals.label("Vínculo %d   ·   Confiança %d" % [int(p.get("bond",0)),int(p.get("trust",0))],13,Color("#e0bdca")))
	v.add_child(Visuals.label("\n%s" % String(p.get("story","Uma vida própria continua mesmo longe de você.")),13,Color("#d5dcd7")))

	var actions=[["CONVERSAR","talk"],["ENSINAR","teach"],["TREINAR JUNTO","train"],["APOIAR","support"]]
	for i in range(actions.size()):
		var b:=Button.new(); b.position=Vector2(350+(i%2)*174,532+int(i/2)*72); b.size=Vector2(160,62); b.text=actions[i][0]; b.add_theme_stylebox_override("normal",Visuals.panel(Color("#132c32"),Color(accent,0.42),14,1)); var act:String=actions[i][1]; b.pressed.connect(func():interact.emit(p,act)); add_child(b)

	var strip:=HBoxContainer.new(); strip.position=Vector2(18,720); strip.size=Vector2(684,110); strip.add_theme_constant_override("separation",6); add_child(strip)
	for i in range(people.size()):
		var b:=Button.new(); b.text=String(people[i].get("name","?")); b.custom_minimum_size=Vector2(130,84); b.disabled=i==selected; var idx:=i; b.pressed.connect(func(): selected=idx; _build()); strip.add_child(b)
