class_name SettingsMenu
extends CanvasLayer
#
#func _ready():
	#var root_vbox := VBoxContainer.new()
	#
	#add_child(root_vbox)
	#
	## manually set anchors/margins to center
	#root_vbox.anchor_left = 0.25
	#root_vbox.anchor_right = 0.75
	#root_vbox.anchor_top = 0.2
	#root_vbox.anchor_bottom = 0.8
	#root_vbox.offset_left = 0
	#root_vbox.offset_right = 0
	#root_vbox.offset_top = 0
	#root_vbox.offset_bottom = 0
	#root_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	#root_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#
	## set spacing between children via theme override
	#var theme := Theme.new()
	#theme.set_constant("separation", "VBoxContainer", 20)
	#root_vbox.theme = theme
	#
	## logo
	#var logo := TextureRect.new()
	#logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	#logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#logo.custom_minimum_size = Vector2(0, 50)
	#root_vbox.add_child(logo)
	#
	## spacer
	#var spacer := Control.new()
	#spacer.custom_minimum_size = Vector2(0, 10)
	#root_vbox.add_child(spacer)
	#
	## font
	#var font_normal := FontVariation.new()
	#font_normal.set_base_font(load("res://assets/fonts/Eurostile/Eurostile_Bold.otf") as Font)
	#font_normal.baseline_offset = 0.2
	#
	## styles
	#var normal_style := StyleBoxFlat.new()
	#normal_style.bg_color = Color("#1a1a1a")
	#var hover_style := StyleBoxFlat.new()
	#hover_style.bg_color = Color("#2f2f2f")
	#var pressed_style := StyleBoxFlat.new()
	#pressed_style.bg_color = Color("#111")
	#
	## buttons
	#for label in ["Continue", "New Game", "Settings", "How to Play", "Quit"]:
		#if label == "Continue":
			#var err := ConfigFile.new().load_encrypted_pass("res://config/savegame.khs", "khet_savegame")
			#if err != OK:
				#continue
		#var button := Button.new()
		#button.text = label
		#button.focus_mode = Control.FOCUS_NONE
		#button.custom_minimum_size = Vector2(350, 100)
		#button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		#button.add_theme_font_override("font", font_normal)
		#button.add_theme_font_size_override("font_size", 42)
		#button.add_theme_stylebox_override("normal", normal_style)
		#button.add_theme_stylebox_override("hover", hover_style)
		#button.add_theme_stylebox_override("pressed", pressed_style)
		#button.connect("mouse_entered", func(): _on_button_mouse_entered(button))
		#button.connect("mouse_exited", func(): _on_button_mouse_exited(button))
		#button.connect("pressed", _on_button_pressed.bind(label))
		#root_vbox.add_child(button)
		#buttons.append(button)
