extends KinematicBody2D

onready var hit_box: Position2D = $Position2D
onready var wolf_sprite: Sprite = $WolfSprite
onready var _idle_timer: Timer = $Timers/IdleTimer
onready var _chase_timer: Timer = $Timers/ChaseTimer
onready var _retreat_timer: Timer = $Timers/RetreatTimer
onready var _end_chase_state_timer: Timer = $Timers/EndChaseState
onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sound_effects: AudioStreamPlayer2D = $SoundEffects

var player = Server.player_node
var direction: String = "down"
var destroyed: bool = false
var frozen: bool = false
var stunned: bool = false
var poisoned: bool = false
var chasing: bool = false
var attacking: bool = false
var knocking_back: bool = false
var playing_sound_effect: bool = false
var random_pos := Vector2.ZERO
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var MAX_MOVE_DISTANCE: float = 500.0
var health: int = Stats.WOLF_HEALTH
var STARTING_HEALTH: int = Stats.WOLF_HEALTH
var tornado_node = null
var hit_projectiles = []

const KNOCKBACK_SPEED = 50
const ACCELERATION = 180
const KNOCKBACK_AMOUNT = 50

var state = IDLE

enum {
	IDLE,
	WALK,
	CHASE,
	ATTACK,
	DEATH,
	RETREAT
}
var rng = RandomNumberGenerator.new()

func _ready():
	hide()
	randomize()
	animation_player.play("loop")
	_idle_timer.wait_time = rand_range(3.0,8.0)
	_chase_timer.connect("timeout", self, "_update_pathfinding_chase")
	_idle_timer.connect("timeout", self, "_update_pathfinding_idle")
	_retreat_timer.connect("timeout", self, "_update_pathfinding_retreat")
	navigation_agent.connect("velocity_computed", self, "move") 
	navigation_agent.set_navigation(get_node("/root/World/Navigation2D"))

func _update_pathfinding_chase():
	navigation_agent.set_target_location(player.global_position)
	
func _update_pathfinding_idle():
	state = WALK
	navigation_agent.set_target_location(Util.get_random_idle_pos(position, MAX_MOVE_DISTANCE))
	
func _update_pathfinding_retreat():
	var target = -player.position*Vector2(100,100)
	navigation_agent.set_target_location(target)
	
func set_sprite_texture():
	match state:
		IDLE:
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/idle/" +  direction + "/body.png")
		WALK:
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/walk/" +  direction + "/body.png")
		CHASE:
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/run/" +  direction + "/body.png")
		RETREAT:
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/run/" +  direction + "/body.png")

	
func move(_velocity: Vector2) -> void:
	if not visible or tornado_node or stunned or destroyed or attacking or state == IDLE:
		return
	if frozen:
		wolf_sprite.modulate = Color("00c9ff")
		velocity = move_and_slide(_velocity*0.75)
	elif poisoned:
		wolf_sprite.modulate = Color("009000")
		velocity = move_and_slide(_velocity*0.9)
	else:
		wolf_sprite.modulate = Color("ffffff")
		velocity = move_and_slide(_velocity)

