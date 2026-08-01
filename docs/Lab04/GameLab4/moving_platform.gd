extends AnimatableBody2D

# ระยะทางที่ต้องการให้เลื่อนไป (เช่น เลื่อนแกน X ไปทางขวา 200 พิกเซล)
# สามารถแก้เลขนี้ในหน้า Inspector ได้เลย
@export var move_offset: Vector2 = Vector2(300, 0)

# เวลาที่ใช้ในการเลื่อน 1 ขา (วินาที)
@export var duration: float = 2.0 

func _ready() -> void:
	# บันทึกตำแหน่งเริ่มต้นไว้
	var start_pos = global_position
	# คำนวณตำแหน่งปลายทาง
	var target_pos = start_pos + move_offset
	
	# สร้าง Tween ขึ้นมาคุมการเดิน (set_loops() คือให้ทำวนซ้ำไปเรื่อยๆ)
	var tween = create_tween().set_loops()
	
	# 💡 หัวใจสำคัญ: ล็อกการคำนวณให้ผูกกับระบบฟิสิกส์ (ป้องกันบั๊กตอนกระโดด/เฟรมกระตุก)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	# คำสั่งเลื่อนไปที่ target_pos ใช้เวลาเท่ากับ duration
	tween.tween_property(self, "global_position", target_pos, duration)
	
	# คำสั่งเลื่อนกลับมาที่ start_pos ใช้เวลาเท่ากับ duration
	tween.tween_property(self, "global_position", start_pos, duration)
