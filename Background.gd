extends Node2D

const initial_state = preload('res://godot_redux/initial_state.gd')

#var background_color = Color('#ffb5b5') <Pink>
#var brick_color = Color('#db7d8a') <Pink>
var background_color = Color('#2a363b')
var brick_color = Color('#52616b')

var state_L

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	var init_state = initial_state.get_state()
	state_L = init_state['game']['state']

func _process(delta: float) -> void:
	if state_L == Constants.State.SELL:
		$"background-bricks".hide()
	elif !$"background-bricks".visible:
		$"background-bricks".show()

#func _draw():
#	return # Don't render bricks
#	var viewport_size = get_viewport().size
#	draw_rect(Rect2(Vector2(0, 0), viewport_size), background_color)
#	if state_L != Constants.State.SELL:
#		draw_bricks()
#		pass

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['state'] != null:
		state_L = store.get_state()['game']['state']
		if state_L == Constants.State.SELL:
			update()

func draw_bricks():
	var viewport_size = get_viewport().size
	viewport_size.y *= .70
	var brick_offset_x = 25
	var brick_offset_y = 25
	var brick_base_height = 25
	var brick_base_length = 50
	var edge_offset = 15
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
			if x + brick_length + (brick_offset_x * 2) > viewport_size.x:
				brick_length = viewport_size.x - x - edge_offset
			if y + brick_base_height + (brick_offset_y * 2) > viewport_size.y:
				brick_height = viewport_size.y - y - edge_offset
			if brick_length < 0.3:
				break
			if brick_height < 1:
				break
			var brick_box = Rect2(Vector2(x, y), Vector2(brick_length, brick_height))
			draw_rounded_rect(brick_box, brick_color, 8)
			x += brick_length + brick_offset_x
		y += brick_base_height + brick_offset_y

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)