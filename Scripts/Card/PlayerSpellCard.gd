class_name PlayerSpellCard
extends Card

@onready var power_label: Label = $MarginContainer/VBoxContainer/PowerPanel/PowerLabel

func _ready():
	z_index = 1
	pass

func update_labels() -> void:
	power_label.text = str(int(data.power))
