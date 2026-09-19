extends "res://scripts/mobile/mobile_game.gd"

const V08Home=preload("res://scripts/v08/home_screen.gd")
const V08Map=preload("res://scripts/v08/world_map_screen.gd")
const V08Cultivation=preload("res://scripts/v08/cultivation_screen.gd")
const V08Realms=preload("res://scripts/v08/realms_screen.gd")
const V08Inventory=preload("res://scripts/v08/inventory_screen.gd")
const V08People=preload("res://scripts/v08/people_screen.gd")
const V08Base=preload("res://scripts/v08/base_screen.gd")
const V08Missions=preload("res://scripts/v08/missions_screen.gd")
const V08Sect=preload("res://scripts/v08/sect_screen.gd")
const V08Lifecycle=preload("res://scripts/v08/lifecycle_screen.gd")
const V08Legacy=preload("res://scripts/v08/legacy_screen.gd")
const V08Combat=preload("res://scripts/v08/combat_screen.gd")
const V08More=preload("res://scripts/v08/more_screen.gd")
const V08Chronicle=preload("res://scripts/v08/chronicle_screen.gd")
const V08Visuals=preload("res://scripts/v08/game_visuals.gd")

var screen_host:Control
var nav_shell:PanelContainer
var modal_panel:PanelContainer
var combat_host:Control
var shell_bg:ColorRect

func _build_shell()->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme=_create_mobile_theme()

	shell_bg=ColorRect.new()
	shell_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell_bg.color=Color("#08171d")
	shell_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(shell_bg)

	add_child(fx)
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	screen_host=Control.new()
	screen_host.position=Vector2(0,0)
	screen_host.size=Vector2(720,1104)
	add_child(screen_host)

	nav_shell=PanelContainer.new()
	nav_shell.position=Vector2(8,1112)
	nav_shell.size=Vector2(704,158)
	nav_shell.add_theme_stylebox_override("panel",V08Visuals.panel(Color("#081b21",0.98),Color("#7c8f89",0.36),24,1))
	add_child(nav_shell)

	bottom_nav=HBoxContainer.new()
	bottom_nav.position=Vector2(14,1120)
	bottom_nav.size=Vector2(692,142)
	bottom_nav.add_theme_constant_override("separation",5)
	add_child(bottom_nav)

	for entry in [
		["life","⌂","VIDA"],
		["map","山","MAPA"],
		["cultivation","◉","CULTIVO"],
		["people","人","PESSOAS"],
		["inventory","袋","BOLSA"],
		["more","◇","MAIS"]
	]:
		var key:String=entry[0]
		var b:=Button.new()
		b.text="%s\n%s" % [entry[1],entry[2]]
		b.custom_minimum_size=Vector2(111,126)
		b.add_theme_font_size_override("font_size",12)
		b.focus_mode=Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal",V08Visuals.panel(Color("#0d252b"),Color("#738b85",0.42),18,1))
		b.add_theme_stylebox_override("pressed",V08Visuals.panel(Color("#17343a"),Color("#d1b568"),18,2))
		b.pressed.connect(_nav_pressed.bind(key))
		bottom_nav.add_child(b)
		nav_buttons[key]=b

	toast=_label("",15,Color("#f4ead1"))
	toast.position=Vector2(42,1024)
	toast.size=Vector2(636,66)
	toast.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	toast.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	toast.add_theme_stylebox_override("normal",V08Visuals.panel(Color("#10272d",0.98),Color("#d1b568",0.7),16,1))
	toast.visible=false
	toast.z_index=80
	add_child(toast)

	overlay=ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color=Color(0.004,0.010,0.014,0.92)
	overlay.z_index=100
	overlay.visible=false
	add_child(overlay)

	combat_host=Control.new()
	combat_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	combat_host.visible=false
	overlay.add_child(combat_host)

	var center:=CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	modal_panel=PanelContainer.new()
	modal_panel.custom_minimum_size=Vector2(620,0)
	modal_panel.add_theme_stylebox_override("panel",V08Visuals.panel(Color("#0d252c"),Color("#d1b568",0.72),22,2))
	center.add_child(modal_panel)
	var margin:=MarginContainer.new()
	for k in ["margin_left","margin_right","margin_top","margin_bottom"]: margin.add_theme_constant_override(k,22)
	modal_panel.add_child(margin)
	overlay_box=VBoxContainer.new()
	overlay_box.add_theme_constant_override("separation",14)
	margin.add_child(overlay_box)

