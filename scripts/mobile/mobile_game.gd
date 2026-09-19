extends Control

const WorldStateScript = preload("res://scripts/core/world_state.gd")
const BirthSystemScript = preload("res://scripts/core/birth_system.gd")
const NotablePersonSystemScript = preload("res://scripts/core/notable_person_system.gd")
const GameContentScript = preload("res://scripts/mobile/game_content.gd")
const MobileAudioScript = preload("res://scripts/mobile/mobile_audio.gd")
const MobileFXScript = preload("res://scripts/mobile/mobile_fx.gd")
const PhaseMapScript = preload("res://scripts/mobile/phase_map_visual.gd")

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

const PHASE_BACKGROUNDS := {
	1:"res://assets/mobile/phase_1_vale_mortal.svg",
	2:"res://assets/mobile/phase_2_qinghe.svg",
	3:"res://assets/mobile/phase_3_ceu_velado.svg",
	4:"res://assets/mobile/phase_4_terras_ancestrais.svg",
	5:"res://assets/mobile/phase_5_nove_ceus.svg",
}

const LOOT_BY_PHASE := {
	1:[
		{"name":"Erva da Nascente","qty":1,"kind":"Erva","rarity":"Comum","desc":"Erva medicinal usada por curandeiros mortais."},
		{"name":"Ferro negro","qty":2,"kind":"Minério","rarity":"Comum","desc":"Minério pesado, bom para armas mortais."},
		{"name":"Madeira fria","qty":1,"kind":"Material","rarity":"Comum","desc":"Madeira resistente que cresce perto da névoa."},
		{"name":"Pétala de orvalho","qty":2,"kind":"Erva","rarity":"Incomum","desc":"Retém um traço quase imperceptível de Qi."}
	],
	2:[
		{"name":"Jade de Qinghe","qty":1,"kind":"Material","rarity":"Incomum","desc":"Jade comercial usado em selos e talismãs simples."},
		{"name":"Tinta de cinábrio","qty":2,"kind":"Talismã","rarity":"Incomum","desc":"Tinta usada por escribas de talismãs."},
		{"name":"Pergaminho selado","qty":1,"kind":"Manual","rarity":"Raro","desc":"Um pergaminho cujo conteúdo ainda não foi identificado."},
		{"name":"Chá de folha espiritual","qty":1,"kind":"Consumível","rarity":"Incomum","desc":"Acalma a mente por algumas horas."}
	],
	3:[
		{"name":"Erva Nuvem Azul","qty":1,"kind":"Erva","rarity":"Raro","desc":"Cresce apenas em montanhas com Qi estável."},
		{"name":"Cristal de Qi menor","qty":2,"kind":"Tesouro","rarity":"Raro","desc":"Cristaliza energia espiritual de baixa pureza."},
		{"name":"Fragmento de técnica","qty":1,"kind":"Manual","rarity":"Raro","desc":"Parte incompleta de uma arte de circulação."},
		{"name":"Folha de intenção da espada","qty":1,"kind":"Tesouro","rarity":"Épico","desc":"Uma folha marcada por intenção residual de espada."}
	],
	4:[
		{"name":"Núcleo de besta ferido","qty":1,"kind":"Besta","rarity":"Épico","desc":"Núcleo danificado, ainda valioso para alquimia."},
		{"name":"Minério espiritual fraturado","qty":2,"kind":"Minério","rarity":"Épico","desc":"Minério arrancado de um veio espiritual instável."},
		{"name":"Osso ancestral","qty":1,"kind":"Besta","rarity":"Épico","desc":"Osso antigo com marcas naturais semelhantes a inscrições."},
		{"name":"Fragmento de formação","qty":1,"kind":"Formação","rarity":"Lendário","desc":"Uma peça funcional de uma formação que sobreviveu séculos."}
	],
	5:[
		{"name":"Pétala da Imortalidade","qty":1,"kind":"Erva","rarity":"Lendário","desc":"Uma pétala que leva séculos para amadurecer."},
		{"name":"Cristal celestial","qty":1,"kind":"Tesouro","rarity":"Lendário","desc":"Energia extremamente pura cristalizada."},
		{"name":"Fragmento do Dao","qty":1,"kind":"Dao","rarity":"Mítico","desc":"Não é exatamente matéria, nem exatamente compreensão."},
		{"name":"Jade do Vazio","qty":1,"kind":"Tesouro","rarity":"Mítico","desc":"Jade que parece ocupar menos espaço do que deveria."}
	]
}

const RUMORS := {
	1:[
		"Caçadores juram que uma criatura enorme atravessou a névoa sem deixar pegadas comuns.",
		"Um velho médico diz que certas pessoas passam a vida inteira sem jamais sentir Qi.",
		"Há relatos de uma criança abandonada perto da estrada — mas ninguém sabe se ainda está lá.",
		"O Templo Abandonado possui inscrições que ninguém da vila consegue ler."
	],
	2:[
		"A Casa das Cem Lanternas prepara um leilão para algo vindo de uma seita destruída.",
		"Uma família marcial de Qinghe procura um professor para uma criança considerada brilhante.",
		"Mercadores afirmam que a Montanha do Véu voltou a aceitar discípulos externos.",
		"Um estudioso mortal ganhou riqueza ao aperfeiçoar um mecanismo de irrigação."
	],
	3:[
		"Um discípulo externo compreendeu intenção de espada depois de passar sete anos limpando o cemitério.",
		"Um ancião permanece em reclusão há cento e vinte anos; ninguém sabe se ainda vive.",
		"A seita perdeu contato com um grupo enviado às Ruínas de Lianshi.",
		"Há rumores de uma erva centenária escondida no Jardim Espiritual."
	],
	4:[
		"Uma besta de Núcleo Dourado reivindicou parte do Vale das Cem Bestas.",
		"Uma veia espiritual na Mina Fraturada mudou de curso após um terremoto.",
		"As Ruínas de Lianshi abriram uma passagem que não existia na última década.",
		"Uma família desapareceu depois de tocar a água do Lago do Espelho Negro."
	],
	5:[
		"A Torre da Tribulação reagiu ao nome de alguém que morreu há milhares de anos.",
		"O Jardim da Imortalidade floresceu fora de época.",
		"O Salão do Destino possui um registro apagado que parece mencionar reencarnação.",
		"Além do Portal da Ascensão existe outro céu — e ninguém garante que seja mais gentil."
	]
}

var world_state: WorldState
var rng := RandomNumberGenerator.new()
var audio: Node
var fx: Control

var current_screen := "life"
var current_location := "spring_village"
var selected_map_phase := 1
var inventory_filter := "Todos"
var map_selected_location := "spring_village"
var life_over := false
var music_enabled := true

var background: TextureRect
var background_tint: ColorRect
var phase_label: Label
var header_title: Label
var header_meta: Label
var header_resource: Label
var screen_title: Label
var content_scroll: ScrollContainer
var content: VBoxContainer
var bottom_nav: HBoxContainer
var toast: Label
var overlay: ColorRect
var overlay_box: VBoxContainer
var music_button: Button
var nav_buttons: Dictionary = {}

func _ready() -> void:
	world_state = WorldStateScript.new()
	add_child(world_state)
	world_state.initialize()
	rng.seed = world_state.world_seed ^ 0x4E4F5645
	world_state.calendar_changed.connect(_on_calendar_changed)
	world_state.rare_encounter_changed.connect(_on_rare_encounter_changed)
	_initialize_life_runtime()

	audio = MobileAudioScript.new()
	add_child(audio)
	fx = MobileFXScript.new()

	_build_shell()
	_show_screen("life")
	_update_phase_presentation()
	_show_toast("Vida %d começou. Seu destino ainda não foi escrito." % world_state.incarnation_index)
	audio.play_sfx("rare")

