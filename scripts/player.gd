extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -420.0
const ATTACK_DURATION := 0.12
const ATTACK_COOLDOWN := 0.25

@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var facing := 1
var attack_timer := 0.0
var attack_cooldown_timer := 0.0
var hit_targets: Array[Node] = []


func _ready() -> void:
	_setup_attack_input()
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	if not is_on_floor():
		velocity.y += gravity * delta

	var move_input := Input.get_axis("ui_left", "ui_right")
	if move_input != 0.0:
		facing = 1 if move_input > 0.0 else -1
	velocity.x = move_input * SPEED

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			_end_attack()

	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
		_start_attack()

	move_and_slide()


func _setup_attack_input() -> void:
	if InputMap.has_action("attack"):
		return
	InputMap.add_action("attack")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_J
	InputMap.action_add_event("attack", event)


func _start_attack() -> void:
	attack_cooldown_timer = ATTACK_COOLDOWN
	attack_timer = ATTACK_DURATION
	hit_targets.clear()
	attack_hitbox.monitoring = true
	attack_shape.disabled = false
	attack_shape.position.x = abs(attack_shape.position.x) * facing


func _end_attack() -> void:
	attack_hitbox.monitoring = false
	attack_shape.disabled = true


func _on_attack_hitbox_body_entered(body: Node) -> void:
	if attack_timer <= 0.0:
		return
	if body in hit_targets:
		return
	if body.has_method("take_hit"):
		body.take_hit(1)
		hit_targets.append(body)
