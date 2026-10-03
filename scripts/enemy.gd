extends CharacterBody2D

# Pellet에 맞았을 때 적용할 밀림 속도
var knockback_velocity: Vector2 = Vector2.ZERO

# 밀림이 얼마나 빨리 줄어드는지
@export var knockback_friction: float = 900.0

func _physics_process(delta):
	# 현재 knockback_velocity만큼 적 이동
	velocity = knockback_velocity
	move_and_slide()

	# 시간이 지나면서 Knockback이 점점 줄어듦
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_friction * delta
	)

# 외부에서 Knockback을 적용할 때 호출
func apply_knockback(direction: Vector2, force: float):
	knockback_velocity = direction * force
