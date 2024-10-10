extends Control

signal timer_start(id)
signal done_answer(id, correct)
signal new_score(id, score)
signal done_reward()
signal done_final()

var hovering_label
var game_board
var cur_q_points
var question_state = QuestionState.INACTIVE
var time = 5
var bonus_time = 0
var points = 0
var id
var reward
var life = 0
var down = false

enum QuestionState {
	INACTIVE,
	ANYONE,
	ANSWERING,
	REWARDING,
	FINALING
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize():
	game_board.question_start.connect(on_question_start)
	game_board.answering_start.connect(on_answering_start)
	game_board.answering_end.connect(on_answering_end)
	game_board.question_end.connect(on_question_end)
	game_board.reward_start.connect(on_reward_start)
	game_board.final_start.connect(on_final_start)

func set_mushroom():
	$PlayerLabelContainer/PlayerIcon/AnimatedSprite2D.animation = "mushroom"

func on_question_start(points):
	cur_q_points = points
	question_state = QuestionState.ANYONE

func on_answering_start(answer_id):
	if answer_id != id:
		question_state = QuestionState.INACTIVE

func on_answering_end(answer_id):
	if answer_id != id:
		question_state = QuestionState.ANYONE

func on_question_end():
	question_state = QuestionState.INACTIVE
	cur_q_points = 0

func on_reward_start(new_reward):
	question_state = QuestionState.REWARDING
	reward = new_reward

func on_final_start():
	question_state = QuestionState.FINALING

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			if hovering_label and question_state == QuestionState.ANYONE:
				start_time(time + bonus_time)
				question_state = QuestionState.ANSWERING
				timer_start.emit(id)
			elif hovering_label and question_state == QuestionState.ANSWERING:
				add_points(cur_q_points)
				$FrogTimer.hide()
				done_answer.emit(id, true)
			elif hovering_label and question_state == QuestionState.REWARDING:
				if reward == "Extra Time":
					bonus_time = 5
				elif reward == "No Wrong \nAnswer":
					life = 1
				elif reward == "1 Point":
					add_points(1)
				done_reward.emit()
		if event.button_index == 2 and event.is_pressed():
			if hovering_label and question_state == QuestionState.ANSWERING:
				add_points(cur_q_points * -1)
				$FrogTimer.hide()
				done_answer.emit(id, false)
	if event is InputEventKey:
		if hovering_label and question_state == QuestionState.FINALING:
			if event.as_text_key_label().is_valid_int():
				if down == false:
					add_points(int(event.as_text_key_label()) * 100)
					down = true
					await get_tree().create_timer(.5).timeout
					down = false
			elif event.as_text_key_label() == "F":
				done_final.emit()

func add_points(new_points):
	if (new_points < 0 and life > 0):
		life = life - 1
		new_score.emit(id, points)
	else:
		points = points + new_points
		$ScoreContainer/Label.text = str(points)
		new_score.emit(id, points)

func _on_label_mouse_entered():
	hovering_label = true
	print(hovering_label)

func _on_label_mouse_exited():
	hovering_label = false
	print(hovering_label)

func start_time(total_time):
	$FrogTimer.show()
	$FrogTimer.set_length(1000, total_time, 6)
	$FrogTimer.start()
