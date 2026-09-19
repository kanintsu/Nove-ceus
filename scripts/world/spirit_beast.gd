class_name SpiritBeast
extends CharacterBody3D

const GRAVITY := 22.0

var game: Node
var home_position := Vector3.ZERO
var health := 180.0
var max_health := 180.0
var move_speed := 5.35
var chase_radius := 15.0
var lose_radius := 28.0
var attack_damage := 72.0
var attack_cooldown := 0.0
var world_age_bonus := 0
var target: PlayerController
var eye_material: StandardMaterial3D

func setup(game_node: Node, age_bonus: int = 0) -> void:
	game = game_node
	world_age_bonus = age_bonus
	home_position = global_position
	max_health = 180.0 + float(age_bonus) * 12.0
	health = max_health
	attack_damage = 72.0 + float(age_bonus) * 4.0
	move_speed = 5.35 + minf(float(age_bonus) * 0.08, 1.2)
	add_to_group("beast")
	_build_collision()
	_build_visual()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	if target == null or not is_instance_valid(target):
		var found := get_tree().get_first_node_in_group("player")
		if found is PlayerController:
			target = found
	var desired := Vector3.ZERO
	if target != null and is_instance_valid(target):
		var distance := global_position.distance_to(target.global_position)
		if distance <= chase_radius or (distance <= lose_radius and global_position.distance_to(home_position) > 1.0):
			desired = target.global_position - global_position
			desired.y = 0.0
			if desired.length() > 0.05:
				desired = desired.normalized()
			if distance < 1.75 and attack_cooldown <= 0.0:
				attack_cooldown = 1.05
				target.take_damage(attack_damage, "Besta Espiritual — Tigre da Névoa")
				if game != null and game.has_method("notify"):
					game.notify("O Tigre da Névoa atinge você com força espiritual!")
		else:
			desired = home_position - global_position
			desired.y = 0.0
			if desired.length() < 0.8:
				desired = Vector3.ZERO
			else:
				desired = desired.normalized()
	velocity.x = desired.x * move_speed
	velocity.z = desired.z * move_speed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	if desired.length() > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(desired.x, desired.z), delta * 6.0)
	move_and_slide()

func take_damage(amount: float, attacker: Node) -> void:
	health = maxf(health - amount, 0.0)
	if attacker is PlayerController:
		target = attacker
	if health <= 0.0:
		if game != null:
			if game.has_method("notify"):
				game.notify("A besta espiritual caiu. Um mortal jamais esqueceria esta vitória.")
			if game.has_method("record_world_event"):
				game.record_world_event("o Tigre da Névoa que dominava a Montanha do Véu foi abatido.")
		queue_free()

func _build_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.72
	shape.height = 1.45
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.72
	add_child(collision)

func _build_visual() -> void:
	var fur := _material(Color(0.16, 0.19, 0.18))
	var stripe := _material(Color(0.035, 0.045, 0.045))
	var bone := _material(Color(0.68, 0.72, 0.66))
	eye_material = _material(Color(0.12, 0.45, 0.32))
	eye_material.emission_enabled = true
	eye_material.emission = Color(0.10, 0.85, 0.50)
	eye_material.emission_energy_multiplier = 3.0
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.35, 0.85, 2.15)
	body.mesh = body_mesh
	body.material_override = fur
	body.position.y = 0.92
	add_child(body)
	var shoulders := MeshInstance3D.new()
	var shoulders_mesh := SphereMesh.new()
	shoulders_mesh.radius = 0.62
	shoulders_mesh.height = 1.1
	shoulders.mesh = shoulders_mesh
	shoulders.material_override = fur
	shoulders.position = Vector3(0.0, 1.02, -0.78)
	add_child(shoulders)
	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.92, 0.72, 0.9)
	head.mesh = head_mesh
	head.material_override = fur
	head.position = Vector3(0.0, 1.28, -1.45)
	add_child(head)
	for side in [-1.0, 1.0]:
		var horn := MeshInstance3D.new()
		var horn_mesh := CylinderMesh.new()
		horn_mesh.top_radius = 0.0
		horn_mesh.bottom_radius = 0.11
		horn_mesh.height = 0.48
		horn.mesh = horn_mesh
		horn.material_override = bone
		horn.position = Vector3(0.32 * side, 1.72, -1.5)
		horn.rotation_degrees.z = 18.0 * side
		add_child(horn)
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.06
		eye_mesh.height = 0.12
		eye.mesh = eye_mesh
		eye.material_override = eye_material
		eye.position = Vector3(0.24 * side, 1.39, -1.91)
		add_child(eye)
	for x in [-0.48, 0.48]:
		for z in [-0.66, 0.66]:
			var leg := MeshInstance3D.new()
			var leg_mesh := BoxMesh.new()
			leg_mesh.size = Vector3(0.28, 0.78, 0.32)
			leg.mesh = leg_mesh
			leg.material_override = stripe
			leg.position = Vector3(x, 0.43, z)
			add_child(leg)
	var tail := MeshInstance3D.new()
	var tail_mesh := CylinderMesh.new()
	tail_mesh.top_radius = 0.08
	tail_mesh.bottom_radius = 0.12
	tail_mesh.height = 1.55
	tail.mesh = tail_mesh
	tail.material_override = fur
	tail.position = Vector3(0.0, 1.05, 1.55)
	tail.rotation_degrees.x = 62.0
	add_child(tail)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
