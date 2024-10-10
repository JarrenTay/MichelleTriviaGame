extends Control

var game_board_template = preload("res://scenes/game_board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_begin_button_pressed():
	var game_board = game_board_template.instantiate()
	add_child(game_board)
