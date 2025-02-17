extends Node

signal set_day
signal set_night
signal season_changed
signal mana_changed
signal energy_changed
signal health_changed
signal health_depleted
signal tool_health_change
signal active_item_updated

onready var SlotClass = load("res://InventoryLogic/Slot.gd")
onready var ItemClass = load("res://InventoryLogic/InventoryItem.gd")

var playerState

var viewInventoryMode: bool = false
var viewMapMode: bool = false
var interactive_screen_mode: bool = false

var health_maximum = 100
var energy_maximum = 100
var mana_maximum = 100

const NUM_INVENTORY_SLOTS = 10
const NUM_HOTBAR_SLOTS = 10

var InventorySlots
var HotbarSlots
var active_item_slot = 0

var player_data = {
	"season": "spring",
	"day_week": "Mon.",
	"day_number": 1,
	"time_minutes": 0,
	"time_hours": 6,
	"health": 100,
	"mana": 100,
	"energy": 100,
	"hotbar": {
		#"0": ["stone sword", 1, 50],
		#"1": ["bow", 1, 50],
		#"2": ["wind staff", 1, 50],
		#"9": ["arrow", 100, null],
	},
	"inventory": {
#			"18": ["wood", 999, null],
#			"19": ["stone", 999, null],
#			"17": ["iron ingot", 99, null],
#			"15": ["bronze ingot", 99, null],
#			"16": ["stone fishing rod", 1, null],
	},
	"chests": {
		"Cave 1-1": {
			"4": ["wheat seeds", 25, null],
			"9": ["health potion I", 2, null],
			"14": ["destruction potion I", 5, null]
		},
		"Cave 1-2": {
			"2": ["bread", 4, null],
			"6": ["regeneration potion II", 3, null],
			"12": ["bronze ore", 8, null],
			"10": ["carrot seeds", 25, null],
		},
		"Cave 1-3": {
			"4": ["speed potion I", 3, null],
			"9": ["arrow", 13, null],
			"16": ["stone", 35, null],
			"25": ["corn seeds", 25, null],
		},
		"Cave 1-4": {
			"4": ["health potion II", 6, null],
			"7": ["poison potion I", 3, null],
			"12": ["wood", 27, null],
			"28": ["tomato seeds", 25, null],
		},
		"Cave 1-5": {
			"1": ["destruction potion II", 8, null],
			"10": ["speed potion II", 6, null],
			"16": ["stone", 35, null],
		},
		"Cave 1-6": {
			"7": ["speed potion II", 3, null],
			"18": ["corn", 6, null],
			"10": ["potato seeds", 40, null],
		},
		"Cave 1-7": {
			"4": ["poison potion III", 2, null],
			"18": ["corn", 6, null],
			"6": ["garlic seeds", 25, null],
		},
		"Cave 1-Boss": {
			"9": ["cooked filet", 5, null],
			"18": ["health potion III", 2, null],
			"26": ["cabbage seeds", 25, null],
		},
		"Cave 2-1": {
			"1": ["iron ore", 14, null],
			"13": ["destruction potion III", 5, null],
			"28": ["strawberry seeds", 25, null],
		},
		"Cave 2-2": {
			"1": ["wood", 80, null],
			"27": ["speed potion III", 3, null],
			"10": ["radish seeds", 25, null],
		},
		"Cave 2-3": {
			"7": ["crab", 6, null],
			"21": ["regeneration potion III", 2, null],
			"9": ["arrow", 36, null],
		},
		"Cave 2-4": {
			"7": ["potato", 16, null],
			"21": ["health potion III", 6, null],
			"10": ["yellow onion seeds", 25, null],
		},
		"Cave 2-5": {
			"21": ["poison potion III", 5, null],
			"14": ["garlic seeds", 25, null],
			"3": ["stone", 120, null],
		},
		"Cave 2-6": {
			"18": ["speed potion III", 5, null],
			"10": ["grape seeds", 25, null],
			"5": ["gold ore", 11, null],
		},
		"Cave 2-7": {
			"4": ["destruction potion III", 8, null],
			"19": ["blueberry seeds", 25, null],
			"25": ["carrot", 15, null],
		},
		"Cave 2-Boss": {
			"4": ["regeneration potion III", 8, null],
			"19": ["sugar cane seeds", 50, null],
			"18": ["speed potion III", 5, null],
		},
		"Cave 1-Fishing": {
			"2": ["wood fishing rod", 1, null],
		}
	},
	"furnaces": {},
	"grain_mills": {},
	"stoves": {},
	"skill_experience": {
			"farming": 0,
			"foraging": 0,
			"fishing": 0,
			"mining": 0,
			"sword": 1,
			"bow": 1,
			"dark": 0,
			"electric": 0,
			"earth": 0,
			"fire": 0,
			"wind": 0,
			"ice": 0,
		},
	"collections": {
		 "crops" : {
			"asparagus": 0,
			"blueberry": 0,
			"cabbage": 0,
			"carrot": 0,
			"cauliflower": 0,
			"corn": 0,
			"garlic": 0,
			"grape": 0,
			"green bean": 0,
			"honeydew melon": 0,
			"green pepper": 0,
			"jalapeno": 0,
			"potato": 0,
			"radish": 0,
			"red pepper": 0,
			"strawberry": 0,
			"sugar cane": 0,
			"tomato": 0,
			"wheat": 0,
			"yellow onion": 0,
			"yellow pepper": 0,
			"zucchini": 0,
		},
		 "resources" : {
			"wood": 0,
			"stone": 0,
			"coal": 0,
			"rope": 0,
			"bronze ore": 0,
			"iron ore": 0,
			"gold ore": 0,
			"aquamarine": 0,
			"emerald": 0,
			"ruby": 0,
			"sapphire": 0,
		},
		"forage" : {
			"purple flower": 0,
			"blue flower": 0,
			"green flower": 0,
			"red flower": 0,
			"red clam": 0,
			"blue clam": 0,
			"pink clam": 0,
			"starfish": 0,
			"baby starfish": 0,
			"white pearl": 0,
			"blue pearl": 0,
			"pink pearl": 0,
			"dark green grass": 0,
			"green grass": 0,
			"red grass": 0,
			"yellow grass": 0,
			"mushroom": 0,
			"raw egg": 0,
		},
		 "fish" : {
			"eel": 0,
			"clownfish": 0,
			"halibut": 0,
			"anchovy": 0,
			"cisco": 0,
			"goldfish": 0,
			"betta": 0,
			"siberian whitefish": 0,
			"red salmon": 0,
			"catfish": 0,
			"koi": 0,
			"purple salmon": 0,
			"lingcod": 0,
			"tilapia": 0,
			"albacore": 0,
			"purple carp": 0,
			"dorado": 0,
			"blowfish": 0,
			"angler": 0,
			"seaweed": 0,
			"octopus": 0,
			"shrimp": 0,
			"crab": 0,
			"nelma": 0
		},
		"food": {
			"asparagus omelette": 0,
			"baked catfish": 0,
			"baked dorado": 0,
			"baked zucchini": 0,
			"blowfish tails": 0,
			"blueberry cake": 0,
			"blueberry pie": 0,
			"bread": 0,
			"calamari with tomatoes": 0,
			"cauliflower soup": 0,
			"cooked filet": 0,
			"cooked green beans": 0,
			"cooked wing": 0,
			"crab cakes": 0,
			"filet mignon": 0,
			"filet soup": 0,
			"filet with garlic mash": 0,
			"filet with tomatoes": 0,
			"grape pastry": 0,
			"green pepper soup": 0,
			"honeydew melon with sugar": 0,
			"mini grape tarts": 0,
			"mushroom soup": 0,
			"pepper and asparagus stir fry": 0,
			"potato soup": 0,
			"potatoes with asparagus": 0,
			"potatoes with green beans": 0,
			"radish soup": 0,
			"red pepper soup": 0,
			"sashimi": 0,
			"sauteed cabbage with garlic": 0,
			"scrambled eggs": 0,
			"seaweed salad": 0,
			"sliced tomatoes and potatoes": 0,
			"smoked jalapeno with eggs": 0,
			"spaghetti": 0,
			"spicy eel": 0,
			"spicy shrimps": 0,
			"strawberry cake": 0,
			"strawberry tart": 0,
			"sugar cane kheer": 0,
			"tomato sandwich": 0,
			"tomato soup": 0,
			"vegetable soup": 0,
			"wings with corn": 0,
			"yellow onion soup": 0,
			"yellow pepper soup": 0,
			"zucchini soup": 0
		}
	}
}

