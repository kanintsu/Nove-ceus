class_name LoreStele
extends Node3D

@export_multiline var lore_text := "Há marcas antigas nesta pedra."

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / LER · estela antiga"

func interact(player: PlayerController) -> void:
	if player.game != null and player.game.has_method("notify"):
		player.game.notify(lore_text)

func _build_visual() -> void:
	var stone := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.9, 2.4, 0.34)
	stone.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.24, 0.27, 0.25)
	material.roughness = 1.0
	stone.material_override = material
	stone.position.y = 1.2
	stone.rotation_degrees.z = -3.0
	add_child(stone)
