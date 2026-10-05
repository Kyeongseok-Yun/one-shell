extends CharacterBody2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

# 플레이어 추적 속도
@export var move_speed: float = 50.0

# 적 체력
@export var max_health: int = 3
var health: int = 3

# 현재 넉백 속도
var knockback_velocity: Vector2 = Vector2.ZERO

# 넉백이 줄어드는 속도
@export var knockback_friction: float = 900.0

# Sprite2D 참조
@onready var sprite: Sprite2D = $Sprite2D

# Player 노드 참조
@onready var player = get_tree().get_first_node_in_group("player")

var is_dead: bool = false

func _physics_process(delta):
	# 플레이어를 향하는 방향
	var chase_direction = Vector2.ZERO

	if player:
		chase_direction = global_position.direction_to(player.global_position)

		# 플레이어가 왼쪽에 있으면 좀비 이미지 좌우반전
		sprite.flip_h = player.global_position.x < global_position.x

	# 추적 이동 + 넉백 이동
	velocity = chase_direction * move_speed + knockback_velocity

	move_and_slide()

	# 넉백은 시간이 지나면서 점점 줄어듦
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * delta
	)


func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction * force


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)

func take_damage(amount: int):
	# 이미 죽은 적이면 추가 데미지 무시
	if is_dead:
		return

	health -= amount
	hit_flash()

	if health <= 0:
		die()


func die():
	# 여러 Pellet이 동시에 맞아도 사망 처리는 딱 한 번
	if is_dead:
		return

	is_dead = true

	var main = get_tree().current_scene

	if main.has_method("add_kill"):
		main.add_kill()
	
	# 충돌/움직임 비활성화
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$AttackArea.monitoring = false
	$Sprite2D.visible = false

	death_sound.play()
	await death_sound.finished	

	queue_free()

func hit_flash():
	sprite.modulate = Color(1.8, 1.8, 1.8)

	await get_tree().create_timer(0.06).timeout

	if not is_dead:
		sprite.modulate = Color.WHITE
