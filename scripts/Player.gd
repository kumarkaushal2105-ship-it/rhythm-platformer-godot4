extends CharacterBody2D

enum Mode { CUBE, SHIP, BALL, WAVE }

var speed: float = 400.0
var base_jump_force: float = -600.0
var gravity: float = 1200.0
var current_mode: Mode = Mode.CUBE
var can_jump: bool = true
var is_alive: bool = true
var velocity_y: float = 0.0
var wave_time: float = 0.0
var wave_amplitude: float = 50.0
var wave_frequency: float = 3.0

var jump_input_buffered: bool = false
var jump_input_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0

var collision_shape: CollisionShape2D
var sprite: Sprite2D
var particles: GPUParticles2D

signal player_died
signal mode_changed(new_mode: Mode)
signal jumped

func _ready() -> void:
	create_visuals()

func create_visuals() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)
	sprite.scale = Vector2(0.8, 0.8)
	update_visual_mode()
	
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	collision_shape.shape = BoxShape2D.new()
	collision_shape.shape.size = Vector2(30, 30)
	
	particles = GPUParticles2D.new()
	add_child(particles)
	particles.emitting = false

func _process(delta: float) -> void:
	if not is_alive:
		return
	
	if jump_input_buffered:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0:
			jump_input_buffered = false
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_input_buffered = true
		jump_buffer_timer = jump_input_buffer_time
	
	match current_mode:
		Mode.CUBE:
			update_cube_mode(delta)
		Mode.SHIP:
			update_ship_mode(delta)
		Mode.BALL:
			update_ball_mode(delta)
		Mode.WAVE:
			update_wave_mode(delta)
	
	if current_mode != Mode.SHIP and current_mode != Mode.WAVE:
		velocity_y += gravity * delta

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	velocity = Vector2(speed, velocity_y)
	velocity = move_and_slide()
	
	if global_position.y > 800:
		die()
	
	LevelManager.update_progress(global_position.x)

func update_cube_mode(delta: float) -> void:
	if is_on_floor():
		can_jump = true
	else:
		can_jump = false
	
	if jump_input_buffered and can_jump:
		jump_input_buffered = false
		perform_jump()

func update_ship_mode(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		velocity_y = -400.0
	else:
		velocity_y += gravity * 0.5 * delta

func update_ball_mode(delta: float) -> void:
	if is_on_floor():
		can_jump = true
	else:
		can_jump = false
	
	if jump_input_buffered and can_jump:
		jump_input_buffered = false
		perform_jump(base_jump_force * 1.2)

func update_wave_mode(delta: float) -> void:
	wave_time += delta * wave_frequency
	velocity_y = sin(wave_time) * wave_amplitude

func perform_jump(jump_force: float = 0.0) -> void:
	if jump_force == 0.0:
		jump_force = base_jump_force
	
	velocity_y = jump_force
	can_jump = false
	jumped.emit()
	
	if particles:
		particles.restart()

func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	update_visual_mode()
	mode_changed.emit(new_mode)

func update_visual_mode() -> void:
	if not sprite:
		return
	
	match current_mode:
		Mode.CUBE:
			sprite.modulate = Color.from_string("#00FF00", Color.WHITE)
		Mode.SHIP:
			sprite.modulate = Color.from_string("#FF0000", Color.WHITE)
		Mode.BALL:
			sprite.modulate = Color.from_string("#0080FF", Color.WHITE)
		Mode.WAVE:
			sprite.modulate = Color.from_string("#FFD700", Color.WHITE)

func die() -> void:
	is_alive = false
	player_died.emit()
	GameManager.restart_level()

func set_gravity_inverted(inverted: bool) -> void:
	gravity = -1200.0 if inverted else 1200.0

func set_speed_multiplier(multiplier: float) -> void:
	speed = 400.0 * multiplier
