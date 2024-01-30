extends Area2D

var pos :Vector2
@onready var Sp = $Sprite2D
@onready var Tr = Vector2(position.x, position.y)
var player 

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	if Sp.frame == 1:
		pos = player.Checkpoint
	if pos == position and Sp.frame == 0:
		Sp.frame = 1
	elif pos != position and Sp.frame == 1:
		Sp.frame = 0

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		body.Checkpoint = Tr
		pos = body.Checkpoint
