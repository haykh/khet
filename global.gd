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
	var segment: SegmentWithCallback
	func _init(inter := Intersection.new(false), sgmt: SegmentWithCallback = null) -> void:
		self.intersection = inter
		self.segment = sgmt

## Segment class holding a pair of two points.
class Segment:
	var start: Vector2
	var end: Vector2
	func _init(st: Vector2, en: Vector2) -> void:
		self.start = st
		self.end = en
	
	func normal() -> Vector2:
		return (self.start - self.end).normalized().orthogonal().normalized()

## Segment class holding a pair of two points with a callback.
##
## Together with [member Segment.start] and [member Segment.end] holds an optional callback [member SegmentWithCallback.callback], 
## which is used when intersection happens with this [param Segment].
class SegmentWithCallback:
	extends Segment
	var callback: Variant
	func _init(st: Vector2, en: Vector2, cbck: Variant = null) -> void:
		super(st, en)
		self.callback = cbck

## Returns an [code]Intersection[/code] object to indicate whether two segments intsersect.
static func segments_intersect(segmentA: SegmentWithCallback, segmentB: SegmentWithCallback) -> Intersection:
	var result: Variant = Geometry2D.segment_intersects_segment(segmentA.start, segmentA.end, segmentB.start, segmentB.end)
	if result != null:
		return Intersection.new(true, result as Vector2)
	return Intersection.new(false)

## Finds the closest intersection by a given [param SegmentWithCallback] with a collection of other [param SegmentWithCallback] objects.
##
## Distance is measured from the [member SegmentWithCallback.start] of the [param segment].
static func find_closest_intersection(segment: SegmentWithCallback, collection_of_segments: Array[SegmentWithCallback]) -> ClosestIntersection:
	var closest_hit := Intersection.new(false)
	var closest_hit_segment: SegmentWithCallback = null
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
