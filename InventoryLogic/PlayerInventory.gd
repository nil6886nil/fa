extends Node

signal active_item_updated
signal clear_chest
var season = "Spring"
var day_num = 1
var time
var InventorySlots
var HotbarSlots

onready var SlotClass = load("res://InventoryLogic/Slot.gd")
onready var ItemClass = load("res://InventoryLogic/InventoryItem.gd")
const NUM_INVENTORY_SLOTS = 10
const NUM_HOTBAR_SLOTS = 10

var viewInventoryMode = false
var viewMapMode = false
var interactive_screen_mode = false
var chatMode = false
var is_inside_sleeping_bag_area = false
var direction_of_sleeping_bag = "left"
var active_item_slot = 0

#	0: ["electric staff", 1, null],
#	1: ["dark magic staff", 1, null],
#	2: ["fire staff", 1, null],
#	4: ["ice staff", 1, null],
#	3: ["earth staff", 1, null],
#	8: ["wood", 500, null],
#	9: ["stone", 500, null],
##	9: ["rope", 12, null],
#	7: ["iron ingot", 150, null],
	#6: ["furnace", 1, null],
#	7: ["wheat seeds", 60, null],
#	2: ["gold pickaxe", 1, null]
#	4: ["destruction potion I", 10, null],
#	5: ["destruction potion II", 10, null],
#	6: ["destruction potion III", 10, null],
#	7: ["health potion I", 10, null],
#	8: ["health potion II", 10, null],
#	9: ["health potion III", 10, null]

var hotbar = {}
var inventory = {}
#	0: ["wind staff", 1, null],
#	2: ["bow", 1, null],
#	1: ["stone sword", 1, null],
#	7: ["arrow", 500, null],
##	3: ["wood box", 100, null],
##	6: ["poison potion I", 100, null],
##	5: ["poison potion II", 100, null],
##	3: ["poison potion III", 100, null],
##	4: ["regeneration potion I", 10, null],
##	5: ["regeneration potion II", 10, null],
###	6: ["regeneration potion III", 10, null],
###	7: ["speed potion I", 10, null],
###	8: ["speed potion II", 10, null],
##	9: ["speed potion II", 10, null],
#}

#func _ready():
#	hotbar = JsonData.player_data["hotbar"]
#	print(hotbar)

var chests = {
	"level 1, room 1" : {
		1: ["bread", 12, null],
		6: ["health potion I", 4, null],
		9: ["destruction potion I", 4, null],
	},
	"level 1, room 2" : {
		2: ["poison potion I", 4, null],
		6: ["speed potion I", 2, null],
		5: ["regeneration potion II",1, null],
	},
	"level 1, room 3" : {
		1: ["cooked filet", 12, null],
		2: ["health potion II", 6, null],
		9: ["destruction potion II", 4, null],
		6: ["arrow", 20, null],
	},
	"level 1, room 4" : {
		5: ["regeneration potion III",1, null],
		3: ["speed potion II", 1, null],
		8: ["poison potion II", 2, null],
	},
	"level 1, room 5" : {
		8: ["shrimp", 17, null],
		5: ["destruction potion III",1, null],
		3: ["poison potion III", 1, null],
		6: ["arrow", 20, null],
	},
	"level 1, room 6" : {
		1: ["crab", 6, null],
		5: ["destruction potion III",1, null],
		3: ["poison potion III", 1, null],
	},
	"level 1, room 7" : {
		1: ["cooked wing", 6, null],
		5: ["destruction potion III",1, null],
		3: ["health potion III", 1, null],
	}, 
	"level 1, room 8" : {
		11: ["asparagus", 9, null],
		5: ["destruction potion III",1, null],
		7: ["poison potion III", 2, null],
	},    
	"level 1, room 9" : {
		14: ["carrot", 20, null],
		5: ["speed potion III",1, null],
		7: ["regeneration potion III", 2, null],
	},
	"level 1, room 10" : {
		1: ["cooked wing", 6, null],
		5: ["destruction potion III",1, null],
		3: ["health potion III", 1, null],
	}, 
	"level 1, room 10-5"  : {
		5: ["wood fishing rod", 1, null],
	},  
	"level 2, room 1" : {
		1: ["bread", 12, null],
		6: ["health potion II", 4, null],
		9: ["destruction potion III", 4, null],
	},
	
}

var furnaces = {}
var grain_mills = {}
var stoves = {}
var tool_cabinets = {}



func isSufficientMaterialToCraft(item):
	var ingredients = JsonData.item_data[item]["Ingredients"]
	for i in range(ingredients.size()):
		if returnSufficentCraftingMaterial(ingredients[i][0], ingredients[i][1]):
			continue
		else:
			return false
	return true

func return_resource_total(item_name):
	var total = 0
	var hotbar = PlayerData.player_data["hotbar"]
	var inventory = PlayerData.player_data["inventory"]
	for slot in hotbar:
		if hotbar[slot][0] == item_name:
			total +=  hotbar[slot][1]
	for slot in inventory:
		if inventory[slot][0] == item_name:
			total += inventory[slot][1]
	return total

