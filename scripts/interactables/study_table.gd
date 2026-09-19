class_name StudyTable
extends Node3D

var busy := false

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / ESTUDAR · passar sete dias no pavilhão mortal"

func interact(player: PlayerController) -> void:
	if busy:
		return
	busy = true
	player.study_mortal_knowledge()
	var timer := get_tree().create_timer(0.65)
	timer.timeout.connect(func() -> void: busy = false)

func _build_visual() -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.25, 0.15, 0.09)
	wood.roughness = 0.9
	var table := MeshInstance3D.new()
	var table_mesh := BoxMesh.new()
	table_mesh.size = Vector3(1.6, 0.18, 0.8)
	table.mesh = table_mesh
	table.material_override = wood
	table.position.y = 0.72
	add_child(table)
	var book := MeshInstance3D.new()
	var book_mesh := BoxMesh.new()
	book_mesh.size = Vector3(0.45, 0.07, 0.32)
	book.mesh = book_mesh
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color(0.72, 0.65, 0.48)
	book.material_override = paper
	book.position = Vector3(0.0, 0.85, 0.0)
	add_child(book)
