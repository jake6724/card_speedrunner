extends Control

@onready var player_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/PlayerDeck
@onready var enemy_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/EnemyDeck
@onready var player_hand: Hand = $MarginContainer/HBoxContainer/Gameboard/Hand
@onready var game_timer: RichTextLabel = $MarginContainer/HBoxContainer/Stats/VBoxContainer/MarginContainer/Timer
@onready var gameover_label: Label = $GameoverLabel

func _ready():
	# Initialize decks
	player_deck.deck_source = GlobalData.player_card_data
	player_deck.generate_new_deck()
	print("Player deck created")

	enemy_deck.deck_source = GlobalData.enemy_card_data
	enemy_deck.generate_new_deck()
	print("Enemy deck created")

	# Initialize Hand, assign its deck
	player_hand.deck = player_deck
	player_hand.initialize_hand()

	# Connect to signals
	game_timer.gameover.connect(on_gameover)

func on_gameover():
	gameover_label.visible = true

# func _input(event):
# 	pass
