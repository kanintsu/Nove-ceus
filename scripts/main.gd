extends Node3D

const WorldStateScript = preload("res://scripts/core/world_state.gd")
const WorldBuilderScript = preload("res://scripts/world/world_builder.gd")
const PlayerScript = preload("res://scripts/player/player_controller.gd")
const HUDScript = preload("res://scripts/ui/game_hud.gd")

var world_state: WorldState
var world_builder: WorldBuilder
var player: PlayerController
var hud: GameHUD
var camera: Camera3D
var sun: DirectionalLight3D
var world_environment: WorldEnvironment
var dead := false
var elapsed_day_time := 0.0
var last_location := ""

func _ready() -> void:
	add_to_group("game")
	world_state = WorldStateScript.new()
	add_child(world_state)
	world_state.initialize()
	_build_environment()
	_build_world()
	_build_camera()
	_build_hud()
	_spawn_current_life()
	world_state.calendar_changed.connect(_on_calendar_changed)
	world_state.chronicle_changed.connect(_refresh_chronicle_if_open)
	world_state.rare_encounter_changed.connect(_on_rare_encounter_changed)
	notify("Você desperta aos 16 anos. Neste mundo, cultivar não é um direito garantido.")

func _process(delta: float) -> void:
	_update_camera(delta)
	_update_location()
	_update_day_light(delta)

func notify(text_value: String) -> void:
	if hud != null:
		hud.show_notification(text_value)

func set_interaction_prompt(text_value: String) -> void:
	if hud != null:
		hud.set_prompt(text_value)

func advance_days(days: int) -> void:
	if dead:
		return
	world_state.advance_days(days)
	if player != null:
		player.life["age"] = world_state.current_age()
	if hud != null and player != null:
		hud.update_world(world_state.world_year, world_state.world_day, world_state.incarnation_index)
		hud.update_player_state(player)
	_check_natural_lifespan()

func record_world_event(text_value: String) -> void:
	world_state.record_world_event(text_value)

func get_current_rare_encounter() -> Dictionary:
	if world_state == null:
		return {}
	return world_state.current_rare_encounter

func accept_rare_encounter(_profile: Dictionary) -> bool:
	if world_state == null or dead:
		return false
	return world_state.accept_current_rare_encounter()

func is_life_active() -> bool:
	return not dead

func on_spiritual_test(diagnosis: String) -> void:
	if hud == null or player == null:
		return
	hud.update_player_state(player)
	if diagnosis == "Afinidade espiritual detectada" or diagnosis == "Raiz espiritual dormente":
		hud.set_objective("Você possui um caminho possível. Procure um lugar onde o Qi se concentre — rumores falam de uma nascente na floresta.")
	else:
		hud.set_objective("O céu não lhe deu um caminho fácil. Você pode viver como mortal, fortalecer o corpo e estudar — ou procurar uma oportunidade capaz de desafiar seu nascimento.")

func on_player_awakened(source_name: String, rewrote_body: bool) -> void:
	if hud != null and player != null:
		hud.update_player_state(player)
		if rewrote_body:
			hud.set_objective("Você roubou uma oportunidade dos céus. Sobreviva ao território da besta e retorne a Qinghe com o caminho do Qi aberto.")
		else:
			hud.set_objective("Você entrou no Refinamento de Qi. O Tigre da Névoa ainda está vários passos acima de você — poder não apaga prudência.")
	record_world_event("alguém na região abriu o caminho do Qi através de %s." % source_name)

func toggle_chronicle() -> void:
	if hud == null:
		return
	var next_state := not hud.is_chronicle_visible()
	hud.set_chronicle(world_state.chronicle_text(), next_state)

func _build_environment() -> void:
	world_environment = WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.08, 0.15, 0.16)
	sky_material.sky_horizon_color = Color(0.48, 0.49, 0.38)
	sky_material.ground_bottom_color = Color(0.05, 0.07, 0.06)
	sky_material.ground_horizon_color = Color(0.32, 0.31, 0.25)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.85
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.40, 0.45, 0.39)
	environment.fog_light_energy = 0.75
	environment.fog_density = 0.006
	environment.fog_height = 4.0
	environment.fog_height_density = 0.05
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_color = Color(1.0, 0.90, 0.72)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _build_world() -> void:
	world_builder = WorldBuilderScript.new()
	add_child(world_builder)
	var age_bonus := maxi(int((world_state.world_year - 137) / 60.0), 0)
	world_builder.setup(self, world_state.world_seed, age_bonus)

func _rebuild_world_for_new_era() -> void:
	if world_builder != null and is_instance_valid(world_builder):
		world_builder.queue_free()
	world_builder = WorldBuilderScript.new()
	add_child(world_builder)
	var age_bonus := maxi(int((world_state.world_year - 137) / 60.0), 0)
	world_builder.setup(self, world_state.world_seed + world_state.world_year, age_bonus)
	var growth := clampi(int((world_state.world_year - 137) / 40.0), 0, 4)
	for i in range(growth):
		var extra_position := WorldBuilder.VILLAGE + Vector3(-15 + i * 7, 1.0, 15)
		var marker := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(3.2, 2.0, 3.0)
		marker.mesh = mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.44, 0.34, 0.22)
		marker.material_override = material
		marker.position = extra_position
		world_builder.add_child(marker)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.fov = 48.0
	camera.current = true
	add_child(camera)

