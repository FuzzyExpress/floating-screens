extends StaticBody3D

@onready var Anchor : MeshInstance3D = $CollisionShape3D/MeshInstance3D
@onready var orignParent : Node3D = self.get_parent_node_3d()

var isHeld : bool
var heldBy : StateKeeper



func pointer_event(hit_pos: Vector3, State: StateKeeper):
	Anchor.mesh.surface_get_material(0).set_shader_parameter("cursor", hit_pos)
	Anchor.mesh.surface_get_material(0).set_shader_parameter("cursor_str", State.click)
	Anchor.mesh.surface_get_material(0).set_shader_parameter("color", G.click if State.click == 1 else G.hover)
	
	if State.click == 1 and not isHeld:
		self.reparent(State.getController())
		isHeld = true
		heldBy = State
		
	elif isHeld and heldBy.click != 1:
		isHeld = false
		heldBy = null
		self.reparent(orignParent)
	
	
func pointer_exit(State: StateKeeper):
	if not isHeld:
		Anchor.mesh.surface_get_material(0).set_shader_parameter("cursor_str", -1)
		Anchor.mesh.surface_get_material(0).set_shader_parameter("color", G.idle)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var strongLevel = true
	# Level the screen: keep facing direction but make Y straight up
	if not strongLevel:
		var current_forward = -self.global_transform.basis.z
		var target_position = self.global_position + current_forward
		self.look_at(target_position, Vector3(0, 1, 0))
	else:
		# Only Y-axis rotation: keep current yaw but zero out pitch and roll
		var current_rotation = self.global_rotation
		self.global_rotation = Vector3(0, current_rotation.y, 0)
