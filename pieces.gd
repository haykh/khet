class_name Pieces

enum Type {
	NONE,
	PYRAMID,
	DJED,
	OBELISK,
	STACKED_OBELISK,
	PHARAOH,
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
	ABSORBER,
}

class Surface:
	var segment: Global.Segment
	var type: SurfaceType
	func _init(sgmt: Global.Segment, tp: SurfaceType) -> void:
		self.segment = sgmt
		self.type = tp

class Polygon:
	var points: Array[Vector2]
	var modulate: float
	func _init(pts: Array[Vector2], mdl: float) -> void:
		self.points = pts
		self.modulate = mdl

class Shape:
	var scale := 0.75
	var polygons: Array[Polygon]
	var surfaces: Array[Surface]
	func _init(pgn: Array[Polygon], srf: Array[Surface]) -> void:
		self.polygons = pgn
		self.surfaces = srf
	
	func add_polygons(container: Node2D, tilesize: Vector2, color: Color) -> void:
		for poly in self.polygons:
			var shape := PackedVector2Array()
			var shape_polygon := Polygon2D.new()
			for pt in poly.points:
				shape.append(pt * tilesize * self.scale)
			shape_polygon.polygon = shape
			shape_polygon.color = color
			shape_polygon.modulate = Color(poly.modulate, poly.modulate, poly.modulate)
			container.add_child(shape_polygon)
	
	func add_surfaces(container: Node2D, tilesize: Vector2, color_dict: Dictionary[SurfaceType, Color]) -> void:
		for surf in self.surfaces:
			var line := Line2D.new()
			line.width = 2
			line.points = [surf.segment.start * tilesize * self.scale, surf.segment.end * tilesize * self.scale]
			line.default_color = color_dict[surf.type]
			container.add_child(line)

const HALFSIZE := 0.5
const PH_RAD := 0.6
const OB_PAD := 0.3
const STACK_OB_PAD := 0.7

static func _vec(pts: Array[float], coeff: float) -> Vector2:
	return Vector2(pts[0], pts[1]) * coeff

static func _sgmt(pt1: Array[float], pt2: Array[float], coeff: float) -> Global.Segment:
	return Global.Segment.new(_vec(pt1, coeff), _vec(pt2, coeff))

static func _poly(pts: Array[Array], coeff: float) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for pt in pts:
		points.append(Vector2(pt[0] as float, pt[1] as float) * coeff)
	return points

