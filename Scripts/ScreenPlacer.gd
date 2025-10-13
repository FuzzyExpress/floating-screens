extends Node3D

@export var LeftTop		: BoneAttachment3D
@export var LeftBottom	: BoneAttachment3D
@export var RightTop	: BoneAttachment3D
@export var RightBottom	: BoneAttachment3D

@onready var Screen : MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	pass
	
	
func _process(_delta: float) -> void:
	if not LeftTop or not LeftBottom or not RightTop or not RightBottom:
		return
	
	# Get all corner positions
	var lt = LeftTop.global_position
	var lb = LeftBottom.global_position
	var rt = RightTop.global_position
	var rb = RightBottom.global_position
	
	# Center the screen at the average of all 4 corners
	global_position = (lt + lb + rt + rb) / 4.0
	
	# Calculate the actual width and height from the corners
	var left_edge = (lt + lb) / 2.0
	var right_edge = (rt + rb) / 2.0
	var top_edge = (lt + rt) / 2.0
	var bottom_edge = (lb + rb) / 2.0
	
	var width = left_edge.distance_to(right_edge)
	var height = top_edge.distance_to(bottom_edge)
	
	# Set the screen size
	var plane_mesh = Screen.mesh as PlaneMesh
	if plane_mesh:
		plane_mesh.size = Vector2(width, height)
	
	# Build a stable basis from the corner vectors
	# X axis: left to right
	var x_axis = (right_edge - left_edge).normalized()
	
	# Y axis: bottom to top
	var y_axis = (top_edge - bottom_edge).normalized()
	
	# Z axis: perpendicular to the plane (normal pointing toward user)
	var z_axis = x_axis.cross(y_axis).normalized()
	
	# Recalculate Y to ensure orthogonality
	y_axis = z_axis.cross(x_axis).normalized()
	
	# PlaneMesh faces along -Z by default, so we need to rotate the basis
	# Swap Y and Z, and negate the new Z to rotate 90 degrees
	Screen.global_basis = Basis(x_axis, z_axis, y_axis)
