class_name GameTimer
extends Control

@onready var display: RichTextLabel = $Display

var timer: Timer 
var time_limit: float = 60

func _ready():
	timer = Timer.new() 
	add_child(timer)
	timer.start(time_limit)

func _process(_delta):
	print(timer.time_left)
	display.text = str(int(timer.time_left))

