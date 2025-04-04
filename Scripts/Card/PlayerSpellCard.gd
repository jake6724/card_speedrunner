class_name PlayerSpellCard
extends Card

@onready var power_label: Label = $MarginContainer/VBoxContainer/PowerPanel/PowerLabel

func _ready():
	pass

func update_labels() -> void:
	power_label.text = str(int(data.power))
