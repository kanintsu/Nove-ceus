extends Control

const WorldStateScript = preload("res://scripts/core/world_state.gd")
const BirthSystemScript = preload("res://scripts/core/birth_system.gd")
const NotablePersonSystemScript = preload("res://scripts/core/notable_person_system.gd")
const GameContentScript = preload("res://scripts/mobile/game_content.gd")
const MobileAudioScript = preload("res://scripts/mobile/mobile_audio.gd")
const MobileFXScript = preload("res://scripts/mobile/mobile_fx.gd")
const PhaseMapScript = preload("res://scripts/mobile/phase_map_visual.gd")
const TacticalCombatScript = preload("res://scripts/mobile/tactical_combat.gd")
const JourneySystemScript = preload("res://scripts/mobile/journey_system.gd")
const ContractSystemScript = preload("res://scripts/mobile/contract_system.gd")
const RelationshipSystemScript = preload("res://scripts/mobile/relationship_system.gd")
const CultivationSessionScript = preload("res://scripts/mobile/cultivation_session.gd")
const WorldEventSystemScript = preload("res://scripts/mobile/world_event_system.gd")
const SectMissionSystemScript = preload("res://scripts/mobile/sect_mission_system.gd")
const CelestialBackdropScript = preload("res://scripts/mobile/celestial_backdrop.gd")
const NavTileScript = preload("res://scripts/mobile/nav_tile.gd")
const EventCardScript = preload("res://scripts/mobile/event_card.gd")
const OrnateSeparatorScript = preload("res://scripts/mobile/ornate_separator.gd")
const PortraitMedallionScript = preload("res://scripts/mobile/portrait_medallion.gd")
const CultivationDiagramScript = preload("res://scripts/mobile/cultivation_diagram.gd")
const InventoryTileScript = preload("res://scripts/mobile/inventory_tile.gd")

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
	"Formação do Espírito",
	"Transformação Celestial",
	"Vazio Espiritual",
	"Transcendência",
	"Meio Imortal",
	"Imortal Terreno",
	"Imortal Celestial",
	"Imortal Verdadeiro",
	"Grande Imortal",
	"Rei Imortal",
	"Imperador Imortal",
	"Santo Celestial",
	"Além do Céu"
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
var active_battle: Dictionary = {}
var active_journey: Dictionary = {}
var pending_world_event_uid := ""
var life_over := false
var music_enabled := true

var backdrop: Control
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
	WorldEventSystemScript.ensure_events(world_state.active_dynamic_events,world_state.world_year,world_state.world_day,rng)
	SectMissionSystemScript.refresh_board(world_state.current_life,world_state.world_year,world_state.world_day,rng)

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
	ContractSystemScript.ensure_contracts(life,_current_phase(),world_state.world_year,world_state.world_day,rng)
	SectMissionSystemScript.ensure_state(life)

