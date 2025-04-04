class_name PlayerUnitCard
extends Card

@onready var health_label: Label = $MarginContainer/VBoxContainer/Numbers/HealthPanel/HealthLabel
@onready var power_label: Label = $MarginContainer/VBoxContainer/Numbers/PowerPanel/PowerLabel

func _ready():
	pass

func update_labels() -> void:
	health_label.text = str(int(data.health))
	power_label.text = str(int(data.power))
