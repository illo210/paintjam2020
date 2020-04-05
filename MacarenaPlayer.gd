extends Area2D

signal rapid
signal life_lost
signal expansion
signal pause
signal restart
signal damage

var speed = 4
var is_on_screen
var old_position = null
var start
var old_velocity
var screen_size
var sprite_size
var current_trail = []
var invulnerable = false
var tile_map
var is_paused = false
var input_array = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
var input_idx = 0

func pause():
	emit_signal("pause")
	is_paused = not is_paused

func _ready():
	position = start
	is_on_screen = false
	old_velocity = Vector2()
	screen_size = get_viewport_rect().size
	sprite_size = $AnimatedSprite.frames.get_frame("default", 0).get_size();
	tile_map = get_node("../../TileMap")
	var timer = Timer.new()
	timer.connect("timeout", self, "macarena")
	self.add_child(timer)
	timer.start(5)
	
func macarena():
	input_idx = (input_idx + 1) % 4
	$AnimatedSprite.modulate = Color(0.5, 1, 0.5)
	yield(get_tree().create_timer(1), "timeout")
	$AnimatedSprite.modulate = Color(1, 1, 1)

func clamp_pos(pos, extrem = 0):
	var x = 1 if extrem else 0
	pos.x = clamp(pos.x, sprite_size.x / 2 * x, screen_size.x - 0.5 * sprite_size.x)
	pos.y = clamp(pos.y, sprite_size.y / 2 * x, screen_size.y - 3 * sprite_size.y - 0.5 * sprite_size.y)
	return pos

func move(delta):
	var velocity = Vector2()
	if is_on_screen == false and invulnerable == false:
		if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
			if Input.is_action_pressed("ui_right"):
				velocity += input_array[input_idx]
			else:
				velocity += input_array[(input_idx + 2) % 4]
		else:
			if Input.is_action_pressed("ui_down"):
				velocity += input_array[(input_idx + 1) % 4]
			elif Input.is_action_pressed("ui_up"):
				velocity += input_array[(input_idx + 3) % 4]
		velocity = velocity.normalized() * speed * 100
	else:
		velocity = old_velocity
	var tmp = position
	position = Vector2()
	position = tmp + velocity * delta
	position = clamp_pos(position)
	if velocity.length() > 0:
		old_velocity = velocity
	collide()


func _process(delta):
	if is_paused != true:
		if Input.is_action_just_released("ui_rapid") and is_on_screen == false:
			emit_signal("rapid")
			stop()
			return
		move(delta)
	if Input.is_action_just_released("ui_restart"):
		emit_signal("restart")
	if Input.is_action_just_released("ui_cancel"):
		pause()


func do_damage():
	if invulnerable == true:
		return
	invulnerable = true
	is_on_screen = false
	old_position = null
	emit_signal("life_lost")
	for cell in current_trail:
		tile_map.set_cellv(cell, 1)
	current_trail.clear()
	old_velocity = Vector2(0, 0)
	position = start
	$AnimatedSprite.modulate = Color(1, 0.5, 0.5)
	yield(get_tree().create_timer(2), "timeout")
	$AnimatedSprite.modulate = Color(1, 1, 1)
	invulnerable = false


func validate_screen():
	var nb = 0
	for cell in current_trail:
		nb += 1
		tile_map.set_cellv(cell, 0)
	emit_signal("expansion", nb)
	current_trail.clear()


func check_behind(loc):
	while old_position != loc:
		if tile_map.get_cellv(old_position) != 0:
			tile_map.set_cellv(old_position, 2)
			current_trail.append(old_position)
		else:
			validate_screen()
		old_position += old_velocity.normalized()


func collide():
	var loc = tile_map.world_to_map(tile_map.to_local(position))
	var idx = tile_map.get_cellv(loc)
	if idx == 0 and is_on_screen == true:
		is_on_screen = false
		check_behind(loc)
		validate_screen()
		old_position = null
	elif idx > 2:
		emit_signal("damage")
	elif idx != 0 and old_velocity.length() != 0:
		is_on_screen = true
		if old_position != null:
			check_behind(loc)
			old_position = loc
		else:
			old_position = loc
			while tile_map.get_cellv(old_position) > 0:
				old_position -= old_velocity.normalized()
				old_position = clamp_pos(old_position, false)

func stop():
	invulnerable = true
	old_velocity = Vector2()
	is_on_screen = false
	old_position = null
	for cell in current_trail:
		tile_map.set_cellv(cell, 1)
	current_trail.clear()
	old_velocity = Vector2(0, 0)
	position = start

