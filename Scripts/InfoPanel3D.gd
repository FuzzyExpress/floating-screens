extends MeshInstance3D

@onready var C : Control = $Control
@onready var Top	= $Control/PanelContainer/VBoxContainer/CenterContainer/Label
@onready var Bottom	= $Control/PanelContainer/VBoxContainer/CenterContainer2/Label2
@export var Mode = "Time"
@export var StateHolder = RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control.reparent($SubViewport)
	
	# Set the viewport texture in the shader (wait one frame for viewport to render)
	await get_tree().process_frame
	var material = $".".mesh.surface_get_material(0)
	if material:
		material.set_shader_parameter("frame_texture", $SubViewport.get_texture())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	C.modulate = StateHolder.State.c
	match Mode:
		"Time":
			var t = Time.get_datetime_dict_from_system()
			var h = t.hour
			if h == 0: h  = 12
			if h > 12: h -= 12
			
			Top.text	= "%d:%d:%d %s" % [h, t.minute, t.second, "PM" if t.hour >= 12 else "AM"]
			Bottom.text = get_date_string_short(t)
		"Performance":
			Top.text	= str(Engine.get_frames_per_second()) + " FPS"
			Bottom.text = str(roundf(delta*1000*1000)/1000) + " mspt"


func get_date_string_short(t) -> String:
	var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
				  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	
	var dow = days[t.weekday]                # Day of week abbreviation
	var mon = months[t.month - 1]            # Month abbreviation
	var day = t.day
	var year = t.year % 100                  # Two-digit year
	
	# Add ordinal suffix (st, nd, rd, th)
	var suffix = "th"
	if day % 10 == 1 and day != 11:
		suffix = "st"
	elif day % 10 == 2 and day != 12:
		suffix = "nd"
	elif day % 10 == 3 and day != 13:
		suffix = "rd"
	
	return "%s, %s %d%s %02d" % [dow, mon, day, suffix, year]
