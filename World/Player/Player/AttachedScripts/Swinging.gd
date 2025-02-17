extends Node2D


onready var sound_effects = $SoundEffects
onready var axe_pickaxe_swing = $AxePickaxeSwing
onready var sword_swing = $SwordSwing
onready var watering_can_particles1 = $WateringCanParticles1
onready var watering_can_particles2 = $WateringCanParticles2

onready var player_animation_player = get_node("../CompositeSprites/AnimationPlayer")
onready var player_animation_player2 = get_node("../CompositeSprites/AnimationPlayer2")
onready var composite_sprites = get_node("../CompositeSprites")


var rng = RandomNumberGenerator.new()

var animation
var direction: String = "down"

enum {
	MOVEMENT, 
	SWINGING,
	EATING,
	FISHING,
	HARVESTING,
	DYING,
	SLEEPING,
	SITTING,
	MAGIC_CASTING,
	BOW_ARROW_SHOOTING
}


func swing(item_name, _direction):
	if get_parent().state != SWINGING:
		get_parent().state = SWINGING
		if item_name == "stone watering can" or item_name == "bronze watering can" or item_name == "gold watering can":
			set_watered_tile()
			animation = "watering_" + _direction.to_lower()
			player_animation_player.play("watering")
		elif item_name == "scythe" or item_name == "wood sword" or item_name == "stone sword" or item_name == "bronze sword" or item_name == "iron sword" or item_name == "gold sword":
			if get_node("../Magic").player_fire_buff:
				sword_swing.special_ability = "fire"
			else:
				sword_swing.special_ability = ""
			if item_name == "scythe":
				player_animation_player.play("scythe_swing_" + _direction.to_lower())
			else:
				sword_swing.tool_name = item_name
				player_animation_player.play("sword_swing_" + _direction.to_lower())
			animation = "sword_swing_" + _direction.to_lower()
			rng.randomize()
			sound_effects.stream = Sounds.sword_whoosh[rng.randi_range(0, Sounds.sword_whoosh.size()-1)]
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -4)
			sound_effects.play()
		elif item_name == "arrow":
			get_parent().state = MOVEMENT
			return
		elif item_name == null:
			set_swing_collision_layer_and_position(item_name, _direction)
			animation = "punch_" + _direction.to_lower()
			player_animation_player.play("punch")
		else:
			set_swing_collision_layer_and_position(item_name, _direction)
			animation = "swing_" + _direction.to_lower()
			player_animation_player.play("axe pickaxe swing")
		PlayerData.change_energy(-1)
		composite_sprites.set_player_animation(get_parent().character, animation, item_name)
		yield(player_animation_player, "animation_finished" )
		get_parent().state = MOVEMENT


func set_swing_collision_layer_and_position(tool_name, direction):
	axe_pickaxe_swing.position = Util.set_swing_position(Vector2(0,0), direction)
	if get_node("../Magic").player_fire_buff:
		axe_pickaxe_swing.special_ability = "fire"
	else:
		axe_pickaxe_swing.special_ability = ""
	if tool_name == "wood axe" or tool_name == "stone axe" or tool_name == "iron axe" or tool_name == "bronze axe" or tool_name == "gold axe": 
		axe_pickaxe_swing.tool_name = tool_name
		axe_pickaxe_swing.set_collision_mask(8)
	elif tool_name == "wood pickaxe" or tool_name == "stone pickaxe" or tool_name == "iron pickaxe" or tool_name == "bronze pickaxe" or tool_name == "gold pickaxe": 
		axe_pickaxe_swing.tool_name = tool_name
		axe_pickaxe_swing.set_collision_mask(16)
		remove_hoed_tile(direction)
	elif tool_name == "wood hoe" or tool_name == "stone hoe" or tool_name == "iron hoe" or tool_name == "bronze hoe" or tool_name == "gold hoe": 
		axe_pickaxe_swing.tool_name = tool_name
		axe_pickaxe_swing.set_collision_mask(0)
		set_hoed_tile(direction)
	elif tool_name == "hammer":
		axe_pickaxe_swing.set_collision_mask(16384)
	elif tool_name == null:
		axe_pickaxe_swing.set_collision_mask(8)
		axe_pickaxe_swing.tool_name = "punch"

func set_hoed_tile(direction):
	if Server.world.name == "World":
		var pos = Util.set_swing_position(global_position, direction)
		var location = Tiles.valid_tiles.world_to_map(pos)
		if Tiles.valid_tiles.get_cellv(location) == 0 and \
		Tiles.hoed_tiles.get_cellv(location) == -1 and \
		Tiles.isCenterBitmaskTile(location, Tiles.dirt_tiles):
			MapData.set_hoed_tile(location)
			yield(get_tree().create_timer(0.6), "timeout")
			InstancedScenes.play_hoed_dirt_effect(location)
			Stats.decrease_tool_health()
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Farming/hoe.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
			sound_effects.play()
			Tiles.hoed_tiles.set_cellv(location, 0)
			Tiles.hoed_tiles.update_bitmask_region()

func remove_hoed_tile(direction):
	if Server.world.name == "World":
		var pos = Util.set_swing_position(global_position, direction)
		var location = Tiles.hoed_tiles.world_to_map(pos)
		if Tiles.hoed_tiles.get_cellv(location) != -1:
			MapData.remove_hoed_tile(location)
			yield(get_tree().create_timer(0.6), "timeout")
			Stats.decrease_tool_health()
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Farming/hoe.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
			sound_effects.play()
			Tiles.watered_tiles.set_cellv(location, -1)
			Tiles.hoed_tiles.set_cellv(location, -1)
			Tiles.hoed_tiles.update_bitmask_area(location)
			Tiles.watered_tiles.update_bitmask_area(location)

func set_watered_tile():
	if Server.world.name == "World":
		direction = get_parent().direction
		var pos = Util.set_swing_position(global_position, direction)
		var location = Tiles.hoed_tiles.world_to_map(pos)
		if Tiles.ocean_tiles.get_cellv(location) != -1 or Tiles.is_well_tile(location, direction):
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Farming/water fill.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
			sound_effects.play()
			Stats.refill_watering_can(PlayerData.player_data["hotbar"][str(PlayerData.active_item_slot)][0])
		elif PlayerData.player_data["hotbar"][str(PlayerData.active_item_slot)][2] >= 1:
			Stats.decrease_tool_health()
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Farming/water.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
			sound_effects.play()
			yield(get_tree().create_timer(0.2), "timeout")
			InstancedScenes.play_watering_can_effect(location)
			if direction != "UP":
				watering_can_particles1.position = Util.returnAdjustedWateringCanPariclePos(direction)
				watering_can_particles1.emitting = true
				watering_can_particles2.position = Util.returnAdjustedWateringCanPariclePos(direction)
				watering_can_particles2.emitting = true
			yield(get_tree().create_timer(0.4), "timeout")
			watering_can_particles1.emitting = false
			watering_can_particles2.emitting = false
			if Tiles.hoed_tiles.get_cellv(location) != -1:
				MapData.set_watered_tile(location)
				Tiles.watered_tiles.set_cellv(location, 0)
				Tiles.watered_tiles.update_bitmask_region()
		else: 
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Farming/ES_Error Tone Chime 6 - SFX Producer.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
			sound_effects.play()