func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = _create_mobile_theme()

	backdrop = CelestialBackdropScript.new()
	add_child(backdrop)

	add_child(fx)
	move_child(fx,1)

	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.015,0.028,0.032,0.10)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	move_child(veil,2)

	# Life header: real UI hierarchy, not a black rectangle over an image.
	var top_frame := MobileCard.new()
	top_frame.position = Vector2(12,12)
	top_frame.size = Vector2(696,170)
	top_frame.custom_minimum_size = Vector2(696,170)
	top_frame.panel_color = Color("#10272d")
	top_frame.border_color = Color("#d1b76b")
	top_frame.inner_glow = Color("#5e9c96")
	add_child(top_frame)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left",16)
	top_margin.add_theme_constant_override("margin_right",14)
	top_margin.add_theme_constant_override("margin_top",15)
	top_margin.add_theme_constant_override("margin_bottom",14)
	top_frame.add_child(top_margin)

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation",14)
	top_margin.add_child(header_row)

	var portrait := PortraitMedallionScript.new()
	portrait.setup(_current_phase(),int(world_state.current_life.get("realm_index",0)),_phase_accent())
	header_row.add_child(portrait)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation",3)
	header_row.add_child(info)

	phase_label = _label("",13,Color("#d9c27d"))
	info.add_child(phase_label)

	header_title = _label("",24,Color("#f2e8c9"))
	info.add_child(header_title)

	header_meta = _label("",14,Color("#d3dfd8"))
	info.add_child(header_meta)

	header_resource = _label("",13,Color("#9fd1c5"))
	header_resource.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(header_resource)

	var controls := VBoxContainer.new()
	controls.custom_minimum_size = Vector2(54,0)
	header_row.add_child(controls)
	music_button = Button.new()
	music_button.text = "♫"
	music_button.custom_minimum_size = Vector2(52,46)
	music_button.focus_mode = Control.FOCUS_NONE
	music_button.pressed.connect(_toggle_music)
	controls.add_child(music_button)
	var seal := Label.new()
	seal.text = "九\n天"
	seal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal.add_theme_font_size_override("font_size",14)
	seal.modulate = Color("#d5bd72")
	controls.add_child(seal)

	var title_band := PanelContainer.new()
	title_band.position = Vector2(32,191)
	title_band.size = Vector2(656,54)
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color("#122a30")
	title_style.bg_color.a = 0.84
	title_style.corner_radius_top_left = 24
	title_style.corner_radius_top_right = 24
	title_style.corner_radius_bottom_left = 24
	title_style.corner_radius_bottom_right = 24
	title_style.border_width_bottom = 1
	title_style.border_color = Color(_phase_accent(),0.48)
	title_band.add_theme_stylebox_override("panel",title_style)
	add_child(title_band)
	screen_title = _label("",25,Color("#f3e5b9"))
	screen_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	screen_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_band.add_child(screen_title)

	content_scroll = ScrollContainer.new()
	content_scroll.position = Vector2(18,258)
	content_scroll.size = Vector2(684,834)
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_scroll.add_theme_constant_override("scrollbar_margin_left",6)
	add_child(content_scroll)

	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(668,0)
	content.add_theme_constant_override("separation",14)
	content_scroll.add_child(content)

	toast = _label("",15,Color("#f4ead1"))
	toast.position = Vector2(42,1018)
	toast.size = Vector2(636,66)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_stylebox_override("normal",_panel_style(Color("#10272d"),16,Color(_phase_accent(),0.8)))
	toast.visible = false
	toast.z_index = 40
	add_child(toast)

	# Dedicated symbolic navigation; no generic giant rectangular buttons.
	var nav_back := PanelContainer.new()
	nav_back.position = Vector2(6,1108)
	nav_back.size = Vector2(708,158)
	var nav_style := StyleBoxFlat.new()
	nav_style.bg_color = Color("#09191e")
	nav_style.bg_color.a = 0.96
	nav_style.corner_radius_top_left = 26
	nav_style.corner_radius_top_right = 26
	nav_style.corner_radius_bottom_left = 12
	nav_style.corner_radius_bottom_right = 12
	nav_style.border_width_top = 1
	nav_style.border_color = Color(_phase_accent(),0.46)
	nav_back.add_theme_stylebox_override("panel",nav_style)
	add_child(nav_back)

	bottom_nav = HBoxContainer.new()
	bottom_nav.position = Vector2(12,1118)
	bottom_nav.size = Vector2(696,140)
	bottom_nav.add_theme_constant_override("separation",5)
	add_child(bottom_nav)

	for data in [
		["life","VIDA"],["map","MAPA"],["cultivation","CULTIVO"],
		["people","PESSOAS"],["inventory","BOLSA"],["chronicle","CRÔNICA"]
	]:
		var key: String = data[0]
		var btn := NavTileScript.new()
		btn.setup(key,String(data[1]),_phase_accent())
		btn.pressed.connect(_nav_pressed.bind(key))
		bottom_nav.add_child(btn)
		nav_buttons[key] = btn

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.005,0.012,0.016,0.88)
	overlay.z_index = 100
	overlay.visible = false
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var event_frame := MobileCard.new()
	event_frame.custom_minimum_size = Vector2(620,0)
	event_frame.panel_color = Color("#10272d")
	event_frame.border_color = Color("#d5ba6a")
	event_frame.inner_glow = Color("#5b9e97")
	center.add_child(event_frame)
	var event_margin := MarginContainer.new()
	event_margin.add_theme_constant_override("margin_left",22)
	event_margin.add_theme_constant_override("margin_right",22)
	event_margin.add_theme_constant_override("margin_top",24)
	event_margin.add_theme_constant_override("margin_bottom",22)
	event_frame.add_child(event_margin)
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
		var b = nav_buttons[key]
		if b.has_method("set_selected"):
			b.set_selected(key == screen_key)
		else:
			b.disabled = key == screen_key

	match screen_key:
		"life": _render_life()
		"map": _render_map()
		"cultivation": _render_cultivation()
		"people": _render_people()
		"inventory": _render_inventory()
		"chronicle": _render_chronicle()
		"sect": _render_sect()

	_update_header()
	_update_phase_presentation()

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()
	content_scroll.scroll_vertical = 0

func _update_phase_presentation() -> void:
	var phase := _current_phase()
	if backdrop != null and backdrop.has_method("set_phase"):
		backdrop.set_phase(phase)
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

	_render_world_events()
	_render_contract_board()

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

	var action_separator := OrnateSeparatorScript.new()
	action_separator.setup("AÇÕES DESTE LUGAR",_phase_accent())
	content.add_child(action_separator)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",10)
	for action in loc.get("actions",[]):
		var def := _action_definition(String(action))
		grid.add_child(_action_button(String(def[0]),String(def[1]),_perform_location_action.bind(String(action))))
	content.add_child(grid)

	var sect_status := String(world_state.current_life.get("sect_status","outsider"))
	if sect_status != "outsider" or _current_phase() >= 2:
		content.add_child(_standalone_button("SEITA DO CÉU VELADO","Missões, mérito, posição e oportunidades da seita.",_show_screen.bind("sect"),"tap"))

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
	var map_sep := OrnateSeparatorScript.new()
	map_sep.setup("REGIÕES E ROTAS",_phase_accent())
	content.add_child(map_sep)

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
	var unlocked := true
	var intro := _add_card("%s" % String(phase_data["name"]))
	intro.add_child(_body_label("%s\n\nObjetivo: %s" % [
		String(phase_data["subtitle"]),String(phase_data["goal"])
	]))
	var required := int(phase_data["required_realm"])
	var current_realm := int(world_state.current_life.get("realm_index",0))
	if current_realm < required:
		intro.add_child(_small_label("ÁREA ABERTA, MAS MUITO ACIMA DO RECOMENDADO · %s" % REALMS[clampi(required,0,REALMS.size()-1)],Color(0.96,0.61,0.53)))
	else:
		intro.add_child(_small_label("Seu reino atual está dentro da faixa recomendada para esta fase.",Color(0.65,0.88,0.72)))

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
	else:
		var days := _travel_days(current_location,key)
		var target_phase := int(loc.get("phase",1))
		var recommended := int(GameContentScript.phase(target_phase)["required_realm"])
		var current_realm := int(world_state.current_life.get("realm_index",0))
		if current_realm < recommended:
			travel.text = "ARRISCAR VIAGEM · %d dias · ACIMA DO SEU REINO" % days
		else:
			travel.text = "VIAJAR PARA ESTE LUGAR · %d dias" % days
		travel.pressed.connect(_travel_to.bind(key,days))
	card.add_child(travel)

func _map_location_selected(key:String) -> void:
	map_selected_location = key
	audio.play_sfx("tap")
	_show_screen("map")
	if backdrop != null and backdrop.has_method("set_phase"):
		backdrop.set_phase(selected_map_phase)
	if fx != null:
		fx.set_phase(selected_map_phase)

