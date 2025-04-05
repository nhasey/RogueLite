extends CharacterBody3D

const FLOOR_NORMAL = Vector3.UP

@export var speed := 7.0
@export var gravity := 30.0
@export var jump_force := 12.0
@export var max_hp: int = 100
var current_hp: int = max_hp

var velocity_y := 0.0

@onready var sprite: Sprite3D = $RotationOffset/Sprite3D
@onready var hp_bar: TextureProgressBar = $"../CanvasLayer/UIRoot/HPBar"  # Adjust path if needed

var texture_idle: Texture2D
var texture_walk: Texture2D
var texture_walk_left: Texture2D
var texture_walk_right: Texture2D
var texture_walk_down: Texture2D


func _ready():
	# Load your textures
	texture_idle = load("res://assets/textures/pixelGuy/pixelGuy.png")
	texture_walk = load("res://assets/textures/pixelGuy/pixelGuy2.png")
	texture_walk_left = load("res://assets/textures/pixelGuy/pixelGuyLeft.png")
	texture_walk_right = load("res://assets/textures/pixelGuy/pixelGuyRight.png")
	texture_walk_down = load("res://assets/textures/pixelGuy/pixelGuyDown.png")
	
	
	sprite.texture = texture_idle
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func _physics_process(delta: float) -> void:
	var direction_ground := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	# Apply gravity
	if not is_on_floor():
		velocity_y -= gravity * delta

	# Set movement velocity
	var velocity = Vector3(
		direction_ground.x * speed,
		velocity_y,
		direction_ground.y * speed
	)
	set_velocity(velocity)
	set_up_direction(FLOOR_NORMAL)
	move_and_slide()

	# If player falls below y = 0, respawn at origin
	if global_transform.origin.y < 0:
		#global_transform.origin = Vector3(0, 0, 0)
		#velocity_y = 0.0
		take_damage(2)  # Optional: take fall damage when falling into the void

	# Reset Y velocity if grounded or ceiling-hit
	if is_on_floor() or is_on_ceiling():
		velocity_y = 0.0

	# 🔁 Sprite switching based on movement
	# 🔁 Sprite switching based on movement
	if direction_ground.length() > 0.01:
		if abs(direction_ground.x) > abs(direction_ground.y):
			if direction_ground.x > 0:
				sprite.texture = texture_walk_right
			else:
				sprite.texture = texture_walk_left
		else:
			sprite.texture = texture_walk_down
	else:
		sprite.texture = texture_idle

	# Update HP bar every frame (in case HP changes)
	hp_bar.value = current_hp

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		velocity_y = jump_force

# 🩸 Take damage function
func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	if current_hp == 0:
		die()

# 💊 Heal function
func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)

# 💀 Die function
func die() -> void:
	print("You died!")
	global_transform.origin = Vector3(0, 0, 0)  # Respawn
	current_hp = max_hp  # Reset HP
