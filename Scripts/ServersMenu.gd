extends Control

@onready var Screen:	MeshInstance3D	= $"../ScreenCollider/ScreenPanel"
@onready var Address:	OptionButton	= find_child("Address")
@onready var Server:	OptionButton	= find_child("Server")
@onready var AddressPicker:	Control		= $"MarginContainer/Frame/VBoxContainer/HorzSplit/Left Side/PickerHolder/PickerEnabled/Address Picker"
@onready var AddressSel:	Label		= $"MarginContainer/Frame/VBoxContainer/HorzSplit/Left Side/Result Address"

@onready var ScreenList: OptionButton	= find_child("Screens")
@onready var ScreenRefresh: Button		= find_child("Refresh")

static	 var addresses:	Dictionary = {}
static	 var servers:	Dictionary = {}

var address	 : String = ""
var port	 : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var json = JSON.new()
	var file = FileAccess.get_file_as_string("res://servers.json")
	var error = json.parse(file)
	if  error:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())
		
	else:
		var config = json.data
		var ID = 1
		for m in config['machines']:
			Address.add_item(m["name"])
			addresses[ID]  = m["addr"]
			ID += 1;
			
		ID = 0
		for s in config['servers']:
			Server.add_item(s['name'])
			servers[ID]  =  s["addr"]
			ID += 1;
	
	Address.select(1)
	_on_address_item_selected(1)
	Server.select(0)
	_on_server_item_selected(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass




func _on_connect_toggled(toggled_on: bool) -> void:
	Screen.mesh.surface_get_material(0).set_shader_parameter("connected", toggled_on)
	Address.disabled = toggled_on
	Server.disabled = toggled_on
	AddressPicker._disable(toggled_on)
	
	ScreenList.disabled  = not toggled_on
	ScreenRefresh.disabled = not toggled_on


func _on_address_item_selected(index: int) -> void:
	$"MarginContainer/Frame/VBoxContainer/HorzSplit/Left Side/PickerHolder".visible = not index
	if index == 0:
		address = AddressPicker.get_addr()
	else:
		address = addresses[index]
	AddressSel.text = address + port
	
func _on_server_item_selected(index: int) -> void:
	port = servers[index]
	AddressSel.text = address + port

func _on_custom_item_selected():
	address = AddressPicker.get_addr()
	AddressSel.text = address + port
