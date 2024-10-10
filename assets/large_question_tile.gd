extends Node2D

signal tile_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_question(qtext):
	$Question.text = qtext
	if "cat" in qtext:
		$Question.position.y = -700
		$TextureRect.texture = load("res://assets/Icons/TychoIcon.png")
		$TextureRect.position.y = -200
	if "mushroom" in qtext:
		$Question.position.y = -700
		$TextureRect.texture = load("res://assets/Icons/morelsIcon.png")
		$TextureRect.position.y = -200

func _on_texture_button_pressed():
	tile_pressed.emit()

func init_timer():
	$FrogTimer.set_length(1800, 10, 6)

func start_timer():
	$FrogTimer.start()

func pause_timer():
	$FrogTimer.pause()

func play_timer():
	$FrogTimer.play()