func _initialize_life_runtime() -> void:
	var life := world_state.current_life
	if not life.has("realm_index"):
		life["realm_index"] = 0
	if not life.has("cultivation_progress"):
		life["cultivation_progress"] = 0.0
	if not life.has("silver"):
		life["silver"] = 48
	if not life.has("spirit_stones"):
		life["spirit_stones"] = 0
	if not life.has("dao_insight"):
		life["dao_insight"] = 0.0
	if not life.has("sect_reputation"):
		life["sect_reputation"] = 0
	if not life.has("world_reputation"):
		life["world_reputation"] = 0
	if not life.has("inventory"):
		life["inventory"] = [
			{"name":"Provisões simples","qty":3,"kind":"Comida","rarity":"Comum","desc":"Comida para alguns dias de estrada."},
			{"name":"Faca de ferro","qty":1,"kind":"Equipamento","rarity":"Comum","desc":"Uma lâmina mortal simples e confiável."},
			{"name":"Tecido comum","qty":2,"kind":"Material","rarity":"Comum","desc":"Material usado em reparos e trocas."}
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

	background_tint = ColorRect.new()
	background_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_tint.color = Color(0.02,0.03,0.04,0.14)
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_tint)

	add_child(fx)
	move_child(fx,2)

	var top_panel := PanelContainer.new()
	top_panel.position = Vector2(14,16)
	top_panel.size = Vector2(692,142)
	top_panel.add_theme_stylebox_override("panel",_panel_style(Color(0.025,0.045,0.055,0.92),20,_phase_accent()))
	add_child(top_panel)

	var top_margin := MarginContainer.new()
	for side in ["margin_left","margin_right","margin_top","margin_bottom"]:
		top_margin.add_theme_constant_override(side,14)
	top_panel.add_child(top_margin)

	var top_v := VBoxContainer.new()
	top_v.add_theme_constant_override("separation",2)
	top_margin.add_child(top_v)

	var row := HBoxContainer.new()
	top_v.add_child(row)
	phase_label = _label("",14,Color(0.96,0.82,0.52))
	phase_label.custom_minimum_size = Vector2(500,24)
	row.add_child(phase_label)
	music_button = Button.new()
	music_button.text = "♫"
	music_button.custom_minimum_size = Vector2(52,40)
	music_button.focus_mode = Control.FOCUS_NONE
	music_button.pressed.connect(_toggle_music)
	row.add_child(music_button)

	header_title = _label("",23,Color(0.98,0.92,0.75))
	top_v.add_child(header_title)
	header_meta = _label("",14,Color(0.84,0.88,0.87))
	top_v.add_child(header_meta)
	header_resource = _label("",13,Color(0.67,0.83,0.78))
	top_v.add_child(header_resource)

	screen_title = _label("",27,Color(0.99,0.95,0.84))
	screen_title.position = Vector2(24,172)
	screen_title.size = Vector2(672,42)
	screen_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(screen_title)

	content_scroll = ScrollContainer.new()
	content_scroll.position = Vector2(18,222)
	content_scroll.size = Vector2(684,866)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(content_scroll)

	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(668,0)
	content.add_theme_constant_override("separation",13)
	content_scroll.add_child(content)

	toast = _label("",15,Color.WHITE)
	toast.position = Vector2(42,1018)
	toast.size = Vector2(636,66)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_stylebox_override("normal",_panel_style(Color(0.02,0.035,0.045,0.95),15,_phase_accent()))
	toast.visible = false
	toast.z_index = 40
	add_child(toast)

	bottom_nav = HBoxContainer.new()
	bottom_nav.position = Vector2(10,1102)
	bottom_nav.size = Vector2(700,164)
	bottom_nav.add_theme_constant_override("separation",5)
	add_child(bottom_nav)

	for data in [
		["life","VIDA"],["map","MAPA"],["cultivation","CULTIVO"],
		["people","PESSOAS"],["inventory","BOLSA"],["chronicle","CRÔNICA"]
	]:
		var key: String = data[0]
		var btn := Button.new()
		btn.text = data[1]
		btn.custom_minimum_size = Vector2(112,126)
		btn.add_theme_font_size_override("font_size",12)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_nav_pressed.bind(key))
		bottom_nav.add_child(btn)
		nav_buttons[key] = btn

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.008,0.012,0.018,0.91)
	overlay.z_index = 100
	overlay.visible = false
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var event_panel := PanelContainer.new()
	event_panel.custom_minimum_size = Vector2(620,0)
	event_panel.add_theme_stylebox_override("panel",_panel_style(Color(0.045,0.065,0.075,0.99),22,_phase_accent()))
	center.add_child(event_panel)
	var event_margin := MarginContainer.new()
	for side in ["margin_left","margin_right","margin_top","margin_bottom"]:
		event_margin.add_theme_constant_override(side,22)
	event_panel.add_child(event_margin)
	overlay_box = VBoxContainer.new()
	overlay_box.add_theme_constant_override("separation",15)
	event_margin.add_child(overlay_box)

func _nav_pressed(key: String) -> void:
	audio.play_sfx("tap")
	_show_screen(key)

func _show_screen(screen_key: String) -> void:
	current_screen = screen_key
	_clear_content()
	for key in nav_buttons.keys():
		var b: Button = nav_buttons[key]
		b.disabled = key == screen_key

	match screen_key:
		"life": _render_life()
		"map": _render_map()
		"cultivation": _render_cultivation()
		"people": _render_people()
		"inventory": _render_inventory()
		"chronicle": _render_chronicle()

	_update_header()
	_update_phase_presentation()

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()
	content_scroll.scroll_vertical = 0

func _update_phase_presentation() -> void:
	var phase := _current_phase()
	background.texture = load(String(PHASE_BACKGROUNDS.get(phase,PHASE_BACKGROUNDS[1])))
	if fx != null:
		fx.set_phase(phase)
	if audio != null:
		audio.play_phase_theme(phase)
	phase_label.text = "FASE %d / 5   ·   %s" % [phase,String(GameContentScript.phase(phase)["name"])]

func _update_header() -> void:
	if world_state == null:
		return
	var life := world_state.current_life
	var realm_index := int(life.get("realm_index",0))
	var loc := _location()
	header_title.text = "VIDA %d  ·  %s" % [world_state.incarnation_index,REALMS[clampi(realm_index,0,REALMS.size()-1)]]
	header_meta.text = "Ano %d · Dia %d   |   %d anos   |   %s" % [
		world_state.world_year,world_state.world_day,world_state.current_age(),String(loc["name"])
	]
	header_resource.text = "Prata %d   ·   Pedras %d   ·   Dao %.0f   ·   Conhecimento %.0f%%" % [
		int(life.get("silver",0)),int(life.get("spirit_stones",0)),
		float(life.get("dao_insight",0.0)),float(life.get("worldly_knowledge",0.0))
	]

func _render_life() -> void:
	screen_title.text = "CAMINHO DESTA VIDA"
	var phase_data := GameContentScript.phase(_current_phase())
	var goal := _add_card("Objetivo da Fase %d" % _current_phase())
	var goal_text := _body_label(String(phase_data["goal"]))
	goal.add_child(goal_text)

	var avatar_wrap := CenterContainer.new()
	avatar_wrap.custom_minimum_size = Vector2(668,300)
	var avatar := TextureRect.new()
	avatar.texture = load("res://assets/mobile/avatar_mortal.svg")
	avatar.custom_minimum_size = Vector2(310,300)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_wrap.add_child(avatar)
	content.add_child(avatar_wrap)

	var status := _add_card("Estado da Vida")
	status.add_child(_body_label(_life_status_text()))

	var loc := _location()
	var loc_card := _add_card(String(loc["name"]))
	loc_card.add_child(_body_label("%s\nPerigo: %s   ·   Qi: %s" % [
		String(loc["desc"]),String(loc["danger"]),_qi_density_label(float(loc["qi"]))
	]))

	var action_title := _label("AÇÕES DESTE LUGAR",17,Color(0.95,0.84,0.61))
	content.add_child(action_title)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",10)
	for action in loc.get("actions",[]):
		var def := _action_definition(String(action))
		grid.add_child(_action_button(String(def[0]),String(def[1]),_perform_location_action.bind(String(action))))
	content.add_child(grid)

	if world_state.current_rare_encounter.size() > 0:
		content.add_child(_standalone_button("ENCONTRO RARO REGISTRADO","Uma pessoa incomum apareceu nesta região. Veja Pessoas.",_show_screen.bind("people"),"rare"))