func _physics_process(delta):
	if not visible or destroyed or stunned: 
		return
	if knocking_back:
		velocity = velocity.move_toward(knockback * KNOCKBACK_SPEED * 7, ACCELERATION * delta * 8)
		velocity = move_and_slide(velocity)
		return
	set_sprite_texture()
	if navigation_agent.is_navigation_finished() and state == WALK:
		state = IDLE
		velocity = Vector2.ZERO
		return
	if (player.state == 5 or player.get_node("Magic").invisibility_active) and chasing:
		end_chase_state()
	elif not (player.state == 5 or player.get_node("Magic").invisibility_active) and $DetectPlayer.get_overlapping_areas().size() >= 1 and not chasing and state != RETREAT:
		start_chase_state()
	if state == CHASE and (position+Vector2(0,-9)).distance_to(player.position) < 70:
		state = ATTACK
		attack()
	var target = navigation_agent.get_next_location()
	var move_direction = position.direction_to(target)
	var desired_velocity = move_direction * navigation_agent.max_speed
	var steering = (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	navigation_agent.set_velocity(velocity)
	
func attack():
	if not attacking:
		play_groan_sound_effect()
		attacking = true
		if Util.chance(50):
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/claw/" +  direction + "/body.png")
			animation_player.play("claw")
		else:
			wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/bite/" +  direction + "/body.png")
			animation_player.play("bite")
		yield(animation_player, "animation_finished")
		if not destroyed:
			animation_player.play("loop")
			attacking = false
			state = CHASE

func hit(tool_name):
	if state == IDLE or state == WALK:
		start_chase_state()
	if tool_name == "blizzard":
		wolf_sprite.modulate = Color("00c9ff")
		$EnemyFrozenState.start(8)
		return
	elif tool_name == "ice projectile":
		wolf_sprite.modulate = Color("00c9ff")
		$EnemyFrozenState.start(3)
	elif tool_name == "lightning spell debuff":
		$EnemyStunnedState.start()
	_end_chase_state_timer.start()
	$HurtBox/AnimationPlayer.play("hit")
	var dmg = Stats.return_tool_damage(tool_name)
	health -= dmg
	InstancedScenes.player_hit_effect(-dmg, position)
	if health < STARTING_HEALTH*.3:
		start_retreat_state()
	if health <= 0 and not destroyed:
		destroy()

func destroy():
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Enemies/killAnimal.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", 0)
	sound_effects.play()
	stop_sound_effects()
	destroyed = true
	wolf_sprite.texture = load("res://Assets/Images/Animals/Wolf/death/" +  direction + "/body.png")
	animation_player.play("death")
	InstancedScenes.intitiateItemDrop("raw filet", position, rng.randi_range(0,2))
	InstancedScenes.intitiateItemDrop("cloth", position, rng.randi_range(0,2))
	yield(animation_player, "animation_finished")
	queue_free()

func _on_HurtBox_area_entered(area):
	if not hit_projectiles.has(area.id):
		if area.id != "":
			hit_projectiles.append(area.id)
		if area.name == "PotionHitbox" and area.tool_name.substr(0,6) == "poison":
			wolf_sprite.modulate = Color("009000")
			$HurtBox/AnimationPlayer.play("hit")
			$EnemyPoisonState.start(area.tool_name)
			return
		if area.name == "SwordSwing":
			PlayerData.player_data["skill_experience"]["sword"] += 1
			Stats.decrease_tool_health()
		else:
			PlayerDataHelpers.add_skill_experience(area.tool_name)
		if area.knockback_vector != Vector2.ZERO:
			$KnockbackParticles.emitting = true
			knocking_back = true
			$Timers/KnockbackTimer.start()
			knockback = area.knockback_vector
			velocity = knockback * 200
		if area.tool_name != "lightning spell" and area.tool_name != "lightning spell debuff":
			hit(area.tool_name)
		if area.tool_name == "lingering tornado":
			$EnemyTornadoState.orbit_radius = rand_range(0,20)
			tornado_node = area
		if area.special_ability == "fire":
			var randomPos = Vector2(rand_range(-8,8), rand_range(-8,8))
			InstancedScenes.initiateExplosionParticles(position+randomPos)
			InstancedScenes.player_hit_effect(-Stats.FIRE_DEBUFF_DAMAGE, position+randomPos)
			health -= Stats.FIRE_DEBUFF_DAMAGE
		elif area.special_ability == "ice":
			wolf_sprite.modulate = Color("00c9ff")
			$EnemyFrozenState.start(3)
		elif area.special_ability == "poison":
			wolf_sprite.modulate = Color("009000")
			$EnemyPoisonState.start("poison arrow")
		yield(get_tree().create_timer(0.25), "timeout")
		$KnockbackParticles.emitting = false

func start_retreat_state():
	state = RETREAT
	_idle_timer.stop()
	_chase_timer.stop()
	_retreat_timer.start()
	stop_sound_effects()
	chasing = false

func start_chase_state():
	start_sound_effects()
	navigation_agent.max_speed = 300
	_idle_timer.stop()
	_chase_timer.start()
	_end_chase_state_timer.start()
	chasing = true
	state = CHASE

func end_chase_state():
	stop_sound_effects()
	navigation_agent.max_speed = 100
	_chase_timer.stop()
	_idle_timer.start()
	chasing = false
	state = WALK
	navigation_agent.set_target_location(Util.get_random_idle_pos(position, MAX_MOVE_DISTANCE))

func _on_EndChaseState_timeout():
	end_chase_state()

func play_groan_sound_effect():
	rng.randomize()
	sound_effects.stream = load("res://Assets/Sound/Sound effects/Animals/Deer/attack.mp3")
	sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", -12)
	sound_effects.play()
	yield(sound_effects, "finished")
	playing_sound_effect = false
	start_sound_effects()

func start_sound_effects():
	if not playing_sound_effect:
		playing_sound_effect = true
		sound_effects.stream = load("res://Assets/Sound/Sound effects/Animals/Deer/gallop.mp3")
		sound_effects.volume_db = Sounds.return_adjusted_sound_db("sound", 0)
		sound_effects.play()

func stop_sound_effects():
	playing_sound_effect = false
	sound_effects.stop()

func _on_VisibilityNotifier2D_screen_entered():
	if chasing:
		start_sound_effects()
	show()

func _on_VisibilityNotifier2D_screen_exited():
	if playing_sound_effect:
		stop_sound_effects()
	hide()

func _on_KnockbackTimer_timeout():
	knocking_back = false
