extends AnimatedSprite2D

const WALK_SPEED_BASE = 6.0
const WALK_SPEED_MIN = 0.3
const WALK_SPEED_MAX = 1.0

@onready var player = get_parent() as CharacterBody2D
@onready var sfx_player = AudioStreamPlayer.new()
@onready var loop_player = AudioStreamPlayer.new()

const AIRBORN_SOUNDS: Array[String] = [
	"res://assets/sounds/airborn-1.ogg",
	"res://assets/sounds/airborn-2.ogg",
	"res://assets/sounds/airborn-3.ogg"
]

const JUMP_SOUNDS: String = "res://assets/sounds/jump.ogg"

const DOUBLE_JUMP_SOUNDS: String = "res://assets/sounds/double_jump.ogg"

const WALK_SOUND: String = "res://assets/sounds/walk.ogg"

const AIRBORN_LOOP: String = "res://assets/sounds/airborn_loop.ogg"


func _ready():
	player.connect("anim_state_changed", Callable(self, "_on_anim_state_changed"))
	connect("animation_looped", Callable(self, "_on_animation_looped"))
	add_child(sfx_player)
	add_child(loop_player)

@warning_ignore("unused_parameter")

func _process(delta: float) -> void:
	if player.velocity.x != 0:
		flip_h = player.velocity.x < 0

	if animation == "walk":
		var walk_speed = abs(player.velocity.x)
		var min_speed = 20.0
		var max_speed = 1250.0

		var speed_factor = inverse_lerp(min_speed, max_speed, walk_speed)
		
		var is_running = Input.is_action_pressed("run")
		var run_multiplier = 1.05 if is_running else 1.0

		speed_scale = lerp(0.2, 1.5, speed_factor) * run_multiplier
	else:
		speed_scale = 1.0


func _on_anim_state_changed(state: String) -> void:
	if !is_playing() or animation != state:
		play(state)

	if state == "walk":
		# function SHOULD be here.... not yet lol
		pass

	if state == "jump":
		play_jump_sound()

	if state == "double_jump":
		play_double_jump_sound()

	if state == "airborn":
		play_airborn_sound()
		start_airborn_loop()

	elif state != "airborn" and loop_player.playing:
		stop_airborn_loop()
		
func play_walk_sound() -> void:
	var sound_path = WALK_SOUND
	var sound = load(sound_path)
	
	sfx_player.stream = sound
	sfx_player.pitch_scale = randf_range(0.75, 1.25)
	sfx_player.play()
	

func play_airborn_sound() -> void:
	var random_index = randi() % AIRBORN_SOUNDS.size()
	var sound_path = AIRBORN_SOUNDS[random_index]
	var sound = load(sound_path)
	sfx_player.stream = sound
	sfx_player.pitch_scale = randf_range(0.75, 1.25)
	sfx_player.play()
	
func play_jump_sound() -> void:
	var sound = load("res://assets/sounds/jump.ogg")
	sfx_player.stream = sound
	sfx_player.pitch_scale = randf_range(0.75, 1.25)
	sfx_player.play()
	
func play_double_jump_sound() -> void:
	var sound = load("res://assets/sounds/double_jump.ogg")
	sfx_player.stream = sound
	sfx_player.pitch_scale = randf_range(0.75, 1.25)
	sfx_player.play()

func start_airborn_loop() -> void:
	if !loop_player.playing:
		var loop_sound = load(AIRBORN_LOOP)
		var audio_stream = loop_sound as AudioStream
		audio_stream.loop = true
		loop_player.stream = audio_stream
		loop_player.play()

func stop_airborn_loop() -> void:
	loop_player.stop()
