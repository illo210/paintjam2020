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
var size = 0

func pause():
	is_paused = not is_paused

func stop():
	print("end send")
	emit_signal("end_expansion")
	end = true

func acceleration():
	expansion_time /= 100

func is_valid(p):
	var n = 0
	var t = tilemap.get_cellv(p)
	if t == 0:
		return false
	var delta = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	for i in range(4):
		var tmp = p + delta[i]
		t = tilemap.get_cellv(tmp)
		if t == tileset_id:
			n += 1
	return n >= 1

func get_around():
	var c = true
	while c == true:
		c = false
		size += 1
		var starts = [start, start, start, start]
		var delta = [Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0)]
		for i in range(4):
			starts[i] = starts[i] + delta[i] * size
		for j in range (size + 1):
			for i in range(4):
				var tmp = [starts[i] + delta[(i + 1) % 4] * j, starts[i] - delta[(i + 1) % 4] * j]
				for k in range(2):
					if is_valid(tmp[k]):
						var t = tilemap.get_cellv(tmp[k])
						if t == 2:
							emit_signal("damage")
						if t > 2 and t != tileset_id:
							emit_signal("game_over")
						else:
							tilemap.set_cellv(tmp[k], tileset_id)
						c = true
						emit_signal("expansion")
			yield()
			if end == true:
				return
	stop()
	end = true

func _ready():
	tilemap = get_node("../../TileMap")
	tilemap.set_cellv(start, tileset_id)


func _process(delta):
	if is_paused != true:
		if end == false:
			if y == null:
				y = get_around()
			current_time += delta
			if current_time > expansion_time:
				y = y.resume()
				current_time -= expansion_time
