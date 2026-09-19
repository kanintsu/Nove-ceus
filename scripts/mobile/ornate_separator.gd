class_name OrnateSeparator
extends Control

var title := ""
var accent := Color("#d7bd72")

func setup(text_value:String,accent_value:Color) -> void:
	title = text_value
	accent = accent_value
	custom_minimum_size = Vector2(668,58)
	queue_redraw()

func _notification(what:int) -> void:
	if what == NOTIFICATION_DRAW:
		var y := size.y*0.55
		var line_color := Color(accent,0.52)
		draw_line(Vector2(12,y),Vector2(size.x*0.31,y),line_color,1.5)
		draw_line(Vector2(size.x*0.69,y),Vector2(size.x-12,y),line_color,1.5)
		var diamond := PackedVector2Array([
			Vector2(size.x*0.5-7,y),Vector2(size.x*0.5,y-7),
			Vector2(size.x*0.5+7,y),Vector2(size.x*0.5,y+7)
		])
		draw_colored_polygon(diamond,Color(accent,0.55))
		draw_string(ThemeDB.fallback_font,Vector2(size.x*0.32,36),title,HORIZONTAL_ALIGNMENT_CENTER,size.x*0.36,20,Color("#f1e2b8"))
