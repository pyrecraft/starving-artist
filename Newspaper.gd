extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font_small = preload('res://WakuWakuFont.tres')
const button_inst = preload('res://Button.tscn')
const background_color = Color('#768996')
const background_shadow_color = Color('#2a363b')

var mission_L

var starting_point
var dimensions

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_size = get_viewport().size
	starting_point = Vector2(viewport_size.x / 8.25, viewport_size.y / 8.0)
	dimensions = Vector2(viewport_size.x * (3.0/4.0), viewport_size.y * (2.0/3.0))
	
	var close_button = button_inst.instance()
	mission_L = store.get_state()['game']['mission']
	if mission_L.max_payout != 999: # Game End
		add_child(close_button)
	elif Constants.IS_ADDICTING_GAMES:
		JavaScript.eval("document.swag.endGame()")
	
	close_button.set_box_position(Vector2(900, 60))
	close_button.set_box_dimensions(30, 30)
	close_button.set_text_offset_x(3)
	close_button.set_text_offset_y(4)
	close_button.set_text('X')
	close_button.set_colors(Color('#f85f73'), Color('#f63e56'))
	
	close_button.connect("clicked", self, "_on_CloseButton_clicked")
	
	assign_headlines(mission_L.main_headline, mission_L.lower_headline, mission_L.side_headline)

func _input(event):
	if event is InputEventMouseButton:
		if event.position.x < starting_point.x or event.position.x > starting_point.x + dimensions.x:
			close_window()
		elif event.position.y < starting_point.y or event.position.y > starting_point.y + dimensions.y:
			close_window()

func assign_headlines(large, lower, side):
	$MainHeadline.bbcode_text = large
	$LowerHeadline.bbcode_text = lower
	$SideHeadline.bbcode_text = side

func _on_CloseButton_clicked():
	close_window()

func _on_ResetButton_clicked():
	get_tree().reload_current_scene()

func close_window():
	if mission_L.max_payout == 999: # Game End
		return
	store.dispatch(actions.game_set_state(Constants.State.PAINT))
	queue_free()

func _draw():
	draw_rounded_rect(Rect2(starting_point, dimensions), background_shadow_color, 25)
	draw_rounded_rect(Rect2(starting_point, dimensions), background_color, 20)
	draw_separation_lines()
	if mission_L.max_payout == 999: # Game End
		$Date.bbcode_text = str(2019)
		var font_position = Vector2(650, 700)
		var text_color = Color('#fbf0f0')
		var text_shadow_color = Color('#393e46')
		position.y += 5
#		draw_string(waku_font_small, Vector2(font_position.x * 1.005, font_position.y * 1.005), \
#			'Made by @pyrecraft', text_shadow_color)
#		draw_string(waku_font_small, font_position, 'Made by @pyrecraft', text_color)

func draw_separation_lines():
	draw_title_main_headline_line()
	draw_main_headline_lines()
	draw_lower_headline_lines()
	draw_side_headline_lines()

func draw_side_headline_lines():
	var in_between_space_y = ((starting_point.y + dimensions.y) - ($SideHeadline.rect_position.y + $SideHeadline.rect_size.y))
	var line_count = 7.0
	var space_diff = in_between_space_y / line_count
	var current_line_y = $SideHeadline.rect_position.y + $SideHeadline.rect_size.y + space_diff
	var starting_x = $SideHeadline.rect_position.x
	var ending_x = $SideHeadline.rect_position.x + $SideHeadline.rect_size.x
	for i in range(0, int(line_count) - 1.0):
		var starting_vec = Vector2(starting_x, current_line_y)
		var ending_vec = Vector2(ending_x, current_line_y)
		draw_rounded_line(starting_vec, ending_vec, Color.black, 6)
		current_line_y += space_diff

func draw_title_main_headline_line():
	var in_between_average_y = ($MainHeadline.rect_position.y - (starting_point.y + $Title.rect_size.y))/2.0
	var starting_pos_x = starting_point.x
	var starting_pos_y = starting_point.y + $Title.rect_size.y + in_between_average_y
	var ending_pos = Vector2((starting_pos_x + dimensions.x), starting_pos_y)
	draw_rounded_line(Vector2(starting_pos_x, starting_pos_y), ending_pos, background_shadow_color, 10)

func draw_lower_headline_lines():
	var in_between_space_y = ((starting_point.y + dimensions.y) - ($LowerHeadline.rect_position.y + $LowerHeadline.rect_size.y))
	var line_count = 5.0
	var space_diff = in_between_space_y / line_count
	var current_line_y = $LowerHeadline.rect_position.y + $LowerHeadline.rect_size.y + space_diff
	var starting_x = $LowerHeadline.rect_position.x
	var ending_x = $LowerHeadline.rect_position.x + $LowerHeadline.rect_size.x
	for i in range(0, int(line_count) - 1.0):
		var starting_vec = Vector2(starting_x, current_line_y)
		var ending_vec = Vector2(ending_x, current_line_y)
		draw_rounded_line(starting_vec, ending_vec, Color.black, 6)
		current_line_y += space_diff

func draw_main_headline_lines():
	var in_between_space_y = ($LowerHeadline.rect_position.y - ($MainHeadline.rect_position.y + $MainHeadline.rect_size.y))
	var line_count = 5.0
	var space_diff = in_between_space_y / line_count
	var current_line_y = $MainHeadline.rect_position.y + $MainHeadline.rect_size.y + space_diff
	var starting_x = $MainHeadline.rect_position.x
	var ending_x = $MainHeadline.rect_position.x + $MainHeadline.rect_size.x
	for i in range(0, int(line_count) - 2.0):
		var starting_vec = Vector2(starting_x, current_line_y)
		var ending_vec = Vector2(ending_x, current_line_y)
		draw_rounded_line(starting_vec, ending_vec, Color.black, 6)
		current_line_y += space_diff

func draw_rounded_line(starting_vec, ending_vec, color, width):
	draw_line(starting_vec, ending_vec, color, width)
	draw_circle(starting_vec, width/2.0, color)
	draw_circle(ending_vec, width/2.0, color)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)