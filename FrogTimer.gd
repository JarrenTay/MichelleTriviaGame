extends Node2D

var timer_width
var timer_dur
var timer_hops

var tweens = []

var phase

enum Phases {
	UP,
	DOWN,
	SIT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Frog.animation = "sit"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pause():
	$UpTimer.paused = true
	$DownTimer.paused = true
	$SitTimer.paused = true
	if phase == Phases.UP:
		tweens[0].pause()
		tweens[1].pause()
	elif phase == Phases.DOWN:
		tweens[0].pause()
		tweens[2].pause()

func play():
	$UpTimer.paused = false
	$DownTimer.paused = false
	$SitTimer.paused = false
	if phase == Phases.UP:
		tweens[0].play()
		tweens[1].play()
	elif phase == Phases.DOWN:
		tweens[0].play()
		tweens[2].play()

func set_length(width, duration, hops):
	timer_width = float(width)
	timer_dur = float(duration)
	timer_hops = float(hops)
	$Frog.position.x = timer_width / 2
	$UpTimer.wait_time = timer_dur / timer_hops / 4.0
	$DownTimer.wait_time = timer_dur / timer_hops / 4.0
	$SitTimer.wait_time = timer_dur / timer_hops / 2.0

func start():
	var hops_and_pause = timer_hops * 2
	for i in timer_hops:
		var hop_duration = timer_dur / timer_hops / 2.0
		var move_tween = create_tween()
		move_tween.tween_property(
			$Frog,
			"position:x",
			$Frog.position.x - (timer_width / timer_hops),
			hop_duration
		)
		var hop_tween_up = create_tween()
		hop_tween_up.tween_property(
			$Frog,
			"position:y",
			$Frog.position.y - 200,
			hop_duration / 2.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		var hop_tween_down = create_tween()
		hop_tween_down.tween_property(
			$Frog,
			"position:y",
			$Frog.position.y,
			hop_duration / 2.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tweens = [move_tween, hop_tween_up, hop_tween_down]
		move_tween.play()
		hop_tween_up.play()
		$UpTimer.start()
		$Frog.animation = "jump"
		await $UpTimer.timeout
		hop_tween_down.play()
		$DownTimer.start()
		await $DownTimer.timeout
		$Frog.animation = "sit"
		$SitTimer.start()
		await $SitTimer.timeout
		
