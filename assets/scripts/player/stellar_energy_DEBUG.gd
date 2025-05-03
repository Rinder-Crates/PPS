extends TextureProgressBar

var max_energy = 100.0
var current_energy = 100.0

func _ready() -> void:
	
	self.value = current_energy
	self.max_value = max_energy

func _process(delta: float) -> void:
	handle_damage()

func handle_damage() -> void:
	pass

func take_damage(amount: float) -> void:
	current_energy -= amount
	current_energy = max(current_energy, 0)
	self.value = current_energy
	
func take_health(amount: float) -> void:
	current_energy += amount
	current_energy = max(current_energy, 0)
	self.value = current_energy
