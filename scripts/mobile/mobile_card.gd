class_name MobileCard
extends VBoxContainer

var panel_color := Color(0.055,0.075,0.085,0.90)
var border_color := Color(0.55,0.50,0.36,0.45)

func _ready() -> void:
	add_theme_constant_override("separation",8)
	custom_minimum_size = Vector2(668,0)
	queue_redraw()

func _draw() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = panel_color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = border_color
	draw_style_box(style,Rect2(Vector2.ZERO,size))
