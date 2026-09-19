class_name PlayerController
extends CharacterBody3D

signal died(cause: String)
signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal state_changed

const GRAVITY := 22.0
const BASE_SPEED := 4.2
const SPRINT_SPEED := 7.0

var game: Node
var life: Dictionary = {}
var mobile_input := Vector2.ZERO
var sprint_mobile := false
var max_health := 100.0
var health := 100.0
var max_stamina := 100.0
var stamina := 100.0
var attack_cooldown := 0.0
var invulnerability := 0.0
var realm := "Mortal"
var qi_amount := 0.0
var max_qi := 100.0
var attack_damage := 7.0
var current_interactable: Node = null
var weapon_root: Node3D
var aura: OmniLight3D

func setup(game_node: Node, life_data: Dictionary) -> void:
	game = game_node
	life = life_data
	add_to_group("player")
	_build_visuals()
	_build_collision()
	_recalculate_mortal_stats()
	health = max_health
	stamina = max_stamina
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)
	state_changed.emit()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	invulnerability = maxf(invulnerability - delta, 0.0)
	var input_vec := mobile_input
	var keyboard := Vector2.ZERO
	keyboard.x = float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	keyboard.y = float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	if keyboard.length() > 0.1:
		input_vec = keyboard.normalized()
	var sprinting := sprint_mobile or Input.is_key_pressed(KEY_SHIFT)
	var move_speed := BASE_SPEED
	if realm != "Mortal":
		move_speed += 0.45
	if sprinting and stamina > 1.0 and input_vec.length() > 0.1:
		move_speed = SPRINT_SPEED + (0.4 if realm != "Mortal" else 0.0)
		stamina = maxf(stamina - 24.0 * delta, 0.0)
	else:
		stamina = minf(stamina + 17.0 * delta, max_stamina)
	stamina_changed.emit(stamina, max_stamina)
	var move_dir := _camera_relative_direction(input_vec)
	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	if move_dir.length() > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(move_dir.x, move_dir.z), delta * 8.0)
	move_and_slide()
	_update_interactable()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			request_interact()
		elif event.keycode == KEY_SPACE or event.keycode == KEY_F:
			request_attack()
		elif event.keycode == KEY_C and game != null and game.has_method("toggle_chronicle"):
			game.toggle_chronicle()

func set_mobile_vector(value: Vector2) -> void:
	mobile_input = value.limit_length(1.0)

func set_mobile_sprint(active: bool) -> void:
	sprint_mobile = active

func request_interact() -> void:
	if current_interactable != null and is_instance_valid(current_interactable) and current_interactable.has_method("interact"):
		current_interactable.interact(self)

func request_attack() -> void:
	if attack_cooldown > 0.0 or health <= 0.0:
		return
	attack_cooldown = 0.58 if realm == "Mortal" else 0.42
	if weapon_root != null:
		weapon_root.rotation_degrees.x = -55.0
		var tween := create_tween()
		tween.tween_property(weapon_root, "rotation_degrees:x", 30.0, 0.12)
		tween.tween_property(weapon_root, "rotation_degrees:x", 0.0, 0.18)
	var best_target: Node3D = null
	var best_distance := 2.65
	for candidate in get_tree().get_nodes_in_group("beast"):
		if candidate is Node3D:
			var distance := global_position.distance_to(candidate.global_position)
			if distance < best_distance:
				best_distance = distance
				best_target = candidate
	if best_target != null and best_target.has_method("take_damage"):
		best_target.take_damage(attack_damage, self)
		if game != null and game.has_method("notify"):
			game.notify("Seu golpe acertou a besta.")

func take_damage(amount: float, source_name: String = "ferimentos") -> void:
	if invulnerability > 0.0 or health <= 0.0:
		return
	invulnerability = 0.28
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		died.emit(source_name)

func reveal_spiritual_state() -> String:
	life["qi_known"] = true
	state_changed.emit()
	return BirthSystem.hidden_diagnosis(int(life.get("qi_potential", BirthSystem.QiPotential.MORTAL)))

