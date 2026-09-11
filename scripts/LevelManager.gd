extends Node

# Level management and progression
var current_level_data: Dictionary
var level_obstacles: Array = []
var level_portals: Array = []
var player_progress: float = 0.0
var level_width: float = 0.0

signal progress_updated(progress: float)
signal level_loaded(level_num: int)

func _ready() -> void:
	pass

func load_level_data(level_num: int) -> Dictionary:
	match level_num:
		1:
			return create_level_1()
		2:
			return create_level_2()
		3:
			return create_level_3()
		_:
			return create_level_1()

func create_level_1() -> Dictionary:
	return {
		"name": "Chromatic Surge",
		"music": "res://assets/music/level_1.ogg",
		"difficulty": 1,
		"length": 5000.0,
		"obstacles": [
			{"type": "spike", "x": 800, "y": 400},
			{"type": "spike", "x": 1200, "y": 400},
			{"type": "gap", "x": 1600, "y": 400, "width": 300},
			{"type": "jump_pad", "x": 2000, "y": 400},
			{"type": "spike", "x": 2400, "y": 400},
		]
	}

func create_level_2() -> Dictionary:
	return {
		"name": "Nexus Flow",
		"music": "res://assets/music/level_2.ogg",
		"difficulty": 2,
		"length": 7000.0,
		"obstacles": [
			{"type": "spike", "x": 800, "y": 400},
			{"type": "jump_pad", "x": 1200, "y": 400},
			{"type": "mode_portal", "x": 1600, "y": 400, "mode": "ball"},
			{"type": "gap", "x": 2000, "y": 400, "width": 300},
			{"type": "spike", "x": 2500, "y": 400},
		]
	}

func create_level_3() -> Dictionary:
	return {
		"name": "Eternal Cascade",
		"music": "res://assets/music/level_3.ogg",
		"difficulty": 3,
		"length": 9000.0,
		"obstacles": [
			{"type": "spike", "x": 600, "y": 400},
			{"type": "jump_pad", "x": 900, "y": 400},
			{"type": "mode_portal", "x": 1300, "y": 400, "mode": "wave"},
			{"type": "gap", "x": 1700, "y": 400, "width": 350},
			{"type": "spike", "x": 2150, "y": 400},
		]
	}

func update_progress(player_x: float) -> void:
	if level_width > 0:
		player_progress = min((player_x / level_width) * 100.0, 100.0)
		progress_updated.emit(player_progress)
