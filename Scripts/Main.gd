extends Control

@onready var grid: Grid = $MarginContainer/HBoxContainer/Gameboard/Grid
@onready var player_deck: Deck = $MarginContainer/HBoxContainer/MarginContainer/Decks/PlayerDeck
@onready var enemy_deck: Deck = $MarginContainer/HBoxContainer/MarginContainer/Decks/EnemyDeck
@onready var player_hand: Hand = $MarginContainer/HBoxContainer/Gameboard/Hand
@onready var game_timer_label: RichTextLabel = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Timer
@onready var gameover_label: Label = $GameoverLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Score
@onready var turn_label: Label = $MarginContainer/HBoxContainer/Stats/MarginContainer/VBoxContainer/Turn
@onready var action_count_label: Label =$MarginContainer/HBoxContainer/MarginContainer/Decks/TurnCount

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
	player_hand.player_action_incremented.connect(on_player_action_incremented)
	game_timer_label.gameover.connect(on_gameover)
	grid.timer_attacked.connect(on_timer_attacked)

	# Start first turn (enemy goes first)
	grid.add_enemy_to_grid(enemy_deck.get_next_card())
	grid.add_enemy_to_grid(enemy_deck.get_next_card())

func on_player_turn_complete():
	# Update turn count
	turn_count += 1
	turn_label.text = "Turn: " + str(turn_count)

	# Reset action count
	on_player_action_incremented(0)

	# Reset hand stats, attack with player units
	player_hand.action_count = 0
	player_hand.attack_with_all_units()

	# Run enemy actions
	grid.shift_all_columns_down()
	grid.add_enemy_to_grid(enemy_deck.get_next_card())
	grid.add_enemy_to_grid(enemy_deck.get_next_card())

func on_gameover():
	gameover_label.visible = true

func on_score_changed(new_score):
	score_label.text = str(new_score)

func on_timer_attacked(time_reduction):
	var new_time: float = game_timer_label.timer.time_left - time_reduction
	if new_time > 0:
		game_timer_label.timer.stop()
		game_timer_label.timer.start(new_time)
	else:
		game_timer_label.timer.stop()

func on_player_action_incremented(action_count: int):
	action_count_label.text = str(action_count)

func _input(_event):
	if Input.is_action_just_pressed("x"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
