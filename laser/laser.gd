class_name Laser
extends Node2D

@export_group("Colors", "color_")
@export_color_no_alpha var color_base := Color("#452a68")
@export_color_no_alpha var color_laser := Color("#cc0013")

@export_group("Nodes")
@export var beam: Line2D

@export_group("Laser Beam", "beam_")
@export var beam_max_steps := 100
@export var beam_max_length := 5000.0

# internal states
var active := false
var coord := Vector2i.ZERO
var orientation := 0

# external refs
var board_ref: Board = null

# = = = = = = = = = = = = = = = = 
# utility functions
func initialize(brd: Board, crd: Vector2i, ori: int) -> void:
	board_ref = brd
	active = false
	coord = crd
	orientation = ori
	beam.width = 4
	beam.default_color = color_laser
	beam.clear_points()

func _input(event: InputEvent):
	if event.is_action_pressed("fire"):
		active = true
		queue_redraw()
	elif event.is_action_released("fire"):
		active = false
		queue_redraw()

func _draw() -> void:
	beam.clear_points()
	if active:
		var origin := board_ref.board_to_pixel((coord as Vector2) + Vector2(0.5, 0.5) - 0.45 * Global.Direction.vec2(orientation))
		var dir := Global.Direction.vec2(orientation)
		
		var points: Array[Vector2] = [origin]
		
		for _i in beam_max_steps:
			var segments: Array[Global.SegmentWithCallback]
			for i in range(board_ref.board.polygon.size()):
				var pt1 := board_ref.board.polygon[i]
				var pt2 := board_ref.board.polygon[(i + 1) % board_ref.board.polygon.size()]
				segments.append(Global.SegmentWithCallback.new(
					board_ref.board.to_global(pt1),
					board_ref.board.to_global(pt2),
					func() -> bool:
						return false
				))
			for child in board_ref.pieces_container.get_children():
				if child is Piece:
					var piece := (child as Piece)
					var piece_segments := piece.surfaces.get_children()
					var num_piece_segments := piece_segments.size()
					assert (num_piece_segments == Pieces.Shapes[piece.type].surfaces.size(), "# of piece segments does not match the # of expected surfaces")
					for s in num_piece_segments:
						var sgmt_line := piece_segments[s] as Line2D
						var sgmt_type := Pieces.Shapes[piece.type].surfaces[s]
						segments.append(Global.SegmentWithCallback.new(
							sgmt_line.to_global(sgmt_line.points[0]),
							sgmt_line.to_global(sgmt_line.points[1]),
							func() -> bool:
								return sgmt_type == Pieces.SurfaceType.REFLECTOR
						))
			var next_beam := Global.SegmentWithCallback.new(origin, origin + dir * beam_max_length)
			var closest_hit := Global.find_closest_intersection(next_beam, segments)
			if closest_hit.intersection.hit:
				if (closest_hit.segment.callback as Callable).call():
					points.append(closest_hit.intersection.position - dir * 5.0)
					dir = Global.reflect(dir, closest_hit.segment.normal())
					origin = closest_hit.intersection.position + dir * 5.0
					points.append(origin)
				else:
					points.append(closest_hit.intersection.position)
					break
		for p in points:
			beam.add_point(beam.to_local(p))
