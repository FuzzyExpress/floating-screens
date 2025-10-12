extends TextureRect

var frame : float = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.rotation_degrees = ( int(frame*6) % 4 ) * 90.
	# print(frame)
	frame += _delta
