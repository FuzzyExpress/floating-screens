extends BoneAttachment3D

@onready var Hand : OpenXRFbHandTrackingMesh = $".."

var index_pinch		: bool = false
var middle_pinch	: bool = false
var ring_pinch		: bool = false
var little_pinch	: bool = false
var menu_gesture	: bool = false

@onready var Index: ProgressBar		= $MarginContainer/PanelContainer/VBoxContainer/Index
@onready var Middle: ProgressBar	= $MarginContainer/PanelContainer/VBoxContainer/Middle
@onready var Ring: ProgressBar		= $MarginContainer/PanelContainer/VBoxContainer/Ring
@onready var Pinky: ProgressBar		= $MarginContainer/PanelContainer/VBoxContainer/Pinky


var wasHit : bool = false
var isDone : bool = false

var LoadScreen = preload("res://Scenes/Screen3D.tscn")
var LoadAnchor = preload("res://Scenes/Anchor3D.tscn")

func loadScreen():


	push_warning('Loading Screen')
	var anchor : Node3D = LoadAnchor.instantiate()
	var screen : Node3D = LoadScreen.instantiate()
	$"../../../..".add_child(anchor)
	anchor.add_child(screen)
	anchor.global_position = self.global_position
	anchor.look_at($"../../../XRCamera3D".global_position)
	anchor.rotate(Vector3(0, 1, 0), PI)
	screen.position.y = 0.04

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer.reparent($SubViewport)
	
	# Set the viewport texture in the shader (wait one frame for viewport to render)
	await get_tree().process_frame
	var material = $Panel.mesh.surface_get_material(0)
	if material:
		material.set_shader_parameter("frame_texture", $SubViewport.get_texture())

func progression(bar: ProgressBar, pressed: bool, reset: bool = false):
	if reset: bar.value = 0
	if pressed:
		bar.value += 0.025
		if bar.value >= 1:
			return true
	else:
		bar.value -= 0.0125
	return false

func done(_log: String, function: String = ""): 
	isDone = true
	_on_button_changed("screen_menu", false)
	print(_log)
	if function:
		Callable(self, function).call()
	else: 
		push_warning("Passed spawning unimplemented screen")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hit = $ShapeCast3D.is_colliding()
	if wasHit != hit and not isDone:
		print(hit, wasHit)
		_on_button_changed("screen_menu", hit)
	wasHit = hit
		
	if hit and not isDone:
		if   progression(Index, index_pinch):	done("Spawn Screen here",	"loadScreen")
		elif progression(Middle, middle_pinch):	done("Start Alignment")
		elif progression(Ring, ring_pinch):		done("N.I. 1")
		elif progression(Pinky, little_pinch):	done("N.I. 2")
	
	if not hit and isDone: isDone = false

func _on_button_changed(_name: String, pressed: bool) -> void:
	match _name:
		"index_pinch":	index_pinch		= pressed
		"middle_pinch":	middle_pinch	= pressed
		"ring_pinch":	ring_pinch		= pressed
		"little_pinch":	little_pinch	= pressed
		#"menu_gesture":  # turns off when prinching, got replaced by a ShapeCast3D
		"screen_menu":
			menu_gesture	= pressed
			$Panel.visible	= pressed
			Index.value = 0;  Middle.value = 0;  Ring.value = 0;  Pinky.value = 0
			$"../../../XR Aim L/RayCast3D".visible = not pressed
			$"../../../XR Aim L/RayCast3D".enabled = not pressed
			$"../../../XR Aim R/RayCast3D".visible = not pressed
			$"../../../XR Aim R/RayCast3D".enabled = not pressed
			$"..".material.set_shader_parameter("rainbow", pressed)

func _on_xr_aim_l_button_pressed(_name:		String) -> void:	_on_button_changed(_name, true)
func _on_xr_aim_l_button_released(_name:	String) -> void:	_on_button_changed(_name, false)
