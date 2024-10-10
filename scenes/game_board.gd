extends Control

var item_no_texture = preload("res://assets/Icons/NoTile.png")
var small_question_tile_template = preload("res://assets/SmallQuestionTile.tscn")
var large_question_tile_template = preload("res://assets/large_question_tile.tscn")
var tf_question_tile_template = preload("res://assets/tfquestion.tscn")
var win_screen_template = preload("res://assets/win_screen.tscn")
var TTTTtexture = preload("res://assets/Icons/TTTT.png")
var PPtexture = preload("res://assets/Icons/PP.png")
var SStexture = preload("res://assets/Icons/S2.png")
var NNNNtexture = preload("res://assets/Icons/N4.png")
var question_card
var temp_disabled = []
var questioners_left = []
var game_state

var questions = [
	"What is the name of the upscale brunch bistro that Michelle used to work at?",
	"What is the difficulty of the hardest boulder that Michelle has ever climbed?",
	"Why is Michelle moving?",
	"How many years did Michelle spend in China?",
	"What state is Michelle moving to?",
	"What was Michelle's major in college?",
	"What is an instrument that Michelle can play?",
	"Where did Michelle work (as of 2 days ago)?",
	"In 2021, Michelle lost one of her body parts. What part of her body did she lose?",
	"What sport did Michelle play in high school?",
	"What is the name of Michelle's cat, pictured below:",
	"What is the name of this mushroom, that Michelle has only foraged once:",
]

var tf_questions = [
	["Michelle is the younger twin.", true],
	["Michelle can lick her elbow.", true],
	["Michelle's mom is in an MLM.", true],
	["Michelle graduated college in 3 years.", false],
	["Michelle has 2 siblings.", false],
	["Michelle likes to drink pickle juice.", true],
	["Mosquitos love Michelle.", true],
	["Michelle cannot tread water.", true],
	["Michelle prefers salty snacks over sweet snacks.", false],
	["Michelle can solve a rubik's cube.", true],
]

var activities = {
	"T. T. T. T.": ["Tick Tack Toe Toss", TTTTtexture],
	"S2": ["Simon Says", SStexture],
	"PP": ["Pickleball Pushover", PPtexture],
	"N x 4": ["Never Nhave Ni Never", NNNNtexture]
}

var rewards = {
	"No Wrong \nAnswer": "The next question you fail will not deduct points from your score.",
	"Extra Time": "You will gain extra time to answer the next three questions shown.",
	"1 Point": "You gain one extra point.",
	"Farther \nBuzzers": "The enemy team's buzzer will be placed 3 feet farther away."
}

signal question_start(points)
signal answering_start(id)
signal answering_end(id)
signal question_end()
signal game_start()
signal reward_start(reward)
signal final_start()

enum GameState {
	QUESTION,
	ACTIVITY,
	REWARD,
	FINAL
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$WheelContainer.hide()
	$GameBoardContainer.show()
	$WheelContainer2.hide()
	$FinalScreen.hide()
	$ScoreListContainer/PlayerCard.game_board = self
	$ScoreListContainer/PlayerCard2.game_board = self
	$ScoreListContainer/PlayerCard.id = 1
	$ScoreListContainer/PlayerCard2.id = 2
	$ScoreListContainer/PlayerCard.initialize()
	$ScoreListContainer/PlayerCard2.initialize()
	$ScoreListContainer/PlayerCard.done_answer.connect(player_done_answer)
	$ScoreListContainer/PlayerCard.timer_start.connect(player_timer_start)
	$ScoreListContainer/PlayerCard.new_score.connect(player_new_score)
	$ScoreListContainer/PlayerCard.done_reward.connect(on_reward_end)
	$ScoreListContainer/PlayerCard.done_final.connect(on_final_end)
	$ScoreListContainer/PlayerCard2.done_answer.connect(player_done_answer)
	$ScoreListContainer/PlayerCard2.timer_start.connect(player_timer_start)
	$ScoreListContainer/PlayerCard2.new_score.connect(player_new_score)
	$ScoreListContainer/PlayerCard2.done_final.connect(on_final_end)
	$ScoreListContainer/PlayerCard2.done_reward.connect(on_reward_end)
	$WheelContainer/MarginContainer/Wheel.game_spun.connect(wheel_game)
	$WheelContainer2/MarginContainer/Wheel2.reward_spun.connect(wheel_reward)
	$ScoreListContainer/PlayerCard2.set_mushroom()
	
