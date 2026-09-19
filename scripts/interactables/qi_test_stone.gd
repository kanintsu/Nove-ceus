class_name QiTestStone
extends Node3D

var used_recently := false

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / INTERAGIR · tocar a Pedra de Afinidade"

func interact(player: PlayerController) -> void:
	if used_recently:
		return
	used_recently = true
	var diagnosis := player.reveal_spiritual_state()
	var game := player.game
	if game != null and game.has_method("notify"):
		game.notify("A pedra responde ao seu corpo: %s." % diagnosis)
	if game != null and game.has_method("on_spiritual_test"):
		game.on_spiritual_test(diagnosis)
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(func() -> void: used_recently = false)

func _build_visual() -> void:
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.82
	base_mesh.bottom_radius = 0.96
	base_mesh.height = 0.36
	base.mesh = base_mesh
	base.material_override = _material(Color(0.19, 0.22, 0.22))
	base.position.y = 0.18
	add_child(base)
	var stone := MeshInstance3D.new()
	var stone_mesh := SphereMesh.new()
	stone_mesh.radius = 0.48
	stone_mesh.height = 0.92
	stone.mesh = stone_mesh
	var glowing := _material(Color(0.18, 0.38, 0.42))
	glowing.emission_enabled = true
	glowing.emission = Color(0.08, 0.46, 0.55)
	glowing.emission_energy_multiplier = 1.4
	stone.material_override = glowing
	stone.position.y = 0.82
	add_child(stone)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material
