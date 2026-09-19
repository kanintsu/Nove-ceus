class_name MortalLifeMarker
extends Node3D

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / VIVER UMA ESTAÇÃO · 90 dias de vida mortal"

func interact(player: PlayerController) -> void:
	if player == null:
		return
	player.live_mortal_season()

func _build_visual() -> void:
	var base := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.4, 0.35, 1.4)
	base.mesh = box
	base.material_override = _material(Color(0.30, 0.20, 0.11))
	base.position.y = 0.18
	add_child(base)
	var awning := MeshInstance3D.new()
	var roof := BoxMesh.new()
	roof.size = Vector3(2.8, 0.18, 1.8)
	awning.mesh = roof
	awning.material_override = _material(Color(0.38, 0.12, 0.08))
	awning.position.y = 1.75
	add_child(awning)
	var label := Label3D.new()
	label.text = "PÁTIO DA VIDA MORTAL\ntrabalho · estudo · treino"
	label.font_size = 24
	label.position.y = 2.35
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 4
	label.outline_modulate = Color(0.02, 0.02, 0.02, 0.8)
	add_child(label)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
