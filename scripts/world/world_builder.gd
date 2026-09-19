class_name WorldBuilder
extends Node3D

const SpiritBeastScript = preload("res://scripts/world/spirit_beast.gd")
const QiTestStoneScript = preload("res://scripts/interactables/qi_test_stone.gd")
const SpiritSpringScript = preload("res://scripts/interactables/spirit_spring.gd")
const CelestialFruitScript = preload("res://scripts/interactables/celestial_fruit.gd")
const TrainingPostScript = preload("res://scripts/interactables/training_post.gd")
const StudyTableScript = preload("res://scripts/interactables/study_table.gd")
const LoreSteleScript = preload("res://scripts/interactables/lore_stele.gd")
const MortalNPCScript = preload("res://scripts/world/mortal_npc.gd")
const RareEncounterNPCScript = preload("res://scripts/world/rare_encounter_npc.gd")
const MortalLifeMarkerScript = preload("res://scripts/interactables/mortal_life_marker.gd")

var rng := RandomNumberGenerator.new()
var game: Node
var material_cache: Dictionary = {}
var beast: SpiritBeast
var rare_encounter_npc: RareEncounterNPC

const VILLAGE := Vector3(-48, 0, 32)
const CITY := Vector3(48, 0, -28)
const FOREST := Vector3(0, 0, 13)
const MOUNTAIN := Vector3(31, 0, 54)
const RUINS := Vector3(-38, 0, -34)

func setup(game_node: Node, seed_value: int, world_age_bonus: int = 0) -> void:
	game = game_node
	rng.seed = seed_value
	_build_ground()
	_build_roads_and_river()
	_build_village()
	_build_city()
	_build_forest()
	_build_mountain(world_age_bonus)
	_build_ruins()
	_build_boundaries()
	refresh_rare_encounter()

func get_spawn_position(origin_id: String) -> Vector3:
	match origin_id:
		"farm_village":
			return VILLAGE + Vector3(-4, 1.2, 1)
		"frontier_hunters":
			return Vector3(-16, 1.2, 29)
		"merchant_town":
			return CITY + Vector3(0, 1.2, 17)
		"martial_house":
			return CITY + Vector3(-10, 1.2, 3)
		"sect_servants":
			return Vector3(18, 1.2, 39)
		"spirit_mine":
			return MOUNTAIN + Vector3(-16, 1.2, -5)
		"deep_forest":
			return Vector3(12, 1.2, 36)
		"ruined_clan":
			return RUINS + Vector3(2, 1.2, 4)
		_:
			return VILLAGE + Vector3(0, 1.2, 0)

func location_name(position: Vector3) -> String:
	if position.distance_to(VILLAGE) < 23.0:
		return "Vila da Nascente"
	if position.distance_to(CITY) < 27.0:
		return "Cidade Qinghe"
	if position.distance_to(MOUNTAIN) < 25.0:
		return "Montanha do Véu · território de besta espiritual"
	if position.distance_to(RUINS) < 20.0:
		return "Ruínas de Lianshi"
	if position.distance_to(FOREST) < 38.0:
		return "Floresta da Névoa Fria"
	return "Estradas do Reino de Yan"

func _build_ground() -> void:
	_static_box("Ground", Vector3(0, -0.6, 0), Vector3(184, 1.2, 184), Color(0.17, 0.24, 0.17), true)
	_visual_box("VillageGrass", VILLAGE + Vector3(0, 0.02, 0), Vector3(38, 0.04, 32), Color(0.23, 0.31, 0.18))
	_visual_box("CityStone", CITY + Vector3(0, 0.025, 0), Vector3(47, 0.05, 42), Color(0.31, 0.30, 0.25))
	_visual_box("ForestFloor", FOREST + Vector3(0, 0.03, 0), Vector3(64, 0.06, 74), Color(0.10, 0.20, 0.13))
	_visual_box("MountainFloor", MOUNTAIN + Vector3(0, 0.04, 0), Vector3(48, 0.08, 42), Color(0.24, 0.22, 0.16))
	_visual_box("RuinsFloor", RUINS + Vector3(0, 0.04, 0), Vector3(31, 0.08, 27), Color(0.24, 0.26, 0.22))

