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

static var Shapes: Dictionary[Type, Shape] = {
	Type.PYRAMID: Shape.new([
		Polygon.new([Vector2(-0.55, -0.55), Vector2(-0.55, 0.55), Vector2(0.55, 0.55), Vector2(0.55, -0.55)], 0.65),
		Polygon.new([Vector2(-0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.5, -0.5)], 0.75),
		Polygon.new([Vector2(-0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.0, 0.0)], 1.2),
		Polygon.new([Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.0, 0.0)], 1.0),
	], [
		Surface.new(Global.Segment.new(Vector2(0.5, -0.5), Vector2(-0.5, 0.5)), SurfaceType.REFLECTOR),
		Surface.new(Global.Segment.new(Vector2(0.5, -0.5), Vector2(-0.25, -0.25)), SurfaceType.ABSORBER),
		Surface.new(Global.Segment.new(Vector2(-0.5, 0.5), Vector2(-0.25, -0.25)), SurfaceType.ABSORBER),
	]),
	Type.DJED: Shape.new([
		Polygon.new([Vector2(-0.55, -0.55), Vector2(-0.55, 0.55), Vector2(0.55, 0.55), Vector2(0.55, -0.55)], 0.65),
		Polygon.new([Vector2(-0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.5, -0.5)], 0.75),
		Polygon.new([Vector2(0.3, -0.5), Vector2(0.5, -0.3), Vector2(-0.3, 0.5), Vector2(-0.5, 0.3)], 1.0),
	], [
		Surface.new(Global.Segment.new(Vector2(0.4, -0.4), Vector2(-0.4, 0.4)), SurfaceType.REFLECTOR),
	]),
	Type.OBELISK: Shape.new([
		Polygon.new([Vector2(-0.55, -0.55), Vector2(-0.55, 0.55), Vector2(0.55, 0.55), Vector2(0.55, -0.55)], 0.65),
		Polygon.new([Vector2(-0.5, -0.5), Vector2(-0.5, 0.5), Vector2(-0.3, 0.3), Vector2(-0.3, -0.3)], 0.75),
		Polygon.new([Vector2(-0.5, 0.5), Vector2(0.5, 0.5), Vector2(0.3, 0.3), Vector2(-0.3, 0.3)], 1.0),
		Polygon.new([Vector2(0.5, 0.5), Vector2(0.5, -0.5), Vector2(0.3, -0.3), Vector2(0.3, 0.3)], 1.2),
		Polygon.new([Vector2(0.5, -0.5), Vector2(-0.5, -0.5), Vector2(-0.3, -0.3), Vector2(0.3, -0.3)], 1.0),
		Polygon.new([Vector2(0.3, -0.3), Vector2(-0.3, -0.3), Vector2(0.0, 0.0)], 1.2),
		Polygon.new([Vector2(-0.3, 0.3), Vector2(0.3, 0.3), Vector2(0.0, 0.0)], 1.2),
		Polygon.new([Vector2(-0.3, -0.3), Vector2(-0.3, 0.3), Vector2(0.0, 0.0)], 1.0),
		Polygon.new([Vector2(0.3, 0.3), Vector2(0.3, -0.3), Vector2(0.0, 0.0)], 1.0),
	], [
		Surface.new(Global.Segment.new(Vector2(0.3, -0.3), Vector2(0.3, 0.3)), SurfaceType.ABSORBER),
		Surface.new(Global.Segment.new(Vector2(0.3, 0.3), Vector2(-0.3, 0.3)), SurfaceType.ABSORBER),
		Surface.new(Global.Segment.new(Vector2(-0.3, -0.3), Vector2(0.3, -0.3)), SurfaceType.ABSORBER),
		Surface.new(Global.Segment.new(Vector2(-0.3, 0.3), Vector2(-0.3, -0.3)), SurfaceType.ABSORBER),
	]),
}
