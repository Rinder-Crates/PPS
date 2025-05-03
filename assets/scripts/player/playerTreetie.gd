# Notes in case I ever give this to anyone...
# Gliding CAN NOT occur after an airborn, until hitting floor again
# Airborn CAN NOT happen mid-air
# Yes, i'm conscious there's unused stuff here and there, i'll remove em later
# I hate realism in games

extends CharacterBody2D

signal anim_state_changed(state: String)
var anim_state := ""

# == Constants ==
const NORMAL_GRAVITY = 2000.0
const GLIDE_GRAVITY = 3.0
const GLIDE_FALL_CAP = 80.0
const FALL_CAP = 2200.0
const TOP_SPEED = 500.0
const JUMP_FORCE = -800.0
const COYOTE_TIME = 0.2
const AIRBORN_VELOCITY = -1350.0
const GLIDE_HORIZONTAL_DAMPING = 0.5
const LOOK_HOLD_DELAY = 0.5
const LOOK_OFFSET = 275.0
const LOOK_LERP_SPEED = 5.0
const RUNNING_MULTIPLIER = 1.75
const CAMERA_ZOOM_IN = 0.8
const CAMERA_ZOOM_OUT = 1.0
const CAMERA_ZOOM_LERP_SPEED = 5.0
const AIR_DASH_ALLOWED = true

# == Variables ==

var respawn_position: Vector2

var gravity = 1200.0
var acceleration = 1300.0
var deceleration = 1500.0
var jump_type: String = ""
var coyote_timer = 0.0
var canAirborn = true
var canDoubleJump = true
var canGlide = true
var look_up_timer = 0.0
var look_down_timer = 0.0
var target_offset_y = 0.0
var cam_wobble_offset = 10.0
var cam_current_offset = Vector2.ZERO
var cam_offset_amount_x = 300.0
var last_move_direction = 0.0
var current_zoom = CAMERA_ZOOM_OUT
var isFalling = false

var current_health = 100.0

@onready var floor_snap_vector = Vector2.DOWN

@onready var cam = $Camera2D
@onready var player_health = $CanvasLayer/HealthBar/TextureProgressBar

func _ready():
	add_to_group("player")
	
func _physics_process(delta: float) -> void:
	
	floor_snap_length = 6.0
	
	handle_gravity(delta)
	handle_jumping(delta)
	handle_horizontal_movement(delta)
	handle_camera(delta)
	handle_look_direction(delta)
	handle_animation_state()
	move_and_slide()

func handle_gravity(delta: float) -> void:
	var is_gliding = Input.is_action_pressed("glide") and not is_on_floor() and velocity.y > 0 and canGlide

	if is_gliding:
		handle_gliding(delta)
		return  # completely skip the rest of gravity handling

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if velocity.y > 0:
		isFalling = true
		jump_type = "falling"

	if is_on_floor():
		canDoubleJump = true
		isFalling = false
		canAirborn = false
		canGlide = true
		coyote_timer = 0.0
		jump_type = ""
	else:
		coyote_timer += delta
		velocity.y += NORMAL_GRAVITY * delta
		velocity.y = min(velocity.y, FALL_CAP)
		
func handle_gliding(delta: float) -> void:
	# Apply a consistent glide fall speed
	velocity.y = move_toward(velocity.y, FALL_CAP * 0.25, GLIDE_GRAVITY * delta)
	velocity.x *= GLIDE_HORIZONTAL_DAMPING
	canGlide = false

func handle_jumping(_delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer < COYOTE_TIME:
			if Input.is_action_pressed("look-up"):
				velocity.y = AIRBORN_VELOCITY
				canAirborn = false
				canDoubleJump = false
				canGlide = false
				jump_type = "airborn"
			else:
				velocity.y = JUMP_FORCE
				canAirborn = true
				canDoubleJump = true
				jump_type = "jump"
			coyote_timer = 0.0
		elif canDoubleJump:
			velocity.y = JUMP_FORCE
			canDoubleJump = false
			jump_type = "double_jump"
			coyote_timer = 0.0

func handle_horizontal_movement(delta: float) -> void:
	var direction = Input.get_axis("move-left", "move-right")
	var is_gliding = Input.is_action_pressed("glide") and not is_on_floor() and velocity.y > 0 and canAirborn
	var is_running = Input.is_action_pressed("run")
	
	var damping = GLIDE_HORIZONTAL_DAMPING if is_gliding else 1.0
	var speed_target = direction * TOP_SPEED * (RUNNING_MULTIPLIER if is_running else 1.0)
	var accel = (acceleration if direction != 0 else deceleration) * damping
	
	velocity.x = move_toward(velocity.x, speed_target, accel * delta)

	if direction != 0:
		last_move_direction = direction

func handle_camera(delta: float) -> void:
	var is_running = Input.is_action_pressed("run")
	var target_zoom = CAMERA_ZOOM_IN if is_running else CAMERA_ZOOM_OUT
	current_zoom = lerp(current_zoom, target_zoom, CAMERA_ZOOM_LERP_SPEED * delta)
	cam.zoom = Vector2(current_zoom, current_zoom)

	var target_offset_x = float(last_move_direction) * (400.0 if is_running else 300.0)
	cam_current_offset.x = lerp(cam_current_offset.x, target_offset_x, delta * 3.0)
	cam_current_offset.y = lerp(cam_current_offset.y, float(target_offset_y), delta * LOOK_LERP_SPEED)

	cam.offset = cam_current_offset

func handle_look_direction(delta: float) -> void:
	var is_moving = Input.get_axis("move-left", "move-right") != 0
	var can_look = not is_moving or velocity.y >= 0.1

	if can_look:
		look_up_timer = look_up_timer + delta if Input.is_action_pressed("look-up") else 0.0
		look_down_timer = look_down_timer + delta if Input.is_action_pressed("look-down") else 0.0
	else:
		look_up_timer = 0.0
		look_down_timer = 0.0

	target_offset_y = (-LOOK_OFFSET if look_up_timer >= LOOK_HOLD_DELAY else 
						LOOK_OFFSET if look_down_timer >= LOOK_HOLD_DELAY else 
						0.0)
						
		
func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	player_health.value = current_health
	
func set_checkpoint(position: Vector2):
	respawn_position = position
	
func kill_or_respawn():
	global_position = respawn_position


func handle_animation_state() -> void:
	var is_gliding = Input.is_action_pressed("glide") and not is_on_floor() and velocity.y > 0 and canAirborn

	if is_gliding:
		set_anim_state("glide")
	elif not is_on_floor():
		if jump_type != "":
			set_anim_state(jump_type)
		else:
			set_anim_state("jump")
	elif abs(velocity.x) > 20:
		set_anim_state("walk")
	else:
		set_anim_state("idle")

func set_anim_state(state: String) -> void:
	if anim_state != state:
		anim_state = state
		emit_signal("anim_state_changed", state)
