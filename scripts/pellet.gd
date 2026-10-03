extends Area2D

# 적에게 적용할 넉백 힘
@export var knockback_force: float = 250.0

# Pellet 이동 속도
@export var speed: float = 900.0

# Pellet 생존 시간
@export var lifetime: float = 1.5

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
	
	if body.has_method("apply_knockback"):
		body.apply_knockback(direction, knockback_force)
		queue_free()
