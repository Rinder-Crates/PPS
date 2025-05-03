extends TextureProgressBar

var max_health = 100.0
var current_health = 100.0
var shake_intensity = 10.0
var shake_speed = 5.0
var original_scale = Vector2(1, 1)
var original_position = Vector2.ZERO

func _ready() -> void:
	self.value = current_health
	self.max_value = max_health
	original_scale = self.scale
	original_position = self.position

func _process(_delta: float) -> void:
	handle_shake_and_scale(_delta)

func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	self.value = current_health
	
func take_health(amount: float) -> void:
	current_health += amount
	current_health = min(current_health, max_health)
	self.value = current_health

func handle_shake_and_scale(_delta: float) -> void:
	if current_health < 50:
		self.scale = original_scale * 1.2

		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity), 
			randf_range(-shake_intensity, shake_intensity)
		)
		self.position = original_position + shake_offset * _delta * shake_speed
	else:
		self.scale = original_scale
		self.position = original_position
