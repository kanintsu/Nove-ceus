class_name GameHUD
extends CanvasLayer

signal reincarnate_requested
signal chronicle_requested

var title_label: Label
var calendar_label: Label
var origin_label: Label
var realm_label: Label
var body_label: Label
var knowledge_label: Label
var hp_bar: ProgressBar
var stamina_bar: ProgressBar
var location_label: Label
var objective_label: Label
var prompt_label: Label
var notification_label: Label
var chronicle_panel: ColorRect
var chronicle_text: RichTextLabel
var death_overlay: ColorRect
var death_title: Label
var death_text: Label
var reincarnate_button: Button
var mobile_controls: MobileControls
var notification_tween: Tween

func _ready() -> void:
	_build_hud()

func bind_player(player: PlayerController) -> void:
	player.health_changed.connect(_on_health_changed)
	player.stamina_changed.connect(_on_stamina_changed)
	player.state_changed.connect(func() -> void: update_player_state(player))
	mobile_controls.move_changed.connect(player.set_mobile_vector)
	mobile_controls.attack_pressed.connect(player.request_attack)
	mobile_controls.interact_pressed.connect(player.request_interact)
	mobile_controls.sprint_changed.connect(player.set_mobile_sprint)
	mobile_controls.chronicle_pressed.connect(func() -> void: chronicle_requested.emit())
	update_player_state(player)

func update_world(year: int, day: int, incarnation: int) -> void:
	title_label.text = "NOVE CÉUS  ·  VIDA %d" % incarnation
	calendar_label.text = "Ano %d  ·  Dia %d" % [year, day]

func update_player_state(player: PlayerController) -> void:
	origin_label.text = "Origem: %s" % String(player.life.get("origin_label", "Desconhecida"))
	realm_label.text = player.spiritual_status_for_ui()
	body_label.text = "Corpo: %s · treino %.0f%%" % [player.body_rank(), float(player.life.get("body_training", 0.0))]
	knowledge_label.text = "Conhecimento mortal: %.0f%%" % float(player.life.get("worldly_knowledge", 0.0))
	_on_health_changed(player.health, player.max_health)
	_on_stamina_changed(player.stamina, player.max_stamina)

func set_location(text_value: String) -> void:
	location_label.text = text_value

func set_objective(text_value: String) -> void:
	objective_label.text = text_value

func set_prompt(text_value: String) -> void:
	prompt_label.text = text_value
	prompt_label.visible = not text_value.is_empty()

func show_notification(text_value: String) -> void:
	notification_label.text = text_value
	notification_label.modulate = Color(1, 1, 1, 1)
	if notification_tween != null and notification_tween.is_valid():
		notification_tween.kill()
	notification_tween = create_tween()
	notification_tween.tween_interval(3.4)
	notification_tween.tween_property(notification_label, "modulate:a", 0.0, 0.8)

func show_death(summary: Dictionary, years_hint: String) -> void:
	death_overlay.visible = true
	death_title.text = "SUA VIDA TERMINOU"
	death_text.text = "Vida %d · %s\nIdade: %d anos\nCausa: %s\n%s" % [int(summary.get("incarnation", 0)), String(summary.get("origin", "")), int(summary.get("age", 0)), String(summary.get("cause", "desconhecida")), years_hint]

func hide_death() -> void:
	death_overlay.visible = false

func set_chronicle(text_value: String, visible_state: bool) -> void:
	chronicle_text.text = text_value
	chronicle_panel.visible = visible_state

func is_chronicle_visible() -> bool:
	return chronicle_panel.visible

func _on_health_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current

