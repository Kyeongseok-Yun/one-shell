extends Area2D

# 적에게 적용할 넉백 힘
@export var knockback_force: float = 250.0

# Pellet 이동 속도
@export var speed: float = 900.0

# Pellet 생존 시간
@export var lifetime: float = 1.5

# Pellet 데미지
@export var damage: int = 1

# 날아갈 방향
var direction: Vector2 = Vector2.RIGHT

func _ready():
	# lifetime초 후 Pellet 삭제
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# 방향 × 속도 × 프레임 시간만큼 이동
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	# 데미지를 받을 수 있는 대상이면 데미지 적용
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# 넉백을 받을 수 있는 대상이면 넉백 적용
	if body.has_method("apply_knockback"):
		body.apply_knockback(direction, knockback_force)

	# 충돌한 Pellet 삭제
	queue_free()