func _select_map_phase(value:int) -> void:
	audio.play_sfx("tap")
	selected_map_phase = clampi(value,1,5)
	var keys: Array[String] = GameContentScript.phase_locations(selected_map_phase)
	map_selected_location = current_location if keys.has(current_location) else (keys[0] if not keys.is_empty() else "")
	_show_screen("map")
	if backdrop != null and backdrop.has_method("set_phase"):
		backdrop.set_phase(selected_map_phase)
	if fx != null:
		fx.set_phase(selected_map_phase)

func _render_cultivation() -> void:
	screen_title.text = "CULTIVO · CORPO · DAO"
	var cult_sep := OrnateSeparatorScript.new()
	cult_sep.setup("DANTIAN E MERIDIANOS",_phase_accent())
	content.add_child(cult_sep)
	var life := world_state.current_life
	var realm_index := int(life.get("realm_index",0))

	var diagram := CultivationDiagramScript.new()
	diagram.setup(
		realm_index,
		float(life.get("cultivation_progress",0.0)),
		float(life.get("meridian_integrity",1.0)),
		float(life.get("dao_insight",0.0)),
		_phase_accent()
	)
	content.add_child(diagram)

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
		var methods := _add_card("Método desta sessão")
		for mode_key in ["safe","compress","temper","insight","reckless"]:
			var mode: Dictionary = CultivationSessionScript.MODES[mode_key]
			var mb := Button.new()
			mb.text = "%s · %d dias\n%s" % [String(mode["name"]),int(mode["days"]),String(mode["text"])]
			mb.custom_minimum_size = Vector2(0,72)
			mb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			mb.focus_mode = Control.FOCUS_NONE
			mb.pressed.connect(_cultivate_mode.bind(mode_key))
			methods.add_child(mb)
		if float(life.get("cultivation_progress",0.0)) >= 100.0:
			content.add_child(_standalone_button("ROMPER O GARGALO","Tentar avançar de reino. Integridade, Dao e vontade influenciam o resultado.",_breakthrough,"breakthrough"))
	else:
		content.add_child(_standalone_button("TENTAR SENTIR O QI","Sete dias de meditação. Não há garantia de resposta.",_try_sense_qi,"qi"))
		if current_location == "qinghe_city":
			content.add_child(_standalone_button("TESTE ESPIRITUAL DE QINGHE","Um teste conhecido pode revelar parte da sua aptidão.",_spiritual_test,"qi"))
		if bool(life.get("qi_known",false)) and int(life.get("qi_potential",3)) == BirthSystemScript.QiPotential.MORTAL:
			content.add_child(_standalone_button("DESAFIAR O DESTINO","Buscar algo capaz de reconstruir um corpo mortal. Chance extremamente baixa.",_seek_heaven_defying,"danger"))

func _render_people() -> void:
	screen_title.text = "PESSOAS · FAMÍLIA · DESTINOS"
	var people_sep := OrnateSeparatorScript.new()
	people_sep.setup("VÍNCULOS QUE SOBREVIVEM AO TEMPO",_phase_accent())
	content.add_child(people_sep)

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
			RelationshipSystemScript.ensure_person(person)
			status += "\nVínculo: %s · Afinidade %d · Confiança %d" % [
				RelationshipSystemScript.relation_title(person),
				int(person.get("bond",0)),int(person.get("trust",0))
			]
			pc.add_child(_body_label(status))
			var rel_grid := GridContainer.new()
			rel_grid.columns = 2
			rel_grid.add_theme_constant_override("h_separation",6)
			rel_grid.add_theme_constant_override("v_separation",6)
			for rel_action in [
				["talk","CONVERSAR"],["teach","ENSINAR"],["train","TREINAR JUNTO"],["support","APOIAR · 20 prata"]
			]:
				var rb := Button.new()
				rb.text = String(rel_action[1])
				rb.custom_minimum_size = Vector2(300,50)
				rb.pressed.connect(_person_action.bind(person,String(rel_action[0])))
				rel_grid.add_child(rb)
			pc.add_child(rel_grid)

	var social := _add_card("Mundo Social")
	social.add_child(_body_label("Reputação no mundo: %d   ·   Reputação na seita: %d\nRelações futuras incluem família, discípulos, mestres, rivais, clãs e descendentes." % [
		int(world_state.current_life.get("world_reputation",0)),
		int(world_state.current_life.get("sect_reputation",0))
	]))

func _render_inventory() -> void:
	screen_title.text = "BOLSA · EQUIPAMENTO · TESOUROS"
	var bag_sep := OrnateSeparatorScript.new()
	bag_sep.setup("PERTENCES DESTA VIDA",_phase_accent())
	content.add_child(bag_sep)
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
		var tile := InventoryTileScript.new()
		tile.setup(item)
		tile.inspect_requested.connect(_inspect_item)
		grid.add_child(tile)
	content.add_child(grid)

func _render_chronicle() -> void:
	screen_title.text = "CRÔNICA DOS NOVE CÉUS"
	var chron_sep := OrnateSeparatorScript.new()
	chron_sep.setup("MEMÓRIA DAS VIDAS",_phase_accent())
	content.add_child(chron_sep)
	var phase_card := _add_card("Fases Conhecidas")
	var realm_index := int(world_state.current_life.get("realm_index",0))
	var unlocked := GameContentScript.unlocked_phase_for_realm(realm_index)
	phase_card.add_child(_body_label("Faixa recomendada pelo seu reino: até Fase %d / 5\nTodas as cinco fases podem ser visitadas. O jogo não impede você de entrar cedo demais — apenas não reduz o perigo para protegê-lo." % unlocked))

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
		"train": _train_body()
		"spar": _start_tactical_combat("spar")
		"rumors": _hear_rumor()
		"travel": _show_screen("map")
		"encounter","relationships": _seek_people()
		"gather": _gather()
		"meditate": _cultivate_mode("safe") if bool(world_state.current_life.get("qi_awakened",false)) else _try_sense_qi()
		"hunt": _start_tactical_combat("hunt")
		"explore": _start_journey()
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
			_start_journey()

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
	_record_contract_action("work")
	_show_toast("Sete dias de trabalho renderam %d de prata." % pay)
	audio.play_sfx("item")
	_show_screen("life")

