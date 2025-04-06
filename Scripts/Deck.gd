class_name Deck
extends Panel

var deck_source: Array[CardData] # Setting this determines if player or enemy deck
var cards: Array[Card]

func generate_new_deck() -> void:
	# Initialize card counts
	var card_counts: Dictionary[String, int] = {}
	for card_data in deck_source:
		card_counts[card_data.name] = 0

	# TODO:  before we make the new cards, check every card in hand and on board and increment their counts

	var r: int
	while cards.size() < (deck_source.size() * 2): # need to subtract cards on board from this
		r = GlobalData.rng.randi_range(0, deck_source.size() - 1)

		if card_counts[(deck_source[r].name)] < 2:
			var new_card_data: CardData = (deck_source[r]).duplicate()
			# Instatiate and initialize card scene based on retrieved card data
			var new_card: Card = GlobalData.card_scenes[new_card_data.type].instantiate()
			new_card.data = new_card_data
			cards.append(new_card)
			card_counts[deck_source[r].name] += 1

## Get card on the top of the deck. 
## This function is responsible for regeneration `cards` if it is empty
func get_next_card() -> Card:
	var card = cards.pop_back()
	if cards.size() == 0:
		generate_new_deck()

	# print(cards.size())
	# TODO: Need to account for this card when regenerating deck somehow. 
	return card
