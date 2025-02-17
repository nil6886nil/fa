extends Control

onready var sound_effects: AudioStreamPlayer = $SoundEffects

onready var front_progress_bar = $SkillProgress/FrontPgBar
onready var back_progress_bar = $SkillProgress/BackPgBar
onready var progress_label = $SkillProgress/ProgressLabel
onready var max_progress_label = $SkillProgress/MaxProgressLabel
onready var icon1 = $Icons/Icon1
onready var icon2 = $Icons/Icon2
onready var icon3 = $Icons/Icon3
onready var icon4 = $Icons/Icon4
onready var sword_btn = $Buttons/SwordBtn
onready var bow_btn = $Buttons/BowBtn
onready var wind_btn = $Buttons/WindBtn
onready var fire_btn = $Buttons/FireBtn
onready var earth_btn = $Buttons/EarthBtn
onready var ice_btn = $Buttons/IceBtn
onready var electric_btn = $Buttons/ElectricBtn
onready var dark_magic_btn = $Buttons/DarkMagicBtn

var skill = "sword"

func initialize():
	show()
	set_bg()
	
func set_bg():
	$Background.texture = load("res://Assets/Images/Inventory UI/skill menus/"+skill+".png")
	front_progress_bar.texture_progress = load("res://Assets/Images/Spell icons/"+ skill +"/front.png")
	back_progress_bar.texture_progress = load("res://Assets/Images/Spell icons/"+ skill +"/back.png")
	$Title.text = skill[0].to_upper() + skill.substr(1,-1)
	set_skills()
	match skill:
		"sword":
			$Title.rect_position.x = -227
			bow_btn.rect_position.x = -125
			wind_btn.rect_position.x = -65
			fire_btn.rect_position.x = -5
			earth_btn.rect_position.x = 55
			ice_btn.rect_position.x = 115
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"bow":
			$Title.rect_position.x = -167
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -65
			fire_btn.rect_position.x = -5
			earth_btn.rect_position.x = 55
			ice_btn.rect_position.x = 115
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"wind":
			$Title.rect_position.x = -107
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -5
			earth_btn.rect_position.x = 55
			ice_btn.rect_position.x = 115
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"fire":
			$Title.rect_position.x = -47
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -110
			earth_btn.rect_position.x = 55
			ice_btn.rect_position.x = 115
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"earth":
			$Title.rect_position.x = 13
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -110
			earth_btn.rect_position.x = -50
			ice_btn.rect_position.x = 115
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"ice":
			$Title.rect_position.x = 73
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -110
			earth_btn.rect_position.x = -50
			ice_btn.rect_position.x = 10
			electric_btn.rect_position.x = 175
			dark_magic_btn.rect_position.x = 235
		"electric":
			$Title.rect_position.x = 133
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -110
			earth_btn.rect_position.x = -50
			ice_btn.rect_position.x = 10
			electric_btn.rect_position.x = 70
			dark_magic_btn.rect_position.x = 235
		"dark":
			$Title.rect_position.x = 193
			bow_btn.rect_position.x = -230
			wind_btn.rect_position.x = -170
			fire_btn.rect_position.x = -110
			earth_btn.rect_position.x = -50
			ice_btn.rect_position.x = 10
			electric_btn.rect_position.x = 70
			dark_magic_btn.rect_position.x = 130
			
