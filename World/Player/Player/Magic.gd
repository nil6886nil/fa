extends Node2D

onready var sound_effects: AudioStreamPlayer = $SoundEffects

onready var PotionProjectile = load("res://World/Objects/Projectiles/PotionProjectile.tscn")

onready var ArrowProjectile = load("res://World/Objects/Projectiles/ArrowProjectile.tscn")

onready var LightningProjectile = load("res://World/Objects/Magic/Lightning/LightningProjectile.tscn")
onready var LightningStrike = load("res://World/Objects/Magic/Lightning/LightningStrike.tscn")
onready var FlashStep = load("res://World/Objects/Magic/Lightning/FlashStep.tscn")

onready var TornadoProjectile = load("res://World/Objects/Magic/Wind/TornadoProjectile.tscn")
onready var DashGhost = load("res://World/Objects/Magic/Wind/DashGhost.tscn")
onready var LingeringTornado = load("res://World/Objects/Magic/Wind/LingeringTornado.tscn")
onready var Whirlwind = load("res://World/Objects/Magic/Wind/Whirlwind.tscn")

onready var FireProjectile = load("res://World/Objects/Magic/Fire/FireProjectile.tscn")
onready var FlameThrower = load("res://World/Objects/Magic/Fire/Flamethrower.tscn")
onready var FireBuffFront = load("res://World/Objects/Magic/Fire/AttachedFlameBehind.tscn")
onready var FireBuffBehind = load("res://World/Objects/Magic/Fire/AttachedFlameFront.tscn")

onready var EarthStrike = load("res://World/Objects/Magic/Earth/EarthStrike.tscn")
onready var EarthGolem = load("res://World/Objects/Magic/Earth/EarthGolem.tscn")
onready var EarthStrikeDebuff = load("res://World/Objects/Magic/Earth/EarthStrikeDebuff.tscn")
onready var Earthquake = load("res://World/Objects/Magic/Earth/Earthquake.tscn")

onready var IceDefense = load("res://World/Objects/Magic/Ice/IceDefense.tscn")
onready var IceProjectile = load("res://World/Objects/Magic/Ice/IceProjectile.tscn")
onready var BlizzardFog = load("res://World/Objects/Magic/Ice/BlizzardFog.tscn")

onready var DemonMage = load("res://World/Objects/Magic/Dark/DemonMage.tscn")
onready var PortalNode = load("res://World/Objects/Magic/Dark/Portal.tscn")

onready var HealthProjectile = load("res://World/Objects/Magic/Health/HealthProjectile.tscn")
onready var HealthBuff = load("res://World/Objects/Magic/Health/HealthBuff.tscn")

onready var player_animation_player = get_node("../CompositeSprites/AnimationPlayer")
onready var player_animation_player2 = get_node("../CompositeSprites/AnimationPlayer2")
onready var composite_sprites = get_node("../CompositeSprites")
var _uuid = load("res://helpers/UUID.gd")
onready var uuid = _uuid.new()

var dashing = false
var player_fire_buff: bool = false

var portal_1_position = null
var portal_2_position = null

const FIRE_BUFF_LENGTH = 10

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
	THROWING
}

signal spell_finished

var animation: String = ""
var direction: String = "DOWN"
var movement_direction: String = ""
var current_potion: String = ""
var is_casting: bool = false
var is_drawing: bool = false
var is_releasing: bool = false
var is_throwing: bool = false
var flamethrower_active: bool = false
var invisibility_active: bool = false
var ice_shield_active: bool = false
var mouse_left_down: bool = false


var starting_mouse_point
var ending_mouse_point


func _input( event ):
	if is_casting or is_drawing or is_throwing:
		$AimDownSightLine.show()
		$CastDirection.look_at(get_global_mouse_position())
		var start_pt = $CastDirection/Position2D.global_position-get_node("../").global_position
		var end_pt = get_local_mouse_position()
		$AimDownSightLine.points = [start_pt, end_pt]
	else:
		$AimDownSightLine.hide()
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false


