class_name MobileFX
extends Control

var rng := RandomNumberGenerator.new()
var particles: Array[Dictionary] = []
var phase := 1
var elapsed := 0.0
var reduced_motion := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rng.seed = 872341
	reduced_motion = false
	_reset_particles()

func set_phase(value: int) -> void:
	phase = clampi(value,1,5)
	_reset_particles()
	queue_redraw()

func _process(delta: float) -> void:
	if reduced_motion:
		return
	elapsed += delta
	for p in particles:
		p["y"] = float(p["y"]) - float(p["speed"]) * delta
		p["x"] = float(p["x"]) + sin(elapsed * float(p["drift"]) + float(p["seed"])) * delta * 5.0
		if float(p["y"]) < -30.0:
			p["y"] = size.y + rng.randf_range(10.0,110.0)
			p["x"] = rng.randf_range(0.0,maxf(size.x,720.0))
	queue_redraw()

func _draw() -> void:
	var palette := _palette()
	for p in particles:
		var alpha := float(p["alpha"])
		var radius := float(p["radius"])
		var color: Color = palette[int(p["color_index"]) % palette.size()]
		color.a = alpha
		draw_circle(Vector2(float(p["x"]),float(p["y"])),radius,color)
		if radius > 3.0:
			var line_color := color
			line_color.a *= 0.35
			draw_line(Vector2(float(p["x"])-radius*2.5,float(p["y"])),Vector2(float(p["x"])+radius*2.5,float(p["y"])),line_color,1.0)

func _reset_particles() -> void:
	particles.clear()
	var amount := 24 + phase * 7
	for _i in range(amount):
		particles.append({
			"x":rng.randf_range(0.0,720.0),
			"y":rng.randf_range(0.0,1280.0),
			"speed":rng.randf_range(4.0,14.0)+phase*1.6,
			"drift":rng.randf_range(0.4,1.3),
			"seed":rng.randf_range(0.0,TAU),
			"radius":rng.randf_range(1.0,4.4),
			"alpha":rng.randf_range(0.15,0.48),
			"color_index":rng.randi_range(0,2)
		})

func _palette() -> Array[Color]:
	match phase:
		1: return [Color("#d7d5a4"),Color("#9fc6b4"),Color("#f2e4ba")]
		2: return [Color("#e2b865"),Color("#d98154"),Color("#f3e1af")]
		3: return [Color("#78c9e2"),Color("#9da8e8"),Color("#e6ddae")]
		4: return [Color("#d05f62"),Color("#8f6ec9"),Color("#e4a767")]
		_: return [Color("#e9d58c"),Color("#86d8ee"),Color("#d7a8ef")]
