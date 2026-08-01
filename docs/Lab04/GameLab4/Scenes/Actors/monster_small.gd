extends CharacterBody2D

@export var speed: float = 60.0
var direction: int = -1 
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	var types = Array($Sprite/AnimateSprite.sprite_frames.get_animation_names())
	$Sprite/AnimateSprite.animation = types.pick_random()
	$Sprite/AnimateSprite.play()
	


func _physics_process(delta: float) -> void:
	# 1. ใส่แรงโน้มถ่วง
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. กำหนดความเร็วเดิน
	velocity.x = speed * direction
	
	# 3. หันหน้าตัวละครด้วย flip_h (ไม่ต้องใช้ scale แล้ว)
	if direction == 1:
		$Sprite/AnimateSprite.flip_h = true 
	elif direction == -1:
		$Sprite/AnimateSprite.flip_h = false  
		
	# 4. เคลื่อนที่ตามฟิสิกส์
	move_and_slide()
	
	# 5. เช็กเงื่อนไขการกลับตัว
	if is_on_wall() or (is_on_floor() and not $RayCast2D.is_colliding()):
		flip_direction()

# ฟังก์ชันหันหลังกลับทิศทาง
func flip_direction() -> void:
	direction *= -1          # กลับทิศเดิน
	
	# กลับด้านตำแหน่ง X ของหนวด RayCast อย่างเดียว (ภาพหันด้านบนแล้ว)
	$RayCast2D.position.x *= -1

func take_damage() -> void:
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(1)
