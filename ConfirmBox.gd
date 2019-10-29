extends Node2D

const CLEAR_TEXT_MESSAGE = 'Are you sure you want to [color=#f85f73]abandon[/color] your masterpiece?'
const SELL_TEXT_MESSAGE = 'Are you sure you want to [color=#62d2a2]sell[/color] your masterpiece?'

const SUPPORTING_MESSAGE = 'This action cannot be undone.'

const button_inst = preload('res://Button.tscn')
const confirm_color = Color('#52616b')
const confirm_shadow_color = Color('#2a363b')

var starting_point
var dimensions
var confirm_type = Constants.ConfirmBox.CLEAR

# Called when the node enters the scene tree for the first time.
func _ready():
	$QuestionText.bbcode_enabled = true
	$SupportText.bbcode_enabled = true
	$SupportText.bbcode_text = SUPPORTING_MESSAGE
	
	var viewport_size = get_viewport().size
	starting_point = Vector2(viewport_size.x / 4.0, viewport_size.y / 6.75)
	dimensions = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
	
	var yes_button = button_inst.instance()
	add_child(yes_button)
	yes_button.set_box_position(Vector2(350, 410))
	yes_button.set_text_offset_x(30)
	yes_button.set_text('Yes')
	
	var no_button = button_inst.instance()
	add_child(no_button)
	no_button.set_box_position(Vector2(550, 410))
	no_button.set_text('No')
	no_button.set_text_offset_x(35)
	no_button.set_colors(Color('#f85f73'), Color('#f63e56'))
	
	yes_button.connect("clicked", self, "_on_YesButton_clicked")
	no_button.connect("clicked", self, "_on_NoButton_clicked")

func _input(event):
	if event is InputEventMouseButton:
		if event.position.x < starting_point.x or event.position.x > starting_point.x + dimensions.x:
			close_window()
		elif event.position.y < starting_point.y or event.position.y > starting_point.y + dimensions.y:
			close_window()

func set_confirm_type(t):
	confirm_type = t
	match t:
		Constants.ConfirmBox.CLEAR:
			set_question_text(CLEAR_TEXT_MESSAGE)
		Constants.ConfirmBox.SELL:
			set_question_text(SELL_TEXT_MESSAGE)

func set_question_text(t):
	print(t)
	$QuestionText.bbcode_text = t

func _on_YesButton_clicked():
	print('Yes button clicked')
	match confirm_type:
		Constants.ConfirmBox.CLEAR:
			store.dispatch(actions.game_set_state(Constants.State.CLEAR))
		Constants.ConfirmBox.SELL:
			store.dispatch(actions.game_set_state(Constants.State.SELL))
	queue_free()

func _on_NoButton_clicked():
	print('No button clicked')
	close_window()

func close_window():
	match confirm_type:
		Constants.ConfirmBox.CLEAR:
			store.dispatch(actions.game_set_state(Constants.State.PAINT))
		Constants.ConfirmBox.SELL:
			store.dispatch(actions.game_set_state(Constants.State.PAINT))
	queue_free()

func _draw():
	draw_rounded_rect(Rect2(starting_point, dimensions), confirm_shadow_color, 25)
	draw_rounded_rect(Rect2(starting_point, dimensions), confirm_color, 20)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)