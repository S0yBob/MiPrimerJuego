extends CharacterBody2D

@onready var SP = $P_Sprite
@onready var anim = $AnimationPlayer
var direction
var regulator
var form = 0
var cambio = true
@onready var Checkpoint = position
var dead = false
var pos
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

#hoctagono
var trepando
var pared
var techo

const SPEED = 300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	if !dead:
		move(delta)
		jump(delta)
		dash(delta)
		rebote()
		trepar()
	if Input.is_action_just_pressed("buton4"):
		position = Checkpoint

func move(delta):
	if !dashing and form != 2:
		direction = Input.get_axis("ui_left", "ui_right")
	if direction and !dashing:
		if form == 0 and velocity.x != 0:
			SP.rotation += 10 * direction * delta
		if form != 2:
			velocity.x = direction * SPEED
	elif dashing:
		if  dashpos < 2:
			velocity.x = dashpos * SPEED * 4
		else:
			velocity.y = JUMP_VELOCITY * 2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if form != 2:
		move_and_slide()

func jump(delta):
	if not is_on_floor() and !dashing and !trepando:
		velocity.y += gravity * delta
	elif dashing:
		velocity.y = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and form == 0 and !active:
		velocity.y = JUMP_VELOCITY

func Cambio(forma):
	if forma != form:
		anim.play("C_pelota")
		form = 0
	if forma != form:
		anim.play("C_cubo")
		form = 1
	if  forma != form:
		anim.play("C.Hoctagono")
		form=2

func dash(delta):
	if dashing:
		if pared and velocity.x == 0 and dashpos < 2 or techo and velocity.y == 0 and dashpos == 2:
			dashing = false
	if DashUses < 1 and is_on_floor() and !dashing:
		DashUses = 1
	if !dashing and form == 1:
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
	if Input.is_action_just_pressed("buton3") and form == 0:
		if !active:
			active = true
		else:
			active = false
	elif form != 0:
		active = false
	if active:
		if not is_on_floor():
			ReboundForce = velocity.y
		elif is_on_floor() and ReboundForce > 0:
			velocity.y -= ReboundForce - 100
		elif ReboundForce != 0:
			ReboundForce = 0

func trepar():
	if form == 2:
		var vertical = Input.get_axis("ui_left", "ui_right")
		var horizontal = Input.get_axis("ui_up", "ui_down")
		if pared:
			velocity.y = SPEED* horizontal
		if techo or is_on_floor() or !techo and !pared:
			velocity.x = SPEED * vertical
		move_and_slide()
		if techo or pared :
			trepando = true
		else:
			trepando = false
	else:
		trepando = false

func revive(hit):
	dead = hit
	if dead:
		anim.play("Daño")
	$"Timers/daño".start(1)

func _on_dash_timeout():
	dashing = false

func _on_cambio_timeout():
	cambio = true

func _on_trepar_body_entered(body):
	if form == 2 or dashing:
		if body.is_in_group("pared"):
			pared = true
		if body.is_in_group("techo"):
			techo = true

func _on_trepar_body_exited(body):
	if body.is_in_group("pared"):
		pared = false
	if body.is_in_group("techo"):
		techo = false

func _on_daño_area_entered(area):
	print(area.name)
	if area.is_in_group("Enemigo"):
		dead = true
		revive(Checkpoint)


func _on_daño_timeout():
	position = Checkpoint
	dead = false
