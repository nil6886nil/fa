extends Node2D

onready var animation_player: AnimationPlayer = $AnimationPlayer 
onready var tree_stump_sprite: Sprite = $TreeSprites/TreeStump
onready var sound_effects: AudioStreamPlayer2D = $SoundEffects

var rng = RandomNumberGenerator.new()

var tree_object
var location 
var health
var variety
var destroyed: bool = false

func _ready():
	hide()
	tree_object = Images.returnTreeObject(variety)
	setTexture(tree_object)
	
func setTexture(tree):
	tree_stump_sprite.texture = tree.largeStump


func hit(tool_name):
	health -= Stats.return_tool_damage(tool_name)
	if MapData.world["stump"].has(name):
		MapData.world["stump"][name]["h"] = health
	if health > 0:
		sound_effects.stream = Sounds.tree_hit[rng.randi_range(0,2)]
		sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -12)
		sound_effects.play()
		if Server.player_node.get_position().x <= get_position().x:
			animation_player.play("stump hit right")
			InstancedScenes.initiateTreeHitEffect(variety, "tree hit right", position+Vector2(0, 12))
		else: 
			InstancedScenes.initiateTreeHitEffect(variety, "tree hit left", position+Vector2(-24, 12))
			animation_player.play("stump hit right")
	elif not destroyed:
		destroyed = true
		if MapData.world["stump"].has(name):
			MapData.world["stump"].erase(name)
		Tiles.add_valid_tiles(location+Vector2(-1,0), Vector2(2,2))
		sound_effects.stream = Sounds.stump_break
		sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -12)
		sound_effects.play()
		animation_player.play("stump destroyed")
		InstancedScenes.initiateTreeHitEffect(variety, "trunk break", position+Vector2(-16, 32))
		var amt = Stats.return_item_drop_quantity(tool_name, "stump")
		PlayerData.player_data["collections"]["resources"]["wood"] += amt
		InstancedScenes.intitiateItemDrop("wood", position, amt)
		yield(sound_effects, "finished")
		queue_free()
		
func _on_StumpHurtBox_area_entered(_area):
	if _area.name == "AxePickaxeSwing":
		Stats.decrease_tool_health()
	if _area.tool_name != "lightning spell" and _area.tool_name != "lightning spell debuff":
		hit(_area.tool_name)
	if _area.special_ability == "fire buff":
		InstancedScenes.initiateExplosionParticles(position+Vector2(rand_range(-16,16), rand_range(-18,12)))
		health -= Stats.FIRE_DEBUFF_DAMAGE


func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
