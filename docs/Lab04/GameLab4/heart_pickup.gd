extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# 1. เช็กว่าเกิดการชนขึ้นจริงๆ ไหม และสิ่งที่มาชนชื่ออะไร
	print("เกิดการชนกับโหนดชื่อ: ", body.name) 
	
	if body.name == "Player":
		print("ตรวจสอบผ่าน: เป็น Player จริงๆ!")
		
		# 2. เช็กว่าเลือดเต็ม 5 หรือเปล่า
		if GameManager.life < 5: 
			print("เลือดน้อยกว่า 5: ทำการเพิ่มเลือด และลบไอเทม!")
			GameManager.life += 1
			queue_free() 
		else:
			print("เลือดเต็มแล้ว: เก็บหัวใจไม่ได้!")
