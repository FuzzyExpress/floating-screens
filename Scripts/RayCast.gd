extends RayCast3D

var Laser	: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Laser = $Laser


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hit : bool	= self.is_colliding()
	var pos			= self.get_collision_point()

	var distance = self.global_position.distance_to(pos)
	
	if hit:
		Laser.mesh.height		= distance
		Laser.position			= Vector3(0, distance/2, 0)
		Laser.mesh.material.set_shader_parameter("color", Vector3(0.0, 0.8, 1.0))
	else:
		Laser.mesh.height		= 1
		Laser.position			= Vector3(0, 0.5, 0)
		Laser.mesh.material.set_shader_parameter("color", Vector3(0.0, 0.3, 1.0))
		
