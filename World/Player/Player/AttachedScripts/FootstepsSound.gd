extends AudioStreamPlayer


func _ready():
	volume_db = Sounds.return_adjusted_sound_db("footstep", -10)
	Sounds.connect("footsteps_sound_change", self, "set_footsteps_sound")
	Sounds.connect("volume_change", self, "set_new_music_volume")
	set_footsteps_sound()


func set_footsteps_sound():
	stop()
	stream = Sounds.current_footsteps_sound
	set_new_music_volume()
	yield(get_tree(), "idle_frame")
	play()
	if Sounds.current_footsteps_sound == Sounds.dirt_footsteps:
		get_node("../../").is_walking_on_dirt = true
	else:
		get_node("../../").is_walking_on_dirt = false


func set_new_music_volume():
	if Sounds.current_footsteps_sound == Sounds.stone_footsteps:
		volume_db = Sounds.return_adjusted_sound_db("footstep", 0)
	else: 
		volume_db = Sounds.return_adjusted_sound_db("footstep", -10)


func _process(delta):
	if Server.world:
		if has_node("/root/World"):
			var location = Tiles.ocean_tiles.world_to_map(Server.player_node.position)
			if Tiles.isCenterBitmaskTile(location, Tiles.deep_ocean_tiles):
				if Sounds.current_footsteps_sound != Sounds.swimming:
					Sounds.current_footsteps_sound = Sounds.swimming
					Sounds.emit_signal("footsteps_sound_change")
			elif Tiles.isCenterBitmaskTile(location, Tiles.ocean_tiles):
				if Sounds.current_footsteps_sound != null:
					play_water_step_sound()
					Sounds.current_footsteps_sound = null
					Sounds.emit_signal("footsteps_sound_change")
			elif Tiles.foundation_tiles.get_cellv(location) == 0 or Tiles.foundation_tiles.get_cellv(location) == 1:
				if Sounds.current_footsteps_sound != Sounds.wood_footsteps:
					Sounds.current_footsteps_sound = Sounds.wood_footsteps
					Sounds.emit_signal("footsteps_sound_change")
			elif Tiles.foundation_tiles.get_cellv(location) != -1:
				if Sounds.current_footsteps_sound != Sounds.stone_footsteps:
					Sounds.current_footsteps_sound = Sounds.stone_footsteps
					Sounds.emit_signal("footsteps_sound_change")
			else:
				if Sounds.current_footsteps_sound != Sounds.dirt_footsteps:
					Sounds.current_footsteps_sound = Sounds.dirt_footsteps
					Sounds.emit_signal("footsteps_sound_change")
		else:
			var location = Tiles.ocean_tiles.world_to_map(Server.player_node.position)
			if Server.world.has_node("Tiles/BridgeTiles"):
				if Server.world.get_node("Tiles/BridgeTiles").get_cellv(location) != -1:
					if Sounds.current_footsteps_sound != Sounds.wood_footsteps:
						Sounds.current_footsteps_sound = Sounds.wood_footsteps
						Sounds.emit_signal("footsteps_sound_change")
				elif Server.world.get_node("Tiles/Floors3").get_cellv(location) != -1 or Server.world.get_node("Tiles/Floors4").get_cellv(location) != -1:
					if Sounds.current_footsteps_sound != Sounds.dirt_footsteps:
						Sounds.current_footsteps_sound = Sounds.dirt_footsteps
						Sounds.emit_signal("footsteps_sound_change")
				else:
					if Sounds.current_footsteps_sound != Sounds.stone_footsteps:
						Sounds.current_footsteps_sound = Sounds.stone_footsteps
						Sounds.emit_signal("footsteps_sound_change")
			elif Server.world.get_node("Tiles/Floors3").get_cellv(location) != -1 or Server.world.get_node("Tiles/Floors4").get_cellv(location) != -1:
				if Sounds.current_footsteps_sound != Sounds.dirt_footsteps:
					Sounds.current_footsteps_sound = Sounds.dirt_footsteps
					Sounds.emit_signal("footsteps_sound_change")
			else:
				if Sounds.current_footsteps_sound != Sounds.stone_footsteps:
					Sounds.current_footsteps_sound = Sounds.stone_footsteps
					Sounds.emit_signal("footsteps_sound_change")

func play_water_step_sound():
	if Util.chance(33):
		stream = load("res://Assets/Sound/Sound effects/Footsteps/water/water_step1.mp3")
	elif Util.chance(33):
		stream = load("res://Assets/Sound/Sound effects/Footsteps/water/water_step2.mp3")
	else:
		stream = load("res://Assets/Sound/Sound effects/Footsteps/water/water_step3.mp3")
	play()
	yield(self, "finished")
	yield(get_tree(), "idle_frame")
	play_water_step_sound()
