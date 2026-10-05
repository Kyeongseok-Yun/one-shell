extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound

@export var pickup_range: float = 65.0

var can_pickup: bool = false

func _ready():
	var shape = collision.shape

	if shape is CircleShape2D:
		shape.radius = pickup_range

func _on_body_entered(body):
	# Player가 닿았고 ammo 변수를 가지고 있으면 재장전
	if not can_pickup:
		return

	if body.has_method("reload_shell"):
		body.reload_shell()

		monitoring = false
		sprite.visible = false
		collision.disabled = true

		reload_sound.play()
		await reload_sound.finished

		queue_free()

func launch(start_position: Vector2, target_position: Vector2):
	global_position = start_position
	can_pickup = false
	collision.disabled = true

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		0.22
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"global_position",
		target_position + Vector2(0, -12),
		0.07
	)

	tween.tween_property(
		self,
		"global_position",
		target_position,
		0.07
	)

	await tween.finished

	can_pickup = true
	collision.disabled = false
