class_name Piece
extends Area2D

@export_group("Colors", "color_")
@export_color_no_alpha var color_silver := Color("#8f8f8f")
@export_color_no_alpha var color_red := Color("#d42f2c")
@export var color_surface_reflector := Color("#55a7e5")
@export var color_surface_absorber := Color("#ffffff00")

@export_group("Nodes")
@export var polygons: Node2D
@export var surfaces: Node2D
@export var shape_ghost: CollisionShape2D

signal sgnl_pickup(piece: Piece)
signal sgnl_rotate(piece: Piece)
signal sgnl_hovered(piece: Piece)
signal sgnl_unhovered(piece: Piece)
signal sgnl_done_animating()

# color dictionaries

# constants
var type := Pieces.Type.NONE
var team := Pieces.Team.NONE

# internal states
var state := Pieces.State.NONE
var coord := Vector2i.ZERO
var orientation := 0

# external refs
var board_ref: Board = null

# = = = = = = = = = = = = = = = = 
# utility functions
func initialize(brd: Board, typ: Pieces.Type, tm: Pieces.Team, crd: Vector2i, ori: int, ts: Vector2) -> void:
	assert (typ != Pieces.Type.NONE, "Piece type is NONE")
	assert (tm != Pieces.Team.NONE, "Piece team is NONE")
	board_ref = brd
	type = typ
	team = tm
	
	z_index = 10
	state = Pieces.State.IDLE
	coord = crd
	orientation = ori
	
	var team_colors: Dictionary[Pieces.Team, Color] = {
		Pieces.Team.SILVER: color_silver,
		Pieces.Team.RED: color_red,
	}
	var surftype_colors: Dictionary[Pieces.SurfaceType, Color] = {
		Pieces.SurfaceType.REFLECTOR: color_surface_reflector,
		Pieces.SurfaceType.ABSORBER: color_surface_absorber,
	}
	
	assert(type in Pieces.Shapes, "Shape for the given piece type not defined")
	
	# piece shape & interaction surfaces
	Pieces.Shapes[type].add_polygons(polygons, ts, team_colors[team])
	Pieces.Shapes[type].add_surfaces(surfaces, ts, surftype_colors)
	
	# hover detection with the ghost
	(shape_ghost.shape as RectangleShape2D).set_size(ts)

# = = = = = = = = = = = = = = = = 
# tweens
func animate_pickup() -> void:
	z_index = 11
	var new_tween := create_tween()
	new_tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.1)
	new_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	new_tween.finished.connect(
		func():
			state = Pieces.State.PICKED
			sgnl_done_animating.emit()
	)

func animate_drop() -> void:
	z_index = 10
	var new_tween := create_tween()
	new_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	new_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	new_tween.finished.connect(
		func():
			state = Pieces.State.IDLE
			sgnl_done_animating.emit()
	)

func animate_to_pos(pixel_pos: Vector2, board_crd: Vector2i) -> void:
	var new_tween := create_tween()
	new_tween.tween_property(self, "position", pixel_pos, 0.1)
	new_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	new_tween.finished.connect(
		func():
			self.coord = board_crd
			sgnl_done_animating.emit()
	)

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
	if state == Pieces.State.IDLE and mouse_event.pressed:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			sgnl_pickup.emit(self)
			get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			sgnl_rotate.emit(self)
			get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	if board_ref.drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		#shape_polygon.modulate = Color(1.2, 1.2, 1.2)
		sgnl_hovered.emit(self)

func _on_mouse_exited() -> void:
	if board_ref.drag_state.piece == null:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		#shape_polygon.modulate = Color.WHITE
		sgnl_unhovered.emit(self)
