class_name CelestialFruit
extends Node3D

var collected := false
var fruit_mesh: MeshInstance3D

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / TOMAR · Fruto da Abertura Celestial"

func interact(player: PlayerController) -> void:
	if collected:
		return
	if bool(player.life.get("qi_awakened", false)):
		if player.game != null and player.game.has_method("notify"):
			player.game.notify("Você já abriu o caminho do Qi. Preservar este fruto seria mais sábio.")
		return
	collected = true
	remove_from_group("interactable")
	if fruit_mesh != null:
		fruit_mesh.visible = false
	player.force_heaven_defying_awaken("Fruto da Abertura Celestial")
	if player.game != null and player.game.has_method("record_world_event"):
		player.game.record_world_event("uma oportunidade celestial desapareceu da Montanha do Véu.")

func _build_visual() -> void:
	var pedestal := MeshInstance3D.new()
	var pedestal_mesh := CylinderMesh.new()
	pedestal_mesh.top_radius = 0.55
	pedestal_mesh.bottom_radius = 0.78
	pedestal_mesh.height = 0.75
	pedestal.mesh = pedestal_mesh
	pedestal.material_override = _material(Color(0.20, 0.20, 0.18))
	pedestal.position.y = 0.38
	add_child(pedestal)
	fruit_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.23
	sphere.height = 0.46
	fruit_mesh.mesh = sphere
	var glow := _material(Color(0.62, 0.82, 0.36))
	glow.emission_enabled = true
	glow.emission = Color(0.40, 0.82, 0.20)
	glow.emission_energy_multiplier = 3.0
	fruit_mesh.material_override = glow
	fruit_mesh.position.y = 1.05
	add_child(fruit_mesh)
	var light := OmniLight3D.new()
	light.light_color = Color(0.55, 0.95, 0.36)
	light.light_energy = 1.6
	light.omni_range = 6.0
	light.position.y = 1.15
	add_child(light)

func _process(delta: float) -> void:
	if fruit_mesh != null and fruit_mesh.visible:
		fruit_mesh.rotation.y += delta * 1.2
		fruit_mesh.position.y = 1.05 + sin(Time.get_ticks_msec() * 0.0025) * 0.08

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.42
	return material