func _study() -> void:
	var life := world_state.current_life
	_advance_days(7)
	if life_over: return
	var gain := 3.0 + float(life.get("intelligence",50))/28.0
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge",0.0))+gain,100.0)
	_record_contract_action("study")
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
	_record_contract_action("rumors")
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
	_record_contract_action("gather")
	_show_toast("Coleta: %s ×%d." % [String(found["name"]),int(found["qty"])])
	audio.play_sfx("item")
	_show_screen("inventory")

func _start_journey() -> void:
	if not active_journey.is_empty():
		_render_journey_overlay()
		return
	active_journey = JourneySystemScript.create_journey(_location(),_current_phase())
	_render_journey_overlay()

func _render_journey_overlay() -> void:
	if active_journey.is_empty():
		return
	var step: int = int(active_journey.get("step",1))
	var max_steps: int = int(active_journey.get("max_steps",3))
	var risk: int = int(active_journey.get("risk",0))
	var discovery: int = int(active_journey.get("discovery",0))
	var supplies: int = int(active_journey.get("supplies",0))
	_show_event(
		"EXPEDIÇÃO · ETAPA %d/%d" % [step,max_steps],
		"%s\n\nRisco acumulado: %d   ·   Descoberta: %d   ·   Suprimentos: %d\n\nEscolha como avançar." % [
			String(active_journey.get("location_name","Local")),risk,discovery,supplies
		],
		[
			["ROTA CAUTELOSA · +segurança",Callable(self,"_journey_choose").bind("safe")],
			["ROTA DESCONHECIDA · equilíbrio",Callable(self,"_journey_choose").bind("balanced")],
			["ROTA PROFUNDA · +risco / +descoberta",Callable(self,"_journey_choose").bind("deep")],
			["ENCERRAR EXPEDIÇÃO",Callable(self,"_journey_abort")]
		]
	)

func _journey_choose(route_key:String) -> void:
	_close_overlay()
	if active_journey.is_empty():
		return
	var result: Dictionary = JourneySystemScript.choose_route(active_journey,route_key,world_state.current_life,rng)
	_advance_days(int(result.get("days",1)))
	if life_over:
		active_journey.clear()
		return
	var event_type: String = String(result.get("type","quiet"))
	var event_text: String = String(result.get("text",""))
	match event_type:
		"danger":
			_show_event("PERIGO NA ROTA",event_text,[
				["ENFRENTAR",Callable(self,"_journey_combat")],
				["RECUAR E ABANDONAR",Callable(self,"_journey_abort")]
			])
			audio.play_sfx("danger")
		"discovery":
			_show_event("ALGO FORA DO COMUM",event_text,[
				["INVESTIGAR",Callable(self,"_journey_discovery")],
				["NÃO ARRISCAR",Callable(self,"_journey_continue")]
			])
			audio.play_sfx("rare")
		"insight":
			world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+1.5
			_show_event("COMPREENSÃO NA ESTRADA",event_text+"\n\nDao +1,5.",[
				["CONTINUAR",Callable(self,"_journey_continue")]
			])
			audio.play_sfx("qi")
		_:
			_show_event("A JORNADA CONTINUA",event_text,[
				["AVANÇAR",Callable(self,"_journey_continue")]
			])

func _journey_discovery() -> void:
	_close_overlay()
	if active_journey.is_empty():
		return
	var quality: int = JourneySystemScript.final_quality(active_journey)
	var phase_loot: Array = LOOT_BY_PHASE[_current_phase()]
	var found: Dictionary = phase_loot[rng.randi_range(0,phase_loot.size()-1)].duplicate(true)
	found["qty"] = maxi(1,int(found.get("qty",1))+int(quality/5.0))
	_add_item(found)
	active_journey["discovery"] = int(active_journey.get("discovery",0))+2
	_show_toast("Descoberta: %s ×%d." % [String(found["name"]),int(found["qty"])])
	audio.play_sfx("item")
	_journey_continue()

func _journey_continue() -> void:
	_close_overlay()
	if active_journey.is_empty():
		return
	JourneySystemScript.advance_step(active_journey)
	if bool(active_journey.get("finished",false)):
		_journey_finish()
	else:
		_render_journey_overlay()

func _journey_combat() -> void:
	_close_overlay()
	_start_tactical_combat("journey")

func _journey_abort() -> void:
	_close_overlay()
	active_journey.clear()
	pending_world_event_uid = ""
	_show_toast("Você encerrou a expedição e voltou vivo.")
	_show_screen("life")

func _journey_finish() -> void:
	if active_journey.is_empty():
		return
	var quality: int = JourneySystemScript.final_quality(active_journey)
	var reward_silver: int = 8+quality*4
	world_state.current_life["silver"] = int(world_state.current_life.get("silver",0))+reward_silver
	if quality >= 8:
		world_state.record_world_event("a Vida %d concluiu uma exploração arriscada em %s." % [world_state.incarnation_index,String(_location()["name"])])
	_record_contract_action("explore")
	if not pending_world_event_uid.is_empty():
		WorldEventSystemScript.resolve(world_state.active_dynamic_events,pending_world_event_uid)
		pending_world_event_uid = ""
	active_journey.clear()
	_close_overlay()
	_show_toast("Expedição concluída. Qualidade %d · +%d prata." % [quality,reward_silver])
	_show_screen("life")

func _hunt() -> void:
	_start_tactical_combat("hunt")
	return
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
	_show_screen("sect")

