class_name Hand
extends HBoxContainer

@export var deck: Deck
@export var grid: Grid
var hand: Array[Card] = []
var placed_units: Array = []
var hover_card: Card
var selected_card: Card
var starting_position: Vector2
var target_position: Vector2
var action_count = 0

signal player_turn_complete

func add_card_to_hand() -> void:
	# Get card from deck, add to hand array, add child
	var new_card: Card = deck.get_next_card()
	hand.append(new_card)
	add_child(new_card)
	new_card.call_deferred("update_labels")

	# Connect to card signals
	new_card.mouse_entered.connect(on_mouse_entered_card.bind(new_card))
	new_card.mouse_exited.connect(on_mouse_exited_card.bind(new_card))

func initialize_hand():
	for i in range(4):
		add_card_to_hand()

func _process(delta):
	if hover_card:
		hover_card.position = hover_card.position.move_toward(target_position, 500 * delta)

	elif selected_card:
		selected_card.global_position = get_global_mouse_position() - (selected_card.size / 2)

func on_mouse_entered_card(card):
	if card is Card:
		if not selected_card: # No hovering until selected_card is released
			if card != hover_card:
				hover_card = card
				starting_position = hover_card.position
				target_position = hover_card.position - Vector2(0,20)

func on_mouse_exited_card(card):
	if card is Card:
		if not selected_card: # If you move the mouse too fast with a card selected, it will trigger exit
			if card == hover_card:
				hover_card = null
				card.position = starting_position
				starting_position = Vector2()
				target_position = Vector2()

func _input(_event):
	if Input.is_action_just_pressed("left_click"):
		if hover_card:
			selected_card = hover_card 
			selected_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hover_card = null

	if Input.is_action_just_released("left_click"):
		if selected_card:
			if grid.player_unit_spot and selected_card is PlayerUnitCard: # Place player_unit card in lane spot
				selected_card.global_position = grid.player_unit_spot.global_position
				selected_card.mouse_filter = Control.MOUSE_FILTER_STOP
				selected_card.mouse_entered.disconnect(on_mouse_entered_card)
				selected_card.mouse_exited.disconnect(on_mouse_exited_card)

				starting_position = Vector2()
				target_position = Vector2()
				selected_card = null

				update_action_count()

			elif selected_card is PlayerSpellCard and grid.selected_enemy: # Cast spell card on enemy
				selected_card.global_position = grid.selected_enemy.global_position
				selected_card.mouse_filter = Control.MOUSE_FILTER_STOP
				# selected_card.mouse_entered.disconnect(on_mouse_entered_card)
				# selected_card.mouse_exited.disconnect(on_mouse_exited_card)
				cast_spell_card(selected_card, grid.selected_enemy) 

				selected_card.queue_free()
				starting_position = Vector2()
				target_position = Vector2()
				selected_card = null

				add_card_to_hand()
				update_action_count()

			else: # Place card back in hand
				selected_card.position = starting_position
				selected_card.mouse_filter = Control.MOUSE_FILTER_STOP
				starting_position = Vector2()
				target_position = Vector2()
				selected_card = null

				
		
	if Input.is_action_just_pressed("right_click"):
		if selected_card:
			selected_card.mouse_filter = Control.MOUSE_FILTER_STOP
			selected_card.position = starting_position
			selected_card = null

func cast_spell_card(player_spell, enemy_card):
	enemy_card.take_damage(player_spell.data.power)

func update_action_count():
	action_count += 1
	# print("Action count: ", action_count)
	if action_count >= 3:
		player_turn_complete.emit()