func _life_status_text() -> String:
	var life := world_state.current_life
	var qi := "Estado espiritual desconhecido"
	if bool(life.get("qi_awakened",false)):
		qi = REALMS[clampi(int(life.get("realm_index",1)),0,REALMS.size()-1)]
	elif bool(life.get("qi_known",false)):
		qi = BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL)))
	return "Origem: %s\nCorpo %.0f%%  ·  Inteligência %d  ·  Vontade %d\nMeridianos %.0f%%  ·  %s" % [
		String(life.get("origin_label","Desconhecida")),
		float(life.get("body_training",0.0)),
		int(life.get("intelligence",50)),int(life.get("willpower",50)),
		float(life.get("meridian_integrity",1.0))*100.0,qi
	]

func _render_map() -> void:
	screen_title.text = "MAPA DOS CINCO CAMINHOS"

	var phase_tabs := HBoxContainer.new()
	phase_tabs.add_theme_constant_override("separation",6)
	for n in range(1,6):
		var tab := Button.new()
		tab.text = "FASE %d" % n
		tab.custom_minimum_size = Vector2(128,54)
		tab.focus_mode = Control.FOCUS_NONE
		tab.disabled = n == selected_map_phase
		tab.pressed.connect(_select_map_phase.bind(n))
		phase_tabs.add_child(tab)
	content.add_child(phase_tabs)

	var phase_data := GameContentScript.phase(selected_map_phase)
	var unlocked := _is_phase_unlocked(selected_map_phase)
	var intro := _add_card("%s" % String(phase_data["name"]))
	intro.add_child(_body_label("%s\n\nObjetivo: %s" % [
		String(phase_data["subtitle"]),String(phase_data["goal"])
	]))
	if not unlocked:
		var required := int(phase_data["required_realm"])
		intro.add_child(_small_label("BLOQUEADA · Requer %s" % REALMS[clampi(required,0,REALMS.size()-1)],Color(0.96,0.61,0.53)))

	var keys: Array[String] = GameContentScript.phase_locations(selected_map_phase)
	if not keys.has(map_selected_location):
		map_selected_location = keys[0] if not keys.is_empty() else current_location

	var visual := PhaseMapScript.new()
	visual.setup(selected_map_phase,keys,current_location,map_selected_location,unlocked)
	visual.location_selected.connect(_map_location_selected)
	content.add_child(visual)

	if not map_selected_location.is_empty() and GameContentScript.LOCATIONS.has(map_selected_location):
		_render_map_location_detail(map_selected_location,unlocked)

func _render_map_location_detail(key:String,unlocked:bool) -> void:
	var loc: Dictionary = GameContentScript.LOCATIONS[key]
	var card := _add_card(String(loc["name"]))
	card.add_child(_body_label("%s\n\nPerigo: %s   ·   Qi: %s" % [
		String(loc["desc"]),String(loc["danger"]),_qi_density_label(float(loc["qi"]))
	]))
	var actions_text := "Atividades: "
	for action in loc.get("actions",[]):
		var def := _action_definition(String(action))
		actions_text += String(def[0]).capitalize() + " · "
	card.add_child(_small_label(actions_text.trim_suffix(" · "),Color(0.72,0.82,0.80)))
	var travel := Button.new()
	travel.custom_minimum_size = Vector2(0,58)
	travel.focus_mode = Control.FOCUS_NONE
	if key == current_location:
		travel.text = "VOCÊ ESTÁ AQUI"
		travel.disabled = true
	elif not unlocked:
		travel.text = "FASE INACESSÍVEL"
		travel.disabled = true
	else:
		var days := _travel_days(current_location,key)
		travel.text = "VIAJAR PARA ESTE LUGAR · %d dias" % days
		travel.pressed.connect(_travel_to.bind(key,days))
	card.add_child(travel)

func _map_location_selected(key:String) -> void:
	map_selected_location = key
	audio.play_sfx("tap")
	_show_screen("map")
	background.texture = load(String(PHASE_BACKGROUNDS[selected_map_phase]))
	if fx != null:
		fx.set_phase(selected_map_phase)

func _select_map_phase(value:int) -> void:
	audio.play_sfx("tap")
	selected_map_phase = clampi(value,1,5)
	var keys: Array[String] = GameContentScript.phase_locations(selected_map_phase)
	map_selected_location = current_location if keys.has(current_location) else (keys[0] if not keys.is_empty() else "")
	_show_screen("map")
	background.texture = load(String(PHASE_BACKGROUNDS[selected_map_phase]))
	if fx != null:
		fx.set_phase(selected_map_phase)

func _render_cultivation() -> void:
	screen_title.text = "CULTIVO · CORPO · DAO"
	var life := world_state.current_life
	var realm_index := int(life.get("realm_index",0))

	var art := TextureRect.new()
	art.texture = load("res://assets/mobile/bg_cultivation.svg")
	art.custom_minimum_size = Vector2(668,285)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content.add_child(art)

	var state_card := _add_card("Estado Espiritual")
	var diagnosis := "O corpo ainda não revelou um caminho espiritual."
	if bool(life.get("qi_awakened",false)):
		diagnosis = "%s\nProgresso %.1f%%   ·   Meridianos %.0f%%\nDao %.0f   ·   Qi local %s" % [
			REALMS[clampi(realm_index,0,REALMS.size()-1)],
			float(life.get("cultivation_progress",0.0)),
			float(life.get("meridian_integrity",1.0))*100.0,
			float(life.get("dao_insight",0.0)),
			_qi_density_label(float(_location()["qi"]))
		]
	elif bool(life.get("qi_known",false)):
		diagnosis = "%s\nQi local: %s" % [
			BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL))),
			_qi_density_label(float(_location()["qi"]))
		]
	state_card.add_child(_body_label(diagnosis))

	if bool(life.get("qi_awakened",false)):
		content.add_child(_standalone_button("MEDITAR 30 DIAS","Circular e refinar Qi usando as condições do local atual.",_meditate,"qi"))
		if float(life.get("cultivation_progress",0.0)) >= 100.0:
			content.add_child(_standalone_button("ROMPER O GARGALO","Tentar avançar de reino. Falha pode ferir meridianos.",_breakthrough,"breakthrough"))
		content.add_child(_standalone_button("CONTEMPLAR O DAO","Transformar experiências em compreensão, não apenas poder bruto.",_comprehend,"qi"))
	else:
		content.add_child(_standalone_button("TENTAR SENTIR O QI","Sete dias de meditação. Não há garantia de resposta.",_try_sense_qi,"qi"))
		if current_location == "qinghe_city":
			content.add_child(_standalone_button("TESTE ESPIRITUAL DE QINGHE","Um teste conhecido pode revelar parte da sua aptidão.",_spiritual_test,"qi"))
		if bool(life.get("qi_known",false)) and int(life.get("qi_potential",3)) == BirthSystemScript.QiPotential.MORTAL:
			content.add_child(_standalone_button("DESAFIAR O DESTINO","Buscar algo capaz de reconstruir um corpo mortal. Chance extremamente baixa.",_seek_heaven_defying,"danger"))

func _render_people() -> void:
	screen_title.text = "PESSOAS · FAMÍLIA · DESTINOS"

	if world_state.current_rare_encounter.size() > 0:
		var p: Dictionary = world_state.current_rare_encounter
		var rare := _add_card("Encontro Raro · %s" % String(p.get("name","Desconhecido")))
		rare.add_child(_body_label("%s\n\n%d anos · %s\nO potencial espiritual dessa pessoa é desconhecido." % [
			String(p.get("story","")),int(p.get("age",0)),String(p.get("role",""))
		]))
		var accept := Button.new()
		accept.text = "ACOLHER E ASSUMIR RESPONSABILIDADE"
		accept.custom_minimum_size = Vector2(0,62)
		accept.pressed.connect(_accept_encounter)
		rare.add_child(accept)

	if world_state.notable_people.is_empty():
		var empty := _add_card("Nenhuma relação atravessou suas vidas ainda")
		empty.add_child(_body_label("Pessoas importantes podem envelhecer, estudar, cultivar, ter carreira própria e morrer mesmo quando você não está presente."))
	else:
		for person in world_state.notable_people:
			var pc := _add_card(String(person.get("name","Desconhecido")))
			var status := "%d anos · %s\nRelação: %s\nCaminho atual: %s" % [
				int(person.get("age",0)),String(person.get("role","mortal")),
				String(person.get("relation","conhecido")),String(person.get("path","mortal"))
			]
			pc.add_child(_body_label(status))

	var social := _add_card("Mundo Social")
	social.add_child(_body_label("Reputação no mundo: %d   ·   Reputação na seita: %d\nRelações futuras incluem família, discípulos, mestres, rivais, clãs e descendentes." % [
		int(world_state.current_life.get("world_reputation",0)),
		int(world_state.current_life.get("sect_reputation",0))
	]))

