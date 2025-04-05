class_name PlayerSpellCard
extends Card

@onready var power_label: Label = $MarginContainer/VBoxContainer/PowerPanel/PowerLabel
@onready var target_label: Label = $MarginContainer/VBoxContainer/TargetPanel/TargetLabel

func _ready():
	z_index = 1
	pass

func update_labels() -> void:
	power_label.text = str(int(data.power))
	var target_text = ""

	match data.target:
		GlobalData.SpellTargetType.SINGLE:
			target_text = "Single"

		GlobalData.SpellTargetType.ROW:
			target_text = "Row"

		GlobalData.SpellTargetType.LANE:
			target_text = "Lane"

	target_label.text = target_text