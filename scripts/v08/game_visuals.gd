class_name GameVisuals
extends RefCounted

static func panel(bg:Color,border:Color,radius:int=18,width:int=1) -> StyleBoxFlat:
	var s:=StyleBoxFlat.new()
	s.bg_color=bg
	s.corner_radius_top_left=radius
	s.corner_radius_top_right=radius
	s.corner_radius_bottom_left=radius
	s.corner_radius_bottom_right=radius
	s.border_width_left=width
	s.border_width_right=width
	s.border_width_top=width
	s.border_width_bottom=width
	s.border_color=border
	s.content_margin_left=12
	s.content_margin_right=12
	s.content_margin_top=10
	s.content_margin_bottom=10
	return s

static func phase_accent(phase:int)->Color:
	match phase:
		1:return Color("#d2b66d")
		2:return Color("#d18b68")
		3:return Color("#77c9de")
		4:return Color("#b56d86")
		_:return Color("#d8c37a")

static func phase_bg(phase:int)->Color:
	match phase:
		1:return Color("#0b2428")
		2:return Color("#271c25")
		3:return Color("#0d2536")
		4:return Color("#241624")
		_:return Color("#15182d")

static func rarity_color(rarity:String)->Color:
	match rarity:
		"Incomum":return Color("#70b493")
		"Raro":return Color("#6aa9d8")
		"Épico":return Color("#a47ad5")
		"Lendário":return Color("#dda85e")
		"Mítico":return Color("#e77a86")
		_:return Color("#a8b0ac")

static func label(text_value:String,size:int,color:Color=Color.WHITE)->Label:
	var l:=Label.new()
	l.text=text_value
	l.add_theme_font_size_override("font_size",size)
	l.modulate=color
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	return l
