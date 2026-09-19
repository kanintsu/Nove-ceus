class_name RebornUI
extends RefCounted

static func panel(bg:Color, border:Color, radius:int=18, width:int=1) -> StyleBoxFlat:
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

static func label(text_value:String, font_size:int, color:Color=Color.WHITE)->Label:
	var l:=Label.new()
	l.text=text_value
	l.add_theme_font_size_override("font_size",font_size)
	l.modulate=color
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	return l

static func button(text_value:String, accent:Color, height:int=58)->Button:
	var b:=Button.new()
	b.text=text_value
	b.custom_minimum_size=Vector2(0,height)
	b.focus_mode=Control.FOCUS_NONE
	b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size",13)
	b.add_theme_stylebox_override("normal",panel(Color("#0b2027",0.96),Color(accent,0.58),15,1))
	b.add_theme_stylebox_override("pressed",panel(Color("#14333a",0.99),accent,15,2))
	return b

static func accent_for_phase(phase:int)->Color:
	match phase:
		1:return Color("#d9bd72")
		2:return Color("#d98b6b")
		3:return Color("#79c9df")
		4:return Color("#bd708d")
		_:return Color("#e0ca7a")

static func dark_for_phase(phase:int)->Color:
	match phase:
		1:return Color("#081b21")
		2:return Color("#211820")
		3:return Color("#0a1f2d")
		4:return Color("#211321")
		_:return Color("#11152a")
