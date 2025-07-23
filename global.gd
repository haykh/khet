class_name Global

const INT_MAX := 9223372036854775807

const BEAM_MAX_BOUNCES := 100
const BEAM_MAX_LENGTH := 5000

enum Rotation {
	CLOCKWISE = 1,
	COUNTERCLOCKWISE = -1
}

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

class PieceShape:
	var shape: Array[Vector2]
	var surfaces: Array[SurfaceType]
	func _init(shp: Array[Vector2], srf: Array[SurfaceType]) -> void:
		self.shape = shp
		self.surfaces = srf

static var Pieces: Dictionary[PieceType, PieceShape] = {
	PieceType.PYRAMID: PieceShape.new([
		Vector2(-0.45, -0.45),
		Vector2(-0.45, 0.45),
		Vector2(0.45, -0.45)
	], [
		SurfaceType.ABSORBER,
		SurfaceType.REFLECTOR,
		SurfaceType.ABSORBER
	]),
	PieceType.DJED: PieceShape.new([
		Vector2(-0.45, 0.45),
		Vector2(0.45, -0.45)
	], [
		SurfaceType.REFLECTOR,
		SurfaceType.REFLECTOR,
	]),
	PieceType.OBELISK: PieceShape.new([
		Vector2(-0.45, -0.45),
		Vector2(-0.45, 0.45),
		Vector2(0.45, 0.45),
		Vector2(0.45, -0.45)
	], [
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
		SurfaceType.ABSORBER,
	])
}
