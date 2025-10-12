extends RayCast3D

@export var HandTracker : XRNode3D

var Laser	: MeshInstance3D
@onready var Hand	: Node3D = HandTracker.find_child("OpenXRFbHandTrackingMesh")

var idle	: Vector3 = Vector3(0.0, 0.3, 1.0)
var hover	: Vector3 = Vector3(0.0, 0.8, 1.0)
var click	: Vector3 = Vector3(1.0, 0.7, 0.1)

# won't parse for some reason
# @onready var State : StateKeeper = StateKeeper.new()
#const StateKeeperClass = preload("res://Scripts/StateKeeper.gd")
#var State: RefCounted = StateKeeperClass.new()

var click_str : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"..".input_float_changed.connect(_on_float_changed)
	Laser = $Laser


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hit : bool	= self.is_colliding()
	var pos			= self.get_collision_point()

	var distance = self.global_position.distance_to(pos)
	
	if hit:
		# var c = click if State.click == 1 else hover
		var c = click if click_str == 1 else hover
		var target	= get_collider()
		if target.has_method("pointer_event"):
			# target.pointer_event(pos, c, State.click)
			target.pointer_event(pos, c, click_str)
		
		Laser.mesh.height		= clamp( distance - 0.2, 0, INF )
		Laser.mesh.radius		= 0.001
		Laser.position			= Vector3(0, distance/2, 0)
		Laser.mesh.material.set_shader_parameter("color", c)
		Hand.material.set_shader_parameter("color", c)
	else:
		# var c = click if State.click == 1 else idle
		var c = click if click_str == 1 else idle
		Laser.mesh.height		= 4.8
		Laser.mesh.radius		= 0.0007
		Laser.position			= Vector3(0, 2.5, 0)
		Laser.mesh.material.set_shader_parameter("color", c)
		Hand.material.set_shader_parameter("color", c)
		


func _on_float_changed(name: String, value: float) -> void:
	match name:
		"index_pinch_strength":
			# State.click = value
			click_str = value
			# pass # left_index_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"middle_pinch_strength":
			pass # left_middle_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"ring_pinch_strength":
			pass # left_ring_strength.get_surface_override_material(0).set_shader_parameter("value", value)
		"little_pinch_strength":
			pass # left_little_strength.get_surface_override_material(0).set_shader_parameter("value", value)
