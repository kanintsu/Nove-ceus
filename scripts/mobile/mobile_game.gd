extends Control

const WorldStateScript = preload("res://scripts/core/world_state.gd")
const BirthSystemScript = preload("res://scripts/core/birth_system.gd")

const REALMS: Array[String] = [
	"Mortal",
	"Refinamento de Qi I", "Refinamento de Qi II", "Refinamento de Qi III",
	"Refinamento de Qi IV", "Refinamento de Qi V", "Refinamento de Qi VI",
	"Refinamento de Qi VII", "Refinamento de Qi VIII", "Refinamento de Qi IX",
	"Estabelecimento de Fundação · Inicial",
	"Estabelecimento de Fundação · Médio",
	"Estabelecimento de Fundação · Tardio",
	"Estabelecimento de Fundação · Pico",
	"Núcleo Dourado · Inicial", "Núcleo Dourado · Médio", "Núcleo Dourado · Tardio",
	"Alma Nascente · Inicial", "Alma Nascente · Médio", "Alma Nascente · Tardio",
	"Transformação da Alma", "Refinamento do Vazio", "Transcendência"
]

const LOCATIONS := {
	"village": {
		"name": "Vila da Nascente",
		"desc": "Uma vila mortal cercada por campos e rumores sobre imortais.",
		"danger": "Baixo",
		"qi": 0.35,
		"travel": 0
	},
	"city": {
		"name": "Cidade Qinghe",
		"desc": "Mercadores, estudiosos, famílias marciais e um antigo teste espiritual.",
		"danger": "Baixo",
		"qi": 0.65,
		"travel": 3
	},
	"forest": {
		"name": "Floresta da Névoa Fria",
		"desc": "Ervas raras, caçadores desaparecidos e presenças que um mortal deve evitar.",
		"danger": "Médio",
		"qi": 1.15,
		"travel": 2
	},
	"ruins": {
		"name": "Ruínas de Lianshi",
		"desc": "Pedras antigas, inscrições partidas e oportunidades que podem ser armadilhas.",
		"danger": "Alto",
		"qi": 1.45,
		"travel": 5
	},
	"mountain": {
		"name": "Montanha do Véu",
		"desc": "Território de besta espiritual. O Qi aqui é denso, mas o preço pode ser a vida.",
		"danger": "Extremo",
		"qi": 2.2,
		"travel": 7
	}
}

var world_state: WorldState
var rng := RandomNumberGenerator.new()
var current_screen := "life"
var current_location := "village"

var background: TextureRect
var header_title: Label
var header_meta: Label
var header_resource: Label
var content_scroll: ScrollContainer
var content: VBoxContainer
var bottom_nav: HBoxContainer
var toast: Label
var overlay: ColorRect
var overlay_box: VBoxContainer
var screen_title: Label

var nav_buttons: Dictionary = {}
var last_year_simulated := 137

func _ready() -> void:
	world_state = WorldStateScript.new()
	add_child(world_state)
	world_state.initialize()
	rng.seed = world_state.world_seed ^ 0x42C0FFEE
	last_year_simulated = world_state.world_year
	world_state.calendar_changed.connect(_on_calendar_changed)
	world_state.rare_encounter_changed.connect(_on_rare_encounter_changed)
	_initialize_life_runtime()
	_build_shell()
	_show_screen("life")
	_show_toast("Vida %d começou. O mundo não promete que você será um cultivador." % world_state.incarnation_index)

func _initialize_life_runtime() -> void:
	var life := world_state.current_life
	if not life.has("realm_index"):
		life["realm_index"] = 0
	if not life.has("cultivation_progress"):
		life["cultivation_progress"] = 0.0
	if not life.has("silver"):
		life["silver"] = 36
	if not life.has("spirit_stones"):
		life["spirit_stones"] = 0
	if not life.has("inventory"):
		life["inventory"] = [
			{"name":"Provisões simples","qty":3,"kind":"Comida","desc":"Comida suficiente para alguns dias de estrada."},
			{"name":"Faca de ferro","qty":1,"kind":"Ferramenta","desc":"Uma lâmina mortal. Útil para trabalho e sobrevivência."},
			{"name":"Tecido comum","qty":2,"kind":"Material","desc":"Tecido simples usado em reparos e trocas."}
		]

