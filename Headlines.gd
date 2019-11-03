extends Node

const ENDING_HEADLINES = [
	'Artist Didn\'t Starve In The End! Woohoo!',
	'Made by PyreCraft for the Weekly Game Jam #120.',
	'Thanks for playing! Hope you had fun and made beautiful art.'
]

func get_headline(criteria):
	match criteria:
		Constants.Criteria.LARGE_COVERAGE:
			return [
				'Huge Mess To Clean After End of Massive War',
				'Cities Crowded Following Massive Population Growth Post-War',
				'Large Cloud Coverage in Sky Suggests Potential Incoming Storm'
			]
		Constants.Criteria.LOW_COVERAGE:
			return [
				'Time of Peace and Quiet Arises After Long War',
				'In Taiwan, protests fizzle out as both sides agree',
				'Sky Nearly Transparent As Not a Single Cloud Encroaches'
			]
		Constants.Criteria.DARK_COLORS:
			return [
				'Cold War Casts Shadow Over Future of Mankind',
				'A coal mine explosion in Centralia, Illinois kills 100',
				'Large Clouds Indicative of Potential Hurricane Approaching'
			]
		Constants.Criteria.LIGHT_COLORS:
			return [
				'Axis Evils Erased, Leading to Light',
				'The Bombay Municipal Corporation takes over the Bombay Electric',
				'Light Winds Approaching but Otherwise Extremely Clear Skies'
			]
		Constants.Criteria.COLOR_VARIETY:
			return [
				'Jackie Robinson Colors the World of Baseball',
				'The United Nations Meet To Discuss International Laws',
				'Mixed Skies - Sunshine, Rain, Snow All Possibilities'
			]
		Constants.Criteria.RED_COLORS:
			return [
				'Communist Flags Bright and Broken',
				'The new post-war Japanese constitution goes into effect',
				'Large Fires Arise Advising Citizens to Beware'
			]
		Constants.Criteria.BLUE_COLORS:
			return [
				'A WWII booby trap explodes in ocean by Japan',
				'Linda B. Buck, biologist, Wins Nobel Prize',
				'Clear Skies, Blue and Beautiful. Not a cloud in sight!'
			]
		Constants.Criteria.GREEN_COLORS:
			return [
				'National Campaign Seeks to Criminalize "Evil Weed"',
				'Bretton Woods Establishes New Global Monetary System',
				'Fires Erupt in Wine Country, Burning Trees'
			]
		Constants.Criteria.LEFT_COVERAGE:
			return [
				'Left-Wing Leader Shines Against Communist Party',
				'Democratically-elected Prime Minister of Hungary resigns',
				'6.7 Earthquake rattles Wine Country in the Pacific West'
			]
		Constants.Criteria.RIGHT_COVERAGE:
			return [
				'Republican Dwight Eisenhower Fights On',
				'The International Fund Now Operates in Eastern Europe',
				'Early Season Snowstorm Slows East Coast Commuters'
			]
	return []