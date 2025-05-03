extends Control

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		togglePause()

func togglePause():
	if get_tree().paused == true:
		$".".hide()
		get_tree().paused == false
		
	elif get_tree().paused == false:
		$".".hide()
		get_tree().paused == true
