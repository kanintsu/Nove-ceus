class_name RebornLegacyScreen
extends Control

signal reincarnate()

const UI=preload("res://scripts/ui/ui.gd")
var state:RebornGameState

func setup(game_state:RebornGameState)->void:
	state=game_state
	queue_redraw()
	_build()

func _build()->void:
	for c in get_children():c.queue_free()
	var title:=UI.label("LEGADO ENTRE VIDAS",27,Color("#f1e0ba"))
	title.position=Vector2(20,18);title.size=Vector2(680,42);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(title)
	var quote:=UI.label("Cada vida é uma página. O Dao é o livro.",15,Color("#cbd5cf"))
	quote.position=Vector2(80,80);quote.size=Vector2(560,54);quote.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(quote)
	var items=[["DEIXE TÉCNICAS","Métodos criados podem sobreviver ao corpo."],["DEIXE ITENS","Armas, relíquias e propriedades permanecem no mundo."],["FORME UMA LINHAGEM","Filhos, discípulos e clãs podem atravessar séculos."],["INFLUENCIE FACÇÕES","Seitas, cidades e famílias lembram antigas escolhas."],["TORNE-SE UMA LENDA","Uma próxima vida pode ouvir histórias sobre você."]]
	for i in range(items.size()):
		var p:=PanelContainer.new();p.position=Vector2(70,175+i*128);p.size=Vector2(580,104)
		p.add_theme_stylebox_override("panel",UI.panel(Color("#0c242b"),Color("#d1a06b",0.42),18,1));add_child(p)
		var v:=VBoxContainer.new();p.add_child(v)
		v.add_child(UI.label(String(items[i][0]),17,Color("#e9ddb9")))
		v.add_child(UI.label(String(items[i][1]),12,Color("#b9cbc4")))
	var r:=UI.button("GIRAR A RODA DA REENCARNAÇÃO",Color("#d1a06b"),72)
	r.position=Vector2(150,860);r.size=Vector2(420,72);r.pressed.connect(func():reincarnate.emit());add_child(r)

func _notification(what:int)->void:
	if what!=NOTIFICATION_DRAW:return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#121d29"),true)
	var c:=Vector2(610,180)
	for r in [65.0,92.0,122.0,158.0]:
		draw_arc(c,r,0,TAU,64,Color("#d1a06b",0.05),1.5)