func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = _create_mobile_theme()
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.035, 0.045, 0.16)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var header := PanelContainer.new()
	header.position = Vector2(18, 18)
	header.size = Vector2(684, 132)
	header.add_theme_stylebox_override("panel", _panel_style(Color(0.055,0.075,0.09,0.90), 18))
	add_child(header)
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 2)
	header.add_child(hv)
	header_title = _label("", 24, Color(0.96,0.90,0.72))
	hv.add_child(header_title)
	header_meta = _label("", 15, Color(0.82,0.86,0.86))
	hv.add_child(header_meta)
	header_resource = _label("", 14, Color(0.67,0.81,0.78))
	hv.add_child(header_resource)

	screen_title = _label("", 28, Color(0.98,0.94,0.82))
	screen_title.position = Vector2(28, 166)
	screen_title.size = Vector2(664, 44)
	screen_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(screen_title)

	content_scroll = ScrollContainer.new()
	content_scroll.position = Vector2(18, 218)
	content_scroll.size = Vector2(684, 890)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(content_scroll)
	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(668, 0)
	content.add_theme_constant_override("separation", 14)
	content_scroll.add_child(content)

	bottom_nav = HBoxContainer.new()
	bottom_nav.position = Vector2(12, 1122)
	bottom_nav.size = Vector2(696, 142)
	bottom_nav.add_theme_constant_override("separation", 6)
	add_child(bottom_nav)
	for data in [
		["life","VIDA"], ["map","MAPA"], ["cultivation","CULTIVO"],
		["people","PESSOAS"], ["inventory","BOLSA"], ["chronicle","CRÔNICA"]
	]:
		var key: String = data[0]
		var btn := Button.new()
		btn.text = data[1]
		btn.custom_minimum_size = Vector2(111, 112)
		btn.add_theme_font_size_override("font_size", 13)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_show_screen.bind(key))
		bottom_nav.add_child(btn)
		nav_buttons[key] = btn

	toast = _label("", 15, Color.WHITE)
	toast.position = Vector2(45, 1040)
	toast.size = Vector2(630, 64)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_stylebox_override("normal", _panel_style(Color(0.03,0.045,0.055,0.93), 15))
	toast.visible = false
	add_child(toast)

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01,0.015,0.02,0.88)
	overlay.visible = false
	overlay.z_index = 100
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.065,0.08,0.09,0.98), 22))
	center.add_child(panel)
	overlay_box = VBoxContainer.new()
	overlay_box.add_theme_constant_override("separation", 14)
	panel.add_child(overlay_box)

func _show_screen(screen_key: String) -> void:
	current_screen = screen_key
	_clear_content()
	for key in nav_buttons.keys():
		var button: Button = nav_buttons[key]
		button.disabled = key == screen_key
	match screen_key:
		"life":
			_render_life()
		"map":
			_render_map()
		"cultivation":
			_render_cultivation()
		"people":
			_render_people()
		"inventory":
			_render_inventory()
		"chronicle":
			_render_chronicle()
	_update_header()

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()

func _set_background(path: String) -> void:
	background.texture = load(path)

func _update_header() -> void:
	var life := world_state.current_life
	var age := world_state.current_age()
	var realm_index := int(life.get("realm_index", 0))
	header_title.text = "VIDA %d  ·  %s" % [world_state.incarnation_index, REALMS[clampi(realm_index,0,REALMS.size()-1)]]
	header_meta.text = "Ano %d · Dia %d  |  %d anos  |  %s" % [world_state.world_year, world_state.world_day, age, LOCATIONS[current_location]["name"]]
	header_resource.text = "Prata %d   ·   Pedras espirituais %d   ·   Conhecimento %.0f%%" % [
		int(life.get("silver",0)), int(life.get("spirit_stones",0)), float(life.get("worldly_knowledge",0.0))
	]

