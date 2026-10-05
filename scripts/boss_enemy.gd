extends "res://scripts/enemy.gd"
const BOSS_LAUGH = preload("res://assets/sounds/boss_laugh.wav")
const BOSS_LINE_1 = preload("res://assets/sounds/boss_line_1.wav")

@onready var boss_voice: AudioStreamPlayer2D = $BossVoice
@onready var voice_timer: Timer = $VoiceTimer
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

func _ready():
	max_health = 20
	health = max_health
	move_speed = 75.0
	
	start_voice_timer()

func apply_knockback(direction: Vector2, force: float):
	super.apply_knockback(direction, force * 0.3)

func start_voice_timer():
	voice_timer.wait_time = randf_range(4.0, 9.0)
	voice_timer.start()


func _on_voice_timer_timeout() -> void:
	if not boss_voice.playing:
		play_random_voice()

	start_voice_timer()

func play_random_voice():
	var voices = [
		BOSS_LAUGH,
		BOSS_LINE_1
	]
	boss_voice.stream = voices.pick_random()
	boss_voice.play()

func take_damage(amount: int):
	if is_dead:
		return

	hit_sound.play()

	super.take_damage(amount)
