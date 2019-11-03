extends Node2D

const button_inst = preload('res://Button.tscn')
const waku_font = preload('res://WakuWakuFontLarge.tres')
const waku_font_small = preload('res://WakuWakuFont.tres')

const text_color = Color('#fbf0f0')
const text_shadow_color = Color('#393e46')
var background_color = Color('#2a363b')
var brick_color = Color('#52616b')

const starting_paint_red = '#f85f73'
const starting_paint_blue = '#07689f'
const starting_paint_black = '#222831'
const starting_paint_yellow = '#f9ed69'
const starting_paint_brown = '#393232'

var font_position

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_play_button()

func _draw():
	var viewport_size = get_viewport().size
	draw_rect(Rect2(Vector2(0, 0), viewport_size), background_color)
	font_position = get_starting_font_position()
	draw_bricks()
	draw_string(waku_font, Vector2(font_position.x * 1.05, font_position.y * 1.025), \
		'Starving Artist', text_shadow_color)
	draw_string(waku_font, font_position, 'Starving Artist', text_color)
	font_position.y += 500
	font_position.x -= 25
	draw_string(waku_font_small, Vector2(font_position.x * 1.025, font_position.y * 1.005), \
		'Made by PyreCraft for the Weekly Game Jam #120', text_shadow_color)
	draw_string(waku_font_small, font_position, 'Made by PyreCraft for the Weekly Game Jam #120', text_color)
	
	draw_palette()

func get_starting_font_position():
	var font_border_offset = .1
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(viewport_size.x / 3.0 - (border_offset_size.x * 2.45 ), 135 + border_offset_size.y * 1.03)

func spawn_play_button():
	var play_button = button_inst.instance()
	add_child(play_button)
	play_button.set_box_position(Vector2(450, 580))
	play_button.set_text('Play')
	play_button.set_text_offset_x(20)
	play_button.set_colors(Color('#07689f'), Color('#055887'))
	play_button.connect("clicked", self, "_on_PlayButton_clicked")

func draw_palette():
	draw_circle(Vector2(515, 385), 81, Color('#aa8f79'))
	draw_circle(Vector2(511, 382), 80, Color('#e8d8c3'))
	
	draw_circle(Vector2(470, 370), 20, Color(starting_paint_red))
	draw_circle(Vector2(540, 420), 20, Color(starting_paint_blue))
	draw_circle(Vector2(490, 420), 20, Color(starting_paint_yellow))
	draw_circle(Vector2(510, 340), 20, Color('#fbf0f0'))
	draw_circle(Vector2(550, 370), 20, Color(background_color))

func _on_PlayButton_clicked():
	get_tree().change_scene("res://Root.tscn")
	pass

func draw_bricks():
	var viewport_size = get_viewport().size
	viewport_size.y *= .70
	var brick_offset_x = 25
	var brick_offset_y = 25
	var brick_base_height = 25
	var brick_base_length = 50
	var edge_offset = 15
	var y_count = 0
	var x_count = 0
	var y = edge_offset
	while y < viewport_size.y:
		randomize()
		var x = edge_offset
		while x < viewport_size.x:
			randomize()
			var brick_length = (randi() % 25) + brick_base_length
			var brick_height = brick_base_height
			if y == edge_offset: # first layer
				brick_length = (viewport_size.x - edge_offset) / 4.0
			elif y_count == 2:
				brick_length = (viewport_size.x - edge_offset)
			if x + brick_length + (brick_offset_x * 2) > viewport_size.x:
				brick_length = viewport_size.x - x - edge_offset
			if y + brick_base_height + (brick_offset_y * 2) > viewport_size.y:
				brick_height = viewport_size.y - y - edge_offset
			if y_count == 2:
				brick_height *= 5
			if brick_length < 0.3:
				break
			if brick_height < 1:
				break
			var brick_box = Rect2(Vector2(x, y), Vector2(brick_length, brick_height))
			draw_rounded_rect(brick_box, brick_color, 8)
			x += brick_length + brick_offset_x
			x_count += 1
		y += brick_base_height + brick_offset_y
		y_count += 1

func draw_rounded_rect(rect, color, circle_radius):
#	draw_circle(rect.position, circle_radius, color)
#	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
#	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
#	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)