func try_awaken_naturally(source_name: String) -> bool:
	if bool(life.get("qi_awakened", false)):
		if game != null and game.has_method("notify"):
			game.notify("Você já consegue sentir o Qi dos céus e da terra.")
		return true
	var potential := int(life.get("qi_potential", BirthSystem.QiPotential.MORTAL))
	life["qi_known"] = true
	if not BirthSystem.can_naturally_awaken(potential):
		state_changed.emit()
		if game != null and game.has_method("notify"):
			game.notify("Você medita por horas, mas o Qi não entra em seus meridianos.")
		return false
	_awaken_qi(source_name, false)
	return true

func force_heaven_defying_awaken(source_name: String) -> bool:
	if bool(life.get("qi_awakened", false)):
		return false
	_awaken_qi(source_name, true)
	return true

func train_body() -> void:
	if stamina < 18.0:
		if game != null and game.has_method("notify"):
			game.notify("Seu corpo está exausto. Descanse antes de continuar.")
		return
	stamina -= 18.0
	life["body_training"] = minf(float(life.get("body_training", 0.0)) + 4.0, 100.0)
	_recalculate_mortal_stats()
	if game != null:
		if game.has_method("advance_days"):
			game.advance_days(1)
		if game.has_method("notify"):
			game.notify("Um dia de treino fortaleceu seu corpo. %s." % body_rank())
	state_changed.emit()

func study_mortal_knowledge() -> void:
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge", 0.0)) + 5.0, 100.0)
	if game != null:
		if game.has_method("advance_days"):
			game.advance_days(7)
		if game.has_method("notify"):
			game.notify("Você passou sete dias estudando medicina, matemática e registros do mundo mortal.")
	state_changed.emit()

func live_mortal_season() -> void:
	if health <= 0.0:
		return
	var intelligence := float(life.get("intelligence", 50))
	var willpower := float(life.get("willpower", 50))
	var physique := float(life.get("physique", 50))
	var knowledge_gain := 2.0 + intelligence / 32.0
	var training_gain := 1.5 + (physique + willpower) / 85.0
	life["worldly_knowledge"] = minf(float(life.get("worldly_knowledge", 0.0)) + knowledge_gain, 100.0)
	life["body_training"] = minf(float(life.get("body_training", 0.0)) + training_gain, 100.0)
	_recalculate_mortal_stats()
	if game != null and game.has_method("advance_days"):
		game.advance_days(90)
	if game != null and game.has_method("is_life_active") and not bool(game.is_life_active()):
		return
	_record_mortal_milestones()
	if game != null and game.has_method("notify"):
		game.notify("Uma estação passou. Você trabalhou, estudou e treinou enquanto o mundo continuou seguindo sem esperar por você.")
	state_changed.emit()

func _record_mortal_milestones() -> void:
	var knowledge := float(life.get("worldly_knowledge", 0.0))
	var intelligence := int(life.get("intelligence", 50))
	var milestones: Array = life.get("mortal_milestones", [])
	if knowledge >= 35.0 and not milestones.has("practical"):
		milestones.append("practical")
		if game != null and game.has_method("record_world_event"):
			game.record_world_event("você aplicou conhecimento mortal para melhorar ferramentas e métodos de trabalho locais.")
	if knowledge >= 65.0 and intelligence >= 70 and not milestones.has("scholar"):
		milestones.append("scholar")
		if game != null and game.has_method("record_world_event"):
			game.record_world_event("seu nome começou a circular entre estudiosos mortais de Qinghe.")
	if knowledge >= 90.0 and intelligence >= 82 and not milestones.has("innovator"):
		milestones.append("innovator")
		if game != null and game.has_method("record_world_event"):
			game.record_world_event("uma criação sua passou a ser usada por moradores da região — um legado sem depender de Qi.")
	life["mortal_milestones"] = milestones

func body_rank() -> String:
	var training := float(life.get("body_training", 0.0))
	if training >= 90.0:
		return "Limite Mortal"
	if training >= 65.0:
		return "Mestre Marcial Mortal"
	if training >= 35.0:
		return "Guerreiro Treinado"
	if training >= 12.0:
		return "Corpo Fortalecido"
	return "Corpo Mortal"

func spiritual_status_for_ui() -> String:
	if bool(life.get("qi_awakened", false)):
		return realm
	if not bool(life.get("qi_known", false)):
		return "Qi: desconhecido"
	return BirthSystem.hidden_diagnosis(int(life.get("qi_potential", BirthSystem.QiPotential.MORTAL)))

