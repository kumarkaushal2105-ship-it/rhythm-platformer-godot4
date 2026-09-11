extends Node

var ui_root: CanvasLayer
var pause_menu: Control
var hud: Control
var completion_screen: Control

func _ready() -> void:
	ui_root = CanvasLayer.new()
	add_child(ui_root)
	ui_root.layer = 100
	
	GameManager.pause_toggled.connect(_on_pause_toggled)
	GameManager.level_completed_signal.connect(_on_level_completed)
	
	create_hud()

func create_hud() -> void:
	hud = Control.new()
	ui_root.add_child(hud)
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	
	var progress_label = Label.new()
	hud.add_child(progress_label)
	progress_label.text = "Progress: 0%"
	progress_label.position = Vector2(20, 20)
	progress_label.add_theme_font_size_override("font_sizes/font_size", 24)
	
	var attempts_label = Label.new()
	hud.add_child(attempts_label)
	attempts_label.text = "Attempts: 0"
	attempts_label.position = Vector2(20, 60)
	attempts_label.add_theme_font_size_override("font_sizes/font_size", 24)
	
	var pause_button = Button.new()
	hud.add_child(pause_button)
	pause_button.text = "PAUSE"
	pause_button.position = Vector2(1100, 20)
	pause_button.size = Vector2(160, 50)
	pause_button.pressed.connect(func(): GameManager.toggle_pause())
	
	LevelManager.progress_updated.connect(func(progress: float): 
		progress_label.text = "Progress: %.0f%%" % progress
	)
	
	GameManager.attempt_updated.connect(func(attempts: int):
		attempts_label.text = "Attempts: %d" % attempts
	)

func create_pause_menu() -> void:
	pause_menu = Control.new()
	ui_root.add_child(pause_menu)
	pause_menu.anchor_right = 1.0
	pause_menu.anchor_bottom = 1.0
	
	var panel = PanelContainer.new()
	pause_menu.add_child(panel)
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title = Label.new()
	vbox.add_child(title)
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_sizes/font_size", 48)
	
	var resume_btn = Button.new()
	vbox.add_child(resume_btn)
	resume_btn.text = "Resume"
	resume_btn.size = Vector2(200, 60)
	resume_btn.pressed.connect(func(): GameManager.toggle_pause())
	
	var restart_btn = Button.new()
	vbox.add_child(restart_btn)
	restart_btn.text = "Restart Level"
	restart_btn.size = Vector2(200, 60)
	restart_btn.pressed.connect(func(): GameManager.restart_level())
	
	var menu_btn = Button.new()
	vbox.add_child(menu_btn)
	menu_btn.text = "Main Menu"
	menu_btn.size = Vector2(200, 60)
	menu_btn.pressed.connect(func(): GameManager.go_to_main_menu())

func create_completion_screen() -> void:
	completion_screen = Control.new()
	ui_root.add_child(completion_screen)
	completion_screen.anchor_right = 1.0
	completion_screen.anchor_bottom = 1.0
	
	var panel = PanelContainer.new()
	completion_screen.add_child(panel)
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title = Label.new()
	vbox.add_child(title)
	title.text = "LEVEL COMPLETE!"
	title.add_theme_font_size_override("font_sizes/font_size", 48)
	
	var attempts_label = Label.new()
	vbox.add_child(attempts_label)
	attempts_label.text = "Attempts: %d" % GameManager.current_attempts
	attempts_label.add_theme_font_size_override("font_sizes/font_size", 32)
	
	var next_btn = Button.new()
	vbox.add_child(next_btn)
	next_btn.text = "Next Level"
	next_btn.size = Vector2(200, 60)
	next_btn.pressed.connect(func(): 
		if GameManager.current_level < GameManager.total_levels:
			GameManager.load_level(GameManager.current_level + 1)
		else:
			GameManager.go_to_level_select()
	)
	
	var menu_btn = Button.new()
	vbox.add_child(menu_btn)
	menu_btn.text = "Level Select"
	menu_btn.size = Vector2(200, 60)
	menu_btn.pressed.connect(func(): GameManager.go_to_level_select())

func _on_pause_toggled(paused: bool) -> void:
	if paused:
		if not pause_menu:
			create_pause_menu()
		pause_menu.visible = true
	else:
		if pause_menu:
			pause_menu.visible = false

func _on_level_completed() -> void:
	if not completion_screen:
		create_completion_screen()
	completion_screen.visible = true
