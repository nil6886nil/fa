extends YSort

func _ready():
	randomize()

func _on_Btn_mouse_entered():
	set_mouse_cursor_type()

func _on_Btn_mouse_exited():
	Input.set_custom_mouse_cursor(Images.normal_mouse)

func _on_Btn_pressed():
	if $DetectPlayer.get_overlapping_areas().size() >= 1 and Server.player_node.state == 0:
		PlayerData.player_data["collections"]["forage"]["raw egg"] += 1
		$Egg.hide()
		$Btn.disabled = true
		Input.set_custom_mouse_cursor(Images.normal_mouse)
		Server.player_node.actions.harvest_forage("raw egg")
		yield(get_tree().create_timer(0.6), "timeout")
		PlayerData.add_item_to_hotbar("raw egg", 1, null)
		queue_free()

func set_mouse_cursor_type():
	if not $Btn.disabled:
		if $DetectPlayer.get_overlapping_areas().size() >= 1:
			Input.set_custom_mouse_cursor(load("res://Assets/mouse cursors/harvest.png"))
		else:
			Input.set_custom_mouse_cursor(load("res://Assets/mouse cursors/harvest transparent.png"))


func _on_DetectPlayer_area_entered(area):
	if $Btn.is_hovered():
		set_mouse_cursor_type()

func _on_DetectPlayer_area_exited(area):
	if $Btn.is_hovered():
		set_mouse_cursor_type()
