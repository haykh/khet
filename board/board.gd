class_name Board
extends Node2D

@export_group("Nodes")
@export var board_shape: BoardShape
@export var board_tilemap : BoardTilemap
@export var markers_container: Node2D
@export var pieces_container: Node2D
@export var lasers_container: Node2D

@export_group("Scenes", "scene_")
@export var scene_laser: PackedScene
@export var scene_piece: PackedScene

# signals
signal sgnl_pause()

# geometry
var nx: int
var ny: int
var sx: float = 0.0
var sy: float = 0.0
var xmax: float = -INF
var xmin: float = INF
var ymax: float = -INF
var ymin: float = INF
var tile_size: Vector2

# colors
var color_board: Color
var color_tile_neutral: Color
var color_tile_silver: Color
var color_tile_red: Color
var color_move_marker: Color
# # laser
var color_laser_base: Color
var color_laser_light: Color
var color_laser_highlight: Color
# # pieces
var color_piece_silver: Color
var color_piece_red: Color
var color_piece_surface_reflector: Color
var color_piece_surface_absorber: Color

# functionality
var get_legal_moves: Callable

# dragging
class DragState:
	var piece: Piece = null
	var original_coord := Vector2i(-1, -1)
	var offset := Vector2.ZERO
	var legal_moves: Array[Vector2i] = []

var drag_state := DragState.new()

# = = = = = = = = = = = = = = = = 
# utility functions
func initialize(
	starting_layout: Global.StartingLayout = Global.StartingLayout.NONE, 
	is_continuing: bool = false, 
	savefile_name: String = "") -> void:
	z_index = 1
	# add tiles
	for pt in (board_shape as Polygon2D).polygon:
		var pt_g := (board_shape as Polygon2D).to_global(pt)
		if pt_g.x > xmax:
			xmax = pt_g.x
		if pt_g.x < xmin:
			xmin = pt_g.x
		if pt_g.y > ymax:
			ymax = pt_g.y
		if pt_g.y < ymin:
			ymin = pt_g.y
	sx = xmax - xmin
	sy = ymax - ymin
	assert(abs(sx * (ny as float) - sy * (nx as float)) < 1e-3, "Board does not respect the aspect ratio %f %f" % [sx, sy])
	tile_size = Vector2(sx / (nx as float), sy / (ny as float))
	
	board_shape.initialize(
		markers_container, 
		board_tilemap, 
		Vector2(sx, sy), 
		Vector2i(nx, ny), 
		tile_size, 
		color_board, 
		color_tile_neutral, 
		color_tile_silver, 
		color_tile_red,
		color_move_marker,
	)
	
	# add lasers
	spawn_laser(Vector2i(0, 0), 1)
	
	# add the pieces
	if not is_continuing:
		assert (starting_layout in Global.Layouts, "Starting layout not supported")
		for piece_config in Global.Layouts[starting_layout].piece_configs:
			spawn_piece(Pieces.Team.SILVER, piece_config.type, piece_config.coord, piece_config.orientation)
			spawn_piece(Pieces.Team.RED, piece_config.type, Vector2i(nx - 1, ny - 1) - piece_config.coord, (piece_config.orientation + 2) % 4)
	else:
		var savefile_khs = ConfigFile.new()
		var err := savefile_khs.load_encrypted_pass(savefile_name, "khet_savegame")
		assert (err == OK, "Cannot open %s" % savefile_name)
		var num_pieces: int = savefile_khs.get_value("GAME", "NUM_PIECES")
		for pi in range(1, num_pieces + 1):
			var typ: Pieces.Type = savefile_khs.get_value("PIECE_%d" % pi, "TYPE")
			var tm: Pieces.Team = savefile_khs.get_value("PIECE_%d" % pi, "TEAM")
			var crd: Vector2i = savefile_khs.get_value("PIECE_%d" % pi, "COORD")
			var ori: int = savefile_khs.get_value("PIECE_%d" % pi, "ORIENTATION")
			spawn_piece(tm, typ, crd, ori)

func save_game(filename: String) -> void:
	var savefile_khs = ConfigFile.new()
	var pi := 1
	for child in pieces_container.get_children():
		if child is not Piece:
			continue
		var piece := child as Piece
		savefile_khs.set_value("PIECE_%d" % pi, "TYPE", piece.type)
		savefile_khs.set_value("PIECE_%d" % pi, "TEAM", piece.team)
		savefile_khs.set_value("PIECE_%d" % pi, "COORD", piece.coord)
		savefile_khs.set_value("PIECE_%d" % pi, "ORIENTATION", piece.orientation)
		pi += 1
	savefile_khs.set_value("GAME", "NUM_PIECES", pi - 1)
	savefile_khs.save_encrypted_pass(filename, "khet_savegame")

func board_to_pixel(board_coord: Vector2, clamp_to_board: bool = true) -> Vector2:
	var result := (tile_size * (board_coord as Vector2) + Vector2(xmin, ymin))
	if clamp_to_board:
		return result.clamp(Vector2(xmin, ymin), Vector2(xmax, ymax))
	return result

func cell_to_pixel(
	cell_coord: Vector2i,
	shift: Vector2 = Vector2(0.5, 0.5),
	clamp_to_board: bool = true,
) -> Vector2:
	return board_to_pixel(cell_coord as Vector2 + shift, clamp_to_board)

