class_name GameTimer
extends RichTextLabel

var timer: Timer
var time_limit: float = 60.0
var left_number: String
var right_number: String

signal gameover

func _ready():
	timer = Timer.new() 
	add_child(timer)
	timer.start(time_limit)
	timer.one_shot = true

func _process(_delta):
	if timer.time_left == 0:
		text = "0:00"
		print("Gameover!")
		gameover.emit()
	else:
		left_number = str(int(timer.time_left) / 60)
		right_number = "%02d" % int(timer.time_left)

		text = left_number + ":" + right_number
	
