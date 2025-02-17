extends Node2D


onready var sound_effects: AudioStreamPlayer2D = $SoundEffects


func _ready():
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -32)
	sound_effects.play()
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("open")
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.play("idle")

func _on_Area2D_area_entered(area):
	Server.player_node.actions.teleport(position)

