class_name Game

enum StartingLayout {
	CLASSIC,
}

class PieceConfiguration:
	var type: Pieces.Type
	var coord: Vector2i
	var orientation: int
	func _init(typ: Pieces.Type, crd: Vector2i, ori: int) -> void:
		self.type = typ
		self.coord = crd
		self.orientation = ori

class PieceConfigurations:
	var piece_configs: Array[PieceConfiguration]
	func _init(pc_cfg: Array[PieceConfiguration]) -> void:
		piece_configs = pc_cfg
	
static var Layouts: Dictionary[StartingLayout, PieceConfigurations] = {
	StartingLayout.CLASSIC: PieceConfigurations.new([
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(2, 7), 2),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(2, 4), 2),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(2, 3), 1),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(3, 2), 2),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(7, 6), 3),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(9, 4), 1),
		PieceConfiguration.new(Pieces.Type.PYRAMID, Vector2i(9, 3), 2),
		PieceConfiguration.new(Pieces.Type.DJED, Vector2i(4, 4), 0),
		PieceConfiguration.new(Pieces.Type.DJED, Vector2i(5, 4), 1),
	])
}

static func initialize(board: Board, layout: StartingLayout) -> void:
	assert (layout in Layouts, "Starting layout not supported")
	for piece_config in Layouts[layout].piece_configs:
		board.spawn_piece(Pieces.Team.SILVER, piece_config.type, piece_config.coord, piece_config.orientation)
		board.spawn_piece(Pieces.Team.RED, piece_config.type, Vector2i(board.nx - 1, board.ny - 1) - piece_config.coord, (piece_config.orientation + 2) % 4)

static func legal_moves(board: Board, piece: Piece) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	for i in board.nx:
		for j in board.ny:
			if abs(i - piece.coord.x) <= 1 and abs(j - piece.coord.y) <= 1:
				moves.append(Vector2i(i, j))
	for child in board.pieces_container.get_children():
		if child is Piece:
			var other_piece := child as Piece
			if other_piece != piece:
				moves.erase(other_piece.coord)
	if piece.team == Pieces.Team.RED:
		moves.erase(Vector2i(1, 0))
		moves.erase(Vector2i(1, board.ny - 1))
		for j in board.ny:
			moves.erase(Vector2i(board.nx - 1, j))
	elif piece.team == Pieces.Team.SILVER:
		moves.erase(Vector2i(board.nx - 2, 0))
		moves.erase(Vector2i(board.nx - 2, board.ny - 1))
		for j in board.ny:
			moves.erase(Vector2i(0, j))
	return moves
