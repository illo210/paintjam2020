extends Node

signal damage
signal expansion
signal end_expansion
signal game_over

var expansion_time = 0.5
var tileset_id = 0
var start
var tilemap
var end = false
var is_paused = false
var y = null
var current_time = 0.0
###########################
var possible_tiles = []
var expansion = false

func pause():
	is_paused = not is_paused

func stop():
	print("end send")
	emit_signal("end_expansion")
	end = true

func acceleration():
	expansion = true
	expansion_time /= 10000

func _ready():
	tilemap = get_node("../../TileMap")
	tilemap.set_cellv(start, tileset_id)
	
func get_around():
	var delta = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	for i in range(4):
		possible_tiles.append([start + delta[i], i])
	while len(possible_tiles) > 0:
		var idx = (randi() + tileset_id) % len(possible_tiles)
		var tile_pair = possible_tiles[idx]
		var pos = tile_pair[0]
		var v = tile_pair[1]
		possible_tiles.remove(idx)
		var length = 10 + randf() * 10
		var initial_length = length
		while length > 0:
			var t = tilemap.get_cellv(pos)
			if t == 0 or t == tileset_id:
				break
			if t == 2:
				emit_signal("damage")
				yield()
				continue
			if t > 2:
				emit_signal("game_over")
			tilemap.set_cellv(pos, tileset_id)
			for i in range(4):
				if i != (v + 2 % 4): # Never go back
					possible_tiles.append([pos + delta[i], i])
			pos += delta[v]
			length -= 1
			emit_signal("expansion")
			yield()
		if initial_length != length and expansion == false:
			current_time *= 10
			yield()
			current_time /= 10
	stop()

func _process(delta):
	if is_paused != true:
		if end == false:
			if y == null:
				y = get_around()
			current_time += delta
			if current_time > expansion_time:
				y = y.resume()
				current_time -= expansion_time
