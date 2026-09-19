extends Control

const GameState=preload("res://scripts/game_state.gd")
const UI=preload("res://scripts/ui/ui.gd")
const Home=preload("res://scripts/screens/home.gd")
const MapScreen=preload("res://scripts/screens/map.gd")
const Cultivation=preload("res://scripts/screens/cultivation.gd")
const Inventory=preload("res://scripts/screens/inventory.gd")
const People=preload("res://scripts/screens/people.gd")
const Missions=preload("res://scripts/screens/missions.gd")
const Combat=preload("res://scripts/screens/combat.gd")
const More=preload("res://scripts/screens/more.gd")
const Sect=preload("res://scripts/screens/sect.gd")
const Cycle=preload("res://scripts/screens/cycle.gd")
const Legacy=preload("res://scripts/screens/legacy.gd")

var state:RebornGameState
var screen_host:Control
var nav:HBoxContainer
var toast:Label
var current_screen:="home"

func _ready()->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	state=GameState.new()
	_build_shell()
	_show_screen("home")

func _build_shell()->void:
	var bg:=ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color=Color("#07171d")
	add_child(bg)
	screen_host=Control.new()
	screen_host.position=Vector2(0,0)
	screen_host.size=Vector2(720,1110)
	add_child(screen_host)
	var nav_panel:=PanelContainer.new()
	nav_panel.position=Vector2(8,1114);nav_panel.size=Vector2(704,156)
	nav_panel.add_theme_stylebox_override("panel",UI.panel(Color("#06171c",0.98),Color("#718883",0.35),24,1))
	add_child(nav_panel)
	nav=HBoxContainer.new()
	nav.position=Vector2(14,1122);nav.size=Vector2(692,140);nav.add_theme_constant_override("separation",5)
	add_child(nav)
	for entry in [["home","⌂","VIDA"],["map","山","MAPA"],["cultivation","◉","CULTIVO"],["people","人","PESSOAS"],["inventory","袋","BOLSA"],["more","◇","MAIS"]]:
		var b:=Button.new()
		b.text="%s\n%s" % [entry[1],entry[2]]
		b.custom_minimum_size=Vector2(111,126)
		b.add_theme_font_size_override("font_size",12)
		b.focus_mode=Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal",UI.panel(Color("#0b252b"),Color("#6f8580",0.40),18,1))
		b.add_theme_stylebox_override("pressed",UI.panel(Color("#14353b"),Color("#d2b76c"),18,2))
		var key:String=entry[0]
		b.pressed.connect(func():_show_screen(key))
		nav.add_child(b)
	toast=UI.label("",14,Color("#f4ead1"))
	toast.position=Vector2(50,1018);toast.size=Vector2(620,72)
	toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;toast.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	toast.add_theme_stylebox_override("normal",UI.panel(Color("#0a2229",0.98),Color("#d2b76c",0.64),16,1))
	toast.visible=false;toast.z_index=50
	add_child(toast)

func _show_screen(key:String)->void:
	current_screen=key
	for c in screen_host.get_children():c.queue_free()
	match key:
		"home":
			var view:=Home.new();view.setup(state);view.navigate.connect(_show_screen);view.world_action.connect(_world_action);view.open_event.connect(_event_action);screen_host.add_child(view)
		"map":
			var view:=MapScreen.new();view.setup(state);view.travel.connect(_travel);screen_host.add_child(view)
		"cultivation":
			var view:=Cultivation.new();view.setup(state);view.meditate.connect(_meditate);view.breakthrough.connect(_breakthrough);view.open_realms.connect(func():_show_more_mode("realms"));screen_host.add_child(view)
		"inventory":
			var view:=Inventory.new();view.setup(state);view.inspect.connect(_inspect_item);screen_host.add_child(view)
		"people":
			var view:=People.new();view.setup(state);view.interact.connect(_person_action);screen_host.add_child(view)
		"missions":
			var view:=Missions.new();view.setup(state);view.event_selected.connect(_event_action);view.mission_selected.connect(_mission_action);screen_host.add_child(view)
		"combat":
			var view:=Combat.new();view.setup(state);view.act.connect(_combat_action);screen_host.add_child(view)
		"sect":
			var view:=Sect.new();view.setup(state);view.serve.connect(_sect_service);view.open_missions.connect(func():_show_screen("missions"));screen_host.add_child(view)
		"cycle":
			var view:=Cycle.new();view.setup(state);screen_host.add_child(view)
		"legacy":
			var view:=Legacy.new();view.setup(state);view.reincarnate.connect(_reincarnate);screen_host.add_child(view)
		"more":
			var view:=More.new();view.setup(state);view.navigate.connect(_more_navigate);view.base_action.connect(_world_action);screen_host.add_child(view)
		_:
			_show_screen("home")

func _show_more_mode(mode:String)->void:
	for c in screen_host.get_children():c.queue_free()
	var view:=More.new();view.mode=mode;view.setup(state);view.navigate.connect(_more_navigate);view.base_action.connect(_world_action);screen_host.add_child(view)
	current_screen="more"

func _more_navigate(key:String)->void:
	match key:
		"cycle":_show_screen("cycle")
		"legacy":_show_screen("legacy")
		"sect":_show_screen("sect")
		_:_show_screen(key)

func _world_action(action:String)->void:
	var message:=""
	match action:
		"work":message=state.work()
		"study":message=state.study()
		"train":message=state.train()
		"rumors":message=state.listen_rumors()
		"meditate":message=state.meditate("safe")
		"rest":state.advance_days(2);message="Você descansou e deixou o corpo recuperar o ritmo."
		_:message="Essa atividade ainda não está disponível aqui."
	_show_toast(message)
	_refresh_current()

func _travel(index:int)->void:
	_show_toast(state.travel_to(index))
	_show_screen("home")

func _meditate(mode:String)->void:
	_show_toast(state.meditate(mode))
	_show_screen("cultivation")

func _breakthrough()->void:
	_show_toast(state.breakthrough())
	_show_screen("cultivation")

func _inspect_item(item:Dictionary)->void:
	_show_toast("%s · %s" % [String(item.get("name","Item")),String(item.get("desc","Sem descrição."))])

func _person_action(index:int,action:String)->void:
	_show_toast(state.interact_person(index,action))
	_show_screen("people")

func _event_action(uid:String)->void:
	_show_toast(state.resolve_event(uid))
	_show_screen("home")

func _mission_action(uid:String)->void:
	_show_toast(state.mark_mission(uid))
	if uid=="m1":
		state.start_combat()
		_show_screen("combat")

func _sect_service()->void:
	_show_toast(state.sect_service())
	_show_screen("sect")

func _combat_action(action:String)->void:
	_show_toast(state.combat_action(action))
	if state.combat.is_empty():_show_screen("home")
	else:_show_screen("combat")

func _reincarnate()->void:
	_show_toast(state.reincarnate())
	_show_screen("home")

func _refresh_current()->void:
	if current_screen in ["home","cultivation","inventory","people","sect"]:_show_screen(current_screen)

func _show_toast(message:String)->void:
	toast.text=message
	toast.visible=true
	var timer:=get_tree().create_timer(3.5)
	timer.timeout.connect(func():toast.visible=false)