func draw_bow(init_direction):
	if validate_bow_requirement():
		get_parent().state = MAGIC_CASTING
		is_drawing = true
		animation = "draw_" + init_direction.to_lower()
		player_animation_player.play("bow draw release")
		sound_effects.stream = load("res://Assets/Sound/Sound effects/Bow and arrow/draw.mp3")
		sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -8)
		sound_effects.play()
		yield(player_animation_player, "animation_finished" )
		wait_for_bow_release()


func validate_bow_requirement():
	var index = get_node("../Camera2D/UserInterface/MagicStaffUI").selected_spell
	match index:
		1:
			return PlayerData.returnSufficentCraftingMaterial("arrow", 1)
		2:
			return PlayerData.returnSufficentCraftingMaterial("arrow", 3)
		3:
			return PlayerData.returnSufficentCraftingMaterial("arrow", 1) and PlayerData.player_data["mana"] > 0
		4:
			return PlayerData.returnSufficentCraftingMaterial("arrow", 2) and PlayerData.player_data["mana"] > 1

func wait_for_bow_release():
	if not mouse_left_down:
		sound_effects.stream = load("res://Assets/Sound/Sound effects/Bow and arrow/release.mp3")
		sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -12)
		sound_effects.play()
		PlayerData.change_energy(-1)
		Stats.decrease_tool_health()
		shoot()
		is_drawing = false
		is_releasing = true
		animation = "release_" + direction.to_lower()
		composite_sprites.set_player_animation(get_parent().character, animation, "bow release")
		player_animation_player.play("bow draw release")
		yield(player_animation_player, "animation_finished" )
		is_releasing = false
		get_parent().direction = direction
		get_parent().state = MOVEMENT
	elif get_parent().state == DYING:
		return
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		wait_for_bow_release()

func shoot():
	var index = get_node("../Camera2D/UserInterface/MagicStaffUI").selected_spell
	match index:
		1:
			single_arrow_shot()
		2:
			multi_arrow_shot()
		3: 
			enchanted_arrow_shot()
		4:
			ricochet_arrow_shot()

func ricochet_arrow_shot():
	PlayerData.remove_material("arrow", 2)
	PlayerData.change_mana(-2)
	var arrow = ArrowProjectile.instance()
	if get_node("../Magic").player_fire_buff:
		arrow.is_fire_arrow = true
	else:
		arrow.is_fire_arrow = false
	arrow.is_ricochet_shot = true
	arrow.position = $CastDirection/Position2D.global_position
	arrow.velocity = (get_global_mouse_position() - arrow.position).normalized()
	get_node("../../../").add_child(arrow)


func enchanted_arrow_shot():
	PlayerData.remove_material("arrow", 1)
	PlayerData.change_mana(-1)
	var arrow = ArrowProjectile.instance()
	if Util.chance(33):
		arrow.is_fire_arrow = true
	elif Util.chance(33):
		arrow.is_ice_arrow = true
	else:
		arrow.is_poison_arrow = true
	arrow.position = $CastDirection/Position2D.global_position
	arrow.velocity = (get_global_mouse_position() - arrow.position).normalized()
	get_node("../../../").add_child(arrow)

func single_arrow_shot():
	PlayerData.remove_material("arrow", 1)
	var arrow = ArrowProjectile.instance()
	if get_node("../Magic").player_fire_buff:
		arrow.is_fire_arrow = true
	else:
		arrow.is_fire_arrow = false
	arrow.position = $CastDirection/Position2D.global_position
	arrow.velocity = (get_global_mouse_position() - arrow.position).normalized()
	get_node("../../../").add_child(arrow)


func multi_arrow_shot():
	PlayerData.remove_material("arrow", 3)
	for i in range(3):
		var arrow = ArrowProjectile.instance()
		if get_node("../Magic").player_fire_buff:
			arrow.is_fire_arrow = true
		else:
			arrow.is_fire_arrow = false
		arrow.position = $CastDirection/Position2D.global_position
		if i == 0:
			arrow.velocity = (get_global_mouse_position() - arrow.position).normalized()
		elif i == 1: 
			arrow.velocity = ((get_global_mouse_position()-arrow.position).normalized()+Vector2(0.25,0.25)).normalized()
		elif i == 2:
			arrow.velocity = ((get_global_mouse_position()-arrow.position).normalized()-Vector2(0.25,0.25)).normalized()
		get_node("../../../").add_child(arrow)


