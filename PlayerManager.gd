extends Node


signal rapid
signal life_lost
signal expansion
signal pause
signal restart


func spawnPlayer(path, spawn, speed):
	var player_resource = load(path)
	var player = player_resource.instance()
	player.speed = speed
	player.start = spawn
	player.connect("rapid", self, "rapid")
	player.connect("life_lost", self, "life_lost")
	player.connect("expansion", self, "expansion")
	player.connect("pause", self, "pause")
	player.connect("restart", self, "restart")
	player.connect("damage", self, "do_damage")
	self.add_child(player)
	

func despawnPlayer():
	for player in self.get_children():
		self.remove_child(player)


func rapid():
	emit_signal("rapid")

func life_lost():
	emit_signal("life_lost")

func expansion(nb = 0):
	emit_signal("expansion", nb)

func pause():
	emit_signal("pause")

func restart():
	emit_signal("restart")


func do_damage():
	for player in self.get_children():
		player.do_damage()


func stop():
	for player in self.get_children():
		player.stop()
