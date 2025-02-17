extends Control


var buildings = ["wall", "foundation", "stairs", "ceiling"]
var current_item = -1

func _ready():
	hide()

func initialize():
	show()
	current_item = -1
	Server.player_node.actions.destroy_placable_object()
	$Circle/AnimationPlayer.play("zoom")
	Server.player_node.get_node("Camera2D").set_process_input(false)
	PlayerData.viewInventoryMode = true
	get_node("Circle/0").initialize()
	get_node("Circle/1").initialize()
	get_node("Circle/2").initialize()
	get_node("Circle/3").initialize()

func _physics_process(delta):
	if not visible:
		return
	set_icon_position()
	if current_item != -1:
		$Title.show()
		$Title.text = buildings[current_item][0].to_upper() + buildings[current_item].substr(1,-1) + ":"
		$Resources.show()
		if current_item == 1 or current_item == 0:
			$Resources.text = "5 x Wood ( " + str(PlayerData.return_resource_total("wood")) + " )"
		else:
			$Resources.text = "Coming soon..."
	else:
		$Title.hide()
		$Resources.hide()


func set_icon_position():
	match current_item:
		-1:
			$Circle/Icons/Wall.position = Vector2(0,-132)
			$Circle/Icons/Foundation.position = Vector2(132,0)
			$Circle/Icons/Stairs.position = Vector2(0,132)
			$Circle/Icons/Ceiling.position = Vector2(-132,0)
		0:
			$Circle/Icons/Wall.position = Vector2(0,-146)
			$Circle/Icons/Foundation.position = Vector2(132,0)
			$Circle/Icons/Stairs.position = Vector2(0,132)
			$Circle/Icons/Ceiling.position = Vector2(-132,0)
		1:
			$Circle/Icons/Wall.position = Vector2(0,-132)
			$Circle/Icons/Foundation.position = Vector2(146,0)
			$Circle/Icons/Stairs.position = Vector2(0,132)
			$Circle/Icons/Ceiling.position = Vector2(-132,0)
		2: 
			$Circle/Icons/Wall.position = Vector2(0,-132)
			$Circle/Icons/Foundation.position = Vector2(132,0)
			$Circle/Icons/Stairs.position = Vector2(0,146)
			$Circle/Icons/Ceiling.position = Vector2(-132,0)
		3:
			$Circle/Icons/Wall.position = Vector2(0,-132)
			$Circle/Icons/Foundation.position = Vector2(132,0)
			$Circle/Icons/Stairs.position = Vector2(0,132)
			$Circle/Icons/Ceiling.position = Vector2(-146,0)


func destroy():
	Server.player_node.get_node("Camera2D").set_process_input(true) 
	if current_item != -1:
		Server.player_node.current_building_item = buildings[current_item]
	else:
		Server.player_node.current_building_item = null
	hide()


func _input(event):
	if PlayerData.player_data["hotbar"].has(str(PlayerData.active_item_slot)):
		if PlayerData.player_data["hotbar"][str(PlayerData.active_item_slot)][0] == "blueprint":
			if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
				if not event.is_pressed():
					destroy()
					yield(get_tree().create_timer(0.1), "timeout")
					PlayerData.viewInventoryMode = false
#