func _awaken_qi(source_name: String, rewrote_body: bool) -> void:
	life["qi_awakened"] = true
	life["qi_known"] = true
	if rewrote_body:
		life["qi_potential"] = BirthSystem.QiPotential.LATENT
		life["meridian_integrity"] = 1.0
	realm = "Refinamento de Qi I"
	qi_amount = 18.0
	max_health += 24.0
	health = max_health
	attack_damage = maxf(22.0, attack_damage)
	if aura != null:
		aura.visible = true
	if game != null:
		if game.has_method("notify"):
			game.notify("O mundo muda. Pela primeira vez, você sente o Qi. [%s]" % source_name)
		if game.has_method("on_player_awakened"):
			game.on_player_awakened(source_name, rewrote_body)
	health_changed.emit(health, max_health)
	state_changed.emit()

func _recalculate_mortal_stats() -> void:
	var training := float(life.get("body_training", 0.0))
	var base_physique := float(life.get("physique", 50))
	max_health = 88.0 + base_physique * 0.22 + training * 0.34
	attack_damage = 5.0 + training * 0.13 + base_physique * 0.025
	if realm != "Mortal":
		max_health += 24.0
		attack_damage = maxf(22.0, attack_damage)
	health = minf(health, max_health)
	health_changed.emit(health, max_health)

func _camera_relative_direction(input_vec: Vector2) -> Vector3:
	if input_vec.length() < 0.01:
		return Vector3.ZERO
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return Vector3(input_vec.x, 0.0, input_vec.y).normalized()
	var forward := -camera.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := camera.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	return (right * input_vec.x + forward * -input_vec.y).normalized()

func _update_interactable() -> void:
	var nearest: Node = null
	var best_distance := 3.0
	for candidate in get_tree().get_nodes_in_group("interactable"):
		if candidate is Node3D:
			var distance := global_position.distance_to(candidate.global_position)
			if distance < best_distance:
				best_distance = distance
				nearest = candidate
	current_interactable = nearest
	if game != null and game.has_method("set_interaction_prompt"):
		if current_interactable != null and current_interactable.has_method("get_prompt"):
			game.set_interaction_prompt(String(current_interactable.get_prompt()))
		else:
			game.set_interaction_prompt("")

func _build_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.65
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.88
	add_child(collision)

func _build_visuals() -> void:
	var cloth := _material(Color(0.10, 0.13, 0.12))
	var skin := _material(Color(0.58, 0.42, 0.31))
	var leather := _material(Color(0.22, 0.15, 0.09))
	var metal := _material(Color(0.42, 0.44, 0.40))
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.34
	torso_mesh.height = 1.05
	torso.mesh = torso_mesh
	torso.material_override = cloth
	torso.position.y = 1.15
	add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.24
	head_mesh.height = 0.48
	head.mesh = head_mesh
	head.material_override = skin
	head.position.y = 1.95
	add_child(head)
	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := CapsuleMesh.new()
		leg_mesh.radius = 0.11
		leg_mesh.height = 0.78
		leg.mesh = leg_mesh
		leg.material_override = leather
		leg.position = Vector3(0.17 * side, 0.48, 0.0)
		add_child(leg)
	weapon_root = Node3D.new()
	weapon_root.position = Vector3(0.48, 1.35, 0.0)
	add_child(weapon_root)
	var spear := MeshInstance3D.new()
	var spear_mesh := CylinderMesh.new()
	spear_mesh.top_radius = 0.035
	spear_mesh.bottom_radius = 0.035
	spear_mesh.height = 2.0
	spear.mesh = spear_mesh
	spear.material_override = leather
	spear.rotation_degrees.z = 78.0
	weapon_root.add_child(spear)
	var tip := MeshInstance3D.new()
	var tip_mesh := CylinderMesh.new()
	tip_mesh.top_radius = 0.0
	tip_mesh.bottom_radius = 0.11
	tip_mesh.height = 0.32
	tip.mesh = tip_mesh
	tip.material_override = metal
	tip.position = Vector3(0.98, 0.0, 0.0)
	tip.rotation_degrees.z = 90.0
	weapon_root.add_child(tip)
	aura = OmniLight3D.new()
	aura.light_color = Color(0.36, 0.78, 1.0)
	aura.light_energy = 1.1
	aura.omni_range = 3.5
	aura.position.y = 1.0
	aura.visible = false
	add_child(aura)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material
