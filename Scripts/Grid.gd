class_name Grid
extends Control

var cell_size: Vector2 = Vector2(150, 200)
var columns: int = 4
var buffer: Vector2 = Vector2(160,30)
var margin_buffer: Vector2 = Vector2(250,0)

var player_unit_spot: PlaceHolderCard
var selected_enemy: EnemyUnitCard

var grid: Array[Array] = [ # Consider initializing with empty card ? That way we could use these to detect if we clicked a empty spot?
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null]]

func _process(delta):
	pass

func _ready():
	# Configure placeholder cards in row 4
	for i in range(4):
		var new_card: PlaceHolderCard = GlobalData.place_holder_card_scene.instantiate()
		grid[3][i] = new_card
		new_card.position = margin_buffer + Vector2(i, 3) * (cell_size + buffer)
		add_child(new_card)

		new_card.mouse_entered.connect(on_place_holder_card_entered.bind(new_card))
		new_card.mouse_exited.connect(on_place_holder_card_exited)

func add_enemy_to_grid(card):
	var col = GlobalData.rng.randi_range(0,3)

	# grid[0][col] = card
	# card.position = margin_buffer + Vector2(col, 0) * (cell_size + buffer)
	# add_child(card)
	# card.mouse_entered.connect(on_enemy_unit_card_entered.bind(card))
	# card.mouse_exited.connect(on_enemy_unit_card_exited.bind(card))
	# card.enemy_unit_died.connect(on_enemy_unit_died.bind(card))

	if not grid[0][col]:
		grid[0][col] = card
		card.position = margin_buffer + Vector2(col, 0) * (cell_size + buffer)
		add_child(card)
		card.mouse_entered.connect(on_enemy_unit_card_entered.bind(card))
		card.mouse_exited.connect(on_enemy_unit_card_exited.bind(card))
		card.enemy_unit_died.connect(on_enemy_unit_died.bind(card))

	else: # TODO: This can eventually be removed, as all enemy cards will move down 1 at the beginning over each turn
		shift_column_down(col)
		grid[0][col] = card
		card.position = margin_buffer + Vector2(col, 0) * (cell_size + buffer)
		add_child(card)
		card.mouse_entered.connect(on_enemy_unit_card_entered.bind(card))
		card.mouse_exited.connect(on_enemy_unit_card_exited.bind(card))
		card.enemy_unit_died.connect(on_enemy_unit_died.bind(card))

	card.call_deferred("update_labels") # Children nodes (e.i the labels) may not have loaded into scene tree yet

# ROW 0
# ROW 1
# ROW 2
# ROW 3 = UNITS

func shift_column_down(col):
	#for i in range((columns - 1), -1, -1):
	for i in range(2, -1, -1):
		if grid[i][col]:
			# if (i + 1) < 3: # Goes up to row 3
			if i != 2:
					grid[i][col].position = margin_buffer + Vector2(col, i + 1) * (cell_size + buffer)
					grid[i + 1][col] = grid[i][col]
					grid[i][col] = null

			# elif (i + 1) == 3: 
			else: 
					grid[i][col].queue_free()
					grid[i][col] = null

func shift_all_columns_down():
	for i in range(4):
		shift_column_down(i)

func on_enemy_unit_card_entered(card):
	if card is EnemyUnitCard: # Not really needed I dont think
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
	return -1000 # Idk man

func get_enemy_cards_in_col(col: int) -> Array:
	var r: Array[EnemyUnitCard] = []
	for row in grid:
		if row[col] is EnemyUnitCard:
			r.append(row[col])
	return r
