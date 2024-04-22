@tool
extends Texture2D
class_name ShapeTexture2D

enum FillType { SOLID, LINEAR_GRADIENT, RADIAL_GRADIENT, NONE }

@export var size : Vector2i = Vector2i(128, 128):
	set(value): size = value; _queue_update()

@export var shape : DrawableShape2D:
	set(value):
		if is_instance_valid(shape):
			shape.changed.disconnect(_queue_update)
		shape = value
		shape.changed.connect(_queue_update)
		_queue_update()


@export_group("Fill", "fill_")
@export var fill_type : FillType = FillType.SOLID:
	set(value): fill_type = value; _queue_update(); property_list_changed.emit()

@export var fill_color := Color.WHITE:
	set(value): fill_color = value; _queue_update()

@export var fill_gradient : Gradient:
	set(value):
		if is_instance_valid(fill_gradient):
			fill_gradient.changed.disconnect(_queue_update)
		fill_gradient = value
		fill_gradient.changed.connect(_queue_update)
		_queue_update()

@export var fill_from : Vector2 = Vector2.ZERO:
	set(value): fill_from = value; _queue_update()

@export var fill_to : Vector2 = Vector2.RIGHT:
	set(value): fill_to = value; _queue_update()

@export_enum("pad", "reflect", "repeat") var fill_repeat : String = "pad":
	set(value): fill_repeat = value; _queue_update()


@export_group("Stroke", "stroke_")
@export var stroke_type : FillType = FillType.SOLID:
	set(value): stroke_type = value; _queue_update(); property_list_changed.emit()

@export_range(0, 128) var stroke_width : float = 0.0:
	set(value): stroke_width = value; _queue_update()

@export var stroke_color := Color.BLACK:
	set(value): stroke_color = value; _queue_update()

@export var stroke_gradient : Gradient:
	set(value):
		if is_instance_valid(stroke_gradient):
			stroke_gradient.changed.disconnect(_queue_update)
		stroke_gradient = value
		stroke_gradient.changed.connect(_queue_update)
		_queue_update()

@export var stroke_from : Vector2 = Vector2.ZERO:
	set(value): stroke_from = value; _queue_update()

@export var stroke_to : Vector2 = Vector2.RIGHT:
	set(value): stroke_to = value; _queue_update()

@export_enum("pad", "reflect", "repeat") var stroke_repeat : String = "pad":
	set(value): stroke_repeat = value; _queue_update()

@export_enum("miter", "round", "bevel") var stroke_joint : String = "round":
	set(value): stroke_joint = value; _queue_update()


@export_group("Transform")
@export var offset : Vector2 = Vector2.ZERO:
	set(value): offset = value; _queue_update()

@export_range(-180, 180, .01, "degrees") var rotation : float = 0.0:
	set(value): rotation = value; _queue_update()

@export var scale : Vector2 = Vector2.ONE:
	set(value): scale = value; _queue_update()

var _texture : Texture2D
var _update_pending : bool


