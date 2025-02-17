extends Control

onready var chatLog = $VBoxContainer/RichTextLabel
onready var inputLabel = $VBoxContainer/HBoxContainer/Label
onready var inputField = $VBoxContainer/HBoxContainer/LineEdit


func _ready():
	initialize_chat_history()
	inputField.connect("text_entered", self, "text_entered")
	
func initialize_chat_history():
	for i in range(Chat.message_history.size()):
		if str(Chat.message_history[i][0]) == str(Server.player_id):
			add_message(Chat.message_history[i][0], Chat.message_history[i][1], '#1359ff')
		else:
			add_message(Chat.message_history[i][0], Chat.message_history[i][1], '#ffffff')
	
func ReceiveMessage(player_id, message):
	if str(player_id) == Server.player_id:
		add_message(player_id, message, '#00e7ff')
	else:
		add_message(player_id, message, '#ffffff')


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			inputField.grab_focus()
		if event.pressed and event.scancode == KEY_ESCAPE:
			inputField.release_focus()
			

func text_entered(text):
	if text != "":
		var data =  {"u": Server.username, "d": text}
		var message = Util.toMessage("SEND_MESSAGE",data)
		Server._client.get_peer(1).put_packet(message)
		inputField.text = ''
		inputField.release_focus()
	
func add_message(username, text, color):
	chatLog.bbcode_text += '\n' 
	chatLog.bbcode_text += '[color=' + color + ']'
	chatLog.bbcode_text += '[' + str(username).substr(0,5) + ']: '
	chatLog.bbcode_text += text
	chatLog.bbcode_text += '[/color]'


func _on_LineEdit_focus_entered():
	PlayerData.chatMode = true


func _on_LineEdit_focus_exited():
	PlayerData.chatMode = false


func _on_TextureButton_pressed():
	$ColorRect.visible = !$ColorRect.visible
	$VBoxContainer.visible = !$VBoxContainer.visible
	if $ColorRect.visible == false:
		$TextureButton.texture_normal = load("res://Assets/Images/Misc/right arrow.png")
	else:
		$TextureButton.texture_normal = load("res://Assets/Images/Misc/left arrow.png")
