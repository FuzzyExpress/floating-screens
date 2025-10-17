extends RayCast3D


@export var HandTracker		: XRNode3D
@export var TouchFinder		: ShapeCast3D
@onready var Touch			: ShapeCast3D = TouchFinder.get_child(0)
@export var Controller		: XRController3D

@export var ID			: int

var Laser	: MeshInstance3D
@onready var Hand	: Node3D = HandTracker.find_child("OpenXRFbHandTrackingMesh")

var targetPast : Node

var nearInterface : bool = false

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


func isColliding():
	if not nearInterface:
		return self.is_colliding()
	else:
		return Touch.is_colliding()

func getCollisionPoint(hit):
	if not nearInterface:
		return self.get_collision_point()
	else:
		if hit:
			return Touch.get_collision_point(0)
		else:
			return TouchFinder.get_collision_point(0)
		
func getCollider(hit):
	if not nearInterface:
		return self.get_collider()
	else:
		if hit:
			return Touch.get_collider(0)
		else:
			return TouchFinder.get_collider(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	nearInterface = false # TouchFinder.get_collision_count() > 0
	var hit : bool	= isColliding()
	var pos			= getCollisionPoint(hit)

	var distance = self.global_position.distance_to(pos)
	
	if nearInterface: State.clickL = hit
	State.hit = hit
	
	State.update()
	
	if hit:
		var target	= getCollider(hit)
		
		if not target or targetPast and targetPast != target and targetPast.has_method("pointer_event"):
			targetPast.pointer_exit(State)
		
		if target.has_method("pointer_event"):
			target.pointer_event(pos, State)
		
		Laser.mesh.height		= clamp( distance - 0.2, 0, INF )
		Laser.mesh.radius		= 0.001
		Laser.position			= Vector3(0, distance/2, 0)
		Laser.mesh.material.set_shader_parameter("color", State.c)
		Hand.material.set_shader_parameter("color", State.c)
		
		targetPast = target
	else:
		if targetPast: targetPast.pointer_exit(State)
		Laser.mesh.height		= 4.8
		Laser.mesh.radius		= 0.0007
		Laser.position			= Vector3(0, 2.5, 0)
		Laser.mesh.material.set_shader_parameter("color", State.c)
		Hand.material.set_shader_parameter("color", State.c)
		targetPast = null


func _on_float_changed(_name: String, value: float) -> void:
	match _name:
		"index_pinch_strength":
			State.clickL = value
		"middle_pinch_strength":
			State.clickR = value
		"ring_pinch_strength":
			State.clickM = value
		"little_pinch_strength":
			State.clickSettings = value
