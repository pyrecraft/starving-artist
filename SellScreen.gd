extends Node2D

var initial_state = load('res://godot_redux/initial_state.gd')
const newspaper = preload('res://Newspaper.tscn')
const button_inst = preload('res://Button.tscn')
const waku_font = preload('res://WakuWakuFont.tres')
const text_color = Color('#fbf0f0')
const text_shadow_color = Color('#393e46')

var font_position = Vector2(0, 0)
var current_transition_state = TransitionState.INITIAL
var dot_count = 1
var skip_counter = 0

enum TransitionState {
	INITIAL,
	RESULTS_TEXT,
	RESULTS_DOTS_TEXT,
	MONEY_TEXT,
	GRADE_TEXT,
	GRADE_SHOW,
	FINISHED
}

var dimensions_L = Vector2(0, 0)
var starting_vector_L = Vector2(0, 0)
var state_L
var grid_L
var money_L
var day_L

var sale_price
var letter_grade
var played_grade_sound = false

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	dimensions_L = store.get_state()['canvas']['dimensions']
	starting_vector_L = store.get_state()['canvas']['starting_vector']
	state_L = store.get_state()['game']['state']
	grid_L = store.get_state()['canvas']['grid']
	money_L = store.get_state()['game']['money']
	day_L = store.get_state()['game']['day']
	font_position = get_starting_font_position()
	clear_text()
	$TransitionTimer.start()
	var painting_info = SaleLogic.get_painting_sale_info()
	sale_price = painting_info[0]
	letter_grade = painting_info[1]
	$ThanksText.hide()

func spawn_next_button():
	var continue_button = button_inst.instance()
	add_child(continue_button)
	continue_button.set_box_position(Vector2(850, 675))
	continue_button.set_text('Next')
	continue_button.set_text_offset_x(20)
#	continue_button.set_colors(Color('#62d2a2'), Color('#33b37c'))
	continue_button.set_colors(Color('#07689f'), Color('#055887'))
	continue_button.connect("clicked", self, "_on_ContinueButton_clicked")

func _on_ContinueButton_clicked():
	store.dispatch(actions.game_set_day(day_L + 1))
	store.dispatch(actions.game_set_mission(Constants.get_next_mission(day_L)))
	store.dispatch(actions.game_set_state(Constants.State.CLEAR))
#	store.dispatch(actions.game_set_state(Constants.State.PAINT))
#	store.dispatch(actions.canvas_set_grid(Constants.initialize_paint_grid_debug()))
	queue_free()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['canvas']['dimensions'] != null:
		dimensions_L = store.get_state()['canvas']['dimensions']
	if store.get_state()['canvas']['starting_vector'] != null:
		starting_vector_L = store.get_state()['canvas']['starting_vector']
	if store.get_state()['canvas']['grid'] != null:
		grid_L = store.get_state()['canvas']['grid']
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']
	if store.get_state()['game']['money'] != null:
		money_L = store.get_state()['game']['money']
	if store.get_state()['game']['day'] != null:
		day_L = store.get_state()['game']['day']

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
				if $ResultsText.visible_characters % 2 == 0:
					$TextAudioStreamPlayer.play()
			else:
				current_transition_state = TransitionState.RESULTS_DOTS_TEXT
		TransitionState.RESULTS_DOTS_TEXT:
			skip_counter += 1
			if skip_counter % 4 != 0:
				return
			if dot_count == 12:
				current_transition_state = TransitionState.MONEY_TEXT
				$ResultsText.bbcode_text = $ResultsText.bbcode_text + ' ' + get_price_bb_code(sale_price)
				$ResultsText.visible_characters += 1
				store.dispatch(actions.game_set_money(money_L + int(sale_price)))
				play_money_sound(letter_grade)
			elif dot_count % 4 == 0 and dot_count != 0:
				$ResultsText.visible_characters -= 3
				$ResultsText.bbcode_text = $ResultsText.bbcode_text.substr(0, $ResultsText.bbcode_text.length() - 3)
			else:
				$ResultsText.bbcode_text = $ResultsText.bbcode_text + '.'
				$ResultsText.visible_characters += 1
			dot_count += 1
		TransitionState.MONEY_TEXT:
			if results_has_text_to_display():
				$ResultsText.visible_characters += 1
				if $ResultsText.visible_characters % 2 == 0:
					$TextAudioStreamPlayer.play()
			elif $TransitionTimer.is_stopped():
				$TransitionTimer.start()
		TransitionState.GRADE_TEXT:
			if grade_has_text_to_display():
				$GradeText.visible_characters += 1
				if $GradeText.visible_characters % 2 == 0:
					$TextAudioStreamPlayer.play()
			elif $TransitionTimer.is_stopped():
				$TransitionTimer.start()
		TransitionState.GRADE_SHOW:
			if grade_has_text_to_display():
				$GradeText.visible_characters += 1
				if !played_grade_sound:
					if letter_grade == 'A+' or letter_grade == 'A':
						$AudioStreamPlayer.play()
					elif letter_grade == 'B+' or letter_grade == 'B':
						$AudioStreamPlayer2.play()
					else:
						$TextAudioStreamPlayer.play()
				played_grade_sound = true
				
			elif $TransitionTimer.is_stopped():
				$TransitionTimer.start()

func play_money_sound(grade):
	match grade:
		'A+':
			$AudioStreamPlayer.play()
		'A':
			$AudioStreamPlayer.play()
		'B+':
			$AudioStreamPlayer2.play()
		'B':
			$AudioStreamPlayer2.play()
		'C+':
			$AudioStreamPlayer2.play()
		'C':
			$AudioStreamPlayer2.play()
		'D':
			$TextAudioStreamPlayer.play()
		'F':
			$TextAudioStreamPlayer.play()
	

func get_grade_bb_code(grade):
	match grade:
		'A+':
			return '[color=#62d2a2]%s[/color]' % grade
		'A':
			return '[color=#3ec78c]%s[/color]' % grade
		'B+':
			return '[color=#fce38a]%s[/color]' % grade
		'B':
			return '[color=#fad550]%s[/color]' % grade
		'C+':
			return '[color=#f08a5d]%s[/color]' % grade
		'C':
			return '[color=#eb682f]%s[/color]' % grade
		'D':
			return '[color=#f85f73]%s[/color]' % grade
		'F':
			return '[color=#f52d47]%s[/color]' % grade

func get_price_bb_code(price):
	var str_amount = str(int(price))
	return '[color=#62d2a2]$%s[/color]' % str_amount

func _on_TransitionTimer_timeout():
	match current_transition_state:
		TransitionState.INITIAL:
			current_transition_state = TransitionState.RESULTS_TEXT
			$TextTimer.start()
			pass
		TransitionState.RESULTS_TEXT:
			current_transition_state = TransitionState.GRADE_TEXT
			pass
		TransitionState.MONEY_TEXT:
			current_transition_state = TransitionState.GRADE_TEXT
			pass
		TransitionState.GRADE_TEXT:
			$GradeText.bbcode_text = $GradeText.bbcode_text + get_grade_bb_code(letter_grade)
			current_transition_state = TransitionState.GRADE_SHOW
		TransitionState.GRADE_SHOW:
			if day_L < 11:
				spawn_next_button()
			else:
#				$ThanksText.show()
				var news = newspaper.instance()
				add_child(news)
			current_transition_state = TransitionState.FINISHED
		TransitionState.FINISHED:
			pass