func _trial() -> void:
	_advance_days(5)
	if life_over:return
	var realm := int(world_state.current_life.get("realm_index",0))
	var phase := _current_phase()
	var chance := clampf(0.52 + float(realm-phase*2)*0.05 + float(world_state.current_life.get("willpower",50))/300.0,0.12,0.88)
	if rng.randf() < chance:
		world_state.current_life["sect_reputation"] = int(world_state.current_life.get("sect_reputation",0))+4
		world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+2.0
		_record_contract_action("trial")
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
	_record_contract_action("comprehend")
	_show_toast("Contemplação: +%.1f compreensão do Dao." % gain)
	audio.play_sfx("qi")

func _seek_inheritance() -> void:
	_advance_days(18)
	if life_over:return
	var chance := 0.025 + _current_phase()*0.012
	if rng.randf() < chance:
		_add_item({"name":"Herança incompleta de um cultivador morto","qty":1,"kind":"Manual","rarity":"Lendário","desc":"Pode conter conhecimento, mentira ou uma intenção deixada para o próximo corpo."})
		world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+6.0
		_record_contract_action("inheritance")
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
		_record_contract_action("formations")
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
		_record_contract_action("tribulation")
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

func _cultivate_mode(mode_key:String) -> void:
	var life := world_state.current_life
	if not bool(life.get("qi_awakened",false)):
		_try_sense_qi()
		return
	var result: Dictionary = CultivationSessionScript.perform(mode_key,life,float(_location()["qi"]),rng)
	_advance_days(int(result.get("days",1)))
	if life_over:
		return
	life["cultivation_progress"] = minf(100.0,float(life.get("cultivation_progress",0.0))+float(result.get("progress",0.0)))
	life["meridian_integrity"] = clampf(float(life.get("meridian_integrity",1.0))+float(result.get("meridian_delta",0.0)),0.18,1.0)
	life["dao_insight"] = float(life.get("dao_insight",0.0))+float(result.get("dao_gain",0.0))
	var summary := "%s\n\nProgresso +%.1f%% · Dao +%.1f · Meridianos agora %.0f%%" % [
		String(result.get("text","Sessão concluída.")),
		float(result.get("progress",0.0)),float(result.get("dao_gain",0.0)),
		float(life.get("meridian_integrity",1.0))*100.0
	]
	_show_event(String(result.get("name","Cultivo")),summary,[["ENCERRAR SESSÃO",Callable(self,"_close_overlay")]])
	if bool(result.get("deviation",false)):
		audio.play_sfx("danger")
	else:
		audio.play_sfx("qi")
	_show_screen("cultivation")

func _meditate() -> void:
	_cultivate_mode("safe")
	return
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

func _render_world_events() -> void:
	WorldEventSystemScript.ensure_events(world_state.active_dynamic_events,world_state.world_year,world_state.world_day,rng)
	var active: Array[Dictionary] = WorldEventSystemScript.active_events(world_state.active_dynamic_events)

	var separator := OrnateSeparatorScript.new()
	separator.setup("EVENTOS DO MUNDO",_phase_accent())
	content.add_child(separator)

	if active.is_empty():
		var empty := _add_card("O mundo está quieto — por enquanto")
		empty.add_child(_body_label("Nenhum acontecimento importante está ativo. O calendário continua avançando e novas situações podem surgir."))
		return

	for event in active:
		var key: String = String(event.get("location","spring_village"))
		var location_name := key
		if GameContentScript.LOCATIONS.has(key):
			location_name = String(GameContentScript.LOCATIONS[key]["name"])
		var remaining: int = WorldEventSystemScript.remaining_days(event,world_state.world_year,world_state.world_day)
		var recommended: int = int(event.get("recommended_realm",0))
		var current_realm: int = int(world_state.current_life.get("realm_index",0))
		var warning := ""
		if current_realm < recommended:
			warning = "⚠ Recomendado: %s" % REALMS[clampi(recommended,0,REALMS.size()-1)]
		var event_card := EventCardScript.new()
		event_card.setup(event,location_name,remaining,warning,_event_accent(String(event.get("type",""))))
		event_card.follow_requested.connect(_world_event_go)
		content.add_child(event_card)

func _event_accent(event_type:String) -> Color:
	match event_type:
		"spirit_rain": return Color("#79cddd")
		"plague": return Color("#9ec5a2")
		"eclipse": return Color("#a58bd1")
		"faction_conflict","tournament","rogue_bounty": return Color("#d17b5d")
		"beast_tide": return Color("#c96c62")
		"herb_bloom": return Color("#8dc68c")
		"ancient_opening": return Color("#c7a46d")
		"sect_recruitment": return Color("#e0c36f")
		"spirit_vein": return Color("#70d1b5")
		"heaven_omen": return Color("#d4b7ed")
		_: return _phase_accent()

func _world_event_go(uid:String) -> void:
	var event: Dictionary = WorldEventSystemScript.find_event(world_state.active_dynamic_events,uid)
	if event.is_empty():
		_show_toast("Esse evento já terminou.")
		return
	var target := String(event.get("location","spring_village"))
	if current_location != target:
		var days := _travel_days(current_location,target)
		_advance_days(days)
		if life_over:
			return
		current_location = target
		selected_map_phase = int(GameContentScript.LOCATIONS[target]["phase"])
		_update_phase_presentation()
		audio.play_sfx("travel")
	_world_event_resolve(uid)

