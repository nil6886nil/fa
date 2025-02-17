extends Node2D


func _process(delta):
	if Server.world:
		if has_node("/root/World"):
			var location = Tiles.ocean_tiles.world_to_map(Server.player_node.position)
			if Tiles.isCenterBitmaskTile(location, Tiles.deep_ocean_tiles):
				if Sounds.current_footsteps_sound != Sounds.swimming:
					Sounds.current_footsteps_sound = Sounds.swimming
					Sounds.emit_signal("footsteps_sound_change")
			else:
				if Sounds.current_footsteps_sound == Sounds.swimming:
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
				

func _ready():
	if has_node("/root/World"):
		Sounds.current_footsteps_sound = Sounds.dirt_footsteps
	else:
		Sounds.current_footsteps_sound = Sounds.stone_footsteps


func _on_DetectWoodPath_area_entered(area):
	if Sounds.current_footsteps_sound != Sounds.wood_footsteps:
		Sounds.current_footsteps_sound = Sounds.wood_footsteps
		Sounds.emit_signal("footsteps_sound_change")

func _on_DetectWoodPath_area_exited(area):
	if $DetectWoodPath.get_overlapping_areas().size() <= 0 and $DetectStonePath.get_overlapping_areas().size() <= 0:
		Sounds.current_footsteps_sound = Sounds.dirt_footsteps
		Sounds.emit_signal("footsteps_sound_change")

func _on_DetectStonePath_area_entered(area):
	if Sounds.current_footsteps_sound != Sounds.stone_footsteps:
		Sounds.current_footsteps_sound = Sounds.stone_footsteps
		Sounds.emit_signal("footsteps_sound_change")

func _on_DetectStonePath_area_exited(area):
	if $DetectStonePath.get_overlapping_areas().size() <= 0 and $DetectWoodPath.get_overlapping_areas().size() <= 0:
		Sounds.current_footsteps_sound = Sounds.dirt_footsteps
		Sounds.emit_signal("footsteps_sound_change")



