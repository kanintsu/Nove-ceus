class_name SpiritSpring
extends Node3D

var busy := false

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / MEDITAR · sentir a nascente espiritual"

func interact(player: PlayerController) -> void:
	if busy:
		return
	busy = true
	if player.try_awaken_naturally("Nascente Espiritual da Névoa"):
		if player.game != null and player.game.has_method("record_world_event"):
			player.game.record_world_event("um jovem cultivador despertou junto à Nascente Espiritual da Névoa.")
	var timer := get_tree().create_timer(1.2)
	timer.timeout.connect(func() -> void: busy = false)

func _build_visual() -> void:
	var basin := MeshInstance3D.new()
	var basin_mesh := CylinderMesh.new()
	basin_mesh.top_radius = 1.6
	basin_mesh.bottom_radius = 1.8
	basin_mesh.height = 0.25
	basin.mesh = basin_mesh
	basin.material_override = _material(Color(0.12, 0.18, 0.19))
	basin.position.y = 0.12
	add_child(basin)
	var water := MeshInstance3D.new()
	var water_mesh := CylinderMesh.new()
	water_mesh.top_radius = 1.42
	water_mesh.bottom_radius = 1.42
	water_mesh.height = 0.08
	water.mesh = water_mesh
	var water_material := _material(Color(0.12, 0.45, 0.52))
	water_material.emission_enabled = true
	water_material.emission = Color(0.04, 0.25, 0.30)
	water_material.emission_energy_multiplier = 1.15
	water.material_override = water_material
	water.position.y = 0.29
	add_child(water)
	var light := OmniLight3D.new()
	light.light_color = Color(0.18, 0.68, 0.76)
	light.light_energy = 0.8
	light.omni_range = 5.5
	light.position.y = 1.2
	add_child(light)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.55
	return material
