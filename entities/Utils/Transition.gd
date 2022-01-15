extends CanvasLayer

signal AnimationFinished

const BLACK = Color(0,0,0,1)
const TRANSPARENT = Color(0,0,0,0)

func _ready():
	set_process(false)
	ShadeOut(2)

func SetBlack():
	$ColorRect.color = BLACK
	
func SetTransparent():
	$ColorRect.color = TRANSPARENT

func ShadeIn(Duration):
	Animate(0, Duration)
	
func ShadeOut(Duration):
	Animate(1, Duration)

func Animate(ShadeType, Duration):
	var FROM = BLACK if ShadeType else TRANSPARENT
	var TO = TRANSPARENT if ShadeType else BLACK
	$Tween.interpolate_property($ColorRect, "color", FROM, TO, Duration, Tween.TRANS_QUAD)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("AnimationFinished")