func _render_life() -> void:
	_set_background("res://assets/mobile/bg_home.svg")
	screen_title.text = "CAMINHO DESTA VIDA"

	var avatar_wrap := CenterContainer.new()
	avatar_wrap.custom_minimum_size = Vector2(668, 390)
	var avatar := TextureRect.new()
	avatar.texture = load("res://assets/mobile/avatar_mortal.svg")
	avatar.custom_minimum_size = Vector2(335, 390)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_wrap.add_child(avatar)
	content.add_child(avatar_wrap)

	var life := world_state.current_life
	var status := _card("Estado atual")
	var status_text := _label(_life_status_text(), 17, Color(0.90,0.92,0.89))
	status_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_child(status_text)
	content.add_child(status)

	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 10)
	actions.add_theme_constant_override("v_separation", 10)
	actions.add_child(_action_button("VIVER 90 DIAS","Trabalho, estudo e treino",_live_season))
	actions.add_child(_action_button("TREINAR","1 dia · fortalece o corpo",_train_body))
	actions.add_child(_action_button("ESTUDAR","7 dias · conhecimento mortal",_study))
	actions.add_child(_action_button("EXPLORAR","3 dias · risco e recursos",_explore))
	content.add_child(actions)

	var location_card := _card(String(LOCATIONS[current_location]["name"]))
	var loc_text := _label(String(LOCATIONS[current_location]["desc"]), 16, Color(0.82,0.86,0.84))
	loc_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	location_card.add_child(loc_text)
	content.add_child(location_card)

	if current_location == "city" and not bool(life.get("qi_known",false)):
		content.add_child(_wide_button("FAZER TESTE ESPIRITUAL", "Descobrir se seu corpo possui um caminho conhecido para o Qi.", _spiritual_test))
	if world_state.current_rare_encounter.size() > 0:
		content.add_child(_wide_button("UM ENCONTRO FOI REGISTRADO", "Há alguém na região que pode mudar esta vida. Abra Pessoas.", _open_people))

func _life_status_text() -> String:
	var life := world_state.current_life
	var qi_text := "Qi: desconhecido"
	if bool(life.get("qi_awakened",false)):
		qi_text = REALMS[int(life.get("realm_index",1))]
	elif bool(life.get("qi_known",false)):
		qi_text = BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL)))
	return "Origem: %s\nCorpo: %.0f%% treinado  ·  Inteligência %d  ·  Vontade %d\n%s" % [
		String(life.get("origin_label","Desconhecida")),
		float(life.get("body_training",0.0)),
		int(life.get("intelligence",50)),
		int(life.get("willpower",50)),
		qi_text
	]

func _render_map() -> void:
	_set_background("res://assets/mobile/bg_map.svg")
	screen_title.text = "REGIÃO DE QINGHE"
	var intro := _card("Seu conhecimento do mundo")
	var txt := _label("Viajar consome dias. Lugares perigosos não se adaptam ao seu poder; entrar despreparado pode encerrar esta vida.", 16, Color(0.88,0.90,0.86))
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_child(txt)
	content.add_child(intro)

	for key in ["village","city","forest","ruins","mountain"]:
		var loc: Dictionary = LOCATIONS[key]
		var card := _card(String(loc["name"]))
		var desc := _label("%s\nPerigo: %s  ·  Qi local: %s" % [String(loc["desc"]), String(loc["danger"]), _qi_density_label(float(loc["qi"]))], 15, Color(0.82,0.87,0.84))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(desc)
		var btn := Button.new()
		if key == current_location:
			btn.text = "VOCÊ ESTÁ AQUI"
			btn.disabled = true
		else:
			var days := _travel_days(current_location,key)
			btn.text = "VIAJAR · %d dias" % days
			btn.pressed.connect(_travel_to.bind(key,days))
		btn.custom_minimum_size = Vector2(0,56)
		btn.focus_mode = Control.FOCUS_NONE
		card.add_child(btn)
		content.add_child(card)