func _world_event_resolve(uid:String) -> void:
	var event: Dictionary = WorldEventSystemScript.find_event(world_state.active_dynamic_events,uid)
	if event.is_empty():
		return
	var event_type := String(event.get("type",""))
	match event_type:
		"beast_tide","rogue_bounty","tournament","faction_conflict":
			pending_world_event_uid = uid
			_start_tactical_combat("world_event")
		"ancient_opening":
			pending_world_event_uid = uid
			_start_journey()
		"sect_recruitment":
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_screen("sect")
		"spirit_rain":
			_advance_days(3)
			if bool(world_state.current_life.get("qi_awakened",false)):
				world_state.current_life["cultivation_progress"] = minf(100.0,float(world_state.current_life.get("cultivation_progress",0.0))+12.0)
				world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+2.0
				_show_toast("Você absorveu a Chuva Espiritual: +12% cultivo e +2 Dao.")
			else:
				_show_toast("Sem um caminho aberto, você apenas sente que o ar mudou.")
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
		"herb_bloom":
			_add_item({"name":"Erva de Florescimento","qty":3,"kind":"Erva","rarity":"Raro","desc":"Colhida durante um florescimento que durou poucos dias."})
			_advance_days(2)
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("Você aproveitou o florescimento antes que outros chegassem.")
		"caravan","merchant_fair":
			var gain := 25+rng.randi_range(0,35)
			world_state.current_life["silver"] = int(world_state.current_life.get("silver",0))+gain
			_advance_days(2)
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("Negócios e contatos renderam %d de prata." % gain)
		"plague":
			var knowledge := float(world_state.current_life.get("worldly_knowledge",0.0))
			_advance_days(7)
			if knowledge >= 35.0:
				world_state.current_life["world_reputation"] = int(world_state.current_life.get("world_reputation",0))+4
				_show_toast("Seu conhecimento ajudou a salvar vidas. Reputação +4.")
			else:
				_show_toast("Você ajudou como pôde, mas faltou conhecimento para mudar o curso da doença.")
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
		"flood":
			_advance_days(6)
			world_state.current_life["body_training"] = minf(100.0,float(world_state.current_life.get("body_training",0.0))+2.0)
			world_state.current_life["world_reputation"] = int(world_state.current_life.get("world_reputation",0))+2
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("Você trabalhou na enchente. Corpo +2 e reputação +2.")
		"spirit_vein":
			world_state.current_life["spirit_stones"] = int(world_state.current_life.get("spirit_stones",0))+rng.randi_range(2,5)
			_advance_days(4)
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("Você obteve algumas pedras espirituais antes da região ser disputada.")
		"eclipse","heaven_omen":
			_advance_days(4)
			world_state.current_life["dao_insight"] = float(world_state.current_life.get("dao_insight",0.0))+4.0
			if rng.randf() < 0.18:
				_damage_meridians(0.04)
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("O fenômeno deixou +4 Dao, mas observar o Céu nunca é completamente seguro.")
		_:
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,uid)
			_show_toast("Você acompanhou o evento até o fim.")
	if event_type not in ["beast_tide","rogue_bounty","tournament","faction_conflict","ancient_opening","sect_recruitment"]:
		_show_screen("life")

func _render_sect() -> void:
	screen_title.text = "SEITA DO CÉU VELADO"
	var life := world_state.current_life
	SectMissionSystemScript.ensure_state(life)
	SectMissionSystemScript.refresh_board(life,world_state.world_year,world_state.world_day,rng)
	var status := String(life.get("sect_status","outsider"))
	var status_card := _add_card("Sua posição")
	status_card.add_child(_body_label("%s\nMérito: %d · Reputação da seita: %d\n\nA seita aceita servos mortais, discípulos e especialistas. Qi muda sua posição, mas não é necessário para existir aqui." % [
		SectMissionSystemScript.status_label(status),int(life.get("sect_merit",0)),int(life.get("sect_reputation",0))
	]))
	var advance := Button.new()
	advance.text = "PEDIR ENTRADA / PROMOÇÃO"
	advance.custom_minimum_size = Vector2(0,56)
	advance.pressed.connect(_sect_join_or_upgrade)
	status_card.add_child(advance)

	var active_card := _add_card("Missões aceitas")
	var active_missions: Array = life.get("sect_missions",[])
	var active_shown := 0
	var now := world_state.world_year*360+world_state.world_day
	for mission in active_missions:
		if bool(mission.get("claimed",false)):
			continue
		active_shown += 1
		var failed := bool(mission.get("failed",false))
		var completed := bool(mission.get("completed",false))
		var remaining := maxi(0,int(mission.get("expires",now))-now)
		active_card.add_child(_body_label("%s\n%s\nProgresso %d/%d · %d dias restantes%s" % [
			String(mission.get("title","Missão")),String(mission.get("text","")),
			int(mission.get("progress",0)),int(mission.get("goal",1)),remaining,
			" · FALHOU" if failed else (" · CONCLUÍDA" if completed else "")
		]))
		if completed and not failed:
			var claim := Button.new()
			claim.text = "RECEBER MÉRITO E RECOMPENSA"
			claim.custom_minimum_size = Vector2(0,48)
			claim.pressed.connect(_claim_sect_mission.bind(String(mission.get("uid",""))))
			active_card.add_child(claim)
	if active_shown == 0:
		active_card.add_child(_body_label("Você ainda não aceitou nenhuma missão."))

	var board := _add_card("Quadro de missões")
	var available: Array = life.get("sect_available",[])
	for mission in available:
		if bool(mission.get("accepted",false)):
			continue
		var rec := int(mission.get("realm",0))
		var current := int(life.get("realm_index",0))
		var warning := ""
		if current < rec:
			warning = "\n⚠ Acima do seu reino recomendado: %s" % REALMS[clampi(rec,0,REALMS.size()-1)]
		board.add_child(_body_label("%s\n%s\nObjetivo %d× %s · Mérito %d · %d prata%s" % [
			String(mission.get("title","Missão")),String(mission.get("text","")),
			int(mission.get("goal",1)),String(mission.get("action","ação")),
			int(mission.get("merit",0)),int(mission.get("silver",0)),warning
		]))
		var accept := Button.new()
		accept.text = "ACEITAR MESMO ASSIM" if current < rec else "ACEITAR MISSÃO"
		accept.custom_minimum_size = Vector2(0,50)
		accept.pressed.connect(_accept_sect_mission.bind(String(mission.get("uid",""))))
		board.add_child(accept)