func set_skills():
	var experience = PlayerData.player_data["skill_experience"][skill]
	var level
	if experience == 0:
		level = 0
		back_progress_bar.max_value = 100
		front_progress_bar.max_value = 100
		back_progress_bar.value = 0
		front_progress_bar.value = 0
	elif experience < 100:
		level = 1
		back_progress_bar.max_value = 100
		front_progress_bar.max_value = 100
		back_progress_bar.value = experience
		front_progress_bar.value = experience * 0.95
	elif experience < 500:
		level = 2
		back_progress_bar.max_value = 500
		front_progress_bar.max_value = 500
		back_progress_bar.value = experience
		front_progress_bar.value = experience * 0.95
	elif experience < 1000:
		level = 3
		back_progress_bar.max_value = 1000
		front_progress_bar.max_value = 1000
		back_progress_bar.value = experience
		front_progress_bar.value = experience * 0.95
	else: 
		level = 4
		back_progress_bar.max_value = 1000
		front_progress_bar.max_value = 1000
		back_progress_bar.value = 1000
		front_progress_bar.value = 1000 * 0.95
	progress_label.text = str(back_progress_bar.value)
	max_progress_label.text = str(back_progress_bar.max_value)
	if level == 0:
		icon1.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon2.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon3.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon4.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		$AttackTitles/Attack1.text = "?????"
		$AttackTitles/Attack2.text = "?????"
		$AttackTitles/Attack3.text = "?????"
		$AttackTitles/Attack4.text = "?????"
		$AttackDescriptions/Attack1.text = "?????"
		$AttackDescriptions/Attack2.text = "?????"
		$AttackDescriptions/Attack3.text = "?????"
		$AttackDescriptions/Attack4.text = "?????"
		$AttackCosts/Attack1.text = "?????"
		$AttackCosts/Attack2.text = "?????"
		$AttackCosts/Attack3.text = "?????"
		$AttackCosts/Attack4.text = "?????"
	elif level == 1:
		icon1.texture = load("res://Assets/Images/Spell icons/"+skill+"/1.png")
		icon2.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon3.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon4.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		$AttackTitles/Attack1.text = Stats.skill_descriptions[skill][1]["n"]
		$AttackTitles/Attack2.text = "?????"
		$AttackTitles/Attack3.text = "?????"
		$AttackTitles/Attack4.text = "?????"
		$AttackDescriptions/Attack1.text = Stats.skill_descriptions[skill][1]["d"]
		$AttackDescriptions/Attack2.text = "?????"
		$AttackDescriptions/Attack3.text = "?????"
		$AttackDescriptions/Attack4.text = "?????"
		$AttackCosts/Attack1.text = Stats.skill_descriptions[skill][1]["c"]
		$AttackCosts/Attack2.text = "?????"
		$AttackCosts/Attack3.text = "?????"
		$AttackCosts/Attack4.text = "?????"
	elif level == 2:
		icon1.texture = load("res://Assets/Images/Spell icons/"+skill+"/1.png")
		icon2.texture = load("res://Assets/Images/Spell icons/"+skill+"/2.png")
		icon3.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		icon4.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		$AttackTitles/Attack1.text = Stats.skill_descriptions[skill][1]["n"]
		$AttackTitles/Attack2.text = Stats.skill_descriptions[skill][2]["n"]
		$AttackTitles/Attack3.text = "?????"
		$AttackTitles/Attack4.text = "?????"
		$AttackDescriptions/Attack1.text = Stats.skill_descriptions[skill][1]["d"]
		$AttackDescriptions/Attack2.text = Stats.skill_descriptions[skill][2]["d"]
		$AttackDescriptions/Attack3.text = "?????"
		$AttackDescriptions/Attack4.text = "?????"
		$AttackCosts/Attack1.text = Stats.skill_descriptions[skill][1]["c"]
		$AttackCosts/Attack2.text = Stats.skill_descriptions[skill][2]["c"]
		$AttackCosts/Attack3.text = "?????"
		$AttackCosts/Attack4.text = "?????"
	elif level == 3:
		icon1.texture = load("res://Assets/Images/Spell icons/"+skill+"/1.png")
		icon2.texture = load("res://Assets/Images/Spell icons/"+skill+"/2.png")
		icon3.texture = load("res://Assets/Images/Spell icons/"+skill+"/3.png")
		icon4.texture = load("res://Assets/Images/Spell icons/"+skill+"/locked.png")
		$AttackTitles/Attack1.text = Stats.skill_descriptions[skill][1]["n"]
		$AttackTitles/Attack2.text = Stats.skill_descriptions[skill][2]["n"]
		$AttackTitles/Attack3.text = Stats.skill_descriptions[skill][3]["n"]
		$AttackTitles/Attack4.text = "?????"
		$AttackDescriptions/Attack1.text = Stats.skill_descriptions[skill][1]["d"]
		$AttackDescriptions/Attack2.text = Stats.skill_descriptions[skill][2]["d"]
		$AttackDescriptions/Attack3.text = Stats.skill_descriptions[skill][3]["d"]
		$AttackDescriptions/Attack4.text = "?????"
		$AttackCosts/Attack1.text = Stats.skill_descriptions[skill][1]["c"]
		$AttackCosts/Attack2.text = Stats.skill_descriptions[skill][2]["c"]
		$AttackCosts/Attack3.text = Stats.skill_descriptions[skill][3]["c"]
		$AttackCosts/Attack4.text = "?????"
	elif level == 4:
		icon1.texture = load("res://Assets/Images/Spell icons/"+skill+"/1.png")
		icon2.texture = load("res://Assets/Images/Spell icons/"+skill+"/2.png")
		icon3.texture = load("res://Assets/Images/Spell icons/"+skill+"/3.png")
		icon4.texture = load("res://Assets/Images/Spell icons/"+skill+"/4.png")
		$AttackTitles/Attack1.text = Stats.skill_descriptions[skill][1]["n"]
		$AttackTitles/Attack2.text = Stats.skill_descriptions[skill][2]["n"]
		$AttackTitles/Attack3.text = Stats.skill_descriptions[skill][3]["n"]
		$AttackTitles/Attack4.text = Stats.skill_descriptions[skill][4]["n"]
		$AttackDescriptions/Attack1.text = Stats.skill_descriptions[skill][1]["d"]
		$AttackDescriptions/Attack2.text = Stats.skill_descriptions[skill][2]["d"]
		$AttackDescriptions/Attack3.text = Stats.skill_descriptions[skill][3]["d"]
		$AttackDescriptions/Attack4.text = Stats.skill_descriptions[skill][4]["d"]
		$AttackCosts/Attack1.text = Stats.skill_descriptions[skill][1]["c"]
		$AttackCosts/Attack2.text = Stats.skill_descriptions[skill][2]["c"]
		$AttackCosts/Attack3.text = Stats.skill_descriptions[skill][3]["c"]
		$AttackCosts/Attack4.text = Stats.skill_descriptions[skill][4]["c"]

func _on_BowBtn_pressed():
	play_select_tab_sound_effect()
	skill = "bow"
	set_bg()

func _on_WindBtn_pressed():
	play_select_tab_sound_effect()
	skill = "wind"
	set_bg()

func _on_FireBtn_pressed():
	play_select_tab_sound_effect()
	skill = "fire"
	set_bg()

func _on_EarthBtn_pressed():
	play_select_tab_sound_effect()
	skill = "earth"
	set_bg()

func _on_IceBtn_pressed():
	play_select_tab_sound_effect()
	skill = "ice"
	set_bg()

func _on_DarkMagicBtn_pressed():
	play_select_tab_sound_effect()
	skill = "dark"
	set_bg()

func _on_SwordBtn_pressed():
	play_select_tab_sound_effect()
	skill = "sword"
	set_bg()

func _on_ElectricBtn_pressed():
	play_select_tab_sound_effect()
	skill = "electric"
	set_bg()
	
func play_select_tab_sound_effect():
	sound_effects.stream = load("res://Assets/Sound/Sound effects/UI/Menu/smallSelect.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", 0)
	sound_effects.play()
