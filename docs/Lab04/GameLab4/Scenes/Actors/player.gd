extends CharacterBody2D
class_name Player

signal hit_enemy
signal hit_trap 


# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 300
@export var jump_force : float = 650
@export var gravity : float = 30
@export var max_jump_count : int = 2
@export var bullet_scene : PackedScene
@export var shoot_cooldown_time : float = 0.2
@export var bullet_lifetime = 2.0

var jump_count : int = 2

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
@export var double_jump : = false

var is_grounded : bool = false
var movement_enabled : bool = true
var spawn_point = Vector2(0,0)
var is_attacking = false
var shoot_cooldown_timer = 0.0
var can_damage = true

# หมายเหตุ: ถ้าเปลี่ยนชื่อโหนด student เป็นชื่ออื่น อย่าลืมเปลี่ยนคำว่า $student ใน 2 บรรทัดนี้ด้วยน้า
@onready var player_sprite : AnimationPlayer = $student/AnimationPlayer
@onready var player_node = $student
@onready var bullet_marker = $BulletMarker
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles



# --------- BUILT-IN FUNCTIONS ---------- #
func _ready() -> void:
	$Camera2D.make_current()
	spawn_point = global_position
	if GameManager.save_player_position.x != 0:
		global_position =  GameManager.save_player_position
		GameManager.save_player_position = Vector2.ZERO
	player_sprite.animation_finished.connect(_on_animation_finished)
	
func _physics_process(_delta):
	is_grounded = is_on_floor()
	movement()

func _process(_delta):
	player_animations()
	flip_player()
	handle_shooting()
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= _delta
	
# --------- CUSTOM FUNCTIONS ---------- #

# <-- Player Movement Code -->
func movement():
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
	elif is_on_floor():
		jump_count = max_jump_count
		velocity.x = 0
	
	handle_jumping()
	
	# Move Player
	if movement_enabled:
		if Input.is_action_pressed("Left"):
			velocity.x = -move_speed
		if Input.is_action_pressed("Right"):
			velocity.x = move_speed
	
	# แก้ไข: ถ้าตกเหว ให้ลดชีวิต 1 ดวงแทนการส่งสัญญาณตายทันที
	if velocity.y > 5000:
		take_damage_from_trap()
		
	move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump") and movement_enabled:
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	if is_attacking:
		return
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.current_animation = "walk"
		else:
			player_sprite.current_animation = "idle"
	else:
		player_sprite.current_animation = "jump"


# Flip player sprite based on X velocity (แก้ไขแล้ว: รักษาขนาดสเกลเดิมไว้ ไม่แบนออกข้าง)
func flip_player():
	if velocity.x < 0: 
		player_node.scale.x = -abs(player_node.scale.x)
	elif velocity.x > 0:
		player_node.scale.x = abs(player_node.scale.x)

# Tween Animations
func death_tween():
	AudioManager.death_sfx.play()
	death_particles.emitting = true
	movement_enabled = false
	
	# เก็บตำแหน่งเดิมของภาพตัวละครไว้ก่อน
	var start_sprite_pos = player_node.position
	
	var tween = create_tween()
	# 💡 แก้ไข: ย่อสเกลและขยับเด้งขึ้นเฉพาะ player_node (ภาพตัวละคร) กล้องจะได้ไม่พัง
	tween.tween_property(player_node, "scale", Vector2.ZERO, 0.15)
	tween.parallel().tween_property(player_node, "position", Vector2(start_sprite_pos.x, start_sprite_pos.y - 100), 0.15)
	
	await tween.finished
	
	# คืนตำแหน่งภาพตัวละครกลับมาจุดเดิม (เพราะเมื่อกี้เราสั่งให้มันเด้งขึ้นไป 100)
	player_node.position = start_sprite_pos
	
	# ย้ายตำแหน่งตัวละครหลักกลับจุดเกิด
	global_position = spawn_point
	
	# 💡 สั่งกล้องให้รีเซ็ตและอัปเดตตำแหน่งทันที
	if has_node("Camera2D"):
		$Camera2D.reset_smoothing()
		$Camera2D.force_update_scroll()
		
	await get_tree().create_timer(0.3).timeout
	movement_enabled = true
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	# 💡 แก้ไข: ยืดสเกลกลับมาเฉพาะ player_node เท่านั้น
	tween.tween_property(player_node, "scale", Vector2.ONE, 0.15)
	# (เอาบรรทัดที่ tween ขยับ position ทิ้งไปเลย เพราะตัวละครอยู่ที่จุดเกิดเรียบร้อยแล้ว)