func _ready():
	pass
	#playerState = load_player_data()
	#player_data = playerState.data

func save_player_data():
	pass
	#playerState.data = player_data
	#var result = ResourceSaver.save(PLAYER_STATE_PATH, playerState)
	#if(result == OK):
		#print("saved player data")
	
func load_player_data():
	pass
	#if ResourceLoader.exists(PLAYER_STATE_PATH):
		#playerState = ResourceLoader.load(PLAYER_STATE_PATH)
		#if playerState is PlayerState: # Check that the data is valid
			#return playerState
		#else:
			#return PlayerState.new()		
	#else:
		#return PlayerState.new()		


func eat(food_name):
	change_energy(JsonData.item_data[food_name]["EnergyHealth"][0])
	change_health(JsonData.item_data[food_name]["EnergyHealth"][1])

func change_mana(amount):
	player_data["mana"] += amount
	if player_data["mana"] < 0:
		player_data["mana"] = 0
	elif player_data["mana"] > mana_maximum:
		player_data["mana"] = mana_maximum
	emit_signal("mana_changed")

func change_health(amount):
	player_data["health"] += amount
	if player_data["health"] <= 0:
		player_data["health"] = 0
		emit_signal("health_depleted")
	elif player_data["health"] >= health_maximum:
		player_data["health"] = health_maximum
	emit_signal("health_changed")

func change_energy(amount):
	player_data["energy"] += amount
	if player_data["energy"] <= 0:
		player_data["energy"] = 0
	elif player_data["energy"] >= energy_maximum:
		player_data["energy"] = energy_maximum
	emit_signal("energy_changed")

func respawn_player():
	player_data["energy"] = energy_maximum
	player_data["health"] = health_maximum
	emit_signal("energy_changed")
	emit_signal("health_changed")

### Player Inventory ###
func remove_material(item, amount):
	var amount_to_remove = amount
	for slot in player_data["hotbar"].keys():
		if player_data["hotbar"][slot][0] == item and amount_to_remove != 0:
			if player_data["hotbar"][slot][1] >= amount_to_remove:
				player_data["hotbar"][slot][1] = player_data["hotbar"][slot][1] - amount_to_remove
				update_hotbar_slot_visual(slot, player_data["hotbar"][slot][0], player_data["hotbar"][slot][1], player_data["hotbar"][slot][2])
				return
			else:
				amount_to_remove = amount_to_remove - player_data["hotbar"][slot][1]
				player_data["hotbar"][slot][1] = 0 
				update_hotbar_slot_visual(slot, player_data["hotbar"][slot][0], player_data["hotbar"][slot][1], player_data["hotbar"][slot][2])
	if amount_to_remove != 0:
		for slot in player_data["inventory"].keys():
			if player_data["inventory"][slot][0] == item and amount_to_remove != 0:
				if player_data["inventory"][slot][1] >= amount_to_remove:
					player_data["inventory"][slot][1] = player_data["inventory"][slot][1] - amount_to_remove
					update_inventory_slot_visual(slot, player_data["inventory"][slot][0], player_data["inventory"][slot][1], player_data["inventory"][slot][2])
					return
				else:
					amount_to_remove = amount_to_remove - player_data["inventory"][slot][1]
					player_data["inventory"][slot][1] = 0 
					update_inventory_slot_visual(slot, player_data["inventory"][slot][0], player_data["inventory"][slot][1], player_data["inventory"][slot][2])