func _render_cultivation() -> void:
	_set_background("res://assets/mobile/bg_cultivation.svg")
	screen_title.text = "CULTIVO E MERIDIANOS"
	var life := world_state.current_life
	var realm_index := int(life.get("realm_index",0))

	var center := CenterContainer.new()
	center.custom_minimum_size = Vector2(668,310)
	var avatar := TextureRect.new()
	avatar.texture = load("res://assets/mobile/avatar_mortal.svg")
	avatar.custom_minimum_size = Vector2(255,300)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center.add_child(avatar)
	content.add_child(center)

	var card := _card("Estado espiritual")
	var status_text := ""
	if bool(life.get("qi_awakened",false)):
		status_text = "%s\nProgresso: %.1f%%\nIntegridade dos meridianos: %.0f%%\nDensidade de Qi deste local: %s" % [
			REALMS[clampi(realm_index,0,REALMS.size()-1)],
			float(life.get("cultivation_progress",0.0)),
			float(life.get("meridian_integrity",1.0))*100.0,
			_qi_density_label(float(LOCATIONS[current_location]["qi"]))
		]
	else:
		var diagnosis := "O estado espiritual ainda é desconhecido."
		if bool(life.get("qi_known",false)):
			diagnosis = BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL)))
		status_text = "%s\nDensidade de Qi deste local: %s" % [diagnosis,_qi_density_label(float(LOCATIONS[current_location]["qi"]))]
	var l := _label(status_text,17,Color(0.88,0.91,0.91))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(l)
	content.add_child(card)

	if bool(life.get("qi_awakened",false)):
		content.add_child(_wide_button("MEDITAR 30 DIAS","Absorver e refinar Qi. Quanto melhor o local, maior o avanço — e o risco.",_meditate))
		if float(life.get("cultivation_progress",0.0)) >= 100.0:
			content.add_child(_wide_button("TENTAR AVANÇO","Romper o gargalo atual. Uma falha pode ferir os meridianos.",_breakthrough))
	else:
		content.add_child(_wide_button("TENTAR SENTIR O QI","7 dias de meditação. Nem todo corpo pode responder.",_try_sense_qi))
		if current_location == "city":
			content.add_child(_wide_button("TESTE DE QINGHE","Um teste conhecido pode revelar parte da sua aptidão.",_spiritual_test))
		if bool(life.get("qi_known",false)) and int(life.get("qi_potential",3)) == BirthSystemScript.QiPotential.MORTAL:
			content.add_child(_wide_button("BUSCAR CAMINHO CONTRA O CÉU","Procurar oportunidades capazes de mudar o próprio corpo. Extremamente raro.",_seek_heaven_defying))

func _render_people() -> void:
	_set_background("res://assets/mobile/bg_home.svg")
	screen_title.text = "PESSOAS E DESTINOS"

	if world_state.current_rare_encounter.size() > 0:
		var p: Dictionary = world_state.current_rare_encounter
		var card := _card("Encontro raro · " + String(p.get("name","Desconhecido")))
		var story := _label("%s\nIdade: %d · %s\nVocê não sabe se essa pessoa possui qualquer aptidão espiritual." % [String(p.get("story","")),int(p.get("age",0)),String(p.get("role",""))],16,Color(0.90,0.90,0.85))
		story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(story)
		var accept := Button.new()
		accept.text = "ACOLHER E ASSUMIR RESPONSABILIDADE"
		accept.custom_minimum_size = Vector2(0,60)
		accept.pressed.connect(_accept_encounter)
		card.add_child(accept)
		content.add_child(card)

	if world_state.notable_people.is_empty():
		var empty := _card("Ninguém atravessou suas vidas ainda")
		var t := _label("Família, protegidos, discípulos, mestres e inimigos importantes aparecerão aqui e continuarão vivendo mesmo quando você estiver longe — ou morto.",16,Color(0.82,0.86,0.84))
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_child(t)
		content.add_child(empty)
	else:
		for person in world_state.notable_people:
			var pc := _card(String(person.get("name","Desconhecido")))
			var summary := "%d anos · %s\nRelação: %s\nEstado: %s" % [
				int(person.get("age",0)),
				String(person.get("role","mortal")),
				String(person.get("relation","conhecido")),
				String(person.get("path","mortal"))
			]
			var pl := _label(summary,16,Color(0.86,0.89,0.87))
			pl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			pc.add_child(pl)
			content.add_child(pc)

func _render_inventory() -> void:
	_set_background("res://assets/mobile/bg_home.svg")
	screen_title.text = "BOLSA E PERTENCES"
	var life := world_state.current_life

	var equip := _card("Equipamento desta vida")
	var eq := _label("Arma: Faca de ferro\nTalismã: —\nRelíquia: —\nArtefato espiritual: —",16,Color(0.86,0.89,0.87))
	equip.add_child(eq)
	content.add_child(equip)

	var inv: Array = life.get("inventory",[])
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	for item in inv:
		var b := Button.new()
		b.text = "%s\n×%d" % [String(item.get("name","Item")),int(item.get("qty",1))]
		b.custom_minimum_size = Vector2(214,112)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size",14)
		b.pressed.connect(_inspect_item.bind(item))
		grid.add_child(b)
	content.add_child(grid)

