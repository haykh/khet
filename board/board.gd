class_name Board
extends Node2D

@export_group("Colors", "color_")
@export_color_no_alpha var color_board := Color("#15161a")
@export_color_no_alpha var color_neutral := Color("#1d1e24")
@export_color_no_alpha var color_silver := Color("#a0afc2")
@export_color_no_alpha var color_red := Color("#ff2019")

@export_group("Nodes")
@export var board: BoardShape
@export var board_tilemap : BoardTilemap
@export var markers_container: Node2D
@export var pieces_container: Node2D
@export var lasers_container: Node2D

@export_group("Scenes")
@export var laser_scene: PackedScene
@export var piece_scene: PackedScene

var nx: int = 10
var ny: int = 8
var sx: int = 0
var sy: int = 0
var xmax: int = 0
var xmin: int = Global.INT_MAX
var ymax: int = 0
var ymin: int = Global.INT_MAX
var tile_size: Vector2

# dragging functionality
class DragState:
	var piece: Piece = null
	var original_coord := Vector2i(-1, -1)
	var offset := Vector2.ZERO
	var legal_moves: Array[Vector2i] = []

var drag_state := DragState.new()

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

func get_board_dimensions() -> void:
	for pt in (board as Polygon2D).polygon:
		var pt_g := (board as Polygon2D).to_global(pt)
		if pt_g.x > xmax:
			xmax = pt_g.x as int
		if pt_g.x < xmin:
			xmin = pt_g.x as int
		if pt_g.y > ymax:
			ymax = pt_g.y as int
		if pt_g.y < ymin:
			ymin = pt_g.y as int
	sx = xmax - xmin
	sy = ymax - ymin
	assert(sx * ny == sy * nx, "Board does not respect the aspect ratio %f %f" % [sx, sy])
	tile_size = Vector2((sx as float) / (nx as float), (sy as float) / (ny as float))

func put_laser(pos: Vector2i, orientation: int) -> void:
	var laser := laser_scene.instantiate() as Laser
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
			assert (child_piece.coord != pos, "Location already occupied")
	var piece := piece_scene.instantiate() as Piece
	piece.initialize(self, piece_team, piece_type, pos, orientation, tile_size)
	piece.position = cell_to_pixel(pos)
	piece.rotation = (orientation as float) * PI / 2.0
	piece.connect("sgnl_pickup", _on_piece_pickup)
	piece.connect("sgnl_rotate", _on_piece_rotate)
	piece.connect("sgnl_done_animating", _on_piece_done_animating)
	pieces_container.add_child(piece)

# = = = = = = = = = = = = = = = = 
# built-in functions
func _ready() -> void:
	z_index = 1
	# add tiles
	get_board_dimensions()
	board.initialize(
		markers_container, 
		board_tilemap, 
		Vector2(sx, sy), 
		Vector2(nx, ny), 
		tile_size, 
		color_board, 
		color_neutral, 
		color_silver, 
		color_red,
	)
	
	# add lasers
	put_laser(Vector2i(0, 0), 1)
	
	# add the pieces
	Game.initialize(self, Game.StartingLayout.CLASSIC)

func _input(event: InputEvent) -> void:
	if drag_state.piece:
		if event is InputEventMouseMotion:
			var new_cell_coord := pixel_to_cell(get_global_mouse_position() + drag_state.offset)
			if new_cell_coord != drag_state.piece.coord and new_cell_coord in drag_state.legal_moves:
				drag_state.piece.animate_to_pos(cell_to_pixel(new_cell_coord), new_cell_coord)
		elif event is InputEventMouseButton:
			var mouse_btn_event := event as InputEventMouseButton
			if not mouse_btn_event.pressed and mouse_btn_event.button_index == MOUSE_BUTTON_LEFT:
				_on_piece_drop()

# = = = = = = = = = = = = = = = = 
# signal callbacks
func _on_piece_pickup(piece: Piece) -> void:
	if drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		drag_state.piece = piece
		drag_state.original_coord = piece.coord
		drag_state.legal_moves = Game.legal_moves(self, piece)
		drag_state.offset = piece.position - get_global_mouse_position()
		drag_state.piece.animate_pickup()
		for child in markers_container.get_children():
			if child is MoveMarker:
				var move_marker := child as MoveMarker
				if move_marker.coord in drag_state.legal_moves:
					move_marker.animate_activate()

func _on_piece_drop() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	drag_state.piece.animate_drop()
	drag_state.piece = null
	drag_state.original_coord = Vector2i(-1, -1)
	drag_state.legal_moves = []
	drag_state.offset = Vector2.ZERO
	for child in markers_container.get_children():
		if child is MoveMarker:
			var move_marker := child as MoveMarker
			if move_marker.active:
				move_marker.animate_deactivate()

func _on_piece_rotate(piece: Piece) -> void:
	piece.animate_rotation(Global.Rotation.CLOCKWISE)

func _on_piece_done_animating() -> void:
	for child in lasers_container.get_children():
		if child is Laser:
			var laser := child as Laser
			laser.queue_redraw()
