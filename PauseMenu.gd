extends Control

signal pause


func resume():
	emit_signal("pause")

func exit():
	get_tree().quit()