func wait_for_cast_release(staff_name):
	if not mouse_left_down:
		cast(staff_name, get_node("../Camera2D/UserInterface/MagicStaffUI").selected_spell)
	elif get_parent().state == DYING:
		return
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		wait_for_cast_release(staff_name)

func cast_spell(staff_name, init_direction):
	yield(get_tree(), "idle_frame")
	if validate_magic_cast_requirements():
		direction = init_direction
		starting_mouse_point = get_global_mouse_position()
		if get_node("../Camera2D/UserInterface/MagicStaffUI").selected_spell != 2:
			get_parent().state = MAGIC_CASTING
			is_casting = true
			animation = "magic_cast_" + init_direction.to_lower()
			player_animation_player.play("bow draw release")
			composite_sprites.set_player_animation(get_parent().character, animation, "magic staff")
			yield(player_animation_player, "animation_finished" )
		wait_for_cast_release(staff_name)
	else:
		get_parent().state = MOVEMENT


func validate_magic_cast_requirements():
	var index = get_node("../Camera2D/UserInterface/MagicStaffUI").selected_spell
	match index:
		1:
			return PlayerData.player_data["mana"] >= 1 and get_node("../Camera2D/UserInterface/MagicStaffUI").validate_spell_cooldown()
		2:
			return PlayerData.player_data["mana"] >= 2 and get_node("../Camera2D/UserInterface/MagicStaffUI").validate_spell_cooldown()
		3:
			return PlayerData.player_data["mana"] >= 5 and get_node("../Camera2D/UserInterface/MagicStaffUI").validate_spell_cooldown()
		4:
			return PlayerData.player_data["mana"] >= 10 and get_node("../Camera2D/UserInterface/MagicStaffUI").validate_spell_cooldown()

func _physics_process(delta):
	var degrees = int($CastDirection.rotation_degrees) % 360
	$CastDirection.look_at(get_global_mouse_position())
	if $CastDirection.rotation_degrees >= 0:
		if degrees <= 45 or degrees >= 315:
			direction = "RIGHT"
		elif degrees <= 135:
			direction = "DOWN"
		elif degrees <= 225:
			direction = "LEFT"
		else:
			direction = "UP"
	else:
		if degrees >= -45 or degrees <= -315:
			direction = "RIGHT"
		elif degrees >= -135:
			direction = "UP"
		elif degrees >= -225:
			direction = "LEFT"
		else:
			direction = "DOWN"
	if is_casting and get_parent().state != DYING:
		if get_parent().cast_movement_direction == "":
			player_animation_player2.stop(false)
			composite_sprites.set_player_animation(get_parent().character, "magic_cast_"+direction.to_lower(), "magic staff")
		else:
			player_animation_player2.play("walk legs")
			composite_sprites.set_player_animation(get_parent().character, "magic_cast_"+direction.to_lower()+"_"+get_parent().cast_movement_direction, "magic staff")
	if is_drawing and get_parent().state != DYING:
		if get_parent().cast_movement_direction == "":
			player_animation_player2.stop(false)
			composite_sprites.set_player_animation(get_parent().character, "draw_"+direction.to_lower(), "bow")
		else:
			player_animation_player2.play("walk legs")
			composite_sprites.set_player_animation(get_parent().character, "draw_"+direction.to_lower()+"_"+get_parent().cast_movement_direction, "bow")
	if is_releasing and get_parent().state != DYING:
		composite_sprites.set_player_animation(get_parent().character, "release_" + direction.to_lower(), "bow release")
	if is_throwing and get_parent().state != DYING:
		if get_parent().cast_movement_direction == "":
			player_animation_player2.stop(false)
			composite_sprites.set_player_animation(get_parent().character, "throw_" + direction.to_lower(), current_potion)
		else:
			player_animation_player2.play("walk legs")
			composite_sprites.set_player_animation(get_parent().character, "throw_"+direction.to_lower()+"_"+get_parent().cast_movement_direction, current_potion)

