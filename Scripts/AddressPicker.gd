extends HBoxContainer

var enabled : bool = true

func get_addr() -> String:
	var addr : String = ""
	for each: Control in self.get_children(false):
		match each.get_class():
			"OptionButton":
				if each.selected > -1:
					addr += str( each.selected )
			"Label":
				addr += "."
				
	return addr


func set_addr(addr: String) -> bool:
	var digits: Array[Node] = find_children("OptionButton*", "OptionButton", false)
	var c	: int = 0
	var arr : Array = addr.split(".")
	
	for each: String in arr:
		if each.length() > 3: push_error(self, " ", set_addr, " input IP's block ", c+1, " is too large!"); return false
		while each.length() != 3:
			each += " "
		
		for d: String in each:
			if d != " ":
				digits[c].select(int(d))
			else:
				digits[c].select(-1)
				
	return true

func _disable(disable: bool):
	for each: OptionButton in find_children("OptionButton*", "OptionButton", false):
		each.disabled = disable
	
	if disable and enabled:
		$"../../PickerDisabled".visible = true
		reparent($"../../PickerDisabled")
		$"../../PickerEnabled".visible = false
		enabled = false
		
	elif not disable and not enabled:
		$"../../PickerEnabled".visible = true
		reparent($"../../PickerEnabled")
		$"../../PickerDisabled".visible = false
		enabled = true
	
func _ready() -> void:
	var digits: Array[Node] = find_children("OptionButton*", "OptionButton", false)
	for each: OptionButton in digits:
		print(each)
		each.item_selected.connect($"../../../../../../../.."._on_custom_item_selected)