func _render_inventory() -> void:
	screen_title.text = "BOLSA · EQUIPAMENTO · TESOUROS"
	var life := world_state.current_life

	var equip := _add_card("Equipamento desta Vida")
	equip.add_child(_body_label("Arma: Faca de ferro   ·   Talismã: —\nRelíquia: —   ·   Artefato espiritual: —\nObjetos carregam história; itens importantes não são descartados apenas por terem número menor."))

	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation",5)
	for f in ["Todos","Erva","Material","Manual","Tesouro"]:
		var b := Button.new()
		b.text = f
		b.custom_minimum_size = Vector2(128,48)
		b.disabled = inventory_filter == f
		b.pressed.connect(_set_inventory_filter.bind(f))
		filters.add_child(b)
	content.add_child(filters)

	var inv: Array = life.get("inventory",[])
	var visible_items: Array = []
	for item in inv:
		if inventory_filter == "Todos" or String(item.get("kind","")) == inventory_filter:
			visible_items.append(item)

	if visible_items.is_empty():
		var empty := _add_card("Nada nesta categoria")
		empty.add_child(_body_label("Explore, trabalhe, negocie ou cultive para encontrar recursos."))
		return

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	for item in visible_items:
		var b := Button.new()
		b.text = "%s\n%s ×%d\n[%s]" % [
			_item_symbol(String(item.get("kind","Objeto"))),
			String(item.get("name","Item")),int(item.get("qty",1)),
			String(item.get("rarity","Comum"))
		]
		b.custom_minimum_size = Vector2(214,132)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size",13)
		b.pressed.connect(_inspect_item.bind(item))
		grid.add_child(b)
	content.add_child(grid)

func _render_chronicle() -> void:
	screen_title.text = "CRÔNICA DOS NOVE CÉUS"
	var phase_card := _add_card("Fases Conhecidas")
	var realm_index := int(world_state.current_life.get("realm_index",0))
	var unlocked := GameContentScript.unlocked_phase_for_realm(realm_index)
	phase_card.add_child(_body_label("Maior fase acessível: %d / 5\nO mundo possui 40 lugares nesta versão, mas conhecer um nome não significa sobreviver a ele." % unlocked))

	var panel := _add_card("O Mundo se Lembra")
	var rich := RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.custom_minimum_size = Vector2(0,650)
	rich.add_theme_font_size_override("normal_font_size",16)
	rich.text = world_state.chronicle_text()
	panel.add_child(rich)

func _perform_location_action(action: String) -> void:
	match action:
		"work": _work()
		"study","research": _study()
		"train","spar": _train_body()
		"rumors": _hear_rumor()
		"travel": _show_screen("map")
		"encounter","relationships": _seek_people()
		"gather": _gather()
		"meditate": _meditate() if bool(world_state.current_life.get("qi_awakened",false)) else _try_sense_qi()
		"hunt": _hunt()
		"explore": _explore()
		"trade": _trade()
		"spirit_test": _spiritual_test()
		"auction": _auction()
		"forge": _forge()
		"rest": _rest()
		"sect": _sect_business()
		"test","trial": _trial()
		"technique": _seek_technique()
		"alchemy": _alchemy()
		"comprehend": _comprehend()
		"inheritance","legacy": _seek_inheritance()
		"formations": _study_formation()
		"observe": _observe()
		"mine": _mine()
		"territory": _territory()
		"beast_pact": _beast_pact()
		"karma": _karma_event()
		"court": _celestial_court()
		"tribulation": _tribulation()
		"ascend": _ascend()
		_:
			_explore()

func _action_definition(action: String) -> Array:
	var defs := {
		"work":["TRABALHAR","Ganhar prata e construir experiência mortal."],
		"study":["ESTUDAR","Conhecimento continua valioso mesmo sem Qi."],
		"research":["PESQUISAR","Investigar registros e ideias por vários dias."],
		"train":["TREINAR CORPO","Fortalecer o que uma vida mortal realmente possui."],
		"spar":["DUELO DE TREINO","Aprender através de confronto controlado."],
		"rumors":["OUVIR RUMORES","Informação pode valer mais que um tesouro."],
		"travel":["ABRIR MAPA","Escolher outro lugar e pagar o tempo da viagem."],
		"encounter":["PROCURAR PESSOAS","Conhecer alguém sem saber que papel terá no futuro."],
		"relationships":["CRIAR VÍNCULOS","Investir tempo em pessoas da seita."],
		"gather":["COLETAR","Buscar ervas, materiais ou algo incomum."],
		"meditate":["MEDITAR","Usar o ambiente para sentir ou refinar Qi."],
		"hunt":["CAÇAR","Risco, recursos e possibilidade real de morte."],
		"explore":["EXPLORAR","Procurar aquilo que não aparece nos mapas comuns."],
		"trade":["NEGOCIAR","Comprar, vender e observar o mercado local."],
		"spirit_test":["TESTAR AFINIDADE","Descobrir parte do estado espiritual do corpo."],
		"auction":["LEILÃO","Disputar mercadorias cuja origem nem sempre é confiável."],
		"forge":["FORJAR","Transformar matéria em ferramenta e legado."],
		"rest":["DESCANSAR","Recuperar mente e pequenas lesões."],
		"sect":["ASSUNTOS DA SEITA","Mérito, deveres e política interna."],
		"test":["PROVA","Aceitar uma avaliação com consequência real."],
		"trial":["PROVAÇÃO","Arriscar corpo e reputação por crescimento."],
		"technique":["TÉCNICAS","Buscar arte de cultivo ou combate."],
		"alchemy":["ALQUIMIA","Transformar ervas e materiais."],
		"comprehend":["COMPREENDER","Buscar Dao em vez de apenas acumular energia."],
		"inheritance":["HERANÇA","Investigar legado que pode ser bênção ou armadilha."],
		"legacy":["LEGADO","Tocar algo deixado por quem veio antes."],
		"formations":["FORMAÇÕES","Estudar padrões espirituais antigos."],
		"observe":["OBSERVAR","Aprender sem desafiar diretamente o perigo."],
		"mine":["MINERAR","Extrair recursos de um lugar disputado."],
		"territory":["TERRITÓRIO","Avaliar quem realmente controla esta terra."],
		"beast_pact":["PACTO BESTIAL","Tentar negociar com uma inteligência não humana."],
		"karma":["KARMA","Enfrentar consequência de ações e vínculos."],
		"court":["SALÃO CELESTIAL","Interagir com poderes que tratam séculos como pouco tempo."],
		"tribulation":["TRIBULAÇÃO","Enfrentar o Céu quando não existe caminho seguro."],
		"ascend":["ASCENSÃO","Tentar atravessar o limite deste mundo."]
	}
	return defs.get(action,["EXPLORAR","Investigar este lugar."])

func _work() -> void:
	var life := world_state.current_life
	_advance_days(7)
	if life_over: return
	var pay := 12 + int(life.get("intelligence",50))/10 + rng.randi_range(0,9)
	life["silver"] = int(life.get("silver",0)) + pay
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge",0.0))+1.8,100.0)
	_show_toast("Sete dias de trabalho renderam %d de prata." % pay)
	audio.play_sfx("item")
	_show_screen("life")

func _study() -> void:
	var life := world_state.current_life
	_advance_days(7)
	if life_over: return
	var gain := 3.0 + float(life.get("intelligence",50))/28.0
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge",0.0))+gain,100.0)
	_show_toast("Estudo concluído: +%.1f%% conhecimento mortal." % gain)
	_show_screen("life")

