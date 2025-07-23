class_name Laser
extends Node2D

@export_group("Colors", "color_")
@export_color_no_alpha var color_base := Color("#452a68")
@export_color_no_alpha var color_laser := Color("#cc0013")

@export_group("Nodes")
@export var beam: Line2D

# internal states
var coord := Vector2i.ZERO
var orientation := 0

# external refs
var board_ref: Board = null

#class Segment:
	#var pt1: Vector2
	#var pt2: Vector2
	#func _init(p1: Vector2, p2: Vector2):
		#self.pt1 = p1
		#self.pt2 = p2
#
#class Intersection:
	#var hit: bool
	#var position: Vector2
	#var segment: Segment
	#func _init(ht: bool, pos: Vector2, sgmt: Segment):
		#self.hit = ht
		#self.position = pos
		#self.segment = sgmt
#
#var ZERO_INTERSECT := Intersection.new(false, Vector2.ZERO, Segment.new(Vector2.ZERO, Vector2.ZERO))
#
#func segment_intersect(p1: Vector2, p2: Vector2, q1: Vector2, q2: Vector2) -> Intersection:
	#var result: Variant = Geometry2D.segment_intersects_segment(p1, p2, q1, q2)
	#if result != null:
		#return Intersection.new(true, result as Vector2, Segment.new(q1, q2))
	#return ZERO_INTERSECT
#
#func cast_beam(origin: Vector2, dir: Vector2) -> Intersection:
	#var closest_hit := ZERO_INTERSECT
	#var closest_hit_distance := INF
	#for child in targets_container.get_children():
		#if child is Piece:
			#var piece := child as Piece
			#for segment in piece.outline_segments.get_children():
				#var pt1: Vector2 = (segment as Line2D).points[0]
				#var pt2: Vector2 = (segment as Line2D).points[1]
				#var hit := segment_intersect(origin, origin + dir * Global.BEAM_MAX_LENGTH, pt1, pt2)
				#if not hit.hit:
					#continue
				#var hit_distance := origin.distance_to(hit.position)
				#if hit_distance < closest_hit_distance:
					#closest_hit = hit
					#closest_hit_distance = hit_distance
	#return closest_hit
#
#func reflect(incident: Vector2, normal: Vector2) -> Vector2:
	#return incident - 2.0 * incident.dot(normal) * normal
#
#func _input(event: InputEvent):
	#if event.is_action_pressed("fire"):
		#var points: Array[Vector2] = []
		#var origin := global_position
		#var direction := Vector2.RIGHT.rotated( rotation)
		#points.append(origin)
		#
		#for _i in Global.BEAM_MAX_BOUNCES:
			#var closest_hit := cast_beam(origin, direction)
			#if not closest_hit.hit:
				#points.append(origin + direction * Global.BEAM_MAX_LENGTH)
				#break
			#points.append(closest_hit.position)
			#var normal = (closest_hit.segment.pt1 - closest_hit.segment.pt2).normalized().orthogonal().normalized()
			#if normal.dot(direction) > 0.0:
				#normal = -normal
			#direction = reflect(direction, normal)
			#
		#beam.clear_points()
		#for p in points:
			#beam.add_point(beam.to_local(p))
	#
	#elif event.is_action_released("fire"):
		#beam.clear_points()
