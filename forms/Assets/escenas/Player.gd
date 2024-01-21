extends CharacterBody2D

@onready var SP = $P_Sprite
@onready var anim = $AnimationPlayer

var direction
var regulator
var form = 1

#cubo
var dashing
var doubleTapTime = 0.2
var tapCount = 0
var tapTimer = 0
var DashActive
var DashUses = 0
var dashpos = 0

#pelota
var ReboundForce = 0
var active 
const JUMP_VELOCITY = -600.0

const SPEED = 300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	animacion()
	move(delta)
	jump(delta)
	dash(delta)
	rebote()

func move(delta):
	if !dashing:
		direction = Input.get_axis("ui_left", "ui_right")
	if direction and !dashing:
		if form == 1:
			SP.rotation += 10 * direction * delta
		velocity.x = direction * SPEED
	elif dashing:
		if  dashpos < 2:
			velocity.x = dashpos * SPEED * 4
		else:
			velocity.y = JUMP_VELOCITY * 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func jump(delta):
	if not is_on_floor() and !dashing:
		velocity.y += gravity * delta
	elif dashing:
		velocity.y = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and form == 1:
		velocity.y = JUMP_VELOCITY

func animacion():
	if Input.is_action_just_pressed("buton1") :
		anim.play("C_pelota")
		form = 1
	elif  Input.is_action_just_pressed("buton2"):
		anim.play("C_cubo")
		form=2

func dash(delta):
	if DashUses < 1 and is_on_floor():
		DashUses = 1
	if !dashing and form == 2:
		if Input.is_action_just_pressed("ui_right"):
			if tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0 and dashpos == 1:
				tapCount = 0
				DashUses -= 1
				dashing = true
				$Timers/Dash.start(0.3)
			elif tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0:
				dashpos = 1
				tapTimer = 0
			else:
				tapCount += 1
				tapTimer = 0
				dashpos = 1
		elif Input.is_action_just_pressed("ui_left"):
			if tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0 and dashpos == -1:

				tapCount = 0
				DashUses -= 1
				dashing = true
				$Timers/Dash.start(0.3)
			elif tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0:
				dashpos = -1
				tapTimer = 0
			else:
				tapCount += 1
				tapTimer = 0
				dashpos = -1
		elif Input.is_action_just_pressed("ui_up"):
			if tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0 and dashpos == 2:
				tapCount = 0
				DashUses -= 1
				dashing = true
				$Timers/Dash.start(0.3)
			elif tapCount == 1 and tapTimer < doubleTapTime and DashUses > 0:
				dashpos = 2
				tapTimer = 0
			else:
				tapCount += 1
				tapTimer = 0
				dashpos = 2
	if dashpos != 0:
		tapTimer += delta
		if tapTimer > doubleTapTime and !dashing:
			dashpos = 0
			tapCount = 0

func rebote():
	if Input.is_action_just_pressed("buton4") and form == 1:
		if !active:
			active = true
			print(active)
		else:
			active = false
			print(active)
	elif form != 1:
		active = false
	if active:
		if not is_on_floor():
			ReboundForce = velocity.y
		elif is_on_floor() and ReboundForce > 0:
			velocity.y -= ReboundForce - 100
		elif ReboundForce != 0:
			ReboundForce = 0

func _on_dash_timeout():
	dashing = false
