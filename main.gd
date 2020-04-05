extends Node2D

signal stop

var game_over_nb = 0
var lost_life = 0
var total_coverage = 0
var stopped_enemies = 0
var occupied_tile = 3
var total_tile = 0
var end_game = false
var time = 0
var timer
var nb_life = 3.0
var is_paused = false
var cells
var level_number = 0
var level = [["Basis", "", [["res://player.tscn", Vector2(7, 7), 4]],
				[["res://Enemy.tscn", Vector2(5, 5), 3, 1], ["res://Enemy.tscn", Vector2(2, 30), 4, 1], ["res://Enemy.tscn", Vector2(57, 43), 5, 1]]],
			["Advanced Basis", "", [["res://player.tscn", Vector2(7, 7), 4]],
				[["res://Enemy.tscn", Vector2(5, 5), 3, 2.5], ["res://Enemy.tscn", Vector2(2, 30), 4, 5], ["res://Enemy.tscn", Vector2(57, 43), 5, 2.5]]],
			["Social distancing at its finest", "", [["res://player.tscn", Vector2(7, 7), 4]],
				[["res://SprawlEnemy.tscn", Vector2(5, 5), 3, 2.5], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 2.5], ["res://SprawlEnemy.tscn", Vector2(57, 43), 5, 2.5]]],
			["Such a divine wind", "", [["res://starplayer.tscn", Vector2(7, 7), 8]],
				[["res://SprawlEnemy.tscn", Vector2(5, 5), 3, 6.0], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 6.0], ["res://SprawlEnemy.tscn", Vector2(57, 43), 5, 6.0]]],
			["Sugar rush", "", [["res://sugarplayer.tscn", Vector2(7, 7), 12]],
				[["res://SprawlEnemy.tscn", Vector2(5, 5), 3, 6.0], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 6.0], ["res://SprawlEnemy.tscn", Vector2(57, 43), 5, 6.0]]],
			["BulletProof", "", [["res://starplayer.tscn", Vector2(7, 7), 8]],
				[["res://BulletEnemy.tscn", Vector2(5, 5), 3, 7.0], ["res://BulletEnemy.tscn", Vector2(2, 30), 4, 7.0], ["res://BulletEnemy.tscn", Vector2(57, 43), 5, 7.0]]],
			["Now don't catch it with your teeth", "", [["res://player.tscn", Vector2(7, 7), 4]],
				[["res://BulletEnemy.tscn", Vector2(5, 5), 3, 5.0], ["res://BulletEnemy.tscn", Vector2(2, 30), 4, 5.0], ["res://BulletEnemy.tscn", Vector2(57, 43), 5, 5.0]]],
			["Eeeeeeh Macarena", "", [["res://MacarenaPlayer.tscn", Vector2(7, 7), 5]],
				[["res://Enemy.tscn", Vector2(5, 5), 3, 5.0], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 5.0], ["res://BulletEnemy.tscn", Vector2(57, 43), 5, 5.0]]],
			["Eeeeeeh Macaroomba !", "", [["res://MacaroombaPlayer.tscn", Vector2(7, 7), 6]],
				[["res://Enemy.tscn", Vector2(5, 5), 3, 5.0], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 5.0], ["res://BulletEnemy.tscn", Vector2(57, 43), 5, 5.0]]],
			["Did I already drank that much ?", "", [["res://player.tscn", Vector2(7, 7), 4,], ["res://invertedplayer.tscn", Vector2(1016, 708), 4]],
				[["res://SprawlEnemy.tscn", Vector2(5, 5), 3, 2.5], ["res://SprawlEnemy.tscn", Vector2(2, 30), 4, 2.5], ["res://BulletEnemy.tscn", Vector2(57, 43), 5, 5.0]]]]

func pause():
	is_paused = not is_paused
	if is_paused == true:
		$HUD.show_pause_menu()
	else:
		$HUD.hide_pause_menu()
		
func calculate_score():
	var score = 0
	score += time
	score += lost_life * 10
	score += game_over_nb * 50
	score += total_coverage
	$"/root/Global".score = score
		
func launch_level():
	is_paused = true
	stopped_enemies = 0
	occupied_tile = 3
	total_tile = 0
	for _cell in $TileMap.get_used_cells_by_id(1):
		total_tile += 1
	end_game = false
	nb_life = (4.0 if level_number != len(level) - 1 else 3.5)
	life_lost()
	$HUD.update_coverage(int(occupied_tile * 100 / total_tile ))
	$HUD.show_message(level[level_number][0])
	yield(get_tree().create_timer(5), "timeout")
	$HUD.hide_message()
	is_paused = false
	timer = Timer.new()
	timer.connect("timeout", self, "update_time")
	self.add_child(timer)
	timer.start()
	for i in range(len(level[level_number][2])):
		print(i)
		$PlayerManager.spawnPlayer(level[level_number][2][i][0], level[level_number][2][i][1], level[level_number][2][i][2])
	for i in range(len(level[level_number][3])):
		$BasicEnemyManager.spawnEnemy(level[level_number][3][i][0], level[level_number][3][i][1], level[level_number][3][i][2], level[level_number][3][i][3])
	
func restart():
	for pos in cells:
		$TileMap.set_cellv(pos, 1)
	$PlayerManager.despawnPlayer()
	$BasicEnemyManager.despawnEnemies()
	timer.queue_free()
	launch_level()

func _ready():
	randomize()
	cells = $TileMap.get_used_cells_by_id(1)
	launch_level()

func game_over():
	if end_game == false:
		end_game = true
		game_over_nb += 1
		$HUD.show_message("GAME OVER !!!")
		emit_signal("stop")

func expansion(nb = 1):
	occupied_tile += nb
	$HUD.update_coverage(int(occupied_tile * 100 / total_tile ))

func end_expansion():
	stopped_enemies += 1
	if stopped_enemies >= 3:
		if end_game == false:
			end_game = true
			$HUD.show_message("GG !!!")
			total_coverage += occupied_tile
			yield(get_tree().create_timer(5), "timeout")
			if level_number != len(level) - 1:
				level_number += 1
				restart()
			else:
				calculate_score()
				get_tree().change_scene("res://TheEnd.tscn")
		
func update_time():
	if end_game == false and is_paused == false:
		time += 1
		$HUD.update_time(time)
	
func life_lost():
	nb_life -= (1.0 if level_number != len(level) - 1 else 0.5)
	lost_life += (1.0 if level_number != len(level) - 1 else 0.5)
	$HUD.update_live(nb_life)
	if nb_life <= 0:
		game_over()
