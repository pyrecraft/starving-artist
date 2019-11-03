extends Node

const DEBUG_MODE = false
const SCREEN_RECORD_MODE = false

enum State {
	PAINT,
	CONFIRM_CLEAR,
	CLEAR,
	STORE,
	CONFIRM_SELL,
	SELL,
	NEXT_DAY,
	NEWS,
	STORE,
	GAME_OVER
}

enum Criteria {
	LARGE_COVERAGE,
	LOW_COVERAGE,
	DARK_COLORS,
	LIGHT_COLORS,
	COLOR_VARIETY,
	RED_COLORS,
	BLUE_COLORS,
	GREEN_COLORS,
	LEFT_COVERAGE,
	RIGHT_COVERAGE
}

enum ConfirmBox {
	CLEAR,
	SELL
}

func initialize_paint_grid():
	var grid = []
	for y in range(get_viewport().size.y):
		grid.append([])
		for x in range(get_viewport().size.x):
			grid[y].append(null)
			x += 1
	return grid

func get_next_mission(day):
	
	match day:
		1:
#			print('LARGE_COVERAGE')
			return Mission.new(Headlines.get_headline(Criteria.LARGE_COVERAGE), Criteria.LARGE_COVERAGE, 100)
		2:
#			print('RED_COLORS')
			return Mission.new(Headlines.get_headline(Criteria.RED_COLORS), Criteria.LARGE_COVERAGE, 100)
		3:
#			print('BLUE_COLORS')
			return Mission.new(Headlines.get_headline(Criteria.BLUE_COLORS), Criteria.BLUE_COLORS, 150)
		4:
#			print('LIGHT_COLORS')
			return Mission.new(Headlines.get_headline(Criteria.LIGHT_COLORS), Criteria.LIGHT_COLORS, 200)
		5:
#			print('COLOR_VARIETY')
			return Mission.new(Headlines.get_headline(Criteria.COLOR_VARIETY), Criteria.COLOR_VARIETY, 250)
		6:
#			print('DARK_COLORS')
			return Mission.new(Headlines.get_headline(Criteria.DARK_COLORS), Criteria.DARK_COLORS, 300)
		7:
#			print('LEFT_COVERAGE')
			return Mission.new(Headlines.get_headline(Criteria.LEFT_COVERAGE), Criteria.LEFT_COVERAGE, 350)
		8:
#			print('LOW_COVERAGE')
			return Mission.new(Headlines.get_headline(Criteria.LOW_COVERAGE), Criteria.LOW_COVERAGE, 375)
		9:
#			print('RIGHT_COVERAGE')
			return Mission.new(Headlines.get_headline(Criteria.RIGHT_COVERAGE), Criteria.RIGHT_COVERAGE, 400)
		10:
#			print('GREEN_COLORS')
			return Mission.new(Headlines.get_headline(Criteria.GREEN_COLORS), Criteria.GREEN_COLORS, 750)
		11:
#			print('ENDING')
			return Mission.new(Headlines.ENDING_HEADLINES, Criteria.GREEN_COLORS, 999)

class Mission:
	var main_headline
	var lower_headline
	var side_headline
	var criteria
	var max_payout
	
	func _init(headlines_arr, c, mp):
		main_headline = headlines_arr[0]
		lower_headline = headlines_arr[1]
		side_headline = headlines_arr[2]
		criteria = c
		max_payout = mp