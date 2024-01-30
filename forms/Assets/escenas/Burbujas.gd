extends Area2D

@onready var Sp = $Sprite2D
@export var forma :int
var player
@onready var anim = $AnimationPlayer
var active = true
# Called when the node enters the scene tree for the first time.
func _ready():
	Sp.frame = forma


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		if player.form != forma and active == false:
			active = true
			anim.play("active")


func _on_body_entered(body):
	if body.is_in_group("player"):
		if player == null:
			player = body
		body.Cambio(forma)
		if player.form == forma and active == true:
			anim.play("desactive")
			active = false