func _build_roads_and_river() -> void:
	_visual_box("RoadVillage", Vector3(-25, 0.07, 24), Vector3(46, 0.08, 5), Color(0.40, 0.32, 0.20), 0.0)
	_visual_box("RoadEast", Vector3(18, 0.07, -4), Vector3(5, 0.08, 57), Color(0.40, 0.32, 0.20), 0.0)
	_visual_box("RoadCity", Vector3(34, 0.07, -27), Vector3(30, 0.08, 5), Color(0.40, 0.32, 0.20), 0.0)
	_visual_box("River", Vector3(-2, 0.09, -9), Vector3(176, 0.10, 7), Color(0.08, 0.26, 0.31), 0.0)
	_static_box("Bridge", Vector3(18, 0.24, -9), Vector3(6.5, 0.42, 9.0), Color(0.31, 0.22, 0.13), true)
	for x in [-72, -48, -24, 0, 24, 48, 72]:
		_visual_box("RiverRock", Vector3(x, 0.22, -11.5 + rng.randf_range(-1.0, 1.0)), Vector3(1.8, 0.45, 1.3), Color(0.27, 0.31, 0.29), rng.randf_range(-25.0, 25.0))

func _build_village() -> void:
	for offset in [Vector3(-10, 0, -7), Vector3(-2, 0, -9), Vector3(8, 0, -6), Vector3(-11, 0, 5), Vector3(1, 0, 7), Vector3(11, 0, 5)]:
		_house(VILLAGE + offset, Color(0.36, 0.16, 0.10), 0.9)
	var well := _mesh_instance(CylinderMesh.new(), _mat(Color(0.32, 0.31, 0.25)))
	var well_mesh := well.mesh as CylinderMesh
	well_mesh.top_radius = 1.15
	well_mesh.bottom_radius = 1.25
	well_mesh.height = 0.6
	well.position = VILLAGE + Vector3(0, 0.3, 0)
	add_child(well)
	var training := TrainingPostScript.new()
	training.position = VILLAGE + Vector3(8, 0, 11)
	add_child(training)
	var mortal_life := MortalLifeMarkerScript.new()
	mortal_life.position = VILLAGE + Vector3(-8, 0, 11)
	add_child(mortal_life)
	_mortal_npc(VILLAGE + Vector3(-6, 0, 1), "Tia Mei", "curandeira", "A floresta alimenta quem a respeita. Os jovens que perseguem luzes estranhas raramente voltam.", Color(0.26, 0.34, 0.25))
	_mortal_npc(VILLAGE + Vector3(5, 0, -1), "Bo Ren", "caçador", "Vi pegadas grandes demais perto da Montanha do Véu. Se você é mortal, aprenda primeiro quando correr.", Color(0.32, 0.24, 0.16))
	_mortal_npc(VILLAGE + Vector3(1, 0, 10), "Lian", "ferreira", "Força não nasce do nada. Mesmo sem Qi, um corpo treinado decide quem volta vivo de uma estrada ruim.", Color(0.28, 0.20, 0.18))
	_location_marker("VILA DA NASCENTE", VILLAGE + Vector3(0, 3.6, 13))

func _build_city() -> void:
	_static_box("CityWallN", CITY + Vector3(0, 1.5, -21), Vector3(48, 3, 1.4), Color(0.36, 0.34, 0.29), true)
	_static_box("CityWallW", CITY + Vector3(-24, 1.5, 0), Vector3(1.4, 3, 42), Color(0.36, 0.34, 0.29), true)
	_static_box("CityWallE", CITY + Vector3(24, 1.5, 0), Vector3(1.4, 3, 42), Color(0.36, 0.34, 0.29), true)
	_static_box("CityWallS1", CITY + Vector3(-15, 1.5, 21), Vector3(18, 3, 1.4), Color(0.36, 0.34, 0.29), true)
	_static_box("CityWallS2", CITY + Vector3(15, 1.5, 21), Vector3(18, 3, 1.4), Color(0.36, 0.34, 0.29), true)
	for offset in [Vector3(-14,0,-12), Vector3(-4,0,-12), Vector3(8,0,-12), Vector3(16,0,-8), Vector3(-15,0,1), Vector3(15,0,3), Vector3(-12,0,11), Vector3(2,0,10), Vector3(12,0,12)]:
		_house(CITY + offset, Color(0.42, 0.12, 0.09), 1.0)
	var test_stone := QiTestStoneScript.new()
	test_stone.position = CITY + Vector3(0, 0, -1)
	add_child(test_stone)
	var study := StudyTableScript.new()
	study.position = CITY + Vector3(-6, 0, 7)
	add_child(study)
	_mortal_npc(CITY + Vector3(6, 0, -2), "Mestre Cao", "escriba", "Há homens que jamais sentiram Qi e ainda assim mudaram dinastias com números, pontes e leis.", Color(0.18, 0.24, 0.31))
	_mortal_npc(CITY + Vector3(-2, 0, 6), "Yu Shan", "mercadora", "Pedras espirituais valem fortunas, mas não tente comprá-las sem saber quem está observando.", Color(0.34, 0.19, 0.25))
	_mortal_npc(CITY + Vector3(9, 0, 9), "Velho Jian", "viajante", "Ouvi falar de uma fruta na montanha capaz de abrir um caminho onde o céu não deixou nenhum. Histórias assim costumam matar mais gente do que salvar.", Color(0.25, 0.25, 0.24))
	_location_marker("CIDADE QINGHE", CITY + Vector3(0, 5.0, -18))