func returnSufficentCraftingMaterial(ingredient, amount_needed):
	var total = return_resource_total(ingredient)
	if total >= amount_needed:
		return true
	return false


func craft_item(item):
	if item == "wood door side":
		item = "wood door"
	var ingredients = JsonData.item_data[item]["Ingredients"]
	for i in range(ingredients.size()):
		remove_material(ingredients[i][0], ingredients[i][1])


func remove_material(item, amount):
	var amount_to_remove = amount
	var hotbar = PlayerData.player_data["hotbar"]
	var inventory = PlayerData.player_data["inventory"]
	for slot in hotbar.keys():
		if hotbar[slot][0] == item and amount_to_remove != 0:
			if hotbar[slot][1] >= amount_to_remove:
				hotbar[slot][1] = hotbar[slot][1] - amount_to_remove
				amount_to_remove = 0
				update_hotbar_slot_visual(slot, hotbar[slot][0], hotbar[slot][1], hotbar[slot][2])
				return
			else:
				amount_to_remove = amount_to_remove - hotbar[slot][1]
				hotbar[slot][1] = 0 
				update_hotbar_slot_visual(slot, hotbar[slot][0], hotbar[slot][1], hotbar[slot][2])
	if amount_to_remove != 0:
		for slot in inventory.keys():
			if inventory[slot][0] == item and amount_to_remove != 0:
				if inventory[slot][1] >= amount_to_remove:
					inventory[slot][1] = inventory[slot][1] - amount_to_remove
					amount_to_remove = 0
					update_inventory_slot_visual(slot, inventory[slot][0], inventory[slot][1], inventory[slot][2])
					return
				else:
					amount_to_remove = amount_to_remove - inventory[slot][1]
					inventory[slot][1] = 0 
					update_inventory_slot_visual(slot, inventory[slot][0], inventory[slot][1], inventory[slot][2])



func remove_single_object_from_hotbar():
	hotbar[active_item_slot][1] -= 1
	update_hotbar_slot_visual(active_item_slot, hotbar[active_item_slot][0], hotbar[active_item_slot][1] , hotbar[active_item_slot][2])


func can_item_be_added_to_inventory(item_name, item_quantity):
	var slot_indices: Array = hotbar.keys()
	slot_indices.sort()
	# check if it exists in hotbar
	for item in slot_indices:
		if hotbar[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - hotbar[item][1]
			if able_to_add >= item_quantity:
				return true
			else:
				item_quantity = item_quantity - able_to_add
	var inv_slot_indices: Array = inventory.keys()
	inv_slot_indices.sort()
	for item in inv_slot_indices:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				return true
			else:
				item_quantity = item_quantity - able_to_add
	# item doesn't exist, so add it to an empty hotbar slot
	for i in range(NUM_HOTBAR_SLOTS):
		if hotbar.has(i) == false:
			return true
	# item doesn't exist, so add it to an empty inventory slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			return true
	return false


		

func update_chest_slot_visual(slot_index, item_name, new_quantity):
	pass
#	var slot = get_tree().root.get_node("/root/World/Players/" + str(Server.player_id) + "/" + str(Server.player_id) + "/Camera2D/UserInterface/OpenChest/ChestSlots/Slot" + str(slot_index + 1))
#	if slot.item != null:
#		if new_quantity == 0:
#			remove_item(slot)
#			slot.removeFromSlot()
#		else:
#			slot.item.set_item(item_name, new_quantity)
#	else:
#		slot.initialize_item(item_name, new_quantity)


func add_item_to_empty_slot(item, slot, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.HOTBAR_INVENTORY:
			hotbar[slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.CHEST:
			chests[id][slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.GRAIN_MILL:
			grain_mills[id][slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.STOVE:
			stoves[id][slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.FURNACE:
			furnaces[id][slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.TOOL_CABINET:
			tool_cabinets[id][slot.slot_index] = [item.item_name, item.item_quantity, item.item_health]


func add_item_quantity(slot, quantity_to_add: int, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.HOTBAR_INVENTORY:
			hotbar[slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.CHEST:
			chests[id][slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.GRAIN_MILL:
			grain_mills[id][slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.STOVE:
			stoves[id][slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.FURNACE:
			furnaces[id][slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.TOOL_CABINET:
			tool_cabinets[id][slot.slot_index][1] += quantity_to_add

func decrease_item_quantity(slot, quantity_to_subtract: int, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.HOTBAR_INVENTORY:
			hotbar[slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.CHEST:
			chests[id][slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.GRAIN_MILL:
			grain_mills[id][slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.STOVE:
			stoves[id][slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.FURNACE:
			furnaces[id][slot.slot_index][1] -= quantity_to_subtract
		SlotClass.SlotType.TOOL_CABINET:
			tool_cabinets[id][slot.slot_index][1] -= quantity_to_subtract



###
### Change active hotbar functions
func active_item_scroll_up() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")

func active_item_scroll_down() -> void:
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")

func hotbar_slot_selected(slot) -> void:
	active_item_slot = slot.slot_index
	emit_signal("active_item_updated")


