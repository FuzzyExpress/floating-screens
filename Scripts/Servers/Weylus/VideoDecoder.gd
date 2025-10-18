extends Node

var Screen : ShaderMaterial
var ScreenProp: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the Android Media Codec decoder
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func VideoHeader(packet):
	"""
	The first binary packet after "NewVideo"
	Contains basic h264 mp4 info
	"""

func VideoContainerHeader(packet):
	"""
	The 2nd binary packet after "NewVideo"
	Contains info about the video stream itself.
	Main interest is setting up the video decoder, and returning width, height, and any other important info.
	"""
	
func VideoFrame(packet):
	"""
	All following binary packets.
	Decode them into an image texture and apply it to the screen.
	"""
	# var frame = decoder.decodeFrame()
	# start decoding as a thread
	# thread should pass to NewFrame() once done

func NewFrame(frame: Texture2D):
	Screen.set_shader_parameter(ScreenProp, frame)
