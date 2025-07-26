class_name MoveMarker
extends Marker2D

var coord: Vector2i
var active: bool

func initialize(crd: Vector2i, tile_size: Vector2) -> void:
	coord = crd
	active = false
	z_index = 1
	position = tile_size * Vector2((coord.x as float) + 0.5, (coord.y as float) + 0.5)
	scale = Vector2(0.0, 0.0)
	var circle_sprite := Sprite2D.new()
	var radial_gradient := GradientTexture2D.new()
	radial_gradient.set_fill(GradientTexture2D.FILL_RADIAL)
	radial_gradient.set_fill_from(Vector2(0.5, 0.5))
	radial_gradient.set_fill_to(Vector2(1.0, 0.5))
	radial_gradient.gradient = Gradient.new()
	radial_gradient.gradient.offsets = PackedFloat32Array([0.5, 1.0])
	radial_gradient.gradient.colors = PackedColorArray([Color(0.180392, 0.545098, 0.341176, 1), Color(0.180392, 0.545098, 0.341176, 0)])
	radial_gradient.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	circle_sprite.texture = radial_gradient
	add_child(circle_sprite)

# = = = = = = = = = = = = = = = = 
# tweens
func animate_activate() -> void:
	active = true
	create_tween()\
		.tween_property(self, "scale", Vector2(0.25, 0.25), 0.2)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func animate_deactivate() -> void:
	active = false
	create_tween()\
		.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