func _build_hud() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.024, 0.021, 0.76)
	shade.position = Vector2(18, 18)
	shade.size = Vector2(356, 208)
	add_child(shade)

	title_label = _label(Vector2(34, 30), Vector2(330, 28), 20)
	title_label.text = "NOVE CÉUS"
	add_child(title_label)
	calendar_label = _label(Vector2(34, 62), Vector2(330, 24), 15)
	add_child(calendar_label)
	origin_label = _label(Vector2(34, 89), Vector2(330, 22), 14)
	add_child(origin_label)
	realm_label = _label(Vector2(34, 114), Vector2(330, 22), 16)
	realm_label.modulate = Color(0.72, 0.88, 0.80)
	add_child(realm_label)
	body_label = _label(Vector2(34, 140), Vector2(330, 20), 13)
	add_child(body_label)
	knowledge_label = _label(Vector2(34, 162), Vector2(330, 20), 13)
	add_child(knowledge_label)

	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(34, 188)
	hp_bar.size = Vector2(154, 13)
	hp_bar.show_percentage = false
	add_child(hp_bar)
	stamina_bar = ProgressBar.new()
	stamina_bar.position = Vector2(200, 188)
	stamina_bar.size = Vector2(154, 13)
	stamina_bar.show_percentage = false
	add_child(stamina_bar)

	location_label = _label(Vector2(828, 92), Vector2(420, 34), 18)
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(location_label)

	var objective_bg := ColorRect.new()
	objective_bg.color = Color(0.02, 0.03, 0.027, 0.72)
	objective_bg.position = Vector2(390, 18)
	objective_bg.size = Vector2(420, 84)
	add_child(objective_bg)
	objective_label = _label(Vector2(408, 32), Vector2(384, 60), 14)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(objective_label)

	notification_label = _label(Vector2(300, 548), Vector2(680, 52), 17)
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(notification_label)

	prompt_label = _label(Vector2(380, 626), Vector2(520, 34), 16)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.modulate = Color(0.88, 0.92, 0.78)
	prompt_label.visible = false
	add_child(prompt_label)

	_build_chronicle()
	_build_death_overlay()
	mobile_controls = MobileControls.new()
	add_child(mobile_controls)

func _build_chronicle() -> void:
	chronicle_panel = ColorRect.new()
	chronicle_panel.color = Color(0.012, 0.02, 0.018, 0.95)
	chronicle_panel.position = Vector2(230, 110)
	chronicle_panel.size = Vector2(820, 500)
	chronicle_panel.visible = false
	add_child(chronicle_panel)
	var heading := _label(Vector2(28, 20), Vector2(650, 30), 22)
	heading.text = "CRÔNICA VIVA DOS NOVE CÉUS"
	chronicle_panel.add_child(heading)
	chronicle_text = RichTextLabel.new()
	chronicle_text.bbcode_enabled = true
	chronicle_text.position = Vector2(28, 64)
	chronicle_text.size = Vector2(764, 368)
	chronicle_text.fit_content = false
	chronicle_panel.add_child(chronicle_text)
	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(670, 444)
	close.size = Vector2(120, 40)
	close.pressed.connect(func() -> void: chronicle_panel.visible = false)
	chronicle_panel.add_child(close)

func _build_death_overlay() -> void:
	death_overlay = ColorRect.new()
	death_overlay.color = Color(0.012, 0.012, 0.014, 0.94)
	death_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_overlay.visible = false
	add_child(death_overlay)
	death_title = _label(Vector2(360, 190), Vector2(560, 54), 32)
	death_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_overlay.add_child(death_title)
	death_text = _label(Vector2(360, 262), Vector2(560, 150), 18)
	death_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	death_overlay.add_child(death_text)
	reincarnate_button = Button.new()
	reincarnate_button.text = "ENTRAR NO CICLO DE REENCARNAÇÃO"
	reincarnate_button.position = Vector2(450, 442)
	reincarnate_button.size = Vector2(380, 58)
	reincarnate_button.pressed.connect(func() -> void: reincarnate_requested.emit())
	death_overlay.add_child(reincarnate_button)

func _label(pos: Vector2, size_value: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = Color(0.91, 0.91, 0.86)
	return label
