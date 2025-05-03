extends Control

@onready var buttons = [
	$VBoxContainer/OptionsButton,
	$VBoxContainer/BeginTestingButton,
	$VBoxContainer/ExitButton
]

@onready var arrow = $"Menu-DownSelectArrow"
@onready var not_yet_label = $NotYetLabel

var selected_index = 1

func _ready():
	not_yet_label.visible = false
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection()

func update_selection():
	for i in range(buttons.size()):
		var sprite = buttons[i]
		if i == selected_index:
			sprite.play("Selected")
		else:
			sprite.play("Unselected")
	move_arrow_to(buttons[selected_index])

func move_arrow_to(button):
	var global_pos = button.global_position
	var frame_size = button.sprite_frames.get_frame_texture(button.animation, button.frame).get_size()
	var arrow_size = arrow.texture.get_size()
	arrow.global_position = Vector2(
		global_pos.x + frame_size.x / 4 - arrow_size.x / 2,
		global_pos.y - arrow_size.y - 100  # Position it above the button
	)

func handle_selection():
	match selected_index:
		0:
			tease_options()
		1:
			start_game()
		2:
			get_tree().quit()

func start_game():
	get_tree().change_scene_to_file("res://assets/scenes/areas/Teal Trails/wakingWays.tscn")

func tease_options():
	not_yet_label.visible = true
	if $AnimationPlayer.has_animation("FadeInNotYet"):
		$AnimationPlayer.play("FadeInNotYet")
