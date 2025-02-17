extends Node2D

onready var sound_effects: AudioStreamPlayer2D = $SoundEffects

var door_open = false

var id
var location
var tier
var health
var max_health
var temp_health = 0
var entered = false

func _ready():
	set_type()


func _input(event):
	if event.is_action_pressed("action") and entered:
		if door_open:
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Door/doorOpen.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound",0)
			sound_effects.play()
			#$AnimationPlayer.play("close")
			$AnimatedSprite.play("close")
			$MovementCollision/CollisionShape2D.disabled = false 
		else:
			sound_effects.stream = load("res://Assets/Sound/Sound effects/Door/doorClose.mp3")
			sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound",0)
			sound_effects.play()
			#$AnimationPlayer.play("open")
			$AnimatedSprite.play("open")
			$MovementCollision/CollisionShape2D.disabled = true
		door_open = !door_open


func set_type():
	match tier:
		"wood":
			$AnimatedSprite.frames = load("res://Assets/Tilesets/doors/animated/side/wood.tres")
			health = Stats.MAX_WOOD_WALL
			max_health = Stats.MAX_WOOD_WALL
		"metal":
			$AnimatedSprite.frames = load("res://Assets/Tilesets/doors/animated/side/metal.tres")
			health = Stats.MAX_METAL_WALL
			max_health = Stats.MAX_METAL_WALL
		"armored":
			$AnimatedSprite.frames = load("res://Assets/Tilesets/doors/animated/side/armored.tres")
			health = Stats.MAX_ARMORED_WALL
			max_health = Stats.MAX_ARMORED_WALL
		"demolish":
			Tiles.add_valid_tiles(location, Vector2(2,1))
			queue_free()
	update_health_bar()


func remove_icon():
	$SelectedBorder.hide()

func _on_EnterDoorway_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if PlayerData.player_data["hotbar"].has(PlayerData.active_item_slot) and not PlayerData.viewInventoryMode:
			var tool_name = PlayerData.player_data["hotbar"][PlayerData.active_item_slot][0]
			if tool_name == "hammer":
				$SelectedBorder.show()
				Server.player_node.get_node("Camera2D/UserInterface/RadialDoorMenu").initialize(location, self)


func _on_HurtBox_area_entered(area):
	if area.name == "AxePickaxeSwing":
		Stats.decrease_tool_health()
	if door_open:
		$HitEffect/Sprite.texture = load("res://Assets/Tilesets/doors/hit effects/" + tier + "/side/open.png")
		$HitEffect/Sprite.position = Vector2(10,-69)
	else:
		$HitEffect/Sprite.texture = load("res://Assets/Tilesets/doors/hit effects/" + tier + "/side/closed.png")
		$HitEffect/Sprite.position = Vector2(2,-63)
	$HitEffect/AnimationPlayer.stop()
	$HitEffect/AnimationPlayer.play("hit")
	show_health()
	if tier == "twig" or tier == "wood":
		health -= 1
	else:
		temp_health += 1
		if temp_health == 3:
			temp_health = 0
			health -= 1
	update_health_bar()

func update_health_bar():
	if health != 0:
		$HealthBar/Progress.value = health
		$HealthBar/Progress.max_value = max_health
	else:
		remove_tile()

func remove_tile():
	Tiles.add_valid_tiles(location, Vector2(1,2))
	queue_free()


func show_health():
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play("show health bar")


func _on_EnterDoorway_area_entered(area):
	entered = true

func _on_EnterDoorway_area_exited(area):
	entered = false


func _on_HammerRepairBox_area_entered(area):
	set_type()
	Server.world.play_upgrade_building_effect(location)
	Server.world.play_upgrade_building_effect(location + Vector2(0,-1))
	show_health()
