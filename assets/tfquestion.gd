extends Control

var num
var question_text
var is_true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(new_num, q_text, new_true):
	num = new_num
	question_text = q_text
	is_true = new_true
	$Button/HBoxContainer/Number.text = str(new_num)
	$Button/HBoxContainer/Question.text = q_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	if is_true:
		$Button/HBoxContainer/True.show()
	else:
		$Button/HBoxContainer/False.show()
