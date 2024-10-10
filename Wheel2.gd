extends Node2D

enum RotationDirections {
	CLOCKWISE = 1,
	COUNTERCLOCKWISE = -1
}

var rotation_direction = RotationDirections.CLOCKWISE
var revolutions = 15
var spin_time = 10.0

var label_array = []
var reward_order = [10, 9, 0, 6, 3]
var rewards = ["No Wrong \nAnswer", "1 Million \nDollars", "500 points", "Ice Cream", "200 points", "Tickets to \nHawaii", "1 Point", "Donuts", "Insider \nKnowledge", "Extra Time", "Farther \nBuzzers", "You Choose"]
var spinning = false

signal reward_spun(reward)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 12:
		var new_label = Label.new()
		new_label.text = rewards[i]
		new_label.size = Vector2(400, 260)
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_label.position = Vector2(300, -130)
		new_label.pivot_offset = Vector2(-300, 130)
		new_label.theme = load("res://assets/themes/WheelTheme2.tres")
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
	await get_tree().create_timer(wheel_duration + 2).timeout
	$WheelSprite.rotation_degrees = fmod($WheelSprite.rotation_degrees, 360.0)
	reward_spun.emit(rewards[get_label_id($WheelSprite.rotation_degrees)])

func get_label_id(degrees):
	var label_raw = 13 - ((degrees + 15) / 30.0)
	var label_id = 0
	if label_raw < 0:
		label_id = ceili(label_raw)
	else:
		label_id = floori(label_raw)
	return label_id % 12

func get_degrees(label_id):
	var degrees = ((12 - label_id) * 30) - 15
	return randi_range(degrees + 1, degrees + 29)

func _on_texture_button_pressed():
	var good = false
	var new_degrees = 0
	if spinning == false:
		spinning = true
		var label_id = reward_order.pop_front()
		spin_the_wheel(get_degrees(label_id))