func _show_screen(screen_key:String)->void:
	current_screen=screen_key
	_clear_v08_screen()
	overlay.visible=false
	for key in nav_buttons.keys():
		var b:Button=nav_buttons[key]
		b.disabled=key==screen_key

	match screen_key:
		"life":
			var view:=V08Home.new()
			view.setup(_home_data())
			view.navigate.connect(_show_screen)
			view.action.connect(_perform_location_action)
			view.follow_event.connect(_world_event_go)
			screen_host.add_child(view)
		"map":
			var view:=V08Map.new()
			view.setup(_map_data())
			view.phase_selected.connect(_v08_phase_selected)
			view.location_selected.connect(_v08_location_selected)
			screen_host.add_child(view)
		"cultivation":
			var view:=V08Cultivation.new()
			view.setup(_cultivation_data())
			view.cultivate.connect(_cultivate_mode)
			view.breakthrough.connect(_breakthrough)
			view.open_realms.connect(_show_screen.bind("realms"))
			screen_host.add_child(view)
		"realms":
			var view:=V08Realms.new()
			var names:Array[String]=REALMS.duplicate()
			view.setup(names,int(world_state.current_life.get("realm_index",0)),_phase_accent())
			screen_host.add_child(view)
		"inventory":
			var view:=V08Inventory.new()
			view.setup(_inventory_data())
			view.inspect.connect(_inspect_item)
			screen_host.add_child(view)
		"people":
			var view:=V08People.new()
			view.setup(_people_data())
			view.interact.connect(_person_action)
			screen_host.add_child(view)
		"base":
			var view:=V08Base.new()
			view.setup({"accent":_phase_accent()})
			view.action.connect(_perform_location_action)
			screen_host.add_child(view)
		"missions":
			var view:=V08Missions.new()
			view.setup(_missions_data())
			view.follow_event.connect(_world_event_go)
			view.claim_contract.connect(_claim_contract)
			view.accept_sect.connect(_accept_sect_mission)
			view.claim_sect.connect(_claim_sect_mission)
			screen_host.add_child(view)
		"sect":
			var view:=V08Sect.new()
			view.setup(_sect_data())
			view.request_rank.connect(_sect_join_or_upgrade)
			view.open_missions.connect(_show_screen.bind("missions"))
			screen_host.add_child(view)
		"lifecycle":
			var view:=V08Lifecycle.new()
			view.setup({"age":world_state.current_age()})
			screen_host.add_child(view)
		"legacy":
			var view:=V08Legacy.new()
			view.setup({})
			view.open_cycle.connect(_show_screen.bind("lifecycle"))
			screen_host.add_child(view)
		"chronicle":
			var view:=V08Chronicle.new()
			view.setup(world_state.chronicle_text())
			screen_host.add_child(view)
		"more":
			var view:=V08More.new()
			view.setup({})
			view.navigate.connect(_show_screen)
			screen_host.add_child(view)
		_:
			_show_screen("life")
			return
	_update_phase_presentation()

func _clear_v08_screen()->void:
	for child in screen_host.get_children():
		child.queue_free()

func _update_header()->void:
	pass

func _update_phase_presentation()->void:
	if audio!=null:
		audio.play_phase_theme(_current_phase())
	if fx!=null:
		fx.set_phase(_current_phase())
	if shell_bg!=null:
		shell_bg.color=V08Visuals.phase_bg(_current_phase()).darkened(0.18)

func _home_data()->Dictionary:
	var life:=world_state.current_life
	var active:Array[Dictionary]=WorldEventSystemScript.active_events(world_state.active_dynamic_events)
	var event:Dictionary={}
	if not active.is_empty(): event=active[0]
	var mission_title:="Sem missão marcada"
	var mission_progress:="Abra Missões para escolher um objetivo."
	for c in life.get("contracts",[]):
		if not bool(c.get("claimed",false)) and not bool(c.get("failed",false)):
			mission_title=String(c.get("title","Contrato"))
			mission_progress="%d/%d · %d prata" % [int(c.get("progress",0)),int(c.get("goal",1)),int(c.get("reward_silver",0))]
			break
	var realm_index:=int(life.get("realm_index",0))
	return {
		"profile":life,
		"location":_location(),
		"phase":GameContentScript.phase(_current_phase()),
		"phase_number":_current_phase(),
		"phase_name":String(GameContentScript.phase(_current_phase()).get("name","")),
		"life_index":world_state.incarnation_index,
		"year":world_state.world_year,
		"day":world_state.world_day,
		"age":world_state.current_age(),
		"realm":REALMS[clampi(realm_index,0,REALMS.size()-1)],
		"goal":String(GameContentScript.phase(_current_phase()).get("goal","")),
		"event":event,
		"mission_title":mission_title,
		"mission_progress":mission_progress,
		"accent":_phase_accent()
	}