func _render_chronicle() -> void:
	_set_background("res://assets/mobile/bg_home.svg")
	screen_title.text = "CRÔNICA DOS NOVE CÉUS"
	var panel := _card("O mundo se lembra")
	var rich := RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.custom_minimum_size = Vector2(0,650)
	rich.add_theme_font_size_override("normal_font_size",16)
	rich.text = world_state.chronicle_text()
	panel.add_child(rich)
	content.add_child(panel)

func _live_season() -> void:
	var life := world_state.current_life
	var knowledge_gain := 2.0 + float(life.get("intelligence",50))/32.0
	var training_gain := 1.5 + float(int(life.get("physique",50))+int(life.get("willpower",50)))/85.0
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge",0.0))+knowledge_gain,100.0)
	life["body_training"] = minf(float(life.get("body_training",0.0))+training_gain,100.0)
	_advance_days(90)
	_show_toast("Uma estação passou. Você viveu como alguém deste mundo, não como um marcador esperando por Qi.")
	_show_screen("life")

func _train_body() -> void:
	var life := world_state.current_life
	life["body_training"] = minf(float(life.get("body_training",0.0))+3.5+float(life.get("physique",50))/50.0,100.0)
	_advance_days(1)
	_show_toast("Um dia de treino fortaleceu o corpo.")
	_show_screen("life")

func _study() -> void:
	var life := world_state.current_life
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge",0.0))+4.0+float(life.get("intelligence",50))/35.0,100.0)
	_advance_days(7)
	_show_toast("Você estudou medicina, números, história e técnicas mortais por sete dias.")
	_show_screen("life")

func _explore() -> void:
	_advance_days(3)
	if overlay.visible:
		return
	var danger := String(LOCATIONS[current_location]["danger"])
	var roll := rng.randf()
	if current_location == "mountain" and int(world_state.current_life.get("realm_index",0)) == 0 and roll < 0.18:
		_show_event("PRESENÇA ESPIRITUAL","Algo enorme se move atrás da névoa. Seu instinto mortal grita para fugir.",[
			["FUGIR",Callable(self,"_event_flee")],
			["OBSERVAR DE LONGE",Callable(self,"_event_observe")]
		])
		return
	if danger == "Alto" and roll < 0.10:
		_show_event("ARMADILHA ANTIGA","Uma inscrição reage à sua presença. O chão começa a emitir luz.",[
			["RECUAR",Callable(self,"_event_flee")],
			["TOCAR A INSCRIÇÃO",Callable(self,"_event_touch_ruin")]
		])
		return
	var items := [
		{"name":"Erva da Névoa","qty":1,"kind":"Erva","desc":"Uma erva medicinal comum em regiões frias."},
		{"name":"Minério de ferro negro","qty":2,"kind":"Minério","desc":"Material mortal resistente usado por ferreiros."},
		{"name":"Madeira espiritual fraca","qty":1,"kind":"Material","desc":"Madeira que reteve traços de Qi por muitos anos."}
	]
	var found: Dictionary = items[rng.randi_range(0,items.size()-1)]
	_add_item(found)
	_show_toast("Exploração concluída: encontrou %s." % String(found["name"]))
	_show_screen("life")

func _event_flee() -> void:
	_close_overlay()
	_advance_days(1)
	_show_toast("Você recuou antes de transformar curiosidade em morte.")

func _event_observe() -> void:
	_close_overlay()
	_advance_days(2)
	world_state.record_world_event("você observou de longe uma poderosa besta espiritual na Montanha do Véu.")
	_show_toast("Você sobreviveu e aprendeu algo: poder também é saber quando não lutar.")

