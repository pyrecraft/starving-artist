extends Node

var GeneralPaints = [
	'#f85f73', # Red
	'#ff9a3c', # Orange
	'#f9ed69', # Yellow
	'#62d2a2', # Green
	'#07689f', # Blue
	'#a56cc1', # Purple
	'#222831', # Black
	'#ffffff' # White
]

var RandomPaints = [
	'#ffc7c7', # Peach
	'#ffe2e2', # Pink
	'#14ffec', # Bright Blue
	'#bad7df', # Gray
	'#dcedc2', # Puke Green
	'#8d6262', # Brown
	'#3a0088', # Retro Purple
	'#900048', # Cranberry
	'#f1c40f', # Puke Yellow
	'#596c68', # Dark Green/Gray
	'#fda403', # Gold
	'#3d0240', # Dark Purple
	'#11cbd7', # Sky Blue
	'#fdfdc4', # Pastel Yellow
	'#ffe8cf', # Pastel Orange
]

func get_random_paints_list():
	var paints = []
	while paints.size() < 8:
		randomize()
		var random_number = randi() % RandomPaints.size()
		var random_paint = RandomPaints[random_number]
		if !paints.has(random_paint):
			paints.append(random_paint)
	
	return paints