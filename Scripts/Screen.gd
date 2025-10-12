extends StaticBody3D

var width = 1920
var height = 1080

var size = 1.0

const scaleMulti = 0.001


@onready var ScreenF = $ScreenCollider/ScreenPanel
@onready var ScreenB = $ScreenCollider/PanelBack

@onready var Colider = $ScreenCollider
@onready var Settings : Control = $Screen
@onready var Port : SubViewport = $SubViewport



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
	Port.size = Vector2(width, height)
	


func getUV(hit_pos: Vector3):
	# Convert global position to local position
	var local_pos = to_local(hit_pos)
	
	var s = Vector2(width, height) * size * scaleMulti  # Get actual mesh size
	
	# The panel mesh is positioned at (width/2, height/2, 0) and has size (width, height)
	# So we need to map from local coordinates to UV space (0-1)
	var uv_x : float = (local_pos.x / s.x) + 0.5
	var uv_y : float = (local_pos.y / s.y) + 0.5
	
	# Clamp to 0-1 range to handle edge cases
	uv_x = clamp(uv_x, 0.0, 1.0)
	uv_y = clamp(uv_y, 0.0, 1.0)
	
	return Vector2(uv_x, uv_y)

func set_cursor(uv, color, str):
	ScreenF.mesh.material.set_shader_parameter("cursor", uv)
	ScreenF.mesh.material.set_shader_parameter("cursor_color", color)
	ScreenF.mesh.material.set_shader_parameter("cursor_str", str)
	

func pointer_event(hit_pos: Vector3, color: Vector3, str: float):
	var uv = getUV(hit_pos)
	set_cursor(uv, color, str)
	print("Hit at %f, %f" % [uv.x, uv.y])

	var vp_size = Port.size
	var pos = Vector2(uv.x * vp_size.x, uv.y * vp_size.y)
	print("Pos at %f, %f" % [pos.x, pos.y])

	var event := InputEventMouseMotion.new()
	event.position = pos
	event.global_position = pos
	event.relative = Vector2.ZERO  # Optional
	event.velocity = Vector2.ZERO

	Port.push_input(event)
	
	print()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Done at run time so screen controll can be edited
	# Controls under a SubViewport don't show up in the 2D editor.
	Settings.reparent(Port)
	
	# Configure viewport
	Port.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	onChange()
	
	# Set the viewport texture in the shader (wait one frame for viewport to render)
	await get_tree().process_frame
	var material = ScreenF.mesh.surface_get_material(0)
	if material:
		material.set_shader_parameter("settings_tex", Port.get_texture())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