func _event_touch_ruin() -> void:
	_close_overlay()
	if rng.randf() < 0.72:
		_damage_meridians(0.08)
		_show_toast("A formação rejeitou você. Seus meridianos sofreram uma pequena lesão.")
	else:
		world_state.current_life["worldly_knowledge"] = minf(float(world_state.current_life.get("worldly_knowledge",0.0))+8.0,100.0)
		_show_toast("Você compreendeu um fragmento de conhecimento antigo.")

func _travel_to(target: String, days: int) -> void:
	_advance_days(days)
	if overlay.visible:
		return
	current_location = target
	_show_toast("Você chegou a %s após %d dias." % [String(LOCATIONS[target]["name"]),days])
	_show_screen("map")

func _spiritual_test() -> void:
	var life := world_state.current_life
	life["qi_known"] = true
	_advance_days(1)
	_show_event("TESTE ESPIRITUAL DE QINGHE",BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL))),[
		["ACEITAR O RESULTADO",Callable(self,"_close_overlay")]
	])
	_update_header()

func _try_sense_qi() -> void:
	var life := world_state.current_life
	_advance_days(7)
	if overlay.visible:
		return
	var potential := int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL))
	life["qi_known"] = true
	var local_qi := float(LOCATIONS[current_location]["qi"])
	var chance := 0.0
	if potential == BirthSystemScript.QiPotential.AWAKENED:
		chance = 0.32 * local_qi
	elif potential == BirthSystemScript.QiPotential.LATENT:
		chance = 0.08 * local_qi
	if chance > 0.0 and rng.randf() < minf(chance,0.78):
		_awaken_qi("meditação em " + String(LOCATIONS[current_location]["name"]))
	else:
		_show_toast("Sete dias passaram. Você sentiu silêncio — talvez por incapacidade, talvez por falta de oportunidade.")
	_show_screen("cultivation")

func _awaken_qi(source: String) -> void:
	var life := world_state.current_life
	life["qi_awakened"] = true
	life["qi_known"] = true
	life["realm_index"] = 1
	life["cultivation_progress"] = 0.0
	world_state.record_world_event("a Vida %d abriu o caminho do Qi através de %s." % [world_state.incarnation_index,source])
	_show_event("PRIMEIRO SOPRO DE QI","Pela primeira vez, o mundo deixa de parecer vazio. Você entrou no Refinamento de Qi I.",[
		["CONTINUAR",Callable(self,"_close_overlay")]
	])

func _meditate() -> void:
	var life := world_state.current_life
	_advance_days(30)
	if overlay.visible:
		return
	var realm_index := int(life.get("realm_index",1))
	var potential := int(life.get("qi_potential",BirthSystemScript.QiPotential.LATENT))
	var talent := 1.0
	if potential == BirthSystemScript.QiPotential.AWAKENED:
		talent = 1.35
	elif potential == BirthSystemScript.QiPotential.LATENT:
		talent = 1.0
	else:
		talent = 0.72
	var gain := (5.0 + float(life.get("willpower",50))/22.0) * float(LOCATIONS[current_location]["qi"]) * talent
	if realm_index >= 10:
		gain *= 0.62
	if realm_index >= 14:
		gain *= 0.38
	life["cultivation_progress"] = minf(float(life.get("cultivation_progress",0.0))+gain,100.0)
	if rng.randf() < 0.025 * float(LOCATIONS[current_location]["qi"]):
		_damage_meridians(0.04)
		_show_toast("O Qi saiu do fluxo correto. Houve progresso, mas seus meridianos sofreram.")
	else:
		_show_toast("Trinta dias de cultivo: +%.1f%% de progresso." % gain)
	_show_screen("cultivation")

func _breakthrough() -> void:
	var life := world_state.current_life
	var realm_index := int(life.get("realm_index",1))
	if realm_index >= REALMS.size()-1:
		_show_toast("O caminho além deste ponto ainda não foi aberto nesta versão do mundo.")
		return
	_advance_days(12)
	if overlay.visible:
		return
	var integrity := float(life.get("meridian_integrity",1.0))
	var will := float(life.get("willpower",50))
	var base_chance := clampf(0.42 + integrity*0.28 + will/300.0 - float(realm_index)*0.012,0.18,0.88)
	if rng.randf() <= base_chance:
		life["realm_index"] = realm_index + 1
		life["cultivation_progress"] = 0.0
		world_state.record_world_event("a Vida %d rompeu um gargalo e alcançou %s." % [world_state.incarnation_index,REALMS[realm_index+1]])
		_show_event("AVANÇO BEM-SUCEDIDO",REALMS[realm_index+1],[
			["ESTABILIZAR O REINO",Callable(self,"_close_overlay")]
		])
	else:
		life["cultivation_progress"] = 62.0
		_damage_meridians(0.12)
		_show_event("GARGALO FALHOU","O avanço colapsou. Parte do progresso foi perdida e os meridianos sofreram.",[
			["RECUPERAR-SE",Callable(self,"_close_overlay")]
		])
	_show_screen("cultivation")

func _seek_heaven_defying() -> void:
	_advance_days(30)
	if overlay.visible:
		return
	var chance := 0.0015
	if current_location == "ruins":
		chance = 0.006
	elif current_location == "mountain":
		chance = 0.004
	if rng.randf() < chance:
		world_state.current_life["qi_potential"] = BirthSystemScript.QiPotential.LATENT
		_show_event("OPORTUNIDADE CONTRA O CÉU","Você encontrou algo que não deveria pertencer a um mortal. Seu corpo começou a mudar.",[
			["ACEITAR A DOR",Callable(self,"_awaken_qi").bind("uma oportunidade que reescreveu seus meridianos")]
		])
	else:
		_show_toast("Um mês de busca terminou sem milagre. O mundo não reserva tesouros para você.")
	_show_screen("cultivation")

func _accept_encounter() -> void:
	if world_state.accept_current_rare_encounter():
		_show_toast("Essa pessoa agora faz parte da história das suas vidas.")
	_show_screen("people")

func _inspect_item(item: Dictionary) -> void:
	_show_event(String(item.get("name","Item")),"%s\nQuantidade: %d\n%s" % [String(item.get("kind","Objeto")),int(item.get("qty",1)),String(item.get("desc",""))],[
		["FECHAR",Callable(self,"_close_overlay")]
	])

func _add_item(item: Dictionary) -> void:
	var inv: Array = world_state.current_life.get("inventory",[])
	for existing in inv:
		if String(existing.get("name","")) == String(item.get("name","")):
			existing["qty"] = int(existing.get("qty",0))+int(item.get("qty",1))
			world_state.current_life["inventory"] = inv
			return
	inv.append(item.duplicate(true))
	world_state.current_life["inventory"] = inv

func _advance_days(days: int) -> void:
	var before_year := world_state.world_year
	world_state.advance_days(days)
	var years_passed := world_state.world_year - before_year
	if years_passed > 0:
		var person_events: Array[String] = NotablePersonSystem.advance_people(world_state.notable_people,years_passed,world_state.rng,world_state.world_year)
		for e in person_events:
			world_state.record_world_event(e)
	_check_natural_death()

func _check_natural_death() -> void:
	var life := world_state.current_life
	var lifespan := int(life.get("natural_lifespan",72))
	var realm_index := int(life.get("realm_index",0))
	var bonus := realm_index * 8
	if realm_index >= 10:
		bonus += 70
	if realm_index >= 14:
		bonus += 180
	if world_state.current_age() >= lifespan + bonus:
		_end_life("velhice")

func _end_life(cause: String) -> void:
	var summary := world_state.end_life(cause,world_state.current_age())
	_show_event("ESTA VIDA TERMINOU","Vida %d · %s\nIdade: %d anos\nCausa: %s\n\nO mundo continuará sem você." % [
		int(summary.get("incarnation",0)),String(summary.get("origin","")),int(summary.get("age",0)),cause
	],[
		["REENCARNAR",Callable(self,"_reincarnate")]
	])

func _reincarnate() -> void:
	_close_overlay()
	world_state.reincarnate()
	current_location = "village"
	_initialize_life_runtime()
	_show_screen("life")
	_show_toast("Décadas podem ter passado. Você nasceu outra vez — sem garantia de uma vida melhor.")

func _damage_meridians(amount: float) -> void:
	var life := world_state.current_life
	life["meridian_integrity"] = maxf(float(life.get("meridian_integrity",1.0))-amount,0.2)

func _travel_days(from_key: String,to_key: String) -> int:
	if from_key == to_key:
		return 0
	var a := int(LOCATIONS[from_key]["travel"])
	var b := int(LOCATIONS[to_key]["travel"])
	return maxi(1,abs(a-b)+1)

func _qi_density_label(value: float) -> String:
	if value < 0.5:
		return "quase inexistente"
	if value < 0.9:
		return "fraca"
	if value < 1.4:
		return "moderada"
	if value < 2.0:
		return "densa"
	return "muito densa"

func _open_people() -> void:
	_show_screen("people")

func _on_calendar_changed(_year: int,_day: int) -> void:
	_update_header()

func _on_rare_encounter_changed(profile: Dictionary) -> void:
	if not profile.is_empty():
		_show_toast("A Crônica registrou um encontro incomum. Veja a tela Pessoas.")
	if current_screen == "people":
		_show_screen("people")

func _show_event(title_text: String,body_text: String,actions: Array) -> void:
	for child in overlay_box.get_children():
		child.queue_free()
	var title := _label(title_text,25,Color(0.96,0.87,0.63))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_box.add_child(title)
	var body := _label(body_text,17,Color(0.90,0.92,0.90))
	body.custom_minimum_size = Vector2(540,0)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_box.add_child(body)
	for action in actions:
		var b := Button.new()
		b.text = String(action[0])
		b.custom_minimum_size = Vector2(0,62)
		var callable: Callable = action[1]
		b.pressed.connect(callable)
		overlay_box.add_child(b)
	overlay.visible = true

func _close_overlay() -> void:
	overlay.visible = false

func _show_toast(text_value: String) -> void:
	toast.text = text_value
	toast.visible = true
	var tween := create_tween()
	tween.tween_interval(3.4)
	tween.tween_callback(func() -> void:
		if is_instance_valid(toast):
			toast.visible = false
	)

func _card(title_text: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(0,0)
	box.add_theme_constant_override("separation",8)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",_panel_style(Color(0.055,0.075,0.085,0.90),18))
	panel.custom_minimum_size = Vector2(668,0)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation",8)
	panel.add_child(inner)
	var title := _label(title_text,19,Color(0.94,0.85,0.64))
	inner.add_child(title)
	box.add_child(panel)
	box.set_meta("inner",inner)
	return inner

func _wide_button(title_text: String,subtext: String,callable: Callable) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(668,84)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",15)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(callable)
	return b

func _action_button(title_text: String,subtext: String,callable: Callable) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(329,92)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",14)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(callable)
	return b

func _label(text_value: String,size_value: int,color_value: Color) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size",size_value)
	l.modulate = color_value
	return l

func _create_mobile_theme() -> Theme:
	var t := Theme.new()
	var normal := _button_style(Color(0.075,0.11,0.125,0.94),Color(0.48,0.53,0.46,0.52))
	var hover := _button_style(Color(0.105,0.145,0.155,0.98),Color(0.72,0.61,0.37,0.78))
	var pressed := _button_style(Color(0.16,0.18,0.16,0.98),Color(0.88,0.72,0.34,0.95))
	var disabled := _button_style(Color(0.055,0.065,0.07,0.78),Color(0.24,0.28,0.28,0.42))
	t.set_stylebox("normal","Button",normal)
	t.set_stylebox("hover","Button",hover)
	t.set_stylebox("pressed","Button",pressed)
	t.set_stylebox("disabled","Button",disabled)
	t.set_color("font_color","Button",Color(0.92,0.92,0.86))
	t.set_color("font_hover_color","Button",Color(1.0,0.93,0.72))
	t.set_color("font_pressed_color","Button",Color(1.0,0.86,0.46))
	t.set_color("font_disabled_color","Button",Color(0.48,0.52,0.51))
	t.set_font_size("font_size","Button",15)
	return t

func _button_style(bg: Color,border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 14
	s.corner_radius_top_right = 14
	s.corner_radius_bottom_left = 14
	s.corner_radius_bottom_right = 14
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = border
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 10.0
	s.content_margin_bottom = 10.0
	return s

func _panel_style(color_value: Color,radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color_value
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left = 18.0
	s.content_margin_right = 18.0
	s.content_margin_top = 14.0
	s.content_margin_bottom = 14.0
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = Color(0.55,0.50,0.36,0.45)
	return s