func _train_body() -> void:
	var life := world_state.current_life
	_advance_days(3)
	if life_over: return
	var gain := 2.2 + float(life.get("physique",50))/38.0
	life["body_training"] = minf(float(life.get("body_training",0.0))+gain,100.0)
	_show_toast("Treino concluído: +%.1f%% corpo." % gain)
	_show_screen("life")

func _hear_rumor() -> void:
	_advance_days(1)
	if life_over: return
	var phase := _current_phase()
	var rumors: Array = RUMORS[phase]
	_show_event("RUMOR DA FASE %d" % phase,String(rumors[rng.randi_range(0,rumors.size()-1)]),[
		["GUARDAR NA MEMÓRIA",Callable(self,"_close_overlay")]
	])
	audio.play_sfx("rare")

func _seek_people() -> void:
	_advance_days(7)
	if life_over: return
	if world_state.current_rare_encounter.size() > 0:
		_show_screen("people")
		return
	if rng.randf() < 0.14:
		world_state.advance_days(90)
		if world_state.current_rare_encounter.size() > 0:
			_show_screen("people")
			return
	world_state.current_life["world_reputation"] = int(world_state.current_life.get("world_reputation",0))+1
	_show_toast("Você conheceu pessoas comuns e ampliou sua rede, mas nenhuma mudou o destino desta vida ainda.")

func _gather() -> void:
	_advance_days(2)
	if life_over: return
	var loot: Array = LOOT_BY_PHASE[_current_phase()]
	var found: Dictionary = loot[rng.randi_range(0,loot.size()-1)].duplicate(true)
	_add_item(found)
	_show_toast("Coleta: %s ×%d." % [String(found["name"]),int(found["qty"])])
	audio.play_sfx("item")
	_show_screen("inventory")

func _explore() -> void:
	_advance_days(3 + _current_phase())
	if life_over: return
	var danger := String(_location()["danger"])
	var danger_chance := {"Baixo":0.02,"Médio":0.07,"Alto":0.14,"Extremo":0.22,"Lendário":0.28}.get(danger,0.05)
	if rng.randf() < float(danger_chance):
		_show_event("O LUGAR REAGIU À SUA PRESENÇA","Você entrou fundo demais. Algo perigoso bloqueia o caminho.",[
			["RECUAR",Callable(self,"_event_flee")],
			["ARRISCAR",Callable(self,"_event_risk")]
		])
		audio.play_sfx("danger")
		return
	_gather()

func _hunt() -> void:
	_advance_days(2)
	if life_over: return
	var realm := int(world_state.current_life.get("realm_index",0))
	var phase := _current_phase()
	var difficulty := phase*3
	_show_event("CAÇADA","Você encontra sinais de uma criatura que conhece melhor este território do que você.",[
		["OBSERVAR E RECUAR",Callable(self,"_event_observe")],
		["PREPARAR ARMADILHA",Callable(self,"_hunt_trap").bind(realm,difficulty)],
		["ENFRENTAR DIRETAMENTE",Callable(self,"_hunt_direct").bind(realm,difficulty)]
	])
	audio.play_sfx("danger")

func _hunt_trap(realm: int,difficulty: int) -> void:
	_close_overlay()
	var chance := clampf(0.45 + float(world_state.current_life.get("worldly_knowledge",0.0))/180.0 + float(realm-difficulty)*0.04,0.08,0.88)
	if rng.randf() < chance:
		_add_item({"name":"Material de besta","qty":1,"kind":"Besta","rarity":"Raro","desc":"Obtido através de preparação, não força bruta."})
		_show_toast("A armadilha funcionou. Você venceu usando preparação.")
		audio.play_sfx("item")
	else:
		_damage_meridians(0.03)
		_show_toast("A criatura escapou e você saiu ferido.")

func _hunt_direct(realm: int,difficulty:int) -> void:
	_close_overlay()
	var chance := clampf(0.18 + float(realm-difficulty)*0.07 + float(world_state.current_life.get("body_training",0.0))/250.0,0.02,0.82)
	if rng.randf() < chance:
		_add_item({"name":"Núcleo bestial instável","qty":1,"kind":"Besta","rarity":"Épico","desc":"Prova de uma vitória que poderia ter terminado diferente."})
		_show_toast("Vitória perigosa. Um núcleo bestial foi obtido.")
		audio.play_sfx("breakthrough")
	else:
		if rng.randf() < 0.30:
			_end_life("morto por uma besta espiritual")
		else:
			_damage_meridians(0.12)
			_show_toast("Você sobreviveu por pouco e voltou com ferimentos graves.")

func _trade() -> void:
	_advance_days(1)
	if life_over: return
	var life := world_state.current_life
	var price := 18 + _current_phase()*9
	if int(life.get("silver",0)) >= price:
		_show_event("MERCADO LOCAL","Um comerciante oferece um pacote de recursos por %d de prata." % price,[
			["COMPRAR",Callable(self,"_buy_market_pack").bind(price)],
			["RECUSAR",Callable(self,"_close_overlay")]
		])
	else:
		_show_toast("Você observa o mercado, mas sua prata não chama atenção de bons vendedores.")

func _buy_market_pack(price:int) -> void:
	_close_overlay()
	var life := world_state.current_life
	life["silver"] = int(life.get("silver",0))-price
	var loot: Array = LOOT_BY_PHASE[_current_phase()]
	var item: Dictionary = loot[rng.randi_range(0,loot.size()-1)].duplicate(true)
	_add_item(item)
	_show_toast("Compra concluída: %s." % String(item["name"]))
	audio.play_sfx("item")

func _auction() -> void:
	_advance_days(1)
	if life_over: return
	var price := 80 + _current_phase()*55
	var item := {"name":"Lote selado das Cem Lanternas","qty":1,"kind":"Tesouro","rarity":"Épico","desc":"O conteúdo verdadeiro só será conhecido depois da compra."}
	_show_event("LEILÃO","Lance atual: %d prata. A origem do lote não foi confirmada." % price,[
		["DAR LANCE",Callable(self,"_auction_bid").bind(price,item)],
		["SAIR",Callable(self,"_close_overlay")]
	])

func _auction_bid(price:int,item:Dictionary) -> void:
	_close_overlay()
	var life := world_state.current_life
	if int(life.get("silver",0)) < price:
		_show_toast("Prata insuficiente. O lote passa para outro comprador.")
		return
	life["silver"] = int(life.get("silver",0))-price
	_add_item(item)
	_show_toast("Você venceu o lote. Agora o risco também é seu.")
	audio.play_sfx("rare")

func _forge() -> void:
	_advance_days(5)
	if life_over: return
	world_state.current_life["worldly_knowledge"] = minf(float(world_state.current_life.get("worldly_knowledge",0.0))+2.2,100.0)
	_add_item({"name":"Lâmina forjada nesta vida","qty":1,"kind":"Equipamento","rarity":"Incomum","desc":"Uma arma marcada pelo trabalho da sua própria encarnação."})
	world_state.record_world_event("a Vida %d forjou uma lâmina que poderá sobreviver ao próprio dono." % world_state.incarnation_index)
	_show_toast("Uma arma própria foi forjada.")
	audio.play_sfx("item")

func _rest() -> void:
	_advance_days(2)
	if life_over: return
	var life := world_state.current_life
	life["meridian_integrity"] = minf(float(life.get("meridian_integrity",1.0))+0.025,1.0)
	_show_toast("Dois dias de descanso recuperaram pequenas lesões.")

func _sect_business() -> void:
	_advance_days(7)
	if life_over:return
	if int(world_state.current_life.get("realm_index",0)) < 1:
		_show_toast("A seita não considera um mortal sem Qi como discípulo de cultivo.")
		return
	world_state.current_life["sect_reputation"] = int(world_state.current_life.get("sect_reputation",0))+rng.randi_range(1,3)
	_show_toast("Você cumpriu deveres da seita e ganhou reputação.")

