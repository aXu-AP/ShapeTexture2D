@tool
extends DrawableShape2D
class_name DrawablePolygon


@export_range(3, 64) var points : int = 5:
	set(value): points = value; emit_changed()

@export var is_star : bool = false:
	set(value): is_star = value; emit_changed()

@export_range(-1, 1) var star_inset : float = 0.5:
	set(value): star_inset = value; emit_changed()


func _get_svg(size : Vector2) -> String:
	var data := ""
	for i in points:
		var angle = TAU * i / points
		var point : Vector2 = Vector2.UP.rotated(angle) * size
		data += "%s %f %f " % ["M" if i == 0 else "L", point.x, point.y ]
		if is_star:
			var angle2 = TAU * (i + .5) / points
			var point2 : Vector2 = Vector2.UP.rotated(angle2) * size * star_inset
			data += "L %f %f " % [point2.x, point2.y ]
			
	data += "Z"
	return "<path d='%s' />" % data
