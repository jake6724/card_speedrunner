class_name Hand
extends HBoxContainer


@export var deck: Deck
var hand: Array[Card] = []
var hover_card: Card
var select_card: Card
var starting_position: Vector2
var target_position: Vector2


func _ready():
	pass

func add_card_to_hand() -> void:
	# Get card from deck, add to hand array, add child
	var new_card: Card = deck.get_next_card()
	hand.append(new_card)
	add_child(new_card)

	# Connect to card signals
	new_card.mouse_entered.connect(on_mouse_entered_card.bind(new_card))
	new_card.mouse_exited.connect(on_mouse_exited_card.bind(new_card))

func initialize_hand():
	for i in range(4):
		add_card_to_hand()

	for card in hand:
		card.update_labels()

func _process(delta):
	if hover_card:
		hover_card.position = hover_card.position.move_toward(target_position, 1500 * delta)

	elif select_card:
		select_card.global_position = get_global_mouse_position() - (select_card.size / 2)

func on_mouse_entered_card(card):
	print("Entered: ", card)
	if card is Card:
		if not select_card: # No hovering until select_card is released
			if card != hover_card:
				hover_card = card
				starting_position = hover_card.position
				target_position = hover_card.position - Vector2(0,125)

func on_mouse_exited_card(card):
	if card is Card:
		if not select_card: # If you move the mouse too fast with a card selected, it will trigger exit
			if card == hover_card:
				print("Exited: ", card)
				hover_card = null
				card.position = starting_position
				starting_position = Vector2()
				target_position = Vector2()

func _input(_event):
	if Input.is_action_just_pressed("left_click"):
		if hover_card:
			select_card = hover_card 
			hover_card = null

	# TODO: If select_card:
	

	# Keep track of which lane the mouse is over. If a lane has been entered (and not exited yet) and player left clicks again,
	# place the card in the -1 slot the vbox container. 

	# Maybe check what the type is of the object arg for mouse_entered to determine if lane, or card in the case of spell casting


	if Input.is_action_just_pressed("right_click"):
		if select_card:
			select_card.position = starting_position
			select_card = null
		