func _build_forest() -> void:
	for i in range(92):
		var x := rng.randf_range(-28.0, 25.0)
		var z := rng.randf_range(-20.0, 47.0)
		var position := FOREST + Vector3(x, 0, z - 13.0)
		if position.distance_to(Vector3(18, 0, -9)) < 9.0:
			continue
		if position.distance_to(VILLAGE) < 20.0:
			continue
		_tree(position, rng.randf_range(0.78, 1.35))
	for i in range(22):
		_rock(FOREST + Vector3(rng.randf_range(-28, 28), 0, rng.randf_range(-28, 32)), rng.randf_range(0.5, 1.25))
	var spring := SpiritSpringScript.new()
	spring.position = Vector3(8, 0, 29)
	add_child(spring)
	_location_marker("NASCENTE ESPIRITUAL", Vector3(8, 3.0, 29))

func _build_mountain(world_age_bonus: int) -> void:
	for i in range(34):
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(10.0, 23.0)
		_rock(MOUNTAIN + Vector3(cos(angle) * radius, 0, sin(angle) * radius), rng.randf_range(0.9, 2.2))
	for step in range(5):
		_static_box("MountainStep%d" % step, MOUNTAIN + Vector3(-6.0 + step * 2.5, 0.24 + step * 0.34, 4.0 + step * 2.2), Vector3(5.0, 0.5 + step * 0.1, 4.6), Color(0.30, 0.28, 0.22), true)
	var fruit := CelestialFruitScript.new()
	fruit.position = MOUNTAIN + Vector3(7.5, 2.2, 13.0)
	add_child(fruit)
	beast = SpiritBeastScript.new()
	beast.position = MOUNTAIN + Vector3(-2.0, 1.1, 3.0)
	add_child(beast)
	beast.setup(game, world_age_bonus)
	_location_marker("MONTANHA DO VÉU", MOUNTAIN + Vector3(0, 6.0, -12))

func _build_ruins() -> void:
	for offset in [Vector3(-9,0,-7), Vector3(-4,0,-8), Vector3(5,0,-6), Vector3(9,0,0), Vector3(-8,0,5), Vector3(2,0,8)]:
		var height := rng.randf_range(1.2, 3.6)
		_static_box("RuinedColumn", RUINS + offset + Vector3(0, height * 0.5, 0), Vector3(0.8, height, 0.8), Color(0.31, 0.33, 0.29), true, rng.randf_range(-8, 8))
	var stele := LoreSteleScript.new()
	stele.lore_text = "A inscrição quase apagada diz: 'Quando o céu nega um caminho, alguns mortais procuram outro.'"
	stele.position = RUINS + Vector3(0, 0, 0)
	add_child(stele)
	_location_marker("RUÍNAS DE LIANSHI", RUINS + Vector3(0, 4.3, 0))

func refresh_rare_encounter() -> void:
	if rare_encounter_npc != null and is_instance_valid(rare_encounter_npc):
		rare_encounter_npc.queue_free()
		rare_encounter_npc = null
	if game == null or not game.has_method("get_current_rare_encounter"):
		return
	var profile: Dictionary = game.get_current_rare_encounter()
	if profile.is_empty():
		return
	rare_encounter_npc = RareEncounterNPCScript.new()
	var kind := String(profile.get("kind", ""))
	match kind:
		"abandoned_child":
			rare_encounter_npc.position = VILLAGE + Vector3(-17, 0, 3)
		"injured_youth":
			rare_encounter_npc.position = Vector3(-20, 0, 22)
		_:
			rare_encounter_npc.position = CITY + Vector3(-18, 0, 15)
	add_child(rare_encounter_npc)
	rare_encounter_npc.setup(game, profile)

