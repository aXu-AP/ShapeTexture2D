@tool
extends DrawableShape2D
class_name DrawableRectangle


@export_range(0, 256, 0.5, "or_greater", "suffix:px") var corner_rounding : float = 0:
	set(value): corner_rounding = value; emit_changed()


func _get_svg(size : Vector2) -> String:
	var offset = -size
	size *= 2
	return "<rect x='%f' y='%f' width='%f' height='%f' rx='%f' ry='%f' />" % [ offset.x, offset.y, size.x, size.y, corner_rounding, corner_rounding]
