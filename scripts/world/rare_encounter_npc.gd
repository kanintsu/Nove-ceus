class_name RareEncounterNPC
extends Node3D

var game: Node
var profile: Dictionary = {}
var accepted := false
var label: Label3D

func setup(game_node: Node, profile_data: Dictionary) -> void:
	game = game_node
	profile = profile_data
	accepted = bool(profile.get("accepted", false))
	add_to_group("interactable")
	_build_visual()
	_refresh_label()

func get_prompt() -> String:
	if accepted:
		return "E / CONVERSAR · %s · seu protegido" % String(profile.get("name", "Desconhecido"))
	match String(profile.get("kind", "")):
		"abandoned_child":
			return "E / ACOLHER · criança abandonada"
		"injured_youth":
			return "E / AJUDAR · jovem ferido"
		_:
			return "E / CONVERSAR · jovem sem mestre"

func interact(_player: PlayerController) -> void:
	if accepted:
		if game != null and game.has_method("notify"):
			game.notify("%s agora depende das escolhas desta vida — o futuro dele ainda é desconhecido." % String(profile.get("name", "Seu protegido")))
		return

	if game == null or not game.has_method("accept_rare_encounter"):
		return
	var accepted_now: bool = bool(game.accept_rare_encounter(profile))
	if not accepted_now:
		return
	accepted = true
	profile["accepted"] = true
	_refresh_label()
	if game.has_method("notify"):
		game.notify("Você decidiu proteger %s. Qi ou não, esta vida agora está ligada à sua." % String(profile.get("name", "essa pessoa")))

func _build_visual() -> void:
	var age := int(profile.get("age", 12))
	var scale_value := 0.48 if age <= 4 else (0.72 if age <= 14 else 0.88)
	var skin := _material(Color(0.60, 0.45, 0.34))
	var cloth := _material(Color(0.30, 0.25, 0.18))
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.29
	torso_mesh.height = 0.90
	torso.mesh = torso_mesh
	torso.material_override = cloth
	torso.position.y = 0.95
	torso.scale = Vector3.ONE * scale_value
	add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head.mesh = head_mesh
	head.material_override = skin
	head.position.y = 1.62 * scale_value + 0.24
	head.scale = Vector3.ONE * scale_value
	add_child(head)
	label = Label3D.new()
	label.font_size = 27
	label.position.y = 2.0 * scale_value + 0.65
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 4
	label.outline_modulate = Color(0.02, 0.02, 0.02, 0.85)
	add_child(label)

func _refresh_label() -> void:
	if label == null:
		return
	if accepted:
		label.text = "%s\nProtegido" % String(profile.get("name", "Desconhecido"))
	else:
		label.text = "%s\n%s" % [String(profile.get("name", "Desconhecido")), String(profile.get("role", "viajante"))]

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material