func _build_boundaries() -> void:
	for i in range(34):
		var angle := TAU * float(i) / 34.0
		var radius := 88.0
		_rock(Vector3(cos(angle) * radius, 0, sin(angle) * radius), rng.randf_range(2.5, 5.0))

func _mortal_npc(position: Vector3, npc_name: String, role: String, dialogue: String, clothing: Color) -> void:
	var npc := MortalNPCScript.new()
	npc.position = position
	add_child(npc)
	npc.setup(game, npc_name, role, dialogue, clothing)

func _house(position: Vector3, roof_color: Color, scale_value: float) -> void:
	_static_box("House", position + Vector3(0, 1.25 * scale_value, 0), Vector3(4.6, 2.5, 3.8) * scale_value, Color(0.48, 0.38, 0.25), true)
	_visual_box("Roof", position + Vector3(0, 2.95 * scale_value, 0), Vector3(5.5, 0.42, 4.7) * scale_value, roof_color, 0.0)
	_visual_box("RoofCap", position + Vector3(0, 3.28 * scale_value, 0), Vector3(4.7, 0.28, 3.9) * scale_value, roof_color.darkened(0.08), 0.0)
	_visual_box("Door", position + Vector3(0, 0.95 * scale_value, -1.93 * scale_value), Vector3(0.9, 1.65, 0.10) * scale_value, Color(0.19, 0.10, 0.06), 0.0)

func _tree(position: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = position
	root.scale = Vector3.ONE * scale_value
	add_child(root)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.15
	trunk_mesh.bottom_radius = 0.23
	trunk_mesh.height = 2.5
	trunk.mesh = trunk_mesh
	trunk.material_override = _mat(Color(0.25, 0.16, 0.09))
	trunk.position.y = 1.25
	root.add_child(trunk)
	for layer in range(3):
		var foliage := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.12
		cone.bottom_radius = 1.25 - layer * 0.18
		cone.height = 1.65
		foliage.mesh = cone
		foliage.material_override = _mat(Color(0.08 + layer * 0.015, 0.28 + layer * 0.02, 0.13))
		foliage.position.y = 2.4 + layer * 0.72
		root.add_child(foliage)

func _rock(position: Vector3, scale_value: float) -> void:
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.72
	sphere.height = 1.05
	mesh.mesh = sphere
	mesh.material_override = _mat(Color(0.28, 0.30, 0.27))
	mesh.position = position + Vector3(0, 0.5 * scale_value, 0)
	mesh.scale = Vector3(scale_value * rng.randf_range(0.8, 1.3), scale_value * rng.randf_range(0.65, 1.15), scale_value * rng.randf_range(0.75, 1.35))
	mesh.rotation_degrees.y = rng.randf_range(0, 180)
	add_child(mesh)

func _location_marker(text_value: String, position: Vector3) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.font_size = 38
	label.modulate = Color(0.78, 0.84, 0.74, 0.88)
	label.outline_size = 6
	label.outline_modulate = Color(0.02, 0.03, 0.025, 0.8)
	label.position = position
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func _static_box(node_name: String, position: Vector3, size_value: Vector3, color: Color, collision_enabled: bool, yaw_degrees: float = 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	body.rotation_degrees.y = yaw_degrees
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size_value
	mesh_instance.mesh = box
	mesh_instance.material_override = _mat(color)
	body.add_child(mesh_instance)
	if collision_enabled:
		var shape := BoxShape3D.new()
		shape.size = size_value
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
	add_child(body)
	return body

func _visual_box(node_name: String, position: Vector3, size_value: Vector3, color: Color, yaw_degrees: float = 0.0) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size_value
	mesh_instance.mesh = box
	mesh_instance.material_override = _mat(color)
	mesh_instance.position = position
	mesh_instance.rotation_degrees.y = yaw_degrees
	add_child(mesh_instance)
	return mesh_instance

func _mesh_instance(mesh_resource: Mesh, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh_resource
	instance.material_override = material
	return instance

func _mat(color: Color) -> StandardMaterial3D:
	var key := color.to_html(true)
	if material_cache.has(key):
		return material_cache[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	material_cache[key] = material
	return material
