@tool
extends DrawableShape2D
class_name DrawableCapsule


@export_range(0, 1) var width : float = 0.5:
	set(value): width = value; emit_changed()


func _get_svg(size : Vector2) -> String:
	var point := Vector2(width, 1 - width) * size
	var data := "M %f %f " % [ point.x, point.y ]
	data += "A %f %f 0 0 1 %f %f " % [ point.x, size.y - point.y, -point.x, point.y ]
	data += "L %f %f " % [ -point.x, -point.y ]
	data += "A %f %f 0 0 1 %f %f " % [ point.x, size.y - point.y, point.x, -point.y ]
	data += "Z"
	return "<path d='%s' />" % data
