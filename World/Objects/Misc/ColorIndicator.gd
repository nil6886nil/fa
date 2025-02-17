extends Node2D

var indicator_color = "Red"
var tile_size


func set_indicator_color():
	$Grid.rect_position.y = (tile_size.y-1) * -32
	$Grid.rect_size = Vector2(32*tile_size.x, 32*tile_size.y)
	$Grid/Bottom/Left.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/bottom left.png")
	$Grid/Bottom/Middle.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/bottom middle.png")
	$Grid/Bottom/Right.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/bottom right.png")
	$Grid/Middle/Left.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/middle left.png")
	$Grid/Middle/Middle.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/middle middle.png")
	$Grid/Middle/Right.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/middle right.png")
	$Grid/Top/Left.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/top left.png")
	$Grid/Top/Middle.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/top middle.png")
	$Grid/Top/Right.texture = load("res://Assets/Images/Misc/Color Indicator/" + indicator_color + "/top right.png")

