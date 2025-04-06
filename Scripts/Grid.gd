class_name Grid
extends Control

var cell_size: Vector2 = Vector2(150, 200)
var columns: int = 4
var buffer: Vector2 = Vector2(160,30)
var margin_buffer: Vector2 = Vector2(250,0)

var player_unit_spot: PlaceHolderCard
var selected_enemy: EnemyUnitCard
var place_holder_cards: Array[PlaceHolderCard] = []

signal timer_attacked

var grid: Array[Array] = [
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null]]

func _ready():
	# Configure placeholder cards in row 4
	for i in range(4):
		var new_card: PlaceHolderCard = GlobalData.place_holder_card_scene.instantiate()
		grid[3][i] = new_card
		new_card.position = margin_buffer + Vector2(i, 3) * (cell_size + buffer)
		add_child(new_card)
		place_holder_cards.append(new_card)
		new_card.mouse_entered.connect(on_place_holder_card_entered.bind(new_card))
		new_card.mouse_exited.connect(on_place_holder_card_exited)

func add_enemy_to_grid(card):
	var col = GlobalData.rng.randi_range(0,3)

	# If not card in starting row/col, place new card
	if not grid[0][col]:
		grid[0][col] = card
		card.position = margin_buffer + Vector2(col, 0) * (cell_size + buffer)
		add_child(card)
		card.mouse_entered.connect(on_enemy_unit_card_entered.bind(card))
		card.mouse_exited.connect(on_enemy_unit_card_exited.bind(card))
		card.enemy_unit_died.connect(on_enemy_unit_died.bind(card))

	# Else, shift occupying card down and then place new card
	else: 
		shift_column_down(col)
		grid[0][col] = card
		card.position = margin_buffer + Vector2(col, 0) * (cell_size + buffer)
		add_child(card)
		card.mouse_entered.connect(on_enemy_unit_card_entered.bind(card))
		card.mouse_exited.connect(on_enemy_unit_card_exited.bind(card))
		card.enemy_unit_died.connect(on_enemy_unit_died.bind(card))

	card.call_deferred("update_labels") # Children nodes (e.i the labels) may not have loaded into scene tree yet

func shift_column_down(col): # Only moves enemy cards 
	for i in range(2, -1, -1):
		if grid[i][col]:
			if i != 2:
					grid[i][col].position = margin_buffer + Vector2(col, i + 1) * (cell_size + buffer)
					grid[i + 1][col] = grid[i][col]
					grid[i][col] = null

			else: 
				var player_unit = get_place_holder_child(place_holder_cards[col])
				# Attack lane's player unit if it exists
				if player_unit:
					player_unit.take_damage(grid[i][col].data.power)
					var time_reduction = grid[i][col].data.power - player_unit.data.health
					timer_attacked.emit(time_reduction)
				# Else attack timer directly
				else:
					timer_attacked.emit(grid[i][col].data.power)

				# Remove attacker
				grid[i][col].queue_free()
				grid[i][col] = null

func shift_all_columns_down():
	for i in range(4):
		shift_column_down(i)

func on_enemy_unit_card_entered(card):
	if card is EnemyUnitCard:
		selected_enemy = card

func on_enemy_unit_card_exited(card):
	if card is EnemyUnitCard:
		selected_enemy = null

func on_place_holder_card_entered(card):
	player_unit_spot = card

func on_place_holder_card_exited():
	player_unit_spot = null

func on_enemy_unit_died(card):
	for row in grid:
		if card in row:
			var index = row.find(card)
			row[index] = null

	GlobalData.increment_score()

func has_enemies() -> bool:
	for y in range(grid.size() - 1):
		for x in range(grid[y].size()):
			if grid[y][x] != null:
				return true
	return false

func find_card_row(card: Card) -> int:
	for i in range(grid.size()):
		if card in grid[i]:
			return i
	return -1
			
func get_enemy_cards_in_row(row: int) -> Array:
	var r: Array[EnemyUnitCard] = []
	for item in grid[row]:
		if item is EnemyUnitCard:
			r.append(item)
	return r

func find_card_col(card: Card) -> int:
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if grid[x][y] == card:
				return y
	return -1000

func get_enemy_cards_in_col(col: int) -> Array:
	var r: Array[EnemyUnitCard] = []
	for row in grid:
		if row[col] is EnemyUnitCard:
			r.append(row[col])
	return r

func get_place_holder_child(place_holder_card):
	for child in place_holder_card.get_children():
		if child is PlayerUnitCard:
			return child
	return null
