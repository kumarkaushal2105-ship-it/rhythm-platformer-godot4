extends Control

func _ready() -> void:
	%Level1.pressed.connect(func(): GameManager.load_level(1))
	%Level2.pressed.connect(func(): GameManager.load_level(2))
	%Level3.pressed.connect(func(): GameManager.load_level(3))
	%BackButton.pressed.connect(func(): GameManager.go_to_main_menu())
