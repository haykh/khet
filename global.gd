class_name Global

const INT_MAX := 9223372036854775807

class Direction:
	static var RIGHT := 0
	static var DOWN := 1
	static var LEFT := 2
	static var UP := 3
	static func vec2i(dir: int) -> Vector2i:
		match dir:
			RIGHT: return Vector2i(1, 0)
			DOWN: return Vector2i(0, 1)
			LEFT: return Vector2i(-1, 0)
			UP: return Vector2i(0, -1)
		return Vector2i.ZERO
	static func vec2(dir: int) -> Vector2:
		match dir:
			RIGHT: return Vector2(1, 0)
			DOWN: return Vector2(0, 1)
			LEFT: return Vector2(-1, 0)
			UP: return Vector2(0, -1)
		return Vector2.ZERO

enum Rotation {
	CLOCKWISE = 1,
	COUNTERCLOCKWISE = -1
}

# = = = = = = = = = = = = = = = = 
# Pieces
enum PieceType {
	NONE,
	PYRAMID,
	DJED,
	OBELISK,
	# more to be added
}

enum PieceState {
	NONE,
	IDLE,
	ANIMATING,
	PICKED,
}

enum SurfaceType {
	NONE,
	REFLECTOR,
	ABSORBER
}

const PIECE_PADDING = 0.1
const PIECE_SIZE = 1.0 - PIECE_PADDING * 2.0
const PIECE_HALFSIZE = PIECE_SIZE * 0.5

class PieceShape:
	var shape: Array[Vector2]
	var surfaces: Array[SurfaceType]
	func _init(shp: Array[Vector2], srf: Array[SurfaceType]) -> void:
		self.shape = shp
		self.surfaces = srf

static var Pieces: Dictionary[PieceType, PieceShape] = {
	PieceType.PYRAMID: PieceShape.new([
		Vector2(-PIECE_HALFSIZE, -PIECE_HALFSIZE),
		Vector2(-PIECE_HALFSIZE, PIECE_HALFSIZE),
		Vector2(PIECE_HALFSIZE, -PIECE_HALFSIZE)
	], [
		SurfaceType.ABSORBER,
		SurfaceType.REFLECTOR,
		SurfaceType.ABSORBER
	]),
	PieceType.DJED: PieceShape.new([
		Vector2(-PIECE_HALFSIZE, PIECE_HALFSIZE),
		Vector2(PIECE_HALFSIZE, -PIECE_HALFSIZE)
	], [
		SurfaceType.REFLECTOR,
		SurfaceType.REFLECTOR,
	]),
	PieceType.OBELISK: PieceShape.new([
		Vector2(-PIECE_HALFSIZE, -PIECE_HALFSIZE),
		Vector2(-PIECE_HALFSIZE, PIECE_HALFSIZE),
		Vector2(PIECE_HALFSIZE, PIECE_HALFSIZE),
		Vector2(PIECE_HALFSIZE, -PIECE_HALFSIZE)
	], [
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
	])
}

# = = = = = = = = = = = = = = = = 
# Collisions

## Helper class for holding a result of an intersection of a beam with a segment
class Intersection:
	var hit: bool
	var position: Vector2
	func _init(ht: bool, pos := Vector2.ZERO) -> void:
		self.hit = ht
		self.position = pos

## Helper class for holding a result of searching for the closest intersection
class ClosestIntersection:
	var intersection: Intersection
	var segment: Segment
	func _init(inter := Intersection.new(false), sgmt: Segment = null) -> void:
		self.intersection = inter
		self.segment = sgmt

## Segment class holding a pair of two points.
##
## Together with [member Segment.start] and [member Segment.end] holds an optional callback [member Segment.callback], 
## which is used when intersection happens with this [param Segment].
class Segment:
	var start: Vector2
	var end: Vector2
	var callback: Variant
	func _init(st: Vector2, en: Vector2, cbck: Variant = null) -> void:
		self.start = st
		self.end = en
		self.callback = cbck
	
	func normal() -> Vector2:
		return (self.start - self.end).normalized().orthogonal().normalized()

## Returns an [code]Intersection[/code] object to indicate whether two segments intsersect.
static func segments_intersect(segmentA: Segment, segmentB: Segment) -> Intersection:
	var result: Variant = Geometry2D.segment_intersects_segment(segmentA.start, segmentA.end, segmentB.start, segmentB.end)
	if result != null:
		return Intersection.new(true, result as Vector2)
	return Intersection.new(false)

## Finds the closest intersection by a given [param Segment] with a collection of other [param Segment] objects.
##
## Distance is measured from the [member Segment.start] of the [param segment].
static func find_closest_intersection(segment: Segment, collection_of_segments: Array[Segment]) -> ClosestIntersection:
	var closest_hit := Intersection.new(false)
	var closest_hit_segment: Segment = null
	var closest_hit_distance := INF
	for other_segment in collection_of_segments:
		var hit := segments_intersect(segment, other_segment)
		if hit.hit:
			var hit_distance := segment.start.distance_to(hit.position)
			if hit_distance < closest_hit_distance:
				closest_hit = hit
				closest_hit_distance = hit_distance
				closest_hit_segment = other_segment
	return ClosestIntersection.new(closest_hit, closest_hit_segment)

## Reflects the [param incident] beam w.r.t. the [param normal]
static func reflect(incident: Vector2, normal: Vector2) -> Vector2:
	if normal.dot(incident) > 0.0:
		normal = -normal
	return incident - 2.0 * incident.dot(normal) * normal