static var Shapes: Dictionary[Type, Shape] = {
	Type.PYRAMID: Shape.new([
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], 1.1 * HALFSIZE), 0.65),
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], HALFSIZE), 0.75),
		Polygon.new(_poly([[-1, -1], [-1, 1], [0, 0]], HALFSIZE), 1.2),
		Polygon.new(_poly([[-1, -1], [1, -1], [0, 0]], HALFSIZE), 1.0),
	], [
		Surface.new(_sgmt([1, -1], [-1, 1], HALFSIZE), SurfaceType.REFLECTOR),
		Surface.new(_sgmt([1, -1], [-1, -1], HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, 1], [-1, -1], HALFSIZE), SurfaceType.ABSORBER),
	]),
	Type.DJED: Shape.new([
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], 1.1 * HALFSIZE), 0.65),
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], HALFSIZE), 0.75),
		Polygon.new(_poly([[0.6, -1], [1, -0.6], [-0.6, 1], [-1, 0.6]], HALFSIZE), 1.0),
	], [
		Surface.new(_sgmt([1, -1], [-1, 1], 0.8 * HALFSIZE), SurfaceType.REFLECTOR),
	]),
	Type.OBELISK: Shape.new([
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], 1.1 * HALFSIZE), 0.65),
		Polygon.new(_poly([[-1, -1], [-1, 1], [-OB_PAD, OB_PAD], [-OB_PAD, -OB_PAD]], HALFSIZE), 0.75),
		Polygon.new(_poly([[-1, 1], [1, 1], [OB_PAD, OB_PAD], [-OB_PAD, OB_PAD]], HALFSIZE), 1.0),
		Polygon.new(_poly([[1, 1], [1, -1], [OB_PAD, -OB_PAD], [OB_PAD, OB_PAD]], HALFSIZE), 1.2),
		Polygon.new(_poly([[1, -1], [-1, -1], [-OB_PAD, -OB_PAD], [OB_PAD, -OB_PAD]], HALFSIZE), 1.0),
		Polygon.new(_poly([[1, -1], [-1, -1], [0, 0]], OB_PAD * HALFSIZE), 1.2),
		Polygon.new(_poly([[-1, 1], [1, 1], [0, 0]], OB_PAD * HALFSIZE), 1.2),
		Polygon.new(_poly([[-1, -1], [-1, 1], [0, 0]], OB_PAD * HALFSIZE), 1.0),
		Polygon.new(_poly([[1, 1], [1, -1], [0, 0]], OB_PAD * HALFSIZE), 1.0),
	], [
		Surface.new(_sgmt([1, -1], [1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([1, 1], [-1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, -1], [1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, 1], [-1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
	]),
	Type.STACKED_OBELISK: Shape.new([
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], 1.1 * HALFSIZE), 0.55),
		Polygon.new(_poly([[-1, -1], [-1, 1], [-OB_PAD, OB_PAD], [-OB_PAD, -OB_PAD]], HALFSIZE), 0.65),
		Polygon.new(_poly([[-1, 1], [1, 1], [OB_PAD, OB_PAD], [-OB_PAD, OB_PAD]], HALFSIZE), 0.9),
		Polygon.new(_poly([[1, 1], [1, -1], [OB_PAD, -OB_PAD], [OB_PAD, OB_PAD]], HALFSIZE), 1.1),
		Polygon.new(_poly([[1, -1], [-1, -1], [-OB_PAD, -OB_PAD], [OB_PAD, -OB_PAD]], HALFSIZE), 0.9),
		Polygon.new(_poly([[-2.5, -2.5], [-2.5, 2.5], [-1, 1], [-1, -1]], OB_PAD * HALFSIZE), 0.9),
		Polygon.new(_poly([[-2.5, 2.5], [2.5, 2.5], [1, 1], [-1, 1]], OB_PAD * HALFSIZE), 1.1),
		Polygon.new(_poly([[2.5, 2.5], [2.5, -2.5], [1, -1], [1, 1]], OB_PAD * HALFSIZE), 1.3),
		Polygon.new(_poly([[2.5, -2.5], [-2.5, -2.5], [-1, -1], [1, -1]], OB_PAD * HALFSIZE), 1.1),
		Polygon.new(_poly([[1, -1], [-1, -1], [0, 0]], OB_PAD * HALFSIZE), 1.3),
		Polygon.new(_poly([[-1, 1], [1, 1], [0, 0]], OB_PAD * HALFSIZE), 1.3),
		Polygon.new(_poly([[-1, -1], [-1, 1], [0, 0]], OB_PAD * HALFSIZE), 1.1),
		Polygon.new(_poly([[1, 1], [1, -1], [0, 0]], OB_PAD * HALFSIZE), 1.1),
	], [
		Surface.new(_sgmt([1, -1], [1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([1, 1], [-1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, -1], [1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, 1], [-1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
	]),
	Type.PHARAOH: Shape.new([
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], 1.1 * HALFSIZE), 0.55),
		Polygon.new(_poly([[-1, -1], [-1, 1], [1, 1], [1, -1]], HALFSIZE), 0.65),
		Polygon.new(_poly([[-0.38, -0.92], [-0.92, -0.38], [-0.92, 0.38], [-0.38, 0.92], [0.38, 0.92], [0.92, 0.38], [0.92, -0.38], [0.38, -0.92]], PH_RAD * HALFSIZE), 1.0),
		Polygon.new(_poly([[-0.92 / PH_RAD, 0.38], [-0.92 / PH_RAD, -0.38], [-0.92, -0.38], [-0.92, 0.38]], PH_RAD * HALFSIZE), 0.8),
		Polygon.new(_poly([[0.92 / PH_RAD, 0.38], [0.92 / PH_RAD, -0.38], [-0.92, -0.38], [-0.92, 0.38]], PH_RAD * HALFSIZE), 0.8),
		Polygon.new(_poly([[0.92, -0.38], [0.92, 0.38], [-0.92, 0.38], [-0.92, -0.38]], PH_RAD * HALFSIZE), 1.2),
	], [
		Surface.new(_sgmt([1, -1], [1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([1, 1], [-1, 1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, -1], [1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
		Surface.new(_sgmt([-1, 1], [-1, -1], 0.6 * HALFSIZE), SurfaceType.ABSORBER),
	]),
}
