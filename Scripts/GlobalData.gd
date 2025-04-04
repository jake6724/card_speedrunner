extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var score: int = 0

enum CardType {PLAYER_UNIT, PLAYER_SPELL, ENEMY_UNIT}
enum SpellTargetType {SINGLE, ROW, LANE}

@onready var player_unit_card_scene: PackedScene = preload("res://Scenes/player_unit_card.tscn")
@onready var player_spell_card_scene: PackedScene = preload("res://Scenes/player_spell_card.tscn")
@onready var enemy_unit_card_scene: PackedScene = preload("res://Scenes/enemy_unit_card.tscn")

@onready var card_scenes: Dictionary[CardType, PackedScene] = {
	CardType.PLAYER_UNIT: player_unit_card_scene,
	CardType.PLAYER_SPELL: player_spell_card_scene,
	CardType.ENEMY_UNIT: enemy_unit_card_scene,
}

@onready var player_card_data: Array[CardData] = [
	preload("res://Data/Player/Spells/spell_1.tres"),
	preload("res://Data/Player/Spells/spell_2.tres"),
	preload("res://Data/Player/Spells/spell_3.tres"),
	preload("res://Data/Player/Spells/spell_4.tres"),
	preload("res://Data/Player/Spells/spell_5.tres"),
	preload("res://Data/Player/Spells/spell_6.tres"),
	preload("res://Data/Player/Spells/spell_7.tres"),
	preload("res://Data/Player/Spells/spell_8.tres"),
	preload("res://Data/Player/Spells/spell_9.tres"),
	preload("res://Data/Player/Spells/spell_10.tres"),
	preload("res://Data/Player/Units/unit_1.tres"),
	preload("res://Data/Player/Units/unit_2.tres"),
	preload("res://Data/Player/Units/unit_3.tres"),
]

@onready var enemy_card_data: Array[CardData] = [
	preload("res://Data/Enemy/enemy_1.tres"),
	preload("res://Data/Enemy/enemy_2.tres"),
	preload("res://Data/Enemy/enemy_3.tres"),
	preload("res://Data/Enemy/enemy_4.tres"),
	preload("res://Data/Enemy/enemy_5.tres"),
	preload("res://Data/Enemy/enemy_6.tres"),
	preload("res://Data/Enemy/enemy_7.tres"),
	preload("res://Data/Enemy/enemy_8.tres"),
	preload("res://Data/Enemy/enemy_9.tres"),
	preload("res://Data/Enemy/enemy_10.tres"),
]

var moving_card: Card
