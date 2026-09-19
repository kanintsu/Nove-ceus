class_name TrainingPost
extends Node3D

var busy := false

func _ready() -> void:
	add_to_group("interactable")
	_build_visual()

func get_prompt() -> String:
	return "E / TREINAR · fortalecer o corpo por um dia"

func interact(player: PlayerController) -> void:
	if busy:
		return
	busy = true
	player.train_body()
	var timer := get_tree().create_timer(0.65)
	timer.timeout.connect(func() -> void: busy = false)

func _build_visual() -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.29, 0.18, 0.10)
	wood.roughness = 0.95
	var post := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.18
	mesh.bottom_radius = 0.24
	mesh.height = 2.1
	post.mesh = mesh
	post.material_override = wood
	post.position.y = 1.05
	add_child(post)
	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var arm_mesh := BoxMesh.new()
		arm_mesh.size = Vector3(0.9, 0.13, 0.13)
		arm.mesh = arm_mesh
		arm.material_override = wood
		arm.position = Vector3(0.42 * side, 1.35, 0.0)
		add_child(arm)
