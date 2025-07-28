class_name Game
extends Node2D

@export_group("Scenes", "scene_")
@export var scene_board: PackedScene

@export_group("Colors")
@export_subgroup("Board", "color_")
@export_color_no_alpha var color_board := Color("#15161a")
@export_color_no_alpha var color_tile_neutral := Color("#1d1e24")
@export_color_no_alpha var color_tile_silver := Color("#a0afc2")
@export_color_no_alpha var color_tile_red := Color("#ff2019")
@export var color_move_marker := Color("ffffff83")
@export_subgroup("Laser", "color_laser_")
@export_color_no_alpha var color_laser_base := Color("#303bbf")
@export_color_no_alpha var color_laser_light := Color("#e00000")
@export_color_no_alpha var color_laser_highlight := Color("#ffdbd5")
@export_subgroup("Pieces", "color_piece_")
@export_color_no_alpha var color_piece_silver := Color("#8f8f8f")
@export_color_no_alpha var color_piece_red := Color("#d42f2c")
@export var color_piece_surface_reflector := Color("#55a7e5")
@export var color_piece_surface_absorber := Color("#ffffff00")

# = = = = = = = = = = = = = = = = 
# built-in functions
func _ready() -> void:
	new_menu()

# = = = = = = = = = = = = = = = = 
# main screens
func start_game(is_continuing := false) -> void:
	var board: Board
	if not is_continuing:
		var settings_cfg = ConfigFile.new()
		var err := settings_cfg.load("res://config/settings.cfg")
		assert (err == OK, "unable to open settings.cfg: %s" % str(err))
		var starting_layout: Global.StartingLayout = settings_cfg.get_value("NEW_GAME", "STARTING_LAYOUT")
		board = initialize_board(starting_layout)
	else:
		board = initialize_board(Global.StartingLayout.NONE, true, "res://config/savegame.khs")
	var hud := HUD.new()
	hud.initialize(color_piece_red, color_piece_silver)
	add_child(hud)
	board.connect("sgnl_pause", func(): 
		board.save_game("res://config/savegame.khs")
		remove_child(board)
		remove_child(hud)
		board.queue_free()
		hud.queue_free()
		new_menu()
	)

func new_menu() -> void:
	var menu := GameMenu.new()
	add_child(menu)
	menu.connect("sgnl_newgame", func():
		remove_child(menu)
		menu.queue_free()
		start_game(false)
	)
	menu.connect("sgnl_continue", func():
		remove_child(menu)
		menu.queue_free()
		start_game(true)
	)

# = = = = = = = = = = = = = = = = 
# utility functions
func initialize_board(starting_layout := Global.StartingLayout.NONE, is_continuing := false, savefile_name := "") -> Board:
	var board := scene_board.instantiate() as Board
	board.nx = 10
	board.ny = 8
	
	# set colors
	board.color_board = color_board
	board.color_tile_neutral = color_tile_neutral
	board.color_tile_silver = color_tile_silver
	board.color_tile_red = color_tile_red
	board.color_move_marker = color_move_marker
	board.color_laser_base = color_laser_base
	board.color_laser_light = color_laser_light
	board.color_laser_highlight = color_laser_highlight
	board.color_piece_silver = color_piece_silver
	board.color_piece_red = color_piece_red
	board.color_piece_surface_reflector = color_piece_surface_reflector
	board.color_piece_surface_absorber = color_piece_surface_absorber
	
	board.initialize(starting_layout, is_continuing, savefile_name)
	board.get_legal_moves = legal_moves
	add_child(board)
	return board

func legal_moves(board: Board, piece: Piece) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	# add all cells within a distance of 1 as legal moves
	for i in board.nx:
		for j in board.ny:
			if absi(i - piece.coord.x) <= 1 and absi(j - piece.coord.y) <= 1:
				moves.append(Vector2i(i, j))
	# remove all occupied cells as legal moves ...
	for child in board.pieces_container.get_children():
		if child is Piece:
			var other_piece := child as Piece
			if other_piece != piece:
				# ... unless stacking two obelisks of the same color
				if piece.type == Pieces.Type.OBELISK and other_piece.type == Pieces.Type.OBELISK and piece.team == other_piece.team:
					continue
				# ... or unless swapping a djed with a pyramid or an obelisk
				elif piece.type == Pieces.Type.DJED and other_piece.type in [Pieces.Type.PYRAMID, Pieces.Type.OBELISK]:
					continue
				else:
					moves.erase(other_piece.coord)
	# remove tiles of the opposing teams color (prohibited zones)
	if piece.team == Pieces.Team.RED:
		moves.erase(Vector2i(1, 0))
		moves.erase(Vector2i(1, board.ny - 1))
		for j in board.ny:
			moves.erase(Vector2i(board.nx - 1, j))
	elif piece.team == Pieces.Team.SILVER:
		moves.erase(Vector2i(board.nx - 2, 0))
		moves.erase(Vector2i(board.nx - 2, board.ny - 1))
		for j in board.ny:
			moves.erase(Vector2i(0, j))
	return moves