func _map_data()->Dictionary:
	var locs:Array=[]
	for key in GameContentScript.phase_locations(selected_map_phase):
		var d:Dictionary=GameContentScript.LOCATIONS[key].duplicate(true)
		d["key"]=key
		locs.append(d)
	return {"selected_phase":selected_map_phase,"locations":locs,"accent":V08Visuals.phase_accent(selected_map_phase)}

func _cultivation_data()->Dictionary:
	var life:=world_state.current_life
	var realm_index:=int(life.get("realm_index",0))
	var purity:=clampf(35.0+float(life.get("meridian_integrity",1.0))*35.0+float(life.get("dao_insight",0.0))*0.15,0.0,100.0)
	return {
		"realm_index":realm_index,
		"realm":REALMS[clampi(realm_index,0,REALMS.size()-1)],
		"progress":float(life.get("cultivation_progress",0.0)),
		"integrity":float(life.get("meridian_integrity",1.0)),
		"dao":float(life.get("dao_insight",0.0)),
		"purity":purity,
		"dantian_state":"Estável" if bool(life.get("qi_awakened",false)) else "Adormecido",
		"local_qi":_qi_density_label(float(_location().get("qi",0.0))),
		"accent":_phase_accent()
	}

func _inventory_data()->Dictionary:
	var life:=world_state.current_life
	return {"items":life.get("inventory",[]),"realm_index":int(life.get("realm_index",0)),"phase":_current_phase(),"accent":_phase_accent()}

func _people_data()->Dictionary:
	return {"people":world_state.notable_people,"accent":Color("#c58ca5")}

func _missions_data()->Dictionary:
	var life:=world_state.current_life
	var events:Array=[]
	for e in WorldEventSystemScript.active_events(world_state.active_dynamic_events):
		var d:Dictionary=e.duplicate(true)
		d["remaining"]=WorldEventSystemScript.remaining_days(e,world_state.world_year,world_state.world_day)
		events.append(d)
	var sect:Array=[]
	for m in life.get("sect_missions",[]): sect.append(m)
	for m in life.get("sect_available",[]):
		if not bool(m.get("accepted",false)): sect.append(m)
	return {"events":events,"contracts":life.get("contracts",[]),"sect_missions":sect,"accent":_phase_accent()}

func _sect_data()->Dictionary:
	var life:=world_state.current_life
	return {
		"status":SectMissionSystemScript.status_label(String(life.get("sect_status","outsider"))),
		"merit":int(life.get("sect_merit",0)),
		"reputation":int(life.get("sect_reputation",0))
	}

func _v08_phase_selected(value:int)->void:
	selected_map_phase=clampi(value,1,5)
	_show_screen("map")

func _v08_location_selected(key:String)->void:
	if not GameContentScript.LOCATIONS.has(key): return
	if key==current_location:
		_show_screen("life")
		return
	_travel_to(key,_travel_days(current_location,key))

func _render_battle_overlay()->void:
	if active_battle.is_empty(): return
	overlay.visible=true
	modal_panel.visible=false
	combat_host.visible=true
	for c in combat_host.get_children(): c.queue_free()
	var enemy:Dictionary=active_battle.get("enemy",{})
	var data:Dictionary=active_battle.duplicate(true)
	data["enemy"]=enemy
	data["intent_text"]=TacticalCombatScript.intent_text(active_battle)
	var view:=V08Combat.new()
	view.setup(data)
	view.battle_action.connect(_battle_action)
	view.use_item.connect(_battle_use_item)
	combat_host.add_child(view)

func _show_event(title_text:String,body_text:String,actions:Array)->void:
	overlay.visible=true
	combat_host.visible=false
	modal_panel.visible=true
	for c in overlay_box.get_children(): c.queue_free()
	var title:=_label(title_text,24,Color("#f1dfb7")); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; overlay_box.add_child(title)
	var body:=_label(body_text,16,Color("#d3ded8")); body.custom_minimum_size=Vector2(540,0); body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; body.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; overlay_box.add_child(body)
	for item in actions:
		var b:=Button.new(); b.text=String(item[0]); b.custom_minimum_size=Vector2(0,60); var cb:Callable=item[1]; b.pressed.connect(cb); overlay_box.add_child(b)

func _close_overlay()->void:
	overlay.visible=false
	combat_host.visible=false
	modal_panel.visible=true
