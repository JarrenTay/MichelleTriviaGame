extends Node2D

enum RotationDirections {
	CLOCKWISE = 1,
	COUNTERCLOCKWISE = -1
}

var rotation_direction = RotationDirections.CLOCKWISE
var revolutions = 15
var spin_time = 10.0

var label_array = []
var games = ["T. T. T. T.", "S2", "PP", "N x 4"]
var rewards = ["Further Buzzers", "No Wrong Answer", "Extra Time", "1 Point"]
var fake_rewards = ["1 Million Dollars", "500 points", "Flowers", "200 points", "Tickets to Hawaii", "Donuts", "Inside Knowledge", "You Choose"]
var unknown_text = "????????"
var spinning = false

signal game_spun(game)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 12:
		var new_label = Label.new()
		new_label.text = unknown_text
		new_label.size = Vector2(400, new_label.size.y)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		new_label.position = Vector2(300, -50)
		new_label.pivot_offset = Vector2(-300, 50)
		new_label.theme = load("res://assets/themes/WheelTheme.tres")
		new_label.rotation_degrees = i * 30
		label_array.append(new_label)
		$WheelSprite.add_child(new_label)

func reready():
	spinning = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spin_the_wheel(target_rotation_degrees: float):
	var wheel_duration = 7
	$WheelSprite.rotation_degrees = fmod($WheelSprite.rotation_degrees, 360.0)
	var t = create_tween()
	var final_rotation_degrees = target_rotation_degrees + revolutions * 360.0 * rotation_direction
	t.tween_property(
		$WheelSprite,
		"rotation_degrees",
		final_rotation_degrees,
		wheel_duration,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.play()
	await get_tree().create_timer(wheel_duration + 1).timeout
	$WheelSprite.rotation_degrees = fmod($WheelSprite.rotation_degrees, 360.0)
	var label_id = get_label_id($WheelSprite.rotation_degrees)
	if (games.size() > 0):
		var game_id = randi_range(0, games.size() - 1)
		label_array[label_id].text = games[game_id]
		games.pop_at(game_id)
	await get_tree().create_timer(3).timeout
	game_spun.emit(label_array[label_id].text)

func get_label_id(degrees):
	var label_raw = 13 - ((degrees + 15) / 30.0)
	var label_id = 0
	if label_raw < 0:
		label_id = ceili(label_raw)
	else:
		label_id = floori(label_raw)
	return label_id % 12

func _on_texture_button_pressed():
	var good = false
	var new_degrees = 0
	if spinning == false:
		spinning = true
		while not good:
			new_degrees = randi_range(0, 359)
			if (new_degrees + 45) % 30 != 0:
				var label_id = get_label_id(new_degrees)
				if label_array[label_id].text.contains(unknown_text):
					good = true
				else:
					good = false
		spin_the_wheel(new_degrees)
