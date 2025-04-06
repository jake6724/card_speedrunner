class_name EnemyUnitCard
extends Card

@onready var power_label: Label = $MarginContainer/PowerPanel/PowerLabel
signal enemy_unit_died

func _ready():
	pass

func update_labels() -> void:
	power_label.text = str(int(data.power))

func take_damage(damage: float) -> void:
	data.power -= damage
	if data.power <= 0:
		enemy_unit_died.emit()
		queue_free()
	else:
		call_deferred("update_labels")