func _trial() -> void:
	_advance_days(5)
	if life_over:return
	var realm := int(world_state.current_life.get("realm_index",0))
	var phase := _current_phase()
	var chance := clampf(0.52 + float(realm-phase*2)*0.05 + float(world_state.current_life.get("willpower",50))/300.0,0.12,0.88)
	if rng.randf() < chance:
		world_state.current_life["sect_reputation"] = int(world_state.current_life.get("sect_reputation",0))+4
		world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+2.0
		_show_event("PROVAÇÃO SUPERADA","Você saiu mais conhecido — e sabendo algo que não sabia antes.",[["CONTINUAR",Callable(self,"_close_overlay")]])
		audio.play_sfx("breakthrough")
	else:
		_damage_meridians(0.08)
		_show_event("PROVAÇÃO FALHOU","Você não morreu, mas o corpo pagou pelo erro.",[["RECUPERAR-SE",Callable(self,"_close_overlay")]])
		audio.play_sfx("danger")

func _seek_technique() -> void:
	_advance_days(10)
	if life_over:return
	if int(world_state.current_life.get("realm_index",0)) < 1:
		_show_toast("Sem Qi, os diagramas espirituais parecem apenas tinta.")
		return
	var rep := int(world_state.current_life.get("sect_reputation",0))
	if rep < 3:
		_show_toast("Seu mérito ainda é baixo demais para receber um manual verdadeiro.")
		return
	_add_item({"name":"Arte de Circulação do Véu","qty":1,"kind":"Manual","rarity":"Raro","desc":"Manual de cultivo da seita, concedido por mérito."})
	_show_toast("Uma técnica verdadeira foi concedida.")
	audio.play_sfx("rare")

func _alchemy() -> void:
	_advance_days(4)
	if life_over:return
	var chance := 0.45 + float(world_state.current_life.get("worldly_knowledge",0.0))/200.0
	if rng.randf() < chance:
		_add_item({"name":"Pílula de recuperação","qty":1,"kind":"Consumível","rarity":"Raro","desc":"Estabiliza ferimentos leves em meridianos."})
		_show_toast("A fornada produziu uma pílula utilizável.")
		audio.play_sfx("item")
	else:
		_show_toast("A fornada falhou. Materiais e tempo foram perdidos.")

func _comprehend() -> void:
	_advance_days(14)
	if life_over:return
	var life := world_state.current_life
	var gain := 1.0 + float(life.get("intelligence",50))/40.0 + _current_phase()*0.35
	life["dao_insight"] = float(life.get("dao_insight",0.0))+gain
	_show_toast("Contemplação: +%.1f compreensão do Dao." % gain)
	audio.play_sfx("qi")

func _seek_inheritance() -> void:
	_advance_days(18)
	if life_over:return
	var chance := 0.025 + _current_phase()*0.012
	if rng.randf() < chance:
		_add_item({"name":"Herança incompleta de um cultivador morto","qty":1,"kind":"Manual","rarity":"Lendário","desc":"Pode conter conhecimento, mentira ou uma intenção deixada para o próximo corpo."})
		world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+6.0
		_show_event("HERANÇA ENCONTRADA","Algo que esperou décadas ou séculos finalmente respondeu à sua presença.",[["ACEITAR",Callable(self,"_close_overlay")]])
		audio.play_sfx("rare")
	else:
		_show_toast("Você procurou por dezoito dias. O passado não lhe devia resposta.")

func _study_formation() -> void:
	_advance_days(9)
	if life_over:return
	if rng.randf() < 0.18:
		_damage_meridians(0.05)
		_show_toast("Uma formação reagiu e queimou parte dos seus meridianos.")
		audio.play_sfx("danger")
	else:
		world_state.current_life["worldly_knowledge"] = minf(float(world_state.current_life.get("worldly_knowledge",0.0))+4.0,100.0)
		_show_toast("Você compreendeu parte da lógica da formação.")

func _observe() -> void:
	_advance_days(3)
	if life_over:return
	world_state.current_life["worldly_knowledge"] = minf(float(world_state.current_life.get("worldly_knowledge",0.0))+2.0,100.0)
	_show_toast("Você aprendeu sem se colocar diretamente na linha da morte.")

func _mine() -> void:
	_advance_days(6)
	if life_over:return
	var qty := rng.randi_range(1,3)
	_add_item({"name":"Minério espiritual","qty":qty,"kind":"Minério","rarity":"Épico","desc":"Recurso valioso extraído de um território disputado."})
	_show_toast("Mineração: %d unidades obtidas." % qty)
	audio.play_sfx("item")

func _territory() -> void:
	_advance_days(2)
	if life_over:return
	_show_event("CONTROLE TERRITORIAL","Este lugar não está vazio esperando por você. Há sinais de bestas, cultivadores e interesses concorrentes. Conquistar será um sistema de clã/território, não um botão gratuito.",[
		["MEMORIZAR O LOCAL",Callable(self,"_record_territory_interest")],
		["RECUAR",Callable(self,"_close_overlay")]
	])

func _record_territory_interest() -> void:
	_close_overlay()
	world_state.record_world_event("a Vida %d demonstrou interesse em controlar %s." % [world_state.incarnation_index,String(_location()["name"])])
	_show_toast("O local foi registrado na sua história.")

func _beast_pact() -> void:
	_advance_days(5)
	if life_over:return
	var realm := int(world_state.current_life.get("realm_index",0))
	if realm < 10:
		_show_toast("A presença bestial não reconhece você como alguém capaz de negociar.")
		return
	if rng.randf() < 0.16:
		_add_item({"name":"Marca de pacto bestial","qty":1,"kind":"Tesouro","rarity":"Lendário","desc":"Uma promessa entre inteligências de espécies diferentes."})
		_show_toast("Um pacto improvável foi formado.")
		audio.play_sfx("rare")
	else:
		_show_toast("Nenhuma besta aceitou se aproximar sem hostilidade.")

func _karma_event() -> void:
	_advance_days(3)
	if life_over:return
	_show_event("FIO DO KARMA","Uma consequência de escolhas antigas se aproxima. O jogo registra relações e ações; nem toda dívida aparece imediatamente.",[
		["ENFRENTAR",Callable(self,"_karma_face")],
		["EVITAR POR AGORA",Callable(self,"_close_overlay")]
	])

func _karma_face() -> void:
	_close_overlay()
	world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+3.0
	world_state.record_world_event("a Vida %d encarou uma consequência kármica em vez de fugir." % world_state.incarnation_index)
	_show_toast("A consequência foi aceita. Seu entendimento mudou.")

func _celestial_court() -> void:
	_advance_days(9)
	if life_over:return
	world_state.current_life["world_reputation"] = int(world_state.current_life.get("world_reputation",0))+5
	_show_toast("Sua existência foi notada por poderes que antes ignoravam seu nome.")

func _tribulation() -> void:
	var realm := int(world_state.current_life.get("realm_index",0))
	if realm < 17:
		_show_toast("Seu cultivo ainda não chama a atenção de uma tribulação verdadeira.")
		return
	_advance_days(7)
	if life_over:return
	var integrity := float(world_state.current_life.get("meridian_integrity",1.0))
	var chance := clampf(0.34 + integrity*0.32 + float(world_state.current_life.get("dao_insight",0.0))/180.0,0.20,0.82)
	if rng.randf() < chance:
		world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+12.0
		_show_event("TRIBULAÇÃO SUPORTADA","O céu não o reconheceu como vencedor; apenas falhou em destruí-lo.",[["PERMANECER DE PÉ",Callable(self,"_close_overlay")]])
		audio.play_sfx("breakthrough")
	else:
		if rng.randf() < 0.28:
			_end_life("morto durante uma tribulação celestial")
		else:
			_damage_meridians(0.22)
			_show_event("TRIBULAÇÃO INTERROMPIDA","Você sobreviveu, mas parte do caminho precisa ser reconstruída.",[["RECUPERAR-SE",Callable(self,"_close_overlay")]])
			audio.play_sfx("danger")

func _ascend() -> void:
	var realm := int(world_state.current_life.get("realm_index",0))
	if realm < 20:
		_show_toast("O Portal da Ascensão permanece indiferente. Seu reino ainda é insuficiente.")
		return
	_show_event("PORTAL DA ASCENSÃO","Além deste céu existe outro mundo onde seu poder pode voltar a parecer pequeno. A ascensão completa será o fechamento do arco principal do jogo.",[
		["TOCAR O PORTAL",Callable(self,"_ascension_record")],
		["AINDA NÃO",Callable(self,"_close_overlay")]
	])

