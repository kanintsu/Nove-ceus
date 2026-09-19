class_name V08ChronicleScreen
extends Control
const Visuals=preload("res://scripts/v08/game_visuals.gd")

func setup(text_value:String)->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for c in get_children(): c.queue_free()
	var title:=Visuals.label("CRÔNICA DOS NOVE CÉUS",25,Color("#f2e4be")); title.position=Vector2(18,16); title.size=Vector2(684,42); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title)
	var scroll:=ScrollContainer.new(); scroll.position=Vector2(32,84); scroll.size=Vector2(656,940); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var p:=PanelContainer.new(); p.custom_minimum_size=Vector2(630,0); p.add_theme_stylebox_override("panel",Visuals.panel(Color("#0d242a"),Color("#8da3b3",0.45),18,1)); scroll.add_child(p)
	var rich:=RichTextLabel.new(); rich.bbcode_enabled=true; rich.fit_content=true; rich.custom_minimum_size=Vector2(600,900); rich.add_theme_font_size_override("normal_font_size",15); rich.text=text_value; p.add_child(rich)
