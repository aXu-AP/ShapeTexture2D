@tool
extends DrawableShape2D
class_name DrawableEllipse


func _get_svg(size : Vector2) -> String:
	return "<ellipse rx='%f' ry='%f' />" % [ size.x, size.y]
