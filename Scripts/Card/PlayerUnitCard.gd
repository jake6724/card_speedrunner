class_name PlayerUnitCard
extends Card

@onready var health_label: Label = $MarginContainer/VBoxContainer/Numbers/HealthPanel/HealthLabel
@onready var power_label: Label = $MarginContainer/VBoxContainer/Numbers/PowerPanel/PowerLabel

signal player_unit_died

func _ready():
	z_index = 2

func update_labels() -> void:
	health_label.text = str(int(data.health))
	power_label.text = str(int(data.power))

func take_damage(damage: float) -> void:
	data.health -= damage
	if data.health <= 0:
		player_unit_died.emit(self)
		queue_free()
	else:
		call_deferred("update_labels")
