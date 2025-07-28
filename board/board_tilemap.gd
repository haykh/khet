class_name BoardTilemap
extends TileMapLayer

var color_to_alt_id: Dictionary[Color, int] = {}

func initialize(tile_size: Vector2, colors: Array[Color], padding := 4) -> void:
	var new_tile_set := TileSet.new()
	new_tile_set.tile_size = tile_size
	var atlas_source := TileSetAtlasSource.new()
	var img := Image.create(tile_size.x as int, tile_size.y as int, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var img_texture := ImageTexture.create_from_image(img)
	atlas_source.texture = img_texture
	atlas_source.texture_region_size = (tile_size as Vector2i) - Vector2i(padding, padding)
	atlas_source.create_tile(Vector2i.ZERO)
	color_to_alt_id.clear()
	for color in colors:
		var alt_id := atlas_source.create_alternative_tile(Vector2i.ZERO)
		atlas_source.get_tile_data(Vector2i.ZERO, alt_id).modulate = color
		color_to_alt_id[color] = alt_id
	new_tile_set.add_source(atlas_source, 0)
	tile_set = new_tile_set

func color_cell(coord: Vector2i, color) -> void:
	set_cell(coord, 0, Vector2i.ZERO, color_to_alt_id[color])
