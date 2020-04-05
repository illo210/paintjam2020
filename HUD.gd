extends CanvasLayer

signal pause

func _ready():
	$Pause.hide()

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	
func hide_message():
	$MessageLabel.text = ""
	$MessageLabel.hide()
	
func update_coverage(percent):
	$ScoreLabel.text = "Coverage: " + str(percent) + "%"
	
func update_time(sec):
	$TimeLabel.text = "Time: " + str(sec)
	
func show_pause_menu():
	$Pause.show()
	
func hide_pause_menu():
	$Pause.hide()

func resume():
	emit_signal("pause")
	
func update_live(nb):
	for i in range(1, 4):
		var h = get_node("HBoxContainer/Heart" + str(i))
		if nb > i - 1:
			h.show()
		else:
			h.hide()
