class_name Pieces

enum Type {
	NONE,
	PYRAMID,
	DJED,
	OBELISK,
	# more to be added
}

enum State {
	NONE,
	IDLE,
	ANIMATING,
	PICKED,
}

enum Team {
	NONE,
	SILVER,
	RED,
}

enum SurfaceType {
	NONE,
	REFLECTOR,
	ABSORBER
}

const _padding = 0.1
const _size = 1.0 - _padding * 2.0
const _halfsize = _size * 0.5

class Shape:
	var shape: Array[Vector2]
	var outlines: Array[Global.Segment]
	var surfaces: Array[SurfaceType]
	func _init(shp: Array[Vector2], otl: Array[Global.Segment], srf: Array[SurfaceType]) -> void:
		self.shape = shp
		self.outlines = otl
		self.surfaces = srf

static var Shapes: Dictionary[Type, Shape] = {
	Type.PYRAMID: Shape.new([
		Vector2(-_halfsize, -_halfsize),
		Vector2(-_halfsize, _halfsize),
		Vector2(_halfsize, -_halfsize)
	], [
		Global.Segment.new(Vector2(-_halfsize, -_halfsize), Vector2(-_halfsize, _halfsize)),
		Global.Segment.new(Vector2(-_halfsize, _halfsize), Vector2(_halfsize, -_halfsize)),
		Global.Segment.new(Vector2(_halfsize, -_halfsize), Vector2(-_halfsize, -_halfsize))
	], [
		SurfaceType.ABSORBER,
		SurfaceType.REFLECTOR,
		SurfaceType.ABSORBER
	]),
	Type.DJED: Shape.new([
		Vector2(-_halfsize, _halfsize),
		Vector2(-_halfsize, _halfsize * 0.75),
		Vector2(_halfsize * 0.75, -_halfsize),
		Vector2(_halfsize, -_halfsize),
		Vector2(_halfsize, -_halfsize * 0.75),
		Vector2(-_halfsize * 0.75, _halfsize)
	], [
		Global.Segment.new(Vector2(-_halfsize, _halfsize), Vector2(_halfsize, -_halfsize)),
	], [
		SurfaceType.REFLECTOR,
	]),
	Type.OBELISK: Shape.new([
		Vector2(-_halfsize, -_halfsize),
		Vector2(-_halfsize, _halfsize),
		Vector2(_halfsize, _halfsize),
		Vector2(_halfsize, -_halfsize)
	], [
		Global.Segment.new(Vector2(-_halfsize, -_halfsize), Vector2(-_halfsize, _halfsize)),
		Global.Segment.new(Vector2(-_halfsize, _halfsize), Vector2(_halfsize, _halfsize)),
		Global.Segment.new(Vector2(_halfsize, _halfsize), Vector2(_halfsize, -_halfsize)),
		Global.Segment.new(Vector2(_halfsize, -_halfsize), Vector2(-_halfsize, -_halfsize)),
	], [
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
	])
}