func _sect_join_or_upgrade() -> void:
	var result := SectMissionSystemScript.join_or_upgrade(world_state.current_life)
	_show_toast(result)
	audio.play_sfx("rare")
	_show_screen("sect")

func _accept_sect_mission(uid:String) -> void:
	var result: Dictionary = SectMissionSystemScript.accept(world_state.current_life,uid)
	_show_toast(String(result.get("text","Não foi possível aceitar.")))
	if bool(result.get("ok",false)):
		audio.play_sfx("rare")
	_show_screen("sect")

func _claim_sect_mission(uid:String) -> void:
	var reward: Dictionary = SectMissionSystemScript.claim(world_state.current_life,uid)
	if reward.is_empty():
		_show_toast("Esta missão ainda não pode ser recebida.")
		return
	_show_toast("%s: +%d mérito e +%d prata." % [
		String(reward.get("title","Missão")),int(reward.get("merit",0)),int(reward.get("silver",0))
	])
	audio.play_sfx("item")
	_show_screen("sect")

func _render_contract_board() -> void:
	var life := world_state.current_life
	ContractSystemScript.ensure_contracts(life,_current_phase(),world_state.world_year,world_state.world_day,rng)
	var card := _add_card("Contratos e objetivos locais")
	var contracts: Array = life.get("contracts",[])
	var shown := 0
	var now_abs: int = world_state.world_year*360+world_state.world_day
	for contract in contracts:
		if int(contract.get("phase",0)) != _current_phase():
			continue
		if bool(contract.get("failed",false)) or bool(contract.get("claimed",false)):
			continue
		shown += 1
		var complete: bool = bool(contract.get("completed",false))
		var remaining: int = maxi(0,int(contract.get("expires",now_abs))-now_abs)
		var line := "%s\n%s\nProgresso %d/%d · %d dias restantes · Recompensa %d prata" % [
			String(contract.get("title","Contrato")),String(contract.get("text","")),
			int(contract.get("progress",0)),int(contract.get("goal",1)),remaining,
			int(contract.get("reward_silver",0))
		]
		card.add_child(_body_label(line))
		if complete:
			var claim := Button.new()
			claim.text = "RECEBER RECOMPENSA"
			claim.custom_minimum_size = Vector2(0,50)
			claim.pressed.connect(_claim_contract.bind(String(contract.get("uid",""))))
			card.add_child(claim)
	if shown == 0:
		card.add_child(_body_label("Nenhum contrato ativo nesta fase."))

func _claim_contract(uid:String) -> void:
	var reward: Dictionary = ContractSystemScript.claim(world_state.current_life,uid)
	if reward.is_empty():
		_show_toast("Este contrato ainda não pode ser recebido.")
		return
	_show_toast("%s concluído: +%d prata e +%d reputação." % [
		String(reward.get("title","Contrato")),int(reward.get("silver",0)),int(reward.get("rep",0))
	])
	audio.play_sfx("item")
	_show_screen("life")

func _record_contract_action(action:String) -> void:
	var completed: Array[String] = ContractSystemScript.record_action(world_state.current_life,action,_current_phase())
	for title in completed:
		_show_toast("Contrato concluído: %s. Recompensa disponível na tela Vida." % title)
		audio.play_sfx("rare")
	var sect_completed: Array[String] = SectMissionSystemScript.record_action(world_state.current_life,action)
	for title in sect_completed:
		_show_toast("Missão da seita concluída: %s. Volte ao quadro para receber mérito." % title)
		audio.play_sfx("rare")

func _person_action(person:Dictionary,action:String) -> void:
	if not bool(person.get("alive",true)):
		_show_toast("Essa pessoa já não está viva.")
		return
	var result: Dictionary = RelationshipSystemScript.interact(person,action,world_state.current_life)
	var days: int = int(result.get("days",0))
	if days > 0:
		_advance_days(days)
	if life_over:
		return
	_show_toast(String(result.get("text","A relação mudou.")))
	_show_screen("people")

func _start_tactical_combat(context:String) -> void:
	if not active_battle.is_empty():
		_render_battle_overlay()
		return
	active_battle = TacticalCombatScript.create_battle(world_state.current_life,_current_phase(),rng)
	active_battle["context"] = context
	TacticalCombatScript.roll_enemy_intent(active_battle,rng)
	_render_battle_overlay()
	audio.play_sfx("danger")

func _render_battle_overlay() -> void:
	if active_battle.is_empty():
		return
	var enemy: Dictionary = active_battle["enemy"]
	var last_text: String = String(active_battle.get("last_text",""))
	var body := "%s\nHP %d/%d\nIntenção: %s\n\nVocê: HP %d/%d · Fôlego %d/3 · Foco %d · Qi %d/%d" % [
		String(enemy.get("name","Inimigo")),int(enemy.get("hp",0)),int(enemy.get("max_hp",0)),
		TacticalCombatScript.intent_text(active_battle),
		int(active_battle.get("player_hp",0)),int(active_battle.get("player_max_hp",0)),
		int(active_battle.get("player_stamina",0)),int(active_battle.get("player_focus",0)),
		int(active_battle.get("player_qi",0)),int(active_battle.get("player_max_qi",0))
	]
	if not last_text.is_empty():
		body += "\n\n"+last_text
	_show_event("COMBATE · TURNO %d" % int(active_battle.get("turn",1)),body,[
		["ATACAR",Callable(self,"_battle_action").bind("strike")],
		["DEFENDER",Callable(self,"_battle_action").bind("guard")],
		["OBSERVAR",Callable(self,"_battle_action").bind("observe")],
		["FINTAR",Callable(self,"_battle_action").bind("feint")],
		["TÉCNICA DE QI",Callable(self,"_battle_action").bind("technique")],
		["USAR ITEM",Callable(self,"_battle_use_item")],
		["FUGIR",Callable(self,"_battle_action").bind("flee")]
	])