	game_state = GameState.QUESTION

func player_done_answer(id, correct):
	if correct:
		questioners_left.clear()
		on_question_end()
	else:
		questioners_left.erase(id)
		if questioners_left.size() == 0:
			on_question_end()
		else:
			question_card.play_timer()
			answering_end.emit(id)
		
func on_question_end():
	question_end.emit()
	large_card_leave()
	await get_tree().create_timer(.5).timeout
	enable_cards()
	var cur_qs_left = questions_left()
	if cur_qs_left % 3 == 0:
		game_state = GameState.ACTIVITY
		activity_wheel() 

func on_activity_end():
	large_card_leave()
	reward_wheel()

func questions_left():
	var questions_left = 0
	var item_list = $GameBoardContainer/ItemList
	for item in item_list.item_count:
		if not item_list.is_item_disabled(item):
			questions_left = questions_left + 1
	return questions_left
	
func on_reward_end():
	large_card_leave()
	if questions_left() == 0:
		game_state = GameState.FINAL
		final_screen()
	else:
		$GameBoardContainer.show()
		$WheelContainer2.hide()
		enable_cards()
		game_state = GameState.QUESTION

func on_final_end():
	var win_screen = win_screen_template.instantiate()
	var winner = 0
	if $ScoreListContainer/PlayerCard.points > $ScoreListContainer/PlayerCard2.points:
		winner = 1
	elif $ScoreListContainer/PlayerCard2.points > $ScoreListContainer/PlayerCard.points:
		winner = -1
	win_screen.set_winner(winner)
	add_child(win_screen)

func final_screen():
	$GameBoardContainer.hide()
	$WheelContainer.hide()
	$WheelContainer2.hide()
	$FinalScreen.show()
	for i in 10:
		var tf_question = tf_question_tile_template.instantiate()
		tf_question.initialize(i + 1, tf_questions[i][0], tf_questions[i][1])
		$FinalScreen/MarginContainer/VBoxContainer.add_child(tf_question)
	final_start.emit()

func activity_wheel():
	$GameBoardContainer.hide()
	$WheelContainer/MarginContainer/Wheel.reready()
	$WheelContainer.show()

func reward_wheel():
	game_state = GameState.REWARD
	$WheelContainer.hide()
	$WheelContainer2/MarginContainer/Wheel2.reready()
	$WheelContainer2.show()

func player_new_score(id, score):
	pass
	
func player_timer_start(id):
	answering_start.emit(id)
	question_card.pause_timer()

func wheel_game(game):
	create_activity_card(game)

func wheel_reward(reward):
	create_reward_card(reward)

func finished_reward():
	game_state = GameState.QUESTION

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	var item_list = $GameBoardContainer/ItemList
	item_list.set_item_icon(index, item_no_texture)
	item_list.set_item_disabled(index, true)
	create_question_card(at_position + $GameBoardContainer/ItemList.global_position)

func disable_cards():
	temp_disabled = []
	var item_list = $GameBoardContainer/ItemList
	for item in item_list.item_count:
		if not item_list.is_item_disabled(item):
			temp_disabled.append(item)
			item_list.set_item_disabled(item, true)

func enable_cards():
	var item_list = $GameBoardContainer/ItemList
	for item in temp_disabled:
		item_list.set_item_disabled(item, false)

func create_question_card(position):
	questioners_left = [1, 2]
	var question_tile = small_question_tile_template.instantiate()
	question_tile.position = position
	question_card = question_tile
	$GameBoardContainer/ItemList.add_child(question_card)
	disable_cards()
	card_leave()
	await get_tree().create_timer(.5).timeout
	var large_tile = large_question_tile_template.instantiate()
	large_tile.tile_pressed.connect(on_large_card_clicked)
	large_tile.position = Vector2(5000, 1250)
	var new_question = questions.pop_at(randi_range(0, questions.size() - 1))
	large_tile.set_question(new_question)
	question_card = large_tile
	large_tile.init_timer()
	add_child(large_tile)
	card_enter()
	question_start.emit(100)
	await get_tree().create_timer(1).timeout
	large_tile.start_timer()
	
func create_activity_card(game):
	var large_tile = large_question_tile_template.instantiate()
	large_tile.tile_pressed.connect(on_large_card_clicked)
	large_tile.get_child(1).text = activities[game][0].replace("\n", " ")
	large_tile.get_child(2).hide()
	large_tile.get_child(3).texture = activities[game][1]
	large_tile.position = Vector2(5000, 1250)
	add_child(large_tile)
	question_card = large_tile
	card_enter()
	game_start.emit()

func create_reward_card(reward):
	var large_tile = large_question_tile_template.instantiate()
	large_tile.tile_pressed.connect(on_large_card_clicked)
	large_tile.get_child(1).text = reward.replace("\n", " ")
	large_tile.get_child(2).text = rewards[reward]
	large_tile.position = Vector2(5000, 1250)
	add_child(large_tile)
	question_card = large_tile
	card_enter()
	reward_start.emit(reward)

func card_leave():
	var t = create_tween()
	t.tween_property(
		question_card,
		"position",
		Vector2(question_card.position.x + 3000, question_card.position.y),
		.5
	)
	t.play()

func card_enter():
	var t = create_tween()
	t.tween_property(
		question_card,
		"position",
		Vector2(question_card.position.x - 3000, question_card.position.y),
		.5
	)
	t.play()

func large_card_leave():
	var t = create_tween()
	t.tween_property(
		question_card,
		"position",
		Vector2(question_card.position.x + 3000, question_card.position.y),
		.5
	)
	t.play()

func on_large_card_clicked():
	if game_state == GameState.QUESTION:
		on_question_end()
	elif game_state == GameState.ACTIVITY:
		on_activity_end()
	elif game_state == GameState.REWARD:
		on_reward_end()
