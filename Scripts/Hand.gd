class_name Hand
extends HBoxContainer

@export var deck: Deck
@export var grid: Grid
var hand: Array[Card] = []
var active_units: Array = []
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
	# Select a hovered card
	if Input.is_action_just_pressed("left_click"):
		if hover_card:
			selected_card = hover_card 
			selected_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hover_card = null

	if Input.is_action_just_released("left_click"):
		if selected_card:
			# Place Unit Card
			if grid.player_unit_spot and selected_card is PlayerUnitCard:
				# Reparent the Unit card under the placeholder card, and reset its position
				var parent = selected_card.get_parent()
				if parent:
					parent.remove_child(selected_card)
					grid.player_unit_spot.add_child(selected_card)
					selected_card.position = Vector2()
					selected_card.mouse_entered.disconnect(on_mouse_entered_card)
					selected_card.mouse_exited.disconnect(on_mouse_exited_card)
					active_units.append(selected_card)
					selected_card.player_unit_died.connect(on_player_unit_died)

				attack_with_unit(selected_card)

				reset_selected_card()
				add_card_to_hand()
				update_action_count()

			# Cast Spell Card
			elif selected_card is PlayerSpellCard and grid.selected_enemy: # Cast spell card on enemy
				selected_card.global_position = grid.selected_enemy.global_position
				cast_spell_card(selected_card, grid.selected_enemy) 

				reset_selected_card()
				add_card_to_hand()
				update_action_count()

			# No Action, place card back in hand
			else:
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

	if Input.is_action_just_pressed("end_turn"):
		player_turn_complete.emit()

func reset_selected_card():
	hand.remove_at(hand.find(selected_card))
	selected_card.mouse_filter = Control.MOUSE_FILTER_STOP
	selected_card = null
	starting_position = Vector2()
	target_position = Vector2()

func attack_with_all_units():
	for card in active_units:
		if card is PlayerUnitCard:
			attack_with_unit(card)

func attack_with_unit(unit: PlayerUnitCard):
	# Find this cards column
	var col_index = grid.find_card_col(unit.get_parent())
	
	# Attack the lowest enemy card in the same column (enemies will never be in last row)
	var col_enemies: Array[EnemyUnitCard] = grid.get_enemy_cards_in_col(col_index)
	if col_enemies:
		col_enemies[-1].take_damage(unit.data.power)

func cast_spell_card(player_spell, enemy_card):
	match player_spell.data.target:
		GlobalData.SpellTargetType.SINGLE:
			enemy_card.take_damage(player_spell.data.power)

		GlobalData.SpellTargetType.ROW:
			var row_index: int = grid.find_card_row(enemy_card)
			var row_enemies: Array[EnemyUnitCard] = grid.get_enemy_cards_in_row(row_index)
			for enemy in row_enemies:
				enemy.take_damage(player_spell.data.power)

		GlobalData.SpellTargetType.LANE:
			var col_index: int = grid.find_card_col(enemy_card)
			var col_enemies: Array[EnemyUnitCard] = grid.get_enemy_cards_in_col(col_index)
			for enemy in col_enemies:
				enemy.take_damage(player_spell.data.power)

	selected_card.queue_free()

func has_unit_card() -> bool:
	for card in hand:
		if card is PlayerUnitCard:
			return true
		else:
			return false
	return false

func update_action_count():
	print("Action count = ", action_count)
	action_count += 1
	# print("Action count: ", action_count)
	if action_count >= 3:
		print("emitting player_turn_complete")
		player_turn_complete.emit()


	elif not grid.has_enemies() and not has_unit_card(): # No enemies and only spell cards
		print("Assuming no enemies and no spell cards")
		player_turn_complete.emit()

func on_player_unit_died(card):
	active_units.remove_at(active_units.find(card))

	# TODO: Need to check for only units and no slots
