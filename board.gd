class_name Board
extends Node2D

@export_group("Nodes")
@export var board: Polygon2D
@export var pieces_container: Node2D
@export var lasers_container: Node2D

@export_group("Scenes")
@export var laser_scene: PackedScene
@export var piece_scene: PackedScene

var nx: int = 10
var ny: int = 10
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
	var offset := Vector2.ZERO

var drag_state := DragState.new()

func board_to_pixel(board_coord: Vector2i) -> Vector2:
	return (tile_size * ((board_coord as Vector2) + Vector2.ONE * 0.5) + Vector2(xmin, ymin)).clamp(Vector2(xmin, ymin), Vector2(xmax, ymax))

func pixel_to_board(pixel_pos: Vector2) -> Vector2i:
	return ((pixel_pos - Vector2(xmin, ymin)) / tile_size as Vector2i).clamp(Vector2i.ZERO, Vector2i(nx - 1, ny - 1))

func get_board_dimensions() -> void:
	for pt in board.polygon:
		if pt.x > xmax:
			xmax = pt.x as int
		if pt.x < xmin:
			xmin = pt.x as int
		if pt.y > ymax:
			ymax = pt.y as int
		if pt.y < ymin:
			ymin = pt.y as int
	sx = xmax - xmin
	sy = ymax - ymin
	assert(sx * ny != sy * nx, "Board does not respect the aspect ratio")
	tile_size = Vector2((sx as float) / (nx as float), (sy as float) / (ny as float))

func put_laser(pos: Vector2i, orientation: int) -> void:
	var laser := laser_scene.instantiate() as Laser
	lasers_container.add_child(laser)

func spawn_piece(pos: Vector2i, piece_type: Global.PieceType, orientation: int) -> void:
	var piece := piece_scene.instantiate() as Piece
	piece.initialize(self, pos, orientation, piece_type, tile_size)
	piece.position = board_to_pixel(pos)
	piece.connect("sgnl_pickup", _on_piece_pickup)
	piece.connect("sgnl_rotate", _on_piece_rotate)
	pieces_container.add_child(piece)

# = = = = = = = = = = = = = = = = 
# built-in functions
func _ready() -> void:
	get_board_dimensions()
	spawn_piece(Vector2i(0, 0), Global.PieceType.PYRAMID, 0)
	spawn_piece(Vector2i(4, 6), Global.PieceType.DJED, 0)
	spawn_piece(Vector2i(8, 2), Global.PieceType.OBELISK, 0)

func _input(event: InputEvent) -> void:
	if drag_state.piece:
		if event is InputEventMouseMotion:
			var new_board_coord := pixel_to_board(get_global_mouse_position() + drag_state.offset)
			if new_board_coord != drag_state.piece.coord:
				var occupied := false
				for child in pieces_container.get_children():
					if child is Piece and (child as Piece).coord == new_board_coord:
						occupied = true
						break
				if not occupied:
					drag_state.piece.animate_to_pos(board_to_pixel(new_board_coord), new_board_coord)
		elif event is InputEventMouseButton:
			var mouse_btn_event := event as InputEventMouseButton
			if not mouse_btn_event.pressed and mouse_btn_event.button_index == MOUSE_BUTTON_LEFT:
				drag_state.piece = null
				drag_state.offset = Vector2.ZERO
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
				

# = = = = = = = = = = = = = = = = 
# signal callbacks
func _on_piece_pickup(piece: Piece) -> void:
	if drag_state.piece == null:
		drag_state.piece = piece
		drag_state.piece.state = Global.PieceState.PICKED
		drag_state.offset = piece.position - get_global_mouse_position()
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)

func _on_piece_rotate(piece: Piece) -> void:
	piece.animate_rotation(Global.Rotation.CLOCKWISE)
