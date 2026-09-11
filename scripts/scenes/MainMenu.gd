extends Control

func _ready() -> void:
	%PlayButton.pressed.connect(func(): GameManager.load_level(1))
	%LevelSelectButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level_select.tscn"))
	%ExitButton.pressed.connect(func(): get_tree().quit())