func pixel_to_cell(pixel_pos: Vector2) -> Vector2i:
	return ((pixel_pos - Vector2(xmin, ymin)) / tile_size as Vector2i).clamp(Vector2i.ZERO, Vector2i(nx - 1, ny - 1))

func spawn_laser(pos: Vector2i, orientation: int) -> void:
	var laser := scene_laser.instantiate() as Laser
	laser.color_base = color_laser_base
	laser.color_light = color_laser_light
	laser.color_highlight = color_laser_highlight
	laser.initialize(self, pos, orientation)
	var pixel_pos := Vector2.ZERO
	assert(orientation >= 0 and orientation <= 3, "Invalid orientation for laser")
	pixel_pos = cell_to_pixel(pos, Vector2(0.5, 0.5) - 0.75 * Global.Direction.vec2(orientation), false)
	laser.position = pixel_pos
	laser.rotation = (orientation as float) * PI / 2.0
	lasers_container.add_child(laser)

func spawn_piece(piece_team: Pieces.Team, piece_type: Pieces.Type, pos: Vector2i, orientation: int) -> void:
	for child in pieces_container.get_children():
		if child is Piece:
			var child_piece := child as Piece
			assert ((child_piece.coord != pos) or 
					(child_piece.type == Pieces.Type.OBELISK and piece_type == Pieces.Type.OBELISK and child_piece.team == piece_team), 
					"Location already occupied")
	var piece := scene_piece.instantiate() as Piece
	piece.color_red = color_piece_red
	piece.color_silver = color_piece_silver
	piece.color_surface_reflector = color_piece_surface_reflector
	piece.color_surface_absorber = color_piece_surface_absorber
	piece.initialize(piece_team, piece_type, pos, orientation, tile_size)
	piece.position = cell_to_pixel(pos)
	piece.rotation = (orientation as float) * PI / 2.0
	piece.connect("sgnl_hovered", _on_piece_hover)
	piece.connect("sgnl_pickup", _on_piece_pickup)
	piece.connect("sgnl_rotate", func(pc: Piece, rot: Global.Rotation): pc.animate_rotation(rot))
	piece.connect("sgnl_done_animating", _on_piece_done_animating)
	pieces_container.add_child(piece)

# = = = = = = = = = = = = = = = = 
# built-in functions
func _input(event: InputEvent) -> void:
	if drag_state.piece != null:
		if event is InputEventMouseMotion:
			var new_cell_coord := pixel_to_cell(get_global_mouse_position() + drag_state.offset)
			if new_cell_coord != drag_state.piece.coord and new_cell_coord in drag_state.legal_moves:
				drag_state.piece.animate_to_pos(cell_to_pixel(new_cell_coord), new_cell_coord)
		elif event is InputEventMouseButton:
			if event.is_action_released("pickup") or event.is_action_released("pickup_top_figure"):
				_on_piece_drop()
	elif event.is_action_pressed("pause"):
		sgnl_pause.emit()

# = = = = = = = = = = = = = = = = 
# signal callbacks
func _on_piece_hover(_piece: Piece, is_hover: bool) -> void:
	if drag_state.piece == null:
		if is_hover:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_piece_pickup(piece: Piece, is_stacked_obelisk: bool) -> void:
	if drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		if is_stacked_obelisk:
			piece.set_type(Pieces.Type.OBELISK)
			spawn_piece(piece.team, Pieces.Type.OBELISK, piece.coord, 0)
		drag_state.piece = piece
		drag_state.original_coord = piece.coord
		drag_state.legal_moves = get_legal_moves.call(self, piece)
		drag_state.offset = piece.position - get_global_mouse_position()
		drag_state.piece.animate_pickup()
		for child in markers_container.get_children():
			if child is not MoveMarker:
				continue
			var move_marker := child as MoveMarker
			if move_marker.coord in drag_state.legal_moves:
				move_marker.animate_activate()

func _on_piece_drop() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	drag_state.piece.animate_drop()
	# check whether djed is swapping places or obelisk is stacking
	for child in pieces_container.get_children():
		if child is not Piece:
			continue
		var piece := child as Piece
		if piece != drag_state.piece and piece.coord == drag_state.piece.coord:
			if drag_state.piece.type == Pieces.Type.DJED:
				assert (piece.type in [Pieces.Type.PYRAMID, Pieces.Type.OBELISK], "Illegal move called")
				piece.animate_to_pos(cell_to_pixel(drag_state.original_coord), drag_state.original_coord)
				break
			elif drag_state.piece.type == Pieces.Type.OBELISK:
				assert (piece.team == drag_state.piece.team, "Illegal move called")
				drag_state.piece.set_type(Pieces.Type.STACKED_OBELISK)
				pieces_container.remove_child(child)
				child.queue_free()
				break
			break
	drag_state.piece = null
	drag_state.original_coord = Vector2i(-1, -1)
	drag_state.legal_moves = []
	drag_state.offset = Vector2.ZERO
	for child in markers_container.get_children():
		if child is not MoveMarker:
			continue
		var move_marker := child as MoveMarker
		if move_marker.active:
			move_marker.animate_deactivate()

func _on_piece_done_animating() -> void:
	for child in lasers_container.get_children():
		if child is Laser:
			var laser := child as Laser
			laser.queue_redraw()
