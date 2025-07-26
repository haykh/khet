class_name BoardShape
extends Polygon2D

func initialize(
	markers_container: Node2D,
	tilemap: BoardTilemap,
	extents: Vector2i,
	dimensions: Vector2i,
	tile_size: Vector2i,
	color_board: Color, 
	color_neutral: Color, 
	color_silver: Color, 
	color_red: Color,
) -> void:
	color = color_board
	var new_color_silver := color_silver.lerp(color_board, 0.75)
	var new_color_red := color_red.lerp(color_board, 0.75)
	tilemap.position = -(extents as Vector2) / 2.0
	tilemap.initialize(tile_size, [color_neutral, new_color_silver, new_color_red])
	var nx := dimensions[0]
	var ny := dimensions[1]
	for i in range(nx):
		for j in range(ny):
			tilemap.color_cell(Vector2i(i, j), color_neutral)
			var marker := MoveMarker.new()
			marker.initialize(Vector2i(i, j), tile_size)
			markers_container.add_child(marker)
	markers_container.position = position - (extents as Vector2) / 2.0
	for j in range(ny):
		tilemap.color_cell(Vector2i(0, j), new_color_red)
		tilemap.color_cell(Vector2i(nx - 1, j), new_color_silver)
	tilemap.color_cell(Vector2i(1, 0), new_color_silver)
	tilemap.color_cell(Vector2i(1, ny - 1), new_color_silver)
	tilemap.color_cell(Vector2i(nx - 2, 0), new_color_red)
	tilemap.color_cell(Vector2i(nx - 2, ny - 1), new_color_red)
