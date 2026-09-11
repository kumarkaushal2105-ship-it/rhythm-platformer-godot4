extends Area2D

enum ObstacleType { SPIKE, GAP, JUMP_PAD, JUMP_RING, GRAVITY_PORTAL, SPEED_PORTAL, MODE_PORTAL }

var obstacle_type: ObstacleType = ObstacleType.SPIKE
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var mode_to_switch: String = "cube"
var glow_intensity: float = 0.0
var glow_direction: float = 1.0

func _ready() -> void:
	create_visuals()
	add_to_group("obstacles")
	area_entered.connect(_on_area_entered)

func create_visuals() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)
	sprite.scale = Vector2(0.6, 0.6)
	update_visual()
	
	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	collision_shape.shape = BoxShape2D.new()

func update_visual() -> void:
	if not sprite:
		return
	
	match obstacle_type:
		ObstacleType.SPIKE:
			sprite.modulate = Color.from_string("#FF3333", Color.WHITE)
			collision_shape.shape.size = Vector2(20, 40)
		ObstacleType.GAP:
			sprite.modulate = Color.from_string("#1a1a2e", Color.WHITE)
			collision_shape.shape.size = Vector2(300, 10)
		ObstacleType.JUMP_PAD:
			sprite.modulate = Color.from_string("#FF6B9D", Color.WHITE)
			collision_shape.shape.size = Vector2(40, 20)
		ObstacleType.JUMP_RING:
			sprite.modulate = Color.from_string("#00D9FF", Color.WHITE)
			collision_shape.shape.size = Vector2(50, 50)
		ObstacleType.GRAVITY_PORTAL:
			sprite.modulate = Color.from_string("#9D4EDD", Color.WHITE)
			collision_shape.shape.size = Vector2(60, 60)
		ObstacleType.SPEED_PORTAL:
			sprite.modulate = Color.from_string("#FFD60A", Color.WHITE)
			collision_shape.shape.size = Vector2(50, 50)
		ObstacleType.MODE_PORTAL:
			sprite.modulate = Color.from_string("#3A86FF", Color.WHITE)
			collision_shape.shape.size = Vector2(50, 50)

func _process(delta: float) -> void:
	if obstacle_type in [ObstacleType.GRAVITY_PORTAL, ObstacleType.SPEED_PORTAL, ObstacleType.MODE_PORTAL]:
		glow_intensity += glow_direction * delta
		if glow_intensity >= 1.0 or glow_intensity <= 0.0:
			glow_direction *= -1.0
		sprite.modulate.a = 0.5 + glow_intensity * 0.5

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player" or area.is_in_group("player"):
		match obstacle_type:
			ObstacleType.SPIKE:
				if area.has_method("die"):
					area.die()
			ObstacleType.GAP:
				if area.has_method("die"):
					area.die()
			ObstacleType.JUMP_PAD:
				if area.has_method("perform_jump"):
					area.perform_jump(-800.0)
			ObstacleType.JUMP_RING:
				if area.has_method("perform_jump"):
					area.perform_jump(-900.0)
			ObstacleType.GRAVITY_PORTAL:
				if area.has_method("set_gravity_inverted"):
					var current_gravity = area.gravity
					area.set_gravity_inverted(current_gravity > 0)
			ObstacleType.SPEED_PORTAL:
				if area.has_method("set_speed_multiplier"):
					area.set_speed_multiplier(1.5)
			ObstacleType.MODE_PORTAL:
				if area.has_method("set_mode"):
					match mode_to_switch:
						"cube":
							area.set_mode(0)
						"ship":
							area.set_mode(1)
						"ball":
							area.set_mode(2)
						"wave":
							area.set_mode(3)

func create_obstacle(obstacle_data: Dictionary, position: Vector2) -> void:
	global_position = position
	
	match obstacle_data["type"]:
		"spike":
			obstacle_type = ObstacleType.SPIKE
		"gap":
			obstacle_type = ObstacleType.GAP
		"jump_pad":
			obstacle_type = ObstacleType.JUMP_PAD
		"jump_ring":
			obstacle_type = ObstacleType.JUMP_RING
		"gravity_portal":
			obstacle_type = ObstacleType.GRAVITY_PORTAL
		"speed_portal":
			obstacle_type = ObstacleType.SPEED_PORTAL
		"mode_portal":
			obstacle_type = ObstacleType.MODE_PORTAL
			if "mode" in obstacle_data:
				mode_to_switch = obstacle_data["mode"]
	
	update_visual()
