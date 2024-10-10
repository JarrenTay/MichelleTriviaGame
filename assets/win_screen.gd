extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_winner(winner):
	if winner == 0 or winner == 1:
		$LeftWinner.animation = "frog"
	else:
		$LeftWinner.animation = "mushroom"
	if winner == 0 or winner == -1:
		$RightWinner.animation = "mushroom"
	else:
		$RightWinner.animation = "frog"
