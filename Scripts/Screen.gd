extends StaticBody3D

var width = 1920
var height = 1080

var size = 1.0

const scaleMulti = 0.0002

@onready var Screen = $CollisionShape3D/MeshInstance3D
@onready var Colider = $CollisionShape3D
@onready var GUI : Control = $Screen
@onready var Port : SubViewport = $SubViewport


# Updating screen size
func onChange():
	# Set panel size
	var s = Vector2(width, height) * size * scaleMulti
	Screen.mesh.size = s
	Colider.shape.size.x = s.x
	Colider.shape.size.y = s.y
	Colider.position.y = s.y / 2 
	
	GUI.size = Vector2(width, height)
	Port.size = Vector2(width, height)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Done at run time so screen controll can be edited
	# Controls under a SubViewport don't show up in the 2D editor.
	GUI.reparent(Port)
	onChange()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
