extends PanelContainer

func _ready():
	set_process(false)
	Defs.connect("TipsUpdated", self, "OnTipsUpdated")
	Defs.connect("LifesUpdated", self, "OnUpdatedLife")

func OnUpdatedLife(NewVal):
	$CenterContainer/HBoxContainer/LifeValue.text = str(NewVal)

func OnTipsUpdated(NewVal):
	$CenterContainer/HBoxContainer/PointsValue.text = str(NewVal)
