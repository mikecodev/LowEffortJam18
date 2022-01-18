extends PanelContainer

func _ready():
	set_process(false)
	Defs.connect("TipsUpdated", self, "OnTipsUpdated")
	Defs.connect("LifesUpdated", self, "OnUpdatedLife")

puppet func OnUpdatedLife(NewVal):
	if is_network_master():
		rpc("OnUpdatedLife", NewVal)
	$CenterContainer/HBoxContainer/LifeValue.text = str(NewVal)

puppet func OnTipsUpdated(NewVal):
	if is_network_master():
		rpc("OnTipsUpdated", NewVal)
	$CenterContainer/HBoxContainer/PointsValue.text = str(NewVal)
