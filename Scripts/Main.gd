extends Control

@onready var grid: Grid = $MarginContainer/HBoxContainer/Gameboard/Grid
@onready var player_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/PlayerDeck
@onready var enemy_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/EnemyDeck
@onready var player_hand: Hand = $MarginContainer/HBoxContainer/Gameboard/Hand
@onready var game_timer: RichTextLabel = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Timer
@onready var gameover_label: Label = $GameoverLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Score
@onready var turn_label: Label = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Turn

var turn_count = 1

func _ready():
	# Initialize decks
	player_deck.deck_source = GlobalData.player_card_data
	player_deck.generate_new_deck()

	enemy_deck.deck_source = GlobalData.enemy_card_data
	enemy_deck.generate_new_deck()

	# Initialize Hand, assign its deck
	player_hand.deck = player_deck
	player_hand.grid = grid
	player_hand.initialize_hand()

	# Connect to signals
	GlobalData.score_changed.connect(on_score_changed)
	player_hand.player_turn_complete.connect(on_player_turn_complete)
	game_timer.gameover.connect(on_gameover)

	# Start first turn (enemy goes first)
	grid.add_enemy_to_grid(enemy_deck.get_next_card())
	grid.add_enemy_to_grid(enemy_deck.get_next_card())

func on_player_turn_complete():
	print("on_player_turn_complete")
	# Update turn count
	turn_count += 1
	turn_label.text = "Turn: " + str(turn_count)

	# Run enemy actions
	grid.shift_all_columns_down()
	grid.add_enemy_to_grid(enemy_deck.get_next_card())
	grid.add_enemy_to_grid(enemy_deck.get_next_card())

	# Reset hand stats, attack with player units
	player_hand.action_count = 0
	player_hand.attack_with_all_units()

func on_gameover():
	gameover_label.visible = true

func on_score_changed(new_score):
	score_label.text = str(new_score)

func _input(_event):
	if Input.is_action_just_pressed("x"):
		grid.add_enemy_to_grid(enemy_deck.get_next_card())