func _build_hud() -> void:
	hud = HUDScript.new()
	add_child(hud)
	hud.reincarnate_requested.connect(_reincarnate)
	hud.chronicle_requested.connect(toggle_chronicle)
	hud.update_world(world_state.world_year, world_state.world_day, world_state.incarnation_index)
	hud.set_objective("Sobreviva. Você é mortal. Explore a região, treine seu corpo e descubra se o Qi algum dia responderá a você.")

func _spawn_current_life() -> void:
	dead = false
	player = PlayerScript.new()
	add_child(player)
	player.setup(self, world_state.current_life)
	player.global_position = world_builder.get_spawn_position(String(world_state.current_life.get("origin_id", "farm_village")))
	player.died.connect(_on_player_died)
	hud.bind_player(player)
	hud.hide_death()
	hud.update_world(world_state.world_year, world_state.world_day, world_state.incarnation_index)
	hud.set_objective(_starting_objective())
	camera.global_position = player.global_position + Vector3(10, 10, 12)
	camera.look_at(player.global_position + Vector3(0, 1.0, 0))

func _starting_objective() -> String:
	var origin_id := String(world_state.current_life.get("origin_id", ""))
	if origin_id == "deep_forest":
		return "Você despertou dentro da Floresta da Névoa Fria. Não enfrente o que não entende. Encontre uma estrada ou abrigo."
	if origin_id == "spirit_mine":
		return "Você nasceu perto da Montanha do Véu. A presença espiritual aqui é sufocante; sobreviver vem antes de cultivar."
	if origin_id == "ruined_clan":
		return "Sua linhagem perdeu tudo. As Ruínas de Lianshi guardam memórias, não segurança. Procure uma vida — ou um caminho."
	return "Você ainda é mortal. Treine, estude, explore Qinghe e descubra se o Qi reconhece seu corpo."

func _on_player_died(cause: String) -> void:
	if dead:
		return
	dead = true
	var summary := world_state.end_life(cause, world_state.current_age())
	if player != null:
		player.set_physics_process(false)
	var hint := "O mundo não vai esperar sua próxima vida."
	hud.show_death(summary, hint)
	record_world_event("uma vida terminou na região; seus pertences foram deixados para o mundo.")

func _reincarnate() -> void:
	if not dead:
		return
	if player != null and is_instance_valid(player):
		player.queue_free()
	world_state.reincarnate()
	_rebuild_world_for_new_era()
	_spawn_current_life()
	notify("Anos passaram. O mundo mudou — e você não recebeu garantia alguma de uma vida melhor.")

func _check_natural_lifespan() -> void:
	if dead or player == null or not is_instance_valid(player):
		return
	var mortal_lifespan := int(world_state.current_life.get("natural_lifespan", 72))
	var lifespan_bonus := 24 if player.realm != "Mortal" else 0
	if world_state.current_age() >= mortal_lifespan + lifespan_bonus:
		_on_player_died("velhice")

func _on_rare_encounter_changed(profile: Dictionary) -> void:
	if world_builder != null and is_instance_valid(world_builder):
		world_builder.refresh_rare_encounter()
	if not profile.is_empty():
		notify("Algo incomum aconteceu na região. A Crônica registrou um novo encontro.")

func _on_calendar_changed(_year: int, _day: int) -> void:
	if hud != null:
		hud.update_world(world_state.world_year, world_state.world_day, world_state.incarnation_index)

func _refresh_chronicle_if_open() -> void:
	if hud != null and hud.is_chronicle_visible():
		hud.set_chronicle(world_state.chronicle_text(), true)

func _update_camera(delta: float) -> void:
	if camera == null or player == null or not is_instance_valid(player):
		return
	var desired := player.global_position + Vector3(10.5, 9.5, 12.0)
	camera.global_position = camera.global_position.lerp(desired, minf(delta * 4.5, 1.0))
	camera.look_at(player.global_position + Vector3(0, 1.1, 0), Vector3.UP)

func _update_location() -> void:
	if player == null or world_builder == null or not is_instance_valid(player):
		return
	var location := world_builder.location_name(player.global_position)
	if location != last_location:
		last_location = location
		hud.set_location(location)

func _update_day_light(delta: float) -> void:
	if sun == null:
		return
	elapsed_day_time += delta
	var phase := fmod(elapsed_day_time / 180.0, 1.0)
	var elevation := -22.0 - sin(phase * TAU) * 34.0
	sun.rotation_degrees.x = elevation
	var daylight := clampf(0.42 + (-sin(phase * TAU) * 0.30), 0.18, 1.15)
	sun.light_energy = daylight
