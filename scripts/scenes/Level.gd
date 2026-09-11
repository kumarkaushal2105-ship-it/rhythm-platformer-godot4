extends Node2D

var level_num: int = 1
var player: CharacterBody2D
var obstacles_container: Node
var level_data: Dictionary
var completion_check_timer: float = 0.0

func _ready() -> void:
	level_data = LevelManager.load_level_data(level_num)
	LevelManager.level_width = level_data["length"]
	
	player = get_node("Player")
	obstacles_container = get_node("Obstacles")
	
	if player:
		player.add_to_group("player")
		player.player_died.connect(_on_player_died)
		var camera = player.get_node("Camera2D")
		if camera:
			camera.make_current()
	
	# Create obstacles from level data
	for obstacle_data in level_data["obstacles"]:
		var obstacle = Obstacle.new()
		obstacles_container.add_child(obstacle)
		var pos = Vector2(obstacle_data["x"], obstacle_data.get("y", 400))
		obstacle.create_obstacle(obstacle_data, pos)
	
	# Setup UI
	var progress_label = get_node("UI/UIControl/ProgressLabel")
	var attempts_label = get_node("UI/UIControl/AttemptsLabel")
	var pause_btn = get_node("UI/UIControl/PauseButton")
	
	if pause_btn:
		pause_btn.pressed.connect(func(): GameManager.toggle_pause())
	
	LevelManager.progress_updated.connect(func(progress: float):
		if progress_label:
			progress_label.text = "Progress: %.0f%%" % progress
	)
	
	GameManager.attempt_updated.connect(func(attempts: int):
		if attempts_label:
			attempts_label.text = "Attempts: %d" % attempts
	)

func _process(delta: float) -> void:
	if player and player.is_alive:
		completion_check_timer += delta
		if completion_check_timer > 0.5:
			completion_check_timer = 0.0
			if player.global_position.x >= level_data["length"]:
				GameManager.complete_level()

func _on_player_died() -> void:
	pass

func load_obstacle_class() -> Script:
	return load("res://scripts/Obstacle.gd")