func throw_potion(potion_name, init_direction):
	PlayerData.remove_single_object_from_hotbar()
	is_throwing = true
	current_potion = potion_name
	direction = init_direction
	get_parent().state = MAGIC_CASTING
	composite_sprites.set_player_animation(get_parent().character, "throw_" + direction.to_lower(), potion_name)
	player_animation_player.play("bow draw release")
	yield(get_tree().create_timer(0.3), "timeout")
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Magic/Potion/throw.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", 0)
	sound_effects.play()
	yield(player_animation_player, "animation_finished" )
	throw(potion_name)
	is_throwing = false
	get_parent().state = MOVEMENT
	get_parent().direction = direction
	
func throw(potion_name):
	var potion = PotionProjectile.instance()
	potion.potion_name = potion_name
	potion.particles_transform = $CastDirection.transform
	potion.target = get_global_mouse_position()
	potion.position = $CastDirection/Position2D.global_position
	get_node("../../../").add_child(potion)


func cast(staff_name, spell_index):
	get_node("../Camera2D/UserInterface/MagicStaffUI").start_spell_cooldown()
	yield(get_tree(), "idle_frame")
	match spell_index:
		1:
			PlayerData.change_mana(-1)
		2:
			PlayerData.change_mana(-2)
		3:
			PlayerData.change_mana(-5)
		4:
			PlayerData.change_mana(-10)
	match staff_name:
		"electric staff":
			match spell_index:
				1:
					play_lightning_projectile(false)
				2:
					play_flash_step()
				3:
					play_lightning_projectile(true)
				4:
					play_lightning_strike()
		"fire staff":
			match spell_index:
				1:
					play_fire_projectile(false)
					yield(self, "spell_finished")
				2:
					play_fire_buff()
				3:
					play_fire_projectile(true)
					yield(self, "spell_finished")
				4:
					play_flamethrower()
					yield(self, "spell_finished")
		"wind staff":
			match spell_index:
				1:
					play_wind_projectile()
				2:
					play_dash()
				3:
					play_lingering_tornado()
				4:
					play_whirlwind()
		"ice staff":
			match spell_index:
				1:
					play_ice_projectile(false)
				2:
					play_ice_shield()
				3:
					play_ice_projectile(true)
				4:
					play_blizzard()
		"earth staff":
			match spell_index:
				1:
					play_earth_strike()
				2:
					play_earth_golem()
					yield(self, "spell_finished")
				3:
					play_earth_strike_buff()
				4:
					play_earthquake()
		"dark magic staff":
			match spell_index:
				1:
					spawn_demon_mage(false)
				2:
					set_invisibility()
				3:
					spawn_demon_mage(true)
				4:
					set_portal()
	is_casting = false
	if get_parent().state != DYING: 
		get_parent().state = MOVEMENT
		get_parent().direction = direction


func set_invisibility():
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Magic/Dark/invisibility.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -8)
	sound_effects.play()
	$Tween.interpolate_property(composite_sprites.get_node("Body"), "modulate:a", 1.0, 0.15, 0.5, 3, 1)
	$Tween.start()
	$Tween.interpolate_property(composite_sprites.get_node("Arms"), "modulate:a", 1.0, 0.15, 0.5, 3, 1)
	$Tween.start()
	$Tween.interpolate_property(composite_sprites.get_node("Legs"), "modulate:a", 1.0, 0.15, 0.5, 3, 1)
	$Tween.start()
	invisibility_active = true
	yield(get_tree().create_timer(10.0), "timeout")
	invisibility_active = false
	$Tween.interpolate_property(composite_sprites.get_node("Body"), "modulate:a", 0.15, 1.0, 0.5, 3, 1)
	$Tween.start()
	$Tween.interpolate_property(composite_sprites.get_node("Arms"), "modulate:a", 0.15, 1.0, 0.5, 3, 1)
	$Tween.start()
	$Tween.interpolate_property(composite_sprites.get_node("Legs"), "modulate:a", 1.0, 0.15, 0.5, 3, 1)
	$Tween.start()


