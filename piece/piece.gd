class_name Piece
extends Area2D

@export_group("Colors", "color_")
@export_color_no_alpha var color_base := Color("#5e5863")
@export_color_no_alpha var color_surface_reflector := Color("#55a7e5")
@export_color_no_alpha var color_surface_absorber := Color("#121212")

@export_group("Nodes")
@export var shape_polygon: Polygon2D
@export var outline_segments: Node2D
@export var shape_ghost: CollisionShape2D

signal sgnl_pickup(piece: Piece)
signal sgnl_rotate(piece: Piece)
signal sgnl_hovered(piece: Piece)
signal sgnl_unhovered(piece: Piece)
signal sgnl_done_animating()

# constants
var type := Global.PieceType.NONE
var tile_size := Vector2.ZERO

# internal states
var state := Global.PieceState.NONE
var coord := Vector2i.ZERO
var orientation := 0
var active_tween: Tween = null

# external refs
var board_ref: Board = null

# = = = = = = = = = = = = = = = = 
# utility functions
func initialize(brd: Board, crd: Vector2i, ori: int, typ: Global.PieceType, ts: Vector2) -> void:
	board_ref = brd
	
	state = Global.PieceState.IDLE
	coord = crd
	orientation = ori
	type = typ
	tile_size = ts
	
	# shape & outline
	var shape := PackedVector2Array()
	assert(type in Global.Pieces, "Shape for the given piece type not defined")
	var npoints := Global.Pieces[type].shape.size()
	assert(npoints == Global.Pieces[type].surfaces.size(), "# of surfaces does not match the # of segments")
	for p in npoints:
		var pt1 := Global.Pieces[type].shape[p]
		var pt2 := Global.Pieces[type].shape[(p + 1) % npoints]
		var surface_type := Global.Pieces[type].surfaces[p]
		shape.append(pt1 * tile_size)
		
		var line := Line2D.new()
		line.width = 2
		line.points = [pt1 * tile_size, pt2 * tile_size]
		match surface_type:
			Global.SurfaceType.ABSORBER:
				line.default_color = color_surface_absorber
				line.z_index = 10
			Global.SurfaceType.REFLECTOR:
				line.default_color = color_surface_reflector
				line.z_index = 11
		outline_segments.add_child(line)
	shape_polygon.polygon = shape
	shape_polygon.color = color_base
	
	# hover detection with the ghost
	(shape_ghost.shape as RectangleShape2D).set_size(ts)

# = = = = = = = = = = = = = = = = 
# tweens
func animate_to_pos(pixel_pos: Vector2, board_crd: Vector2i) -> void:
	var new_tween := create_tween()
	new_tween.tween_property(self, "position", pixel_pos, 0.1)
	new_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	new_tween.finished.connect(
		func():
			self.coord = board_crd
			sgnl_done_animating.emit()
	)
	if active_tween != null and active_tween.is_running():
		active_tween.stop()
		active_tween = new_tween
	else:
		active_tween = new_tween

func animate_rotation(rot: Global.Rotation) -> void:
	var new_tween := create_tween()
	var new_orientation := orientation + (rot as int)
	new_tween.tween_property(self, "rotation", (new_orientation as float) * PI / 2.0, 0.1)
	new_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	new_tween.finished.connect(
		func():
			self.orientation = new_orientation
			sgnl_done_animating.emit()
	)
	if active_tween != null and active_tween.is_running():
		active_tween.tween_subtween(new_tween)
	else:
		active_tween = new_tween

# = = = = = = = = = = = = = = = = 
# built-in functions
func _ready() -> void:
	connect("input_event", Callable(self, "_on_input_event"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

# = = = = = = = = = = = = = = = = 
# signal emitters
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if state == Global.PieceState.IDLE and mouse_event.pressed:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			sgnl_pickup.emit(self)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			sgnl_rotate.emit(self)
			get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	if board_ref.drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		shape_polygon.modulate = Color(2, 2, 2)
		sgnl_hovered.emit(self)

func _on_mouse_exited() -> void:
	if board_ref.drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		shape_polygon.modulate = Color.WHITE
		sgnl_unhovered.emit(self)
