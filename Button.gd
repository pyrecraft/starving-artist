extends Node2D

signal clicked

const waku_font = preload('res://WakuWakuFont.tres')
const hover_color = Color('#ff7e67')
const money_shadow_color = Color('#393e46')

var box_color = Color('#62d2a2')
var box_clicked_color = Color('#33b37c')

var font_position = Vector2(0, 0)
var box_position = Vector2(0, 0)
var box_dimensions = Vector2(0, 0)
var text_offset_x = 13
var text_offset_y = 0
var is_hover = false
var is_clicked = false
var text = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("mouse_entered", self, "_on_Area2D_mouse_entered")
	$Area2D.connect("mouse_exited", self, "_on_Area2D_mouse_exited")
	$Area2D.connect("input_event", self, "_on_Area2D_input_event")
	box_dimensions = get_box_dimensions()
	box_position = Vector2(0, 0)
	font_position = get_starting_font_position()
	set_collision_shape()

func _process(delta):
#	print(randi() % 20)
	pass

func set_text(t):
	text = t

func set_colors(regular, clicked):
	box_color = regular
	box_clicked_color = clicked
	update()

func set_box_position(vec):
	box_position = vec
	box_dimensions = get_box_dimensions()
	font_position = get_starting_font_position()
	set_collision_shape()
	update()

func get_box_position():
	var font_border_offset = 0.075
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(viewport_size.x - border_offset_size.x - box_dimensions.x, \
		viewport_size.y - border_offset_size.y - box_dimensions.y)

func get_box_dimensions():
	var box_height = 40
	var box_width = 120
	return Vector2(box_width, box_height)

func set_box_dimensions(h, w):
	box_dimensions = Vector2(h, w)
	font_position = get_starting_font_position()
	set_collision_shape()
	update()

func set_text_offset_x(val):
	text_offset_x = val
	font_position = get_starting_font_position()
	update()

func set_text_offset_y(val):
	text_offset_y = val
	font_position = get_starting_font_position()
	update()

func get_starting_font_position():
	return Vector2(box_position.x + text_offset_x, text_offset_y + box_position.y + (box_dimensions.y * (3.75/5.0)))

func _draw():
	if is_hover:
		draw_rounded_rect(Rect2(box_position, box_dimensions), hover_color, 10)
	if is_clicked:
		draw_rounded_rect(Rect2(box_position, box_dimensions), box_clicked_color, 7)
	else:
		draw_rounded_rect(Rect2(box_position, box_dimensions), box_color, 7)
	draw_string(waku_font, Vector2(font_position.x * 1.002, font_position.y * 1.002), \
		text, money_shadow_color)
	draw_string(waku_font, font_position, text, Color('#fbf0f0'))

func set_collision_shape():
	$Area2D/CollisionShape2D.position.x = box_position.x + (box_dimensions.x / 2.0)
	$Area2D/CollisionShape2D.position.y = box_position.y + (box_dimensions.y / 2.0)
	$Area2D/CollisionShape2D.shape.extents = Vector2(box_dimensions.x / 1.9, box_dimensions.y / 1.6)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)

func _on_Area2D_mouse_entered():
	is_hover = true
	update()

func _on_Area2D_mouse_exited():
	is_hover = false
	is_clicked = false
	update()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if !is_clicked:
			is_clicked = true
		else:
			emit_signal("clicked")
			is_clicked = false
		update()