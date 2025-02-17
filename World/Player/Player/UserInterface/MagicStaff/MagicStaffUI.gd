extends Control

onready var sound_effects: AudioStreamPlayer = $SoundEffects

var selected_spell: int = 1
var selected_staff = ""


var COOL_DOWN_PERIOD_1: int = 1
var COOL_DOWN_PERIOD_2: int = 2
var COOL_DOWN_PERIOD_3: int = 5
var COOL_DOWN_PERIOD_4: int = 10


func _ready():
	PlayerDataHelpers.connect("new_skill_unlocked", self, "play_level_up_sound")

func play_level_up_sound():
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Player/skill unlocked.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", 0)
	sound_effects.play()
	set_bgs()


func initialize(item_name):
	show()
	selected_spell = 1
	if item_name == "wind staff":
		selected_staff = "wind"
	elif item_name == "fire staff":
		selected_staff = "fire"
	elif item_name == "earth staff":
		selected_staff = "earth"
	elif item_name == "ice staff":
		selected_staff = "ice"
	elif item_name == "dark magic staff":
		selected_staff = "dark"
	elif item_name == "electric staff":
		selected_staff = "electric"
	elif item_name == "wood sword" or item_name == "stone sword" or item_name == "bronze sword" or item_name == "iron sword" or item_name == "gold sword":
		selected_staff = "sword"
	elif item_name == "bow":
		selected_staff = "bow"
	set_selected_spell()
	set_bgs()

func set_bgs():
	var experience = PlayerData.player_data["skill_experience"][selected_staff]
	var level
	if experience == 0:
		level = 0
		$Bg/btn1.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn2.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn3.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn4.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn1.disabled = true
		$Bg/btn2.disabled = true
		$Bg/btn3.disabled = true
		$Bg/btn4.disabled = true
	elif experience < 100:
		level = 1
		$Bg/btn1.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/1.png")
		$Bg/btn2.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn3.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn4.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn1.disabled = false
		$Bg/btn2.disabled = true
		$Bg/btn3.disabled = true
		$Bg/btn4.disabled = true
	elif experience < 500:
		level = 2
		$Bg/btn1.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/1.png")
		$Bg/btn2.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/2.png")
		$Bg/btn3.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn4.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn1.disabled = false
		$Bg/btn2.disabled = false
		$Bg/btn3.disabled = true
		$Bg/btn4.disabled = true
	elif experience < 1000:
		level = 3
		$Bg/btn1.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/1.png")
		$Bg/btn2.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/2.png")
		$Bg/btn3.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/3.png")
		$Bg/btn4.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/locked.png")
		$Bg/btn1.disabled = false
		$Bg/btn2.disabled = false
		$Bg/btn3.disabled = false
		$Bg/btn4.disabled = true
	else: 
		level = 4
		$Bg/btn1.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/1.png")
		$Bg/btn2.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/2.png")
		$Bg/btn3.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/3.png")
		$Bg/btn4.texture_normal = load("res://Assets/Images/Spell icons/" + selected_staff + "/4.png")
		$Bg/btn1.disabled = false
		$Bg/btn2.disabled = false
		$Bg/btn3.disabled = false
		$Bg/btn4.disabled = false


func set_selected_spell():
	match selected_spell:
		1:
			$SelectedBg.rect_position.x = 0
		2:
			$SelectedBg.rect_position.x = 17
		3:
			$SelectedBg.rect_position.x = 34
		4:
			$SelectedBg.rect_position.x = 51


func start_spell_cooldown():
	match selected_spell:
		1:
			$Tween.interpolate_property(get_node("Cooldown"+str(selected_spell)), "rect_size",
				Vector2(16,16), Vector2(16,0), COOL_DOWN_PERIOD_1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		2:
			$Tween.interpolate_property(get_node("Cooldown"+str(selected_spell)), "rect_size",
				Vector2(16,16), Vector2(16,0), COOL_DOWN_PERIOD_2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		3:
			$Tween.interpolate_property(get_node("Cooldown"+str(selected_spell)), "rect_size",
				Vector2(16,16), Vector2(16,0), COOL_DOWN_PERIOD_3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		4:
			$Tween.interpolate_property(get_node("Cooldown"+str(selected_spell)), "rect_size",
				Vector2(16,16), Vector2(16,0), COOL_DOWN_PERIOD_4,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func validate_spell_cooldown():
	return get_node("Cooldown"+str(selected_spell)).rect_size.y == 0

func _on_1_pressed():
	Sounds.play_small_select_sound()
	selected_spell = 1
	set_selected_spell()

func _on_2_pressed():
	Sounds.play_small_select_sound()
	selected_spell = 2
	set_selected_spell()

func _on_4_pressed():
	Sounds.play_small_select_sound()
	selected_spell = 4
	set_selected_spell()

func _on_3_pressed():
	Sounds.play_small_select_sound()
	selected_spell = 3
	set_selected_spell()
