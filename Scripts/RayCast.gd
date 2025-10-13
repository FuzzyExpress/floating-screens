extends RayCast3D


@export var HandTracker : XRNode3D
@export var Controller : XRController3D

@export var ID			: int

var Laser	: MeshInstance3D
@onready var Hand	: Node3D = HandTracker.find_child("OpenXRFbHandTrackingMesh")

var targetPast : Node

# won't parse for some reason
@onready var State : StateKeeper = StateKeeper.new()
#const StateKeeperClass = preload("res://Scripts/StateKeeper.gd")
#var State: RefCounted = StateKeeperClass.new()

var click_str : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	State.ID = ID
	State.Controller = Controller
	$"..".input_float_changed.connect(_on_float_changed)
	Laser = $Laser


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hit : bool	= self.is_colliding()
	var pos			= self.get_collision_point()

	var distance = self.global_position.distance_to(pos)
	
	if hit:
		var c = G.click if State.click == 1 else G.hover
		var target	= get_collider()
		
		if not target or targetPast and targetPast != target and targetPast.has_method("pointer_event"):
			targetPast.pointer_exit(State)
		
		if target.has_method("pointer_event"):
			target.pointer_event(pos, State)
		
		Laser.mesh.height		= clamp( distance - 0.2, 0, INF )
		#Laser.mesh.height		= clamp( distance - 0.0, 0, INF )
		Laser.mesh.radius		= 0.001
		Laser.position			= Vector3(0, distance/2, 0)
		Laser.mesh.material.set_shader_parameter("color", c)
		Hand.material.set_shader_parameter("color", c)
		
		targetPast = target
	else:
		var c = G.click if State.click == 1 else G.idle
		Laser.mesh.height		= 4.8
		#Laser.mesh.height		= 5.0
		Laser.mesh.radius		= 0.0007
		Laser.position			= Vector3(0, 2.5, 0)
		Laser.mesh.material.set_shader_parameter("color", c)
		Hand.material.set_shader_parameter("color", c)
		


func _on_float_changed(name: String, value: float) -> void:
	match name:
		"index_pinch_strength":
			State.click = value
			# pass # left_index_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"middle_pinch_strength":
			pass # left_middle_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"ring_pinch_strength":
			pass # left_ring_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"little_pinch_strength":
			pass # left_little_strength.get_surface_override_material(0).set_shader_parameter("value", value)
