extends MarginContainer

signal GameFinished(Points)

var Points = 0
var Life = 20

func _ready():
	set_process(false)

func UpdatePoints(Diff):
	Points = clamp(Points - Diff, 0, 5000)
	$HBoxContainer/PointsValue.text = Points

func UpdateLife(Diff):
	Life = clamp(Life - Diff, 0, 20)
	$HBoxContainer/LifeValue.text = Life
	if(Life == 0):
		emit_signal("GameFinished", Points)
