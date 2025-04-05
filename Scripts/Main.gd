extends Control

@onready var grid: Grid = $MarginContainer/HBoxContainer/Gameboard/Grid
@onready var player_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/PlayerDeck
@onready var enemy_deck: Deck = $MarginContainer/HBoxContainer/Decks/MarginContainer/EnemyDeck
@onready var player_hand: Hand = $MarginContainer/HBoxContainer/Gameboard/Hand
@onready var game_timer: RichTextLabel = $MarginContainer/HBoxContainer/Stats/VBoxContainer/MarginContainer/Timer
@onready var gameover_label: Label = $GameoverLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/Stats/VBoxContainer/MarginContainer/Score

var is_player_turn: bool = false

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

func _process(_delta):
	if is_player_turn:
		player_hand.attack_with_all_units()
		if not grid.has_enemies():
			is_player_turn = false
	else:
		grid.add_enemy_to_grid(enemy_deck.get_next_card())
		player_hand.action_count = 0
		is_player_turn = true

func on_gameover():
	gameover_label.visible = true

func on_player_turn_complete():
	is_player_turn = false

func on_score_changed(new_score):
	score_label.text = str(new_score)

func _input(_event):
	if Input.is_action_just_pressed("x"):
		grid.add_enemy_to_grid(enemy_deck.get_next_card())
