extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Woooooooooooo")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("This is a frame")
	print(str(delta) + " seconds since previous frame")
