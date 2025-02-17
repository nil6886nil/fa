extends Node

var item_data: Dictionary
var crop_data: Dictionary
var world_data: Dictionary
var player_data: Dictionary

func _ready():
	item_data = LoadData("res://JSONData/ItemData.json")
	crop_data = LoadData("res://JSONData/CropData.json")
	#world_data = LoadData("res://JSONData/world.json")

func LoadData(file_path):
	var json_data
	var file_data = File.new() 
	
	file_data.open(file_path, File.READ)
	json_data = JSON.parse(file_data.get_as_text())
	file_data.close()
	return json_data.result
