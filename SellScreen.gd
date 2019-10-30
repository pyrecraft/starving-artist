extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')
const waku_font = preload('res://WakuWakuFont.tres')
const text_color = Color('#fbf0f0')
const text_shadow_color = Color('#393e46')

var font_position = Vector2(0, 0)
var current_transition_state = TransitionState.INITIAL

enum TransitionState {
	INITIAL,
	RESULTS_TEXT,
	GRADE_TEXT
}

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var state_L
var grid_L

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = store.get_state()['canvas']['dimensions']
	starting_vector_L = store.get_state()['canvas']['starting_vector']
	state_L = store.get_state()['game']['state']
	grid_L = store.get_state()['canvas']['grid']
	font_position = get_starting_font_position()
	clear_text()
	$TransitionTimer.start()
#	SaleLogic.get_painting_sale_info_params(starting_vector_L, dimensions_L, grid_L)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['canvas']['starting_vector'] != null:
		starting_vector_L = store.get_state()['canvas']['starting_vector']
	if store.get_state()['canvas']['grid'] != null:
		print('Received new grid inside SellScreen')
		grid_L = store.get_state()['canvas']['grid']
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']

func get_starting_font_position():
	var font_border_offset = 0.05
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(viewport_size.x / 2.0 - (border_offset_size.x * 1.25 ), border_offset_size.y * 1.03)

func clear_text():
	$ResultsText.visible_characters = 0
	$GradeText.visible_characters = 0

func results_has_text_to_display():
	return $ResultsText.visible_characters < $ResultsText.get_total_character_count()

func grade_has_text_to_display():
	return $GradeText.visible_characters < $GradeText.get_total_character_count()

func _draw():
	draw_string(waku_font, Vector2(font_position.x * 1.0025, font_position.y * 1.05), \
		'Results', text_shadow_color)
	draw_string(waku_font, font_position, 'Results', text_color)

func _on_TextTimer_timeout():
	match current_transition_state:
		TransitionState.INITIAL:
			pass
		TransitionState.RESULTS_TEXT:
			if results_has_text_to_display():
				$ResultsText.visible_characters += 1
			else:
				$TransitionTimer.start()
		TransitionState.GRADE_TEXT:
			if grade_has_text_to_display():
				$GradeText.visible_characters += 1
			else:
				$TransitionTimer.start()

func _on_TransitionTimer_timeout():
	match current_transition_state:
		TransitionState.INITIAL:
			current_transition_state = TransitionState.RESULTS_TEXT
			$TextTimer.start()
			pass
		TransitionState.RESULTS_TEXT:
			current_transition_state = TransitionState.GRADE_TEXT
			pass
		TransitionState.GRADE_TEXT:
			pass # Display continue button