func _ascension_record() -> void:
	_close_overlay()
	world_state.record_world_event("a Vida %d tocou o Portal da Ascensão e fez os Nove Céus responderem." % world_state.incarnation_index)
	_show_toast("Os Nove Céus responderam. O próximo mundo ainda não foi aberto nesta build.")
	audio.play_sfx("breakthrough")

func _spiritual_test() -> void:
	var life := world_state.current_life
	_advance_days(1)
	if life_over:return
	life["qi_known"] = true
	_show_event("TESTE ESPIRITUAL",BirthSystemScript.hidden_diagnosis(int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL))),[
		["ACEITAR O RESULTADO",Callable(self,"_close_overlay")]
	])
	audio.play_sfx("qi")

func _try_sense_qi() -> void:
	var life := world_state.current_life
	_advance_days(7)
	if life_over:return
	var potential := int(life.get("qi_potential",BirthSystemScript.QiPotential.MORTAL))
	life["qi_known"] = true
	var local_qi := float(_location()["qi"])
	var chance := 0.0
	if potential == BirthSystemScript.QiPotential.AWAKENED:
		chance = 0.30*local_qi
	elif potential == BirthSystemScript.QiPotential.LATENT:
		chance = 0.075*local_qi
	if chance > 0.0 and rng.randf() < minf(chance,0.76):
		_awaken_qi("meditação em %s" % String(_location()["name"]))
	else:
		_show_toast("Sete dias passaram sem resposta clara. O mundo não confirmou que você possui um caminho.")
	_show_screen("cultivation")

func _awaken_qi(source:String) -> void:
	var life := world_state.current_life
	life["qi_awakened"] = true
	life["qi_known"] = true
	life["realm_index"] = maxi(1,int(life.get("realm_index",0)))
	life["cultivation_progress"] = 0.0
	world_state.record_world_event("a Vida %d abriu o caminho do Qi através de %s." % [world_state.incarnation_index,source])
	_show_event("PRIMEIRO SOPRO DE QI","O mundo deixa de parecer silencioso. Você entrou no Refinamento de Qi I.",[
		["ABRIR OS OLHOS",Callable(self,"_close_overlay")]
	])
	audio.play_sfx("breakthrough")

func _meditate() -> void:
	var life := world_state.current_life
	if not bool(life.get("qi_awakened",false)):
		_try_sense_qi()
		return
	_advance_days(30)
	if life_over:return
	var realm := int(life.get("realm_index",1))
	var potential := int(life.get("qi_potential",BirthSystemScript.QiPotential.LATENT))
	var talent := 1.0
	if potential == BirthSystemScript.QiPotential.AWAKENED: talent = 1.35
	elif potential == BirthSystemScript.QiPotential.LATENT: talent = 1.0
	else: talent = 0.70
	var gain := (4.5 + float(life.get("willpower",50))/24.0)*float(_location()["qi"])*talent
	if realm >= 10: gain *= 0.60
	if realm >= 14: gain *= 0.42
	if realm >= 17: gain *= 0.31
	life["cultivation_progress"] = minf(float(life.get("cultivation_progress",0.0))+gain,100.0)
	if rng.randf() < minf(0.018*float(_location()["qi"]),0.16):
		_damage_meridians(0.04)
		_show_toast("O fluxo desviou. Você avançou, mas os meridianos sofreram.")
	else:
		_show_toast("Trinta dias de cultivo: +%.1f%%." % gain)
	audio.play_sfx("qi")
	_show_screen("cultivation")

func _breakthrough() -> void:
	var life := world_state.current_life
	var realm := int(life.get("realm_index",1))
	if realm >= REALMS.size()-1:
		_show_toast("O caminho além da Transcendência ainda não está aberto.")
		return
	_advance_days(12)
	if life_over:return
	var integrity := float(life.get("meridian_integrity",1.0))
	var insight := float(life.get("dao_insight",0.0))
	var chance := clampf(0.40+integrity*0.28+float(life.get("willpower",50))/310.0+insight/400.0-float(realm)*0.011,0.14,0.86)
	if rng.randf() < chance:
		life["realm_index"] = realm+1
		life["cultivation_progress"] = 0.0
		world_state.record_world_event("a Vida %d alcançou %s." % [world_state.incarnation_index,REALMS[realm+1]])
		_show_event("GARGALO ROMPIDO",REALMS[realm+1],[["ESTABILIZAR",Callable(self,"_close_overlay")]])
		audio.play_sfx("breakthrough")
	else:
		life["cultivation_progress"] = 58.0
		_damage_meridians(0.11)
		_show_event("AVANÇO FALHOU","O reino rejeitou sua fundação atual. Parte do progresso se perdeu.",[["RECUPERAR-SE",Callable(self,"_close_overlay")]])
		audio.play_sfx("danger")
	_show_screen("cultivation")

func _seek_heaven_defying() -> void:
	_advance_days(30)
	if life_over:return
	var chance := 0.0012
	if _current_phase() >= 4: chance = 0.0045
	if String(_location().get("tags",[])).find("ruin") >= 0: chance += 0.002
	if rng.randf() < chance:
		world_state.current_life["qi_potential"] = BirthSystemScript.QiPotential.LATENT
		_show_event("OPORTUNIDADE CONTRA O CÉU","Algo raro o suficiente para mudar uma vida mortal respondeu à sua presença.",[
			["ACEITAR A DOR",Callable(self,"_awaken_qi").bind("uma oportunidade que reescreveu seus meridianos")]
		])
		audio.play_sfx("rare")
	else:
		_show_toast("Um mês de busca terminou sem milagre. O mundo não reservou nada para você.")

func _event_flee() -> void:
	_close_overlay()
	_advance_days(1)
	_show_toast("Você recuou antes de transformar curiosidade em cadáver.")

func _event_observe() -> void:
	_close_overlay()
	_advance_days(2)
	world_state.current_life["worldly_knowledge"] = minf(float(world_state.current_life.get("worldly_knowledge",0.0))+2.5,100.0)
	_show_toast("Você aprendeu observando e continuou vivo.")

func _event_risk() -> void:
	_close_overlay()
	var realm := int(world_state.current_life.get("realm_index",0))
	var phase := _current_phase()
	var chance := clampf(0.38+float(realm-phase*2)*0.05+float(world_state.current_life.get("willpower",50))/350.0,0.06,0.80)
	if rng.randf() < chance:
		_gather()
	else:
		if rng.randf() < 0.18:
			_end_life("morto explorando uma zona muito acima de suas capacidades")
		else:
			_damage_meridians(0.09)
			_show_toast("Você escapou ferido e sem recompensa.")

func _accept_encounter() -> void:
	if world_state.accept_current_rare_encounter():
		_show_toast("Essa pessoa agora faz parte da história das suas vidas.")
		audio.play_sfx("rare")
	_show_screen("people")

func _set_inventory_filter(value:String) -> void:
	inventory_filter = value
	audio.play_sfx("tap")
	_show_screen("inventory")

func _inspect_item(item:Dictionary) -> void:
	_show_event(String(item.get("name","Item")),"%s · %s\nQuantidade: %d\n\n%s" % [
		String(item.get("kind","Objeto")),String(item.get("rarity","Comum")),
		int(item.get("qty",1)),String(item.get("desc",""))
	],[["FECHAR",Callable(self,"_close_overlay")]])

func _add_item(item:Dictionary) -> void:
	var inv: Array = world_state.current_life.get("inventory",[])
	for existing in inv:
		if String(existing.get("name","")) == String(item.get("name","")):
			existing["qty"] = int(existing.get("qty",0))+int(item.get("qty",1))
			world_state.current_life["inventory"] = inv
			return
	inv.append(item.duplicate(true))
	world_state.current_life["inventory"] = inv

func _advance_days(days:int) -> void:
	var before := world_state.world_year
	world_state.advance_days(days)
	var years_passed := world_state.world_year-before
	if years_passed > 0:
		var events: Array[String] = NotablePersonSystemScript.advance_people(world_state.notable_people,years_passed,world_state.rng,world_state.world_year)
		for e in events:
			world_state.record_world_event(e)
	_check_natural_death()
	_update_header()

func _check_natural_death() -> void:
	if life_over:return
	var life := world_state.current_life
	var lifespan := int(life.get("natural_lifespan",72))
	var realm := int(life.get("realm_index",0))
	var bonus := realm*8
	if realm >= 10: bonus += 70
	if realm >= 14: bonus += 180
	if realm >= 17: bonus += 400
	if world_state.current_age() >= lifespan+bonus:
		_end_life("velhice")

func _end_life(cause:String) -> void:
	if life_over:return
	life_over = true
	var summary := world_state.end_life(cause,world_state.current_age())
	audio.play_sfx("death")
	_show_event("ESTA VIDA TERMINOU","Vida %d · %s\nIdade: %d anos\nCausa: %s\n\nO mundo continuará se movendo sem você." % [
		int(summary.get("incarnation",0)),String(summary.get("origin","")),
		int(summary.get("age",0)),cause
	],[["REENCARNAR",Callable(self,"_reincarnate")]])

func _reincarnate() -> void:
	_close_overlay()
	world_state.reincarnate()
	life_over = false
	current_location = "spring_village"
	selected_map_phase = 1
	_initialize_life_runtime()
	_show_screen("life")
	_show_toast("Anos passaram. Uma nova vida começou em um mundo que não esperou por você.")

func _damage_meridians(amount:float) -> void:
	var life := world_state.current_life
	life["meridian_integrity"] = maxf(float(life.get("meridian_integrity",1.0))-amount,0.18)

func _travel_to(target:String,days:int) -> void:
	_advance_days(days)
	if life_over:return
	current_location = target
	selected_map_phase = int(GameContentScript.LOCATIONS[target]["phase"])
	_update_phase_presentation()
	audio.play_sfx("travel")
	_show_toast("Você chegou a %s após %d dias." % [String(_location()["name"]),days])
	_show_screen("life")

func _travel_days(from_key:String,to_key:String) -> int:
	if from_key == to_key:return 0
	var a := int(GameContentScript.LOCATIONS[from_key]["travel"])
	var b := int(GameContentScript.LOCATIONS[to_key]["travel"])
	return maxi(1,int(ceil(abs(a-b)*0.65))+1)

func _location() -> Dictionary:
	return GameContentScript.LOCATIONS[current_location]

func _current_phase() -> int:
	return int(_location()["phase"])

func _is_phase_unlocked(phase:int) -> bool:
	var realm := int(world_state.current_life.get("realm_index",0))
	return realm >= int(GameContentScript.phase(phase)["required_realm"])

func _qi_density_label(value:float) -> String:
	if value < 0.5:return "quase inexistente"
	if value < 0.9:return "fraca"
	if value < 1.5:return "moderada"
	if value < 2.5:return "densa"
	if value < 4.5:return "muito densa"
	return "celestial"

func _phase_accent() -> Color:
	match _current_phase():
		1:return Color("#b6b27a")
		2:return Color("#d59b58")
		3:return Color("#7cc6dd")
		4:return Color("#b95c66")
		_:return Color("#d9c373")

func _item_symbol(kind:String) -> String:
	match kind:
		"Erva":return "✿"
		"Minério":return "◆"
		"Manual":return "▤"
		"Tesouro","Dao":return "✦"
		"Talismã","Formação":return "◇"
		"Besta":return "◈"
		"Equipamento":return "†"
		"Consumível","Comida":return "●"
		_:return "□"

func _toggle_music() -> void:
	music_enabled = not music_enabled
	audio.set_music_enabled(music_enabled)
	music_button.text = "♫" if music_enabled else "×"
	_show_toast("Música ativada." if music_enabled else "Música desativada.")

func _on_calendar_changed(_year:int,_day:int) -> void:
	_update_header()

func _on_rare_encounter_changed(profile:Dictionary) -> void:
	if not profile.is_empty():
		_show_toast("Um encontro incomum foi registrado. Veja Pessoas.")
		audio.play_sfx("rare")
	if current_screen == "people":
		_show_screen("people")

func _show_event(title_text:String,body_text:String,actions:Array) -> void:
	for child in overlay_box.get_children():
		child.queue_free()
	var title := _label(title_text,25,Color(0.98,0.86,0.61))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_box.add_child(title)
	var body := _label(body_text,17,Color(0.90,0.93,0.91))
	body.custom_minimum_size = Vector2(540,0)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_box.add_child(body)
	for action in actions:
		var b := Button.new()
		b.text = String(action[0])
		b.custom_minimum_size = Vector2(0,62)
		b.focus_mode = Control.FOCUS_NONE
		var cb: Callable = action[1]
		b.pressed.connect(cb)
		overlay_box.add_child(b)
	overlay.visible = true

func _close_overlay() -> void:
	overlay.visible = false

func _show_toast(text_value:String) -> void:
	toast.text = text_value
	toast.visible = true
	var tween := create_tween()
	tween.tween_interval(3.2)
	tween.tween_callback(func() -> void:
		if is_instance_valid(toast):
			toast.visible = false
	)

func _add_card(title_text:String) -> VBoxContainer:
	var root := MobileCard.new()
	root.panel_color = Color(0.025,0.050,0.060,0.90)
	root.border_color = _phase_accent().darkened(0.22)
	content.add_child(root)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",16)
	margin.add_theme_constant_override("margin_right",16)
	margin.add_theme_constant_override("margin_top",13)
	margin.add_theme_constant_override("margin_bottom",15)
	root.add_child(margin)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation",9)
	margin.add_child(inner)
	var title := _label(title_text,19,Color(0.96,0.84,0.61))
	inner.add_child(title)
	return inner

func _body_label(text_value:String) -> Label:
	var l := _label(text_value,15,Color(0.86,0.90,0.88))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _small_label(text_value:String,color_value:Color) -> Label:
	var l := _label(text_value,13,color_value)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _standalone_button(title_text:String,subtext:String,callback:Callable,sfx_kind:String="tap") -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(668,84)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",15)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func() -> void:
		audio.play_sfx(sfx_kind)
		callback.call()
	)
	return b

func _action_button(title_text:String,subtext:String,callback:Callable) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(329,94)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",13)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func() -> void:
		audio.play_sfx("tap")
		callback.call()
	)
	return b

func _label(text_value:String,size_value:int,color_value:Color) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size",size_value)
	l.modulate = color_value
	return l

func _create_mobile_theme() -> Theme:
	var t := Theme.new()
	t.set_stylebox("normal","Button",_button_style(Color(0.045,0.080,0.092,0.95),Color(0.46,0.49,0.38,0.58)))
	t.set_stylebox("hover","Button",_button_style(Color(0.075,0.115,0.125,0.98),Color(0.76,0.62,0.34,0.82)))
	t.set_stylebox("pressed","Button",_button_style(Color(0.14,0.16,0.14,0.99),Color(0.94,0.74,0.31,0.95)))
	t.set_stylebox("disabled","Button",_button_style(Color(0.03,0.045,0.05,0.78),Color(0.22,0.27,0.27,0.38)))
	t.set_color("font_color","Button",Color(0.91,0.92,0.87))
	t.set_color("font_hover_color","Button",Color(1.0,0.92,0.70))
	t.set_color("font_pressed_color","Button",Color(1.0,0.84,0.42))
	t.set_color("font_disabled_color","Button",Color(0.47,0.51,0.50))
	t.set_font_size("font_size","Button",14)
	return t

func _button_style(bg:Color,border:Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	for corner in ["corner_radius_top_left","corner_radius_top_right","corner_radius_bottom_left","corner_radius_bottom_right"]:
		s.set(corner,14)
	for edge in ["border_width_left","border_width_right","border_width_top","border_width_bottom"]:
		s.set(edge,1)
	s.border_color = border
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 9.0
	s.content_margin_bottom = 9.0
	return s

func _panel_style(color_value:Color,radius:int,border:Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color_value
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left = 14.0
	s.content_margin_right = 14.0
	s.content_margin_top = 12.0
	s.content_margin_bottom = 12.0
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_color = border
	return s
