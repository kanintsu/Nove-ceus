class_name MortalNPC
extends Node3D

var display_name := "Morador"
var role := "Mortal"
var dialogue := "A vida continua."
var game: Node

func setup(game_node: Node, name_value: String, role_value: String, dialogue_value: String, clothing: Color) -> void:
	game = game_node
	display_name = name_value
	role = role_value
	dialogue = dialogue_value
	add_to_group("interactable")
	_build_visual(clothing)

func get_prompt() -> String:
	return "E / CONVERSAR · %s · %s" % [display_name, role]

func interact(_player: PlayerController) -> void:
	if game != null and game.has_method("notify"):
		game.notify("%s: “%s”" % [display_name, dialogue])

func _build_visual(clothing: Color) -> void:
	var skin := _material(Color(0.58, 0.43, 0.32))
	var cloth := _material(clothing)
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.30
	torso_mesh.height = 0.95
	torso.mesh = torso_mesh
	torso.material_override = cloth
	torso.position.y = 1.05
	add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.44
	head.mesh = head_mesh
	head.material_override = skin
	head.position.y = 1.78
	add_child(head)
	var label := Label3D.new()
	label.text = "%s
%s" % [display_name, role]
	label.font_size = 28
	label.position.y = 2.45
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 4
	label.outline_modulate = Color(0.02, 0.02, 0.02, 0.8)
	add_child(label)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
