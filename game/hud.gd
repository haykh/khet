class_name HUD
extends CanvasLayer

func initialize(color_red: Color, color_silver: Color) -> void:
	var font_normal := FontVariation.new()
	font_normal.set_base_font(load("res://assets/fonts/Eurostile/Eurostile.otf") as Font)
	var theme := Theme.new()
	theme.set_font("font", "Label", font_normal)
	theme.set_font_size("font_size", "Label", 64)
	
	var label_red := Label.new()
	label_red.text = "Red"
	label_red.theme = theme
	label_red.add_theme_color_override("font_color", color_red)
	label_red.anchor_right = 0
	label_red.anchor_bottom = 0
	label_red.offset_left = 20
	label_red.offset_top = 20
	add_child(label_red)
	
	var label_silver := Label.new()
	label_silver.text = "Silver"
	label_silver.theme = theme
	label_silver.add_theme_color_override("font_color", color_silver)
	label_silver.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	label_silver.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	label_silver.grow_vertical = Control.GROW_DIRECTION_BEGIN
	label_silver.offset_right = -20
	label_silver.offset_bottom = -20
	label_silver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(label_silver)