# แก้ไขแล้ว: ให้การยืดหดตอนกระโดดอ้างอิงจากขนาดสเกลปัจจุบัน ไม่เพี้ยนเป็นสเกล 1
func jump_tween():
	var current_scale = player_node.scale
	var tween = create_tween()
	tween.tween_property(player_node, "scale", Vector2(current_scale.x * 0.8, current_scale.y * 1.2), 0.1)
	tween.tween_property(player_node, "scale", current_scale, 0.1)

func damage_tween():
	var tween = create_tween() 
	tween.stop(); tween.play()
	can_damage = false
	for i in range(1,10):
		tween.tween_property(player_node , "modulate", Color.RED, 0.1)
		tween.tween_property(player_node , "modulate", Color.WHITE, 0.1)
	await tween.finished
	can_damage = true

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(body):
	if body.is_in_group("Traps"):
		take_damage_from_trap() # เปลี่ยนมาเรียกฟังก์ชันลดเลือดแทน
		return
		
	if !can_damage: return
	
	if body.is_in_group("Enemy"):
		# เด้งตัวผู้เล่นออกเมื่อโดนชน
		var dx = body.position.x - position.x
		velocity.y = -400
		if dx > 0:
			velocity.x = -300
		else:
			velocity.x = 300					
		
		# 1. ลดชีวิตใน GameManager ลง 1
		GameManager.life -= 1
		
		# 2. เช็กว่าชีวิตหมดหรือยัง?
		if GameManager.life <= 0:
			hit_enemy.emit() # ส่งสัญญาณบอกเกมว่าตายแล้ว (Game Over)
			death_tween()    # เล่นอนิเมชันตาย
		else:
			damage_tween()   # ถ้ายังไม่ตาย ให้กะพริบอมตะชั่วคราว (can_damage = false)

# ฟังก์ชันจัดการเมื่อโดนกับดัก หรือเดินตกเหว
func take_damage_from_trap():
	if !can_damage: return
	
	GameManager.life -= 1
	
	if GameManager.life <= 0:
		hit_trap.emit() # สัญญาณบอกเกมว่าตายจากกับดัก (Game Over)
		death_tween()
	else:
		# ถ้าหัวใจยังเหลือ ให้รีสปอว์นกลับจุดเกิดล่าสุด และกะพริบอมตะ
		global_position = spawn_point
		velocity = Vector2.ZERO
		
		# --- จุดที่เพิ่มเข้ามา: สั่งให้กล้องวาร์ปมาที่จุดเกิดทันที ---
		if has_node("Camera2D"):
			$Camera2D.reset_smoothing()
		# ----------------------------------------------
			
		damage_tween()

func handle_shooting():
	if Input.is_action_just_pressed("Shoot") and movement_enabled and shoot_cooldown_timer <= 0:
		shoot()

func shoot():
	if bullet_scene == null:
		return
	is_attacking = true
	player_sprite.play("punch")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_marker.global_position
	var angle = deg_to_rad(randf_range(0, 20))
	var sign_x = 1.0 if player_node.scale.x > 0 else -1.0
	var dir = Vector2(cos(angle) * sign_x, -sin(angle))
	get_parent().add_child(bullet)
	bullet.shoot(dir, 600, bullet_lifetime)
	shoot_cooldown_timer = shoot_cooldown_time

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Attack":
		is_attacking = false