func _update() -> void:
	var svg = "<svg width='%d' height='%d' xmlns='http://www.w3.org/2000/svg'><defs>" % [ size.x, size.y ]
	var actual_offset : Vector2 = Vector2(size) / 2 + offset
	var actual_size : Vector2 = size
	if stroke_type != FillType.NONE:
		actual_size -= Vector2(stroke_width, stroke_width)
	actual_size = actual_size / 2 * scale
	svg += _svg_gradient("FillGradient", fill_type, fill_gradient, fill_from, fill_to, fill_repeat)
	svg += _svg_gradient("StrokeGradient", stroke_type, stroke_gradient, stroke_from, stroke_to, stroke_repeat)
	svg += "</defs><g stroke-width='%f' " %  stroke_width
	svg += "stroke-linejoin='%s' " % stroke_joint
	
	if fill_type == FillType.SOLID:
		svg += _svg_color("fill", fill_color)
	elif fill_type == FillType.LINEAR_GRADIENT or fill_type == FillType.RADIAL_GRADIENT:
		svg += "fill='url(#FillGradient)'"
	elif fill_type == FillType.NONE:
		svg += "fill='none'"
	
	if stroke_type == FillType.SOLID:
		svg += _svg_color("stroke", stroke_color)
	elif stroke_type == FillType.LINEAR_GRADIENT or stroke_type == FillType.RADIAL_GRADIENT:
		svg += "stroke='url(#StrokeGradient)'"
	
	svg += " transform='translate(%f, %f) rotate(%f)'>" % [ actual_offset.x, actual_offset.y, rotation ]
	svg += shape.get_svg(actual_size)
	svg += "</g></svg>"
	
	var img = Image.new()
	img.load_svg_from_string(svg)
	img.fix_alpha_edges()
	
	var new_texture = ImageTexture.create_from_image(img)
	if _texture:
		RenderingServer.texture_replace(_texture.get_rid(), new_texture.get_rid())
	else:
		_texture = new_texture
	_update_pending = false


func _svg_color(prefix : String, color : Color, prefix2 : String = "") -> String:
	if prefix2 == "":
		prefix2 = prefix
	return "%s='#%s' %s-opacity='%f'" % [prefix, color.to_html(0), prefix2, color.a]


func _svg_gradient(id : String, type : FillType, gradient : Gradient, from : Vector2, to : Vector2, repeat : String) -> String:
	if not is_instance_valid(gradient):
		return ""
	var svg := ""
	from = from * Vector2(size) - Vector2(size) / 2
	to = to * Vector2(size) - Vector2(size) / 2
	if type == FillType.LINEAR_GRADIENT:
		svg += "<linearGradient id='%s' x1='%f' y1='%f' x2='%f' y2='%f' spreadMethod='%s' gradientUnits='userSpaceOnUse'>" % \
			[ id, from.x, from.y, to.x, to.y, repeat ]
		for i in gradient.get_point_count():
			svg += "<stop %s offset='%f' />" % [_svg_color("stop-color", gradient.get_color(i), "stop"), gradient.get_offset(i)]
		svg += "</linearGradient>"
	elif type == FillType.RADIAL_GRADIENT:
		svg += "<radialGradient id='%s' cx='%f' cy='%f' r='%f' spreadMethod='%s' gradientUnits='userSpaceOnUse'>" % \
			[ id, from.x, from.y, from.distance_to(to), repeat ]
		for i in gradient.get_point_count():
			svg += "<stop %s offset='%f' />" % [_svg_color("stop-color", gradient.get_color(i), "stop"), gradient.get_offset(i)]
		svg += "</radialGradient>"
	return svg


func _validate_property(property : Dictionary):
	if property.name == "fill_color" and fill_type != FillType.SOLID:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if fill_type != FillType.LINEAR_GRADIENT and fill_type != FillType.RADIAL_GRADIENT:
		match property.name:
			"fill_gradient", "fill_from", "fill_to", "fill_repeat":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "stroke_color" and stroke_type != FillType.SOLID:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if stroke_type != FillType.LINEAR_GRADIENT and stroke_type != FillType.RADIAL_GRADIENT:
		match property.name:
			"stroke_gradient", "stroke_from", "stroke_to", "stroke_repeat":
				property.usage = PROPERTY_USAGE_NO_EDITOR
	if stroke_type == FillType.NONE:
		match property.name:
			"stroke_width", "stroke_joint":
				property.usage = PROPERTY_USAGE_NO_EDITOR


func _queue_update():
	emit_changed()
	if _update_pending:
		return
	_update_pending = true
	_update.call_deferred()


func _get_width() -> int:
	return size.x


func _get_height() -> int:
	return size.y


func _get_rid() -> RID:
	if !_texture:
		_texture = create_placeholder()
	return _texture.get_rid()
