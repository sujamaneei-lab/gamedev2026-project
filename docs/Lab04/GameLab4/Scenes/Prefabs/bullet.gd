extends RigidBody2D

func shoot(direction: Vector2, speed: float, lifetime: float):
	apply_impulse(direction * speed)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

# ฟังก์ชันนี้จะทำงานทันทีที่กระสุนบินไปชนอะไรสักอย่าง
func _on_body_entered(body: Node) -> void:
	# เช็กว่าตัวที่ถูกชน (body) มีฟังก์ชัน take_damage ไหม? (ซึ่งก็คือ Enemy ของเรา)
	if body.has_method("take_damage"):
		body.take_damage() # สั่งให้ศัตรูตาย
	
	# ทำลายกระสุนทิ้งทันทีที่ชน (จะได้ไม่เด้งลงพื้นต่อ)
	queue_free()
