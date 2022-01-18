extends PanelContainer

func _ready():
	set_process(false)
	Defs.connect("TipsUpdated", self, "OnTipsUpdated")
	Defs.connect("LifesUpdated", self, "OnUpdatedLife")

puppet func OnUpdatedLife(NewVal):
	rpc("OnUpdatedLife", NewVal)
	$CenterContainer/HBoxContainer/LifeValue.text = str(NewVal)

puppet func OnTipsUpdated(NewVal):
	rpc("OnTipsUpdated", NewVal)
	$CenterContainer/HBoxContainer/PointsValue.text = str(NewVal)