func add_item_to_hotbar(item_name, item_quantity, item_health):
	var slot_indices: Array = player_data["hotbar"].keys()
	slot_indices.sort()
	for item in slot_indices:
		if player_data["hotbar"][item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - player_data["hotbar"][item][1]
			if able_to_add >= item_quantity:
				player_data["hotbar"][item][1] += item_quantity
				update_hotbar_slot_visual(item, player_data["hotbar"][item][0], player_data["hotbar"][item][1], player_data["hotbar"][item][2])
				return
			else:
				player_data["hotbar"][item][1] += able_to_add
				update_hotbar_slot_visual(item, player_data["hotbar"][item][0], player_data["hotbar"][item][1], player_data["hotbar"][item][2])
				item_quantity = item_quantity - able_to_add
	# item doesn't exist in hotbar yet, so add it to an empty slot
	for i in range(NUM_HOTBAR_SLOTS):
		if player_data["hotbar"].has(str(i)) == false:
			player_data["hotbar"][str(i)] = [item_name, item_quantity, item_health]
			update_hotbar_slot_visual(i, item_name, item_quantity, item_health)
			Server.player_node.set_held_object()
			return
	# if hotbar full, add to inventory
	add_item_to_inventory(item_name, item_quantity, item_health)

func add_item_to_inventory(item_name, item_quantity, item_health):
	var slot_indices: Array = player_data["inventory"].keys()
	slot_indices.sort()
	for item in slot_indices:
		if player_data["inventory"][item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - player_data["inventory"][item][1]
			if able_to_add >= item_quantity:
				player_data["inventory"][item][1] += item_quantity
				update_inventory_slot_visual(item, player_data["inventory"][item][0], player_data["inventory"][item][1], player_data["inventory"][item][2])
				return
			else:
				player_data["inventory"][item][1] += able_to_add
				update_inventory_slot_visual(item, player_data["inventory"][item][0], player_data["inventory"][item][1] , player_data["inventory"][item][2])
				item_quantity = item_quantity - able_to_add
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if player_data["inventory"].has(str(i)) == false:
			player_data["inventory"][str(i)] = [item_name, item_quantity, item_health]
			update_inventory_slot_visual(i, item_name, item_quantity, item_health)
			return
	InstancedScenes.initiateInventoryItemDrop([item_name, item_quantity, item_health], Server.player_node.position)

func update_inventory_slot_visual(slot_index, item_name, new_quantity, item_health):
	var slot = InventorySlots.get_node("Slot" + str(int(slot_index) + 1))
	if slot.item != null:
		if new_quantity == 0:
			remove_item(slot)
			slot.removeFromSlot()
		else:
			slot.item.set_item(item_name, new_quantity, item_health)
	else:
		slot.initialize_item(item_name, new_quantity, item_health)

func update_hotbar_slot_visual(slot_index, item_name, new_quantity, item_health):
	var slot = HotbarSlots.get_node("Slot" + str(int(slot_index) + 1))
	if slot.item != null:
		if new_quantity == 0:
			remove_item(slot)
			slot.removeFromSlot()
		else:
			slot.item.set_item(item_name, new_quantity, item_health)
	else:
		slot.initialize_item(item_name, new_quantity, item_health)


func add_item_to_empty_slot(item, slot, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			player_data["hotbar"][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.HOTBAR_INVENTORY:
			player_data["hotbar"][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.INVENTORY:
			player_data["inventory"][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.CHEST:
			player_data["chests"][id][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.GRAIN_MILL:
			player_data["grain_mills"][id][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.STOVE:
			player_data["stoves"][id][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.FURNACE:
			player_data["furnaces"][id][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]
		SlotClass.SlotType.TOOL_CABINET:
			player_data["tool_cabinets"][id][str(slot.slot_index)] = [item.item_name, item.item_quantity, item.item_health]


func remove_item(slot, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			player_data["hotbar"].erase(str(slot.slot_index))
		SlotClass.SlotType.HOTBAR_INVENTORY:
			player_data["hotbar"].erase(str(slot.slot_index))
		SlotClass.SlotType.INVENTORY:
			player_data["inventory"].erase(str(slot.slot_index))
		SlotClass.SlotType.CHEST:
			player_data["chests"][id].erase(str(slot.slot_index))
		SlotClass.SlotType.GRAIN_MILL:
			player_data["grain_mills"][id].erase(str(slot.slot_index))
		SlotClass.SlotType.STOVE:
			player_data["stoves"][id].erase(str(slot.slot_index))
		SlotClass.SlotType.FURNACE:
			player_data["furnaces"][id].erase(str(slot.slot_index))
		SlotClass.SlotType.TOOL_CABINET:
			player_data["tool_cabinets"][id].erase(str(slot.slot_index))

func add_item_quantity(slot, quantity_to_add: int, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			player_data["hotbar"][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.HOTBAR_INVENTORY:
			player_data["hotbar"][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.INVENTORY:
			player_data["inventory"][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.CHEST:
			player_data["chests"][id][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.GRAIN_MILL:
			player_data["grain_mills"][id][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.STOVE:
			player_data["stoves"][id][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.FURNACE:
			player_data["furnaces"][id][str(slot.slot_index)][1] += quantity_to_add
		SlotClass.SlotType.TOOL_CABINET:
			player_data["tool_cabintes"][id][str(slot.slot_index)][1] += quantity_to_add
			
func decrease_item_quantity(slot, quantity_to_subtract: int, var id = null):
	match slot.slotType:
		SlotClass.SlotType.HOTBAR:
			player_data["hotbar"][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.HOTBAR_INVENTORY:
			player_data["hotbar"][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.INVENTORY:
			player_data["inventory"][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.CHEST:
			player_data["chests"][id][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.GRAIN_MILL:
			player_data["grain_mills"][id][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.STOVE:
			player_data["stoves"][id][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.FURNACE:
			player_data["furnaces"][id][str(slot.slot_index)][1] -= quantity_to_subtract
		SlotClass.SlotType.TOOL_CABINET:
			player_data["tool_cabintes"][id][str(slot.slot_index)][1] -= quantity_to_subtract

func return_resource_total(item_name):
	var total = 0
	var hotbar = player_data["hotbar"]
	var inventory = player_data["inventory"]
	for slot in hotbar:
		if hotbar[str(slot)][0] == item_name:
			total +=  hotbar[str(slot)][1]
	for slot in inventory:
		if inventory[str(slot)][0] == item_name:
			total += inventory[str(slot)][1]
	return total

func returnSufficentCraftingMaterial(ingredient, amount_needed):
	var total = return_resource_total(ingredient)
	if total >= amount_needed:
		return true
	return false

func isSufficientMaterialToCraft(item):
	var ingredients = JsonData.item_data[item]["Ingredients"]
	for i in range(ingredients.size()):
		if returnSufficentCraftingMaterial(ingredients[i][0], ingredients[i][1]):
			continue
		else:
			return false
	return true

func craft_item(item):
	var ingredients = JsonData.item_data[item]["Ingredients"]
	for i in range(ingredients.size()):
		remove_material(ingredients[i][0], ingredients[i][1])

func remove_single_object_from_hotbar():
	player_data["hotbar"][str(active_item_slot)][1] -= 1
	update_hotbar_slot_visual(active_item_slot, player_data["hotbar"][str(active_item_slot)][0], player_data["hotbar"][str(active_item_slot)][1] , player_data["hotbar"][str(active_item_slot)][2])


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

