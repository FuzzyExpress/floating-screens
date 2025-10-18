extends StaticBody3D

@export var width = 1920
@export var height = 1080

@export var size = 0.4

const scaleMulti = 0.001

# Track click state per pointer
var pointer_states = {}  # Dictionary to track each pointer's previous click state


@onready var ScreenF = $ScreenCollider/ScreenPanel
@onready var ScreenB = $ScreenCollider/PanelBack

@onready var Colider = $ScreenCollider
@onready var Settings : Control = $Screen
@onready var Port : SubViewport = $SubViewport

var settingsOpenAmt : float = 0
var settingsOpen : bool  = false
var settingsLast : bool  = false

# Updating screen size
func onChange():
	# Set panel size
	var s = Vector2(width, height) * size * scaleMulti
	ScreenF.mesh.size = s
	ScreenB.mesh.size = s
	ScreenF.mesh.material.set_shader_parameter("size", s)
	ScreenB.mesh.material.set_shader_parameter("size", s)

	Colider.shape.size.x = s.x
	Colider.shape.size.y = s.y
	Colider.position.y = s.y / 2 
	
	Settings.size = Vector2(width, height)
	Port.size     = Vector2(width, height)
	


func getUV(hit_pos: Vector3):
	# Convert global position to local position
	var local_pos = to_local(hit_pos)
	
	var s = Vector2(width, height) * size * scaleMulti  # Get actual mesh size
	
	# The panel mesh is positioned at (width/2, height/2, 0) and has size (width, height)
	# So we need to map from local coordinates to UV space (0-1)
	var uv_x : float = (local_pos.x / s.x) + 0.5
	var uv_y : float = (local_pos.y / s.y) # - 0.5
	
	# Clamp to 0-1 range to handle edge cases
	uv_x = clamp(uv_x, 0.0, 1.0)
	uv_y = clamp(uv_y, 0.0, 1.0)
	
	return Vector2(uv_x, uv_y)

func set_cursor(iUV, State):
	var uv = iUV;
	var scaler
	var m = min(float(width), float(height))
	if m != 0:
		scaler = Vector2(float(width), float(height)) / m
	
	uv.x = G.remap(0, 1, 0.28 * scaler.x, -0.28 * scaler.x,  iUV.x)
	uv.y = G.remap(0, 1, 0.28 * scaler.y, -0.28 * scaler.y,  iUV.y)

	ScreenF.mesh.material.set_shader_parameter("cursor" + str(State.ID + 1), uv)
	ScreenF.mesh.material.set_shader_parameter("cursor_color" + str(State.ID + 1), State.c)
	ScreenF.mesh.material.set_shader_parameter("cursor_str" + str(State.ID + 1), State.str)


func pointer_exit(State: StateKeeper):
	ScreenF.mesh.material.set_shader_parameter("cursor_str" + str(State.ID + 1), -1)
	#ScreenF.mesh.material.set_shader_parameter("color" + str(State.ID + 1), G.idle) 

func pointer_event(hit_pos: Vector3, State: StateKeeper):
	if settingsLast != (State.clickSettings > G.PinchThresh):
		settingsLast = (State.clickSettings > G.PinchThresh)
		if settingsLast: settingsOpen = not settingsOpen
			
	
	
	var uv = getUV(hit_pos)
	uv.y = 1 - uv.y
	set_cursor(uv, State)
	# print("Hit at %f, %f" % [uv.x, uv.y])
	
	if not settingsOpen: return

	var vp_size = Port.size
	var pos = Vector2(uv.x * vp_size.x, uv.y * vp_size.y)
	# print("Pos at %f, %f" % [pos.x, pos.y])

	# Always send mouse motion
	var motion_event := InputEventMouseMotion.new()
	motion_event.position = pos
	motion_event.global_position = pos
	motion_event.relative = Vector2.ZERO
	motion_event.velocity = Vector2.ZERO
	Port.push_input(motion_event)
	
	# Handle click detection (threshold for pinch strength)
	var pointer_id = State.ID
	
	# Get previous click state (default to false if not tracked yet)
	var was_clicking = pointer_states.get(pointer_id, false)
	var is_clicking = State.clickL >= G.PinchThresh

	
	# Detect state changes
	if is_clicking and not was_clicking:
		# Mouse button pressed
		var press_event := InputEventMouseButton.new()
		press_event.position = pos
		press_event.global_position = pos
		press_event.button_index = MOUSE_BUTTON_LEFT
		press_event.pressed = true
		Port.push_input(press_event)
	
	elif not is_clicking and was_clicking:
		# Mouse button released
		var release_event := InputEventMouseButton.new()
		release_event.position = pos
		release_event.global_position = pos
		release_event.button_index = MOUSE_BUTTON_LEFT
		release_event.pressed = false
		Port.push_input(release_event)
	
	# Update tracked state
	pointer_states[pointer_id] = is_clicking


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Done at run time so screen controll can be edited
	# Controls under a SubViewport don't show up in the 2D editor.
	Settings.reparent(Port)
	onChange()
	
	# Set the viewport texture in the shader (wait one frame for viewport to render)
	await get_tree().process_frame
	var material = ScreenF.mesh.surface_get_material(0)
	if material:
		material.set_shader_parameter("settings_tex", Port.get_texture())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if settingsOpen and settingsOpenAmt != 1:
		settingsOpenAmt += ( 0.0125 + 0.025 ) * 0.5
		settingsOpenAmt = clamp(settingsOpenAmt, 0, 1) 
		ScreenF.mesh.surface_get_material(0).set_shader_parameter("settings", G.EaseIOCubic(settingsOpenAmt))
	
	elif not settingsOpen and settingsOpenAmt != 0:
		settingsOpenAmt -= ( 0.0125 + 0.025 ) * 0.5
		settingsOpenAmt = clamp(settingsOpenAmt, 0, 1) 
		ScreenF.mesh.surface_get_material(0).set_shader_parameter("settings", G.EaseIOCubic(settingsOpenAmt))

#
#func _on_screen_gui_input(event: InputEvent) -> void:
	#Test.text = event.as_text()
