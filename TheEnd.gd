extends Node2D

var player_score
var table_id = 489992
var node_name

func _ready():
	node_name = $CanvasLayer/HighscoreInput/VBoxContainer/CenterContainer/Name
	$CanvasLayer/HighscoreInput.hide()
	$CanvasLayer/Highscore.hide()
	node_name.text = ""
	player_score = $"/root/Global".score
	$CanvasLayer/HighscoreInput/Score.text = "Score: " + str(player_score)
	node_name.placeholder_text = "Enter name"
	$GameJoltAPI.open_session()
	var timer = Timer.new()
	timer.connect("timeout", self, "ping")
	self.add_child(timer)
	timer.start(60)


func ping():
	$GameJoltAPI.ping_session()


func get_pname():
	if node_name.text == "":
		node_name.text = "guest" + str(randi() % 10000)
	return node_name.text.replace(" ", "") 

func submit_score(score):
	var guest_name = get_pname()
	$GameJoltAPI.add_score(str(score), int(score), "", "", guest_name, table_id)


func api_scores_added(_success):
	get_score()


func get_score():
	$GameJoltAPI.fetch_scores('', '', 10, table_id)

func add_line(nb, rank, name, score, color=false):
	var anchor = $CanvasLayer/Highscore/VBoxContainer.get_child(nb - 1);
	var highscoreline_ressource = load("res://HighscoreLine.tscn")
	var highscoreline = highscoreline_ressource.instance()
	$CanvasLayer/Highscore/VBoxContainer.add_child_below_node(anchor, highscoreline)
	highscoreline.get_node("Rank").text = str(rank)
	highscoreline.get_node("Username").text = str(name)
	highscoreline.get_node("Score").text = str(score)
	if color == true:
		highscoreline.modulate = Color(1, 0.2, 0.2)
		pass


func api_scores_fetched(data):
	var score = parse_json(data)
	var i = 1
	for score in score.get("response").get("scores"):
		add_line(i, i, score.get("guest"), score.get("score"))
		i += 1
	$GameJoltAPI.get_ranking(player_score, table_id)


func api_fetch_rank(data):
	var rank = parse_json(data).get("response").get("rank")
	if rank > 10:
		add_line(11, rank, get_pname(), player_score, true)

func api_session_opened(_success):
	$CanvasLayer/HighscoreInput.show()


func submit_name():
	$CanvasLayer/HighscoreInput.hide()
	$CanvasLayer/Highscore.show()
	submit_score(player_score)

func restart():
	get_tree().change_scene("res://screen.tscn")

func exit():
	get_tree().quit()