# Dark magic #
func set_portal():
	if Server.world.name.substr(0,4) == "Cave":
		if Tiles.cave_wall_tiles.get_cellv(Tiles.cave_wall_tiles.world_to_map(get_global_mouse_position())) != -1:
			return
	if not portal_1_position and not portal_2_position:
		portal_1_position = get_global_mouse_position()
		var spell = PortalNode.instance()
		get_node("../../..").add_child(spell)
		spell.name = "Portal1"
		spell.position = get_global_mouse_position()
	elif portal_1_position and not portal_2_position:
		portal_2_position = get_global_mouse_position()
		var spell = PortalNode.instance()
		get_node("../../..").add_child(spell)
		spell.name = "Portal2"
		spell.position = get_global_mouse_position()
	elif portal_1_position and portal_2_position:
		get_node("../../../Projectiles/Portal1").queue_free()
		get_node("../../../Portal2").queue_free()
		portal_2_position = null
		portal_1_position = get_global_mouse_position()
		var spell = PortalNode.instance()
		get_node("../../..").add_child(spell)
		yield(get_tree(), "idle_frame")
		spell.name = "Portal1"
		spell.position = get_global_mouse_position()

func spawn_demon_mage(debuff):
	var spell = DemonMage.instance()
	get_node("../../../").add_child(spell)
	spell.debuff = debuff
	spell.position = get_global_mouse_position()

# Earth #
func play_earth_strike():
	var spell = EarthStrike.instance()
	get_node("../../../").add_child(spell)
	spell.position = get_global_mouse_position()

func play_earth_golem():
	get_node("../Area2Ds/HurtBox/CollisionShape2D").set_deferred("disabled", true)
	var spell = EarthGolem.instance()
	add_child(spell)
	yield(get_tree().create_timer(1.0), "timeout")
	composite_sprites.hide()
	yield(get_tree().create_timer(2.0), "timeout")
	get_node("../Camera2D").start_small_shake()
	yield(get_tree().create_timer(0.5), "timeout")
	composite_sprites.show()
	yield(self, "spell_finished")
	get_node("../Area2Ds/HurtBox/CollisionShape2D").set_deferred("disabled", false)

func play_earth_strike_buff():
	ending_mouse_point = get_global_mouse_position()
	var current_pt = Tiles.valid_tiles.world_to_map(starting_mouse_point) * 32
	if abs(abs(ending_mouse_point.x) - abs(starting_mouse_point.x)) > abs(abs(ending_mouse_point.y) - abs(starting_mouse_point.y)): # Horizontal
		if ending_mouse_point.x > starting_mouse_point.x: # Moving right:
			while current_pt.x < ending_mouse_point.x:
				var spell = EarthStrikeDebuff.instance()
				spell.position = current_pt
				get_node("../../../").add_child(spell)
				current_pt.x += 96
				yield(get_tree().create_timer(0.1), "timeout")
		else: # Moving left
			while current_pt.x > ending_mouse_point.x:
				var spell = EarthStrikeDebuff.instance()
				spell.position = current_pt
				get_node("../../../").add_child(spell)
				current_pt.x -= 96
				yield(get_tree().create_timer(0.1), "timeout")
	else: # Vertical 
		if ending_mouse_point.y > starting_mouse_point.y: # Moving down:
			while current_pt.y < ending_mouse_point.y:
				var spell = EarthStrikeDebuff.instance()
				spell.position = current_pt
				get_node("../../../").add_child(spell)
				current_pt.y += 64
				yield(get_tree().create_timer(0.1), "timeout")
		else: # Moving up
			while current_pt.y > ending_mouse_point.y:
				var spell = EarthStrikeDebuff.instance()
				spell.position = current_pt
				get_node("../../../").add_child(spell)
				current_pt.y -= 64
				yield(get_tree().create_timer(0.1), "timeout")
	
func play_earthquake():
	var spell = Earthquake.instance()
	add_child(spell)

# Lightning #

func play_flash_step():
	var mouse_pos = get_global_mouse_position()
	if Server.world.name.substr(0,4) == "Cave":
		if Tiles.cave_wall_tiles.get_cellv(Tiles.cave_wall_tiles.world_to_map(mouse_pos)) != -1:
			return
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Magic/Lightning/teleport.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
	sound_effects.play()
	yield(get_tree().create_timer(0.2), "timeout")
	get_parent().position = mouse_pos
	composite_sprites.material.set_shader_param("flash_modifier", 0.7)
	yield(get_tree().create_timer(0.2), "timeout")
	composite_sprites.material.set_shader_param("flash_modifier", 0.0)
	var spell = FlashStep.instance()
	add_child(spell)

