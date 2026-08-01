extends Control

func _input(event: InputEvent) -> void:
	# ถ้าผู้เล่นคลิกเมาส์ หรือกดปุ่มใดๆ บนคีย์บอร์ด
	if event is InputEventMouseButton and event.pressed:
		# เปลี่ยนฉากกลับไปที่หน้า Menu หลักของเกม (เปลี่ยนเส้นทางไฟล์ให้ตรงกับของคุณ)
		get_tree().change_scene_to_file("res://Scenes/Levels/menu.tscn")