func _battle_action(action:String) -> void:
	_close_overlay()
	if active_battle.is_empty():
		return
	var player_result: Dictionary = TacticalCombatScript.resolve_player_action(active_battle,action,world_state.current_life,rng)
	var text_value: String = String(player_result.get("text",""))
	if bool(active_battle.get("finished",false)):
		active_battle["last_text"] = text_value
		_finish_battle()
		return
	var enemy_text: String = TacticalCombatScript.resolve_enemy_turn(active_battle,rng)
	text_value += "\n"+enemy_text
	if int(active_battle.get("player_hp",0)) <= 0:
		active_battle["last_text"] = text_value
		_handle_battle_defeat()
		return
	TacticalCombatScript.next_turn(active_battle,rng)
	active_battle["last_text"] = text_value
	_render_battle_overlay()

func _battle_use_item() -> void:
	_close_overlay()
	if active_battle.is_empty():
		return
	var inv: Array = world_state.current_life.get("inventory",[])
	var used := false
	for item in inv:
		var name: String = String(item.get("name",""))
		if int(item.get("qty",0)) <= 0:
			continue
		if name == "Pílula de recuperação" or name == "Provisões simples":
			item["qty"] = int(item.get("qty",0))-1
			var heal: int = 34 if name == "Pílula de recuperação" else 16
			active_battle["player_hp"] = mini(int(active_battle.get("player_max_hp",100)),int(active_battle.get("player_hp",0))+heal)
			active_battle["last_text"] = "Você usa %s e recupera %d HP." % [name,heal]
			used = true
			break
	if not used:
		active_battle["last_text"] = "Você não possui item de recuperação utilizável."
	_render_battle_overlay()

func _finish_battle() -> void:
	if active_battle.is_empty():
		return
	var context: String = String(active_battle.get("context","hunt"))
	if bool(active_battle.get("fled",false)):
		active_battle.clear()
		if context == "world_event":
			pending_world_event_uid = ""
		if context == "journey":
			_journey_abort()
		else:
			_show_toast("Você fugiu e preservou a vida.")
		return
	if bool(active_battle.get("victory",false)):
		var enemy: Dictionary = active_battle["enemy"]
		if context == "spar":
			world_state.current_life["body_training"] = minf(float(world_state.current_life.get("body_training",0.0))+2.5,100.0)
			world_state.current_life["world_reputation"] = int(world_state.current_life.get("world_reputation",0))+1
			_record_contract_action("trial")
			_show_toast("Vitória no duelo. Corpo e reputação melhoraram.")
		else:
			var silver: int = int(enemy.get("reward_silver",0))
			world_state.current_life["silver"] = int(world_state.current_life.get("silver",0))+silver
			_add_item({"name":String(enemy.get("loot","Material de combate")),"qty":1,"kind":"Besta","rarity":"Raro","desc":"Obtido em combate tático."})
			if context == "hunt":
				_record_contract_action("hunt")
			_show_toast("Vitória: +%d prata e %s." % [silver,String(enemy.get("loot","recurso"))])
		audio.play_sfx("breakthrough")
		if context == "world_event" and not pending_world_event_uid.is_empty():
			WorldEventSystemScript.resolve(world_state.active_dynamic_events,pending_world_event_uid)
			pending_world_event_uid = ""
	active_battle.clear()
	if context == "journey":
		_journey_continue()
	else:
		_show_screen("life")

func _handle_battle_defeat() -> void:
	if active_battle.is_empty():
		return
	var context: String = String(active_battle.get("context","hunt"))
	var enemy: Dictionary = active_battle["enemy"]
	var enemy_realm: int = int(enemy.get("realm",0))
	var player_realm: int = int(world_state.current_life.get("realm_index",0))
	active_battle.clear()
	_close_overlay()
	if context == "world_event":
		pending_world_event_uid = ""
	if context == "spar":
		_damage_meridians(0.03)
		_show_toast("Você perdeu o duelo, mas saiu vivo e aprendeu com a derrota.")
		return
	var death_chance: float = clampf(0.22+float(enemy_realm-player_realm)*0.08,0.18,0.72)
	if rng.randf() < death_chance:
		_end_life("morto em combate contra %s" % String(enemy.get("name","um inimigo")))
		return
	_damage_meridians(0.14)
	if context == "journey":
		active_journey.clear()
	_show_toast("Você sobreviveu derrotado, com ferimentos sérios.")

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
	WorldEventSystemScript.ensure_events(world_state.active_dynamic_events,world_state.world_year,world_state.world_day,rng)
	SectMissionSystemScript.refresh_board(world_state.current_life,world_state.world_year,world_state.world_day,rng)
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
	WorldEventSystemScript.ensure_events(world_state.active_dynamic_events,world_state.world_year,world_state.world_day,rng)
	SectMissionSystemScript.refresh_board(world_state.current_life,world_state.world_year,world_state.world_day,rng)
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
	_record_contract_action("travel")
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

func _is_phase_unlocked(_phase:int) -> bool:
	return true

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
	var eyebrow := _label("◇  NOVE CÉUS",10,Color(_phase_accent(),0.72))
	inner.add_child(eyebrow)
	var title := _label(title_text,20,Color("#f2e3b9"))
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
	b.text = "✦  %s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(668,88)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",15)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal",_button_style(Color("#18373b"),Color(_phase_accent(),0.62)))
	b.add_theme_stylebox_override("pressed",_button_style(Color("#24494b"),_phase_accent()))
	b.pressed.connect(func() -> void:
		audio.play_sfx(sfx_kind)
		callback.call()
	)
	return b

func _action_button(title_text:String,subtext:String,callback:Callable) -> Button:
	var b := Button.new()
	b.text = "◆  %s\n%s" % [title_text,subtext]
	b.custom_minimum_size = Vector2(329,102)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",13)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal",_button_style(Color("#142f34"),Color("#6e9992")))
	b.add_theme_stylebox_override("pressed",_button_style(Color("#21454a"),_phase_accent()))
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
