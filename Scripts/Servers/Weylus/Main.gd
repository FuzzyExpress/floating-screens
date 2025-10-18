extends Node

var online
var address

var Socket  = load("res://Scripts/Servers/Weylus/WebSocket.gd")
var Decoder = load("res://Scripts/Servers/Weylus/VideoDecoder.gd")

signal NewScreens(Dictionary)# hook to screen list OptionButton
signal PickedScreen(int) # hook to screen list OptionButton
#signal 

func _init(_address) -> void:
	address = "ws://" + _address
	online = true


func SendConfig(screen: int = 1):
	var config = {
		"Config": {
			"capturable_id": screen, # lastScreen, # Settings.find_child("Screens").selected,
			"capture_cursor": true,
			"max_width": 6000,
			"max_height": 6000,
			"uinput_support": true,
			#"client_name": "WeylusVR " + get_parent().ScreenID
			#"client_name": "VR Weylus " + get_parent().ScreenID
			"client_name": "Floating Screens" #baseName + get_parent().ScreenID
		}
	}
	Socket.send(JSON.stringify(config))

func GetScreens():
	Socket.send("GetCapturableList")

func Disconnect():
	"""
	Stop connection to the server and destroy this client.
	"""
	online = false

enum ButtonType {Stylus, Eraser, Touch, MouseL, MouseR, MouseM}
enum ButtonDir  {Down, Move, Up}

func PointerEvent(type: ButtonType, dir: ButtonDir, x: float, y: float):
	"""
	Screen input event. Takes a type of input, it's direction, and location.
	"""
	
func KeyEvent(key: String):
	"""
	Keybaord event.
	"""

func SetTextureDestination(material: ShaderMaterial, name: String) -> bool:
	"""
	Set the material that the video should be applied to.
	-> material.set_shader_parameter(name, <texture>)
	"""
	if material and name: 
		Screen = material
		return true
	else: return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
