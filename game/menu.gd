class_name GameMenu
extends CanvasLayer

var buttons: Array[Button]

signal sgnl_continue()
signal sgnl_newgame()

func _ready():
	# fonts
	var font_normal := FontVariation.new()
	font_normal.set_base_font(load("res://assets/fonts/Eurostile/Eurostile_Extd.otf") as Font)
	var font_bold := FontVariation.new()
	font_bold.set_base_font(load("res://assets/fonts/Eurostile/Eurostile_Bold.otf") as Font)
	font_bold.baseline_offset = 0.2
	
	var root_vbox := VBoxContainer.new()
	var root_vbox_theme := Theme.new()
	root_vbox_theme.set_constant("separation", "VBoxContainer", 10)
	root_vbox.theme = root_vbox_theme
	
	root_vbox.anchor_left = 0.25
	root_vbox.anchor_right = 0.75
	root_vbox.anchor_top = 0.2
	root_vbox.anchor_bottom = 0.8
	root_vbox.offset_left = 0
	root_vbox.offset_right = 0
	root_vbox.offset_top = 0
	root_vbox.offset_bottom = 0
	root_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	root_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	add_child(root_vbox)
	
	var logo_vbox = VBoxContainer.new()
	logo_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var logo_vbox_theme := Theme.new()
	logo_vbox_theme.set_constant("separation", "VBoxContainer", -20)
	logo_vbox.theme = logo_vbox_theme
	root_vbox.add_child(logo_vbox)
	
	# logo
	var logo := Label.new()
	var sublogo := Label.new()
	logo.text = "Khet"
	sublogo.text = "strategy at the speed of light"
	
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	logo.add_theme_font_override("font", font_normal)
	logo.add_theme_font_size_override("font_size", 106)
	sublogo.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	sublogo.add_theme_font_override("font", font_normal)
	sublogo.add_theme_font_size_override("font_size", 18)
	
	logo_vbox.add_child(logo)
	logo_vbox.add_child(sublogo)
	
	# spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	root_vbox.add_child(spacer)
	
	# styles
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#1a1a1a")
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color("#2f2f2f")
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color("#111")
	
	# buttons
	for label in ["Continue", "New Game", "Settings", "How to Play", "Quit"]:
		if label == "Continue":
			var err := ConfigFile.new().load_encrypted_pass("res://config/savegame.khs", "khet_savegame")
			if err != OK:
				continue
		var button := Button.new()
		button.text = label
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(350, 100)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_override("font", font_bold)
		button.add_theme_font_size_override("font_size", 42)
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)
		button.connect("mouse_entered", func(): _on_button_mouse_entered(button))
		button.connect("mouse_exited", func(): _on_button_mouse_exited(button))
		button.connect("pressed", _on_button_pressed.bind(label))
		root_vbox.add_child(button)
		buttons.append(button)
	var image := TextureRect.new()
	image.texture = load("res://assets/figures/caution.png")
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	
	image.anchor_left = 1
	image.anchor_top = 1
	image.anchor_right = 1
	image.anchor_bottom = 1
	
	var width := 300
	var padx := 40
	var pady := 20
	image.offset_left = -(width + padx)
	image.offset_right = -padx
	image.offset_top = -(image.texture.get_height() * width / image.texture.get_width() + pady)
	
	add_child(image)

func _on_button_mouse_entered(_btn: Button) -> void:
	print("entered")

func _on_button_mouse_exited(_btn: Button) -> void:
	print("exited")

func _on_button_pressed(label: String) -> void:
	match label:
		"Continue":
			sgnl_continue.emit()
		"New Game":
			sgnl_newgame.emit()
		"Settings":
			print("Opening settings...")
		"How to Play":
			print("Showing tutorial...")
		"Quit":
			get_tree().quit()
