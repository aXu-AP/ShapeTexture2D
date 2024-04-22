@tool
extends Resource
class_name DrawableShape2D


## Returns an svg element for drawing the shape.
func get_svg(size : Vector2) -> String:
	return _get_svg(size)


func _get_svg(size : Vector2) -> String:
	return "<path d='' />"
