extends Node

# Game state management
var current_level: int = 1
var total_levels: int = 3
var current_attempts: int = 0
var best_times: Dictionary = {}
var game_paused: bool = false
var level_completed: bool = false

signal level_restarted
signal level_completed_signal
signal pause_toggled(paused: bool)
signal attempt_updated(attempts: int)

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not level_completed:
		toggle_pause()

func toggle_pause() -> void:
	game_paused = !game_paused
	get_tree().paused = game_paused
	pause_toggled.emit(game_paused)

func restart_level() -> void:
	current_attempts += 1
	attempt_updated.emit(current_attempts)
	get_tree().paused = false
	game_paused = false
	level_restarted.emit()
	get_tree().reload_current_scene()

func complete_level() -> void:
	level_completed = true
	if current_level not in best_times:
		best_times[current_level] = current_attempts
	else:
		best_times[current_level] = min(best_times[current_level], current_attempts)
	level_completed_signal.emit()

func load_level(level_num: int) -> void:
	current_level = level_num
	current_attempts = 0
	level_completed = false
	get_tree().paused = false
	game_paused = false
	attempt_updated.emit(current_attempts)
	match level_num:
		1:
			get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
		2:
			get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
		3:
			get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")

func go_to_main_menu() -> void:
	get_tree().paused = false
	game_paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_level_select() -> void:
	get_tree().paused = false
	game_paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
