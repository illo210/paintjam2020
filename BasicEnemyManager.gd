extends Node

signal expansion
signal end_expansion
signal damage
signal game_over


func spawnEnemy(path, spawn, tile, speed):
	var enemy_resource = load(path)
	var enemy = enemy_resource.instance()
	enemy.expansion_time = 1 / speed
	enemy.tileset_id = tile
	enemy.start = spawn
	enemy.connect("damage", self, "damage")
	enemy.connect("expansion", self, "expansion")
	enemy.connect("end_expansion", self, "end_expansion")
	enemy.connect("game_over", self, "game_over")
	self.add_child(enemy)
	
func damage():
	self.emit_signal("damage")
	
func expansion():
	self.emit_signal("expansion")
	
func end_expansion():
	self.emit_signal("end_expansion")
	
func game_over():
	self.emit_signal("game_over")
	
func despawnEnemies():
	for enemy in self.get_children():
		self.remove_child(enemy)

func pause():
	for enemy in self.get_children():
		enemy.pause()

func stop():
	for enemy in self.get_children():
		enemy.stop()

func acceleration():
	for enemy in self.get_children():
		enemy.acceleration()