func play_lightning_projectile(debuff):
	var spell = LightningProjectile.instance()
	spell.debuff = debuff
	spell.transform = $CastDirection.transform
	spell.position = $CastDirection/Position2D.global_position
	spell.velocity = get_global_mouse_position() - spell.position
	get_node("../../../").add_child(spell)

func play_lightning_strike():
	var spell = LightningStrike.instance()
	get_node("../../../").add_child(spell)
	spell.position = get_global_mouse_position()

# Ice #

func play_ice_projectile(debuff):
	var spell = IceProjectile.instance()
	spell.debuff = debuff
	spell.projectile_transform = $CastDirection.transform
	spell.position = $CastDirection/Position2D.global_position
	spell.velocity = get_global_mouse_position() - spell.position
	get_node("../../../Projectiles").add_child(spell)


func play_ice_shield():
	ice_shield_active = true
	get_node("../Area2Ds/HurtBox/CollisionShape2D").set_deferred("disabled", true)
	var spell = IceDefense.instance()
	add_child(spell)
	yield(self, "spell_finished")
	ice_shield_active = false
	get_node("../Area2Ds/HurtBox/CollisionShape2D").set_deferred("disabled", false)


func play_blizzard():
	var spell = BlizzardFog.instance()
	spell.position = get_parent().position
	get_node("../../../Projectiles").add_child(spell)


# Wind #

func play_lingering_tornado():
	var spell = LingeringTornado.instance()
	spell.particles_transform = $CastDirection.transform
	spell.target = get_global_mouse_position() + Vector2(0,32)
	spell.position = $CastDirection/Position2D.global_position
	get_node("../../../Projectiles").add_child(spell)

func play_wind_projectile():
	var spell = TornadoProjectile.instance()
	spell.position = $CastDirection/Position2D.global_position
	spell.velocity = get_global_mouse_position() - spell.position
	get_node("../../../").add_child(spell)

func play_dash():
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Magic/Wind/dash.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -16)
	sound_effects.play()
	$DustParticles.emitting = true
	$DustBurst.rotation = (get_parent().input_vector*-1).angle()
	$DustBurst.restart()
	$DustBurst.emitting = true
	set_player_whitened()
	dashing = true
	$GhostTimer.start()
	yield(get_tree().create_timer(0.5), "timeout")
	$DustParticles.emitting = false
	$DustBurst.emitting = false
	dashing = false
	$GhostTimer.stop()

func set_player_whitened():
	composite_sprites.material.set_shader_param("flash_modifier", 0.7)
	yield(get_tree().create_timer(0.5), "timeout")
	composite_sprites.material.set_shader_param("flash_modifier", 0.0)

var body_sprites = ["Arms", "Body"]

func _on_GhostTimer_timeout():
	for sprite_name in body_sprites:
		var sprite = get_node("../CompositeSprites/" + sprite_name)
		var ghost: Sprite = DashGhost.instance()
		get_node("../../../").add_child(ghost)
		ghost.global_position = global_position + Vector2(0,-32)
		ghost.texture = sprite.texture
		ghost.hframes = sprite.hframes
		ghost.frame = sprite.frame

func play_whirlwind():
	var spell = Whirlwind.instance()
	add_child(spell)

# Fire #
func play_fire_projectile(debuff):
	for i in range(3):
		var spell = FireProjectile.instance()
		spell.debuff = debuff
		spell.position = $CastDirection/Position2D.global_position
		spell.velocity = get_global_mouse_position() - spell.position
		get_node("../../../Projectiles").add_child(spell)
		yield(get_tree().create_timer(0.35), "timeout")
	emit_signal("spell_finished")


func play_fire_buff():
	var spell = FireBuffFront.instance()
	get_node("../").add_child(spell)
	var spell2 = FireBuffBehind.instance()
	get_node("../").add_child(spell2)
	player_fire_buff = true
	yield(get_tree().create_timer(FIRE_BUFF_LENGTH), "timeout")
	player_fire_buff = false
	
func play_flamethrower():
	var spell = FlameThrower.instance()
	spell.name = "FlameThrower"
	$CastDirection.add_child(spell)
	spell.position = $CastDirection/Position2D.position
	yield(get_tree().create_timer(4.0), "timeout")
	emit_signal("spell_finished")

