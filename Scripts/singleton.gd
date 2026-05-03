extends Node
class_name Singleton
#-------------------------------------------------------------------------------
var game_scene: Game_System
#-------------------------------------------------------------------------------
func Set_Button(_b:Button, _selected:Callable, _submited:Callable) -> void:
	Disconnect_Button(_b)
	_b.focus_entered.connect(_selected)
	_b.pressed.connect(_submited)
#-------------------------------------------------------------------------------
func Disconnect_Button(_b:Button) -> void:
	Disconnect_All(_b.focus_entered)
	Disconnect_All(_b.pressed)
	Disconnect_All(_b.gui_input)
#-------------------------------------------------------------------------------
func Disconnect_All(_signal:Signal):
	var _dictionaryArray : Array = _signal.get_connections()
	#-------------------------------------------------------------------------------
	for _dictionary in _dictionaryArray:
		_signal.disconnect(_dictionary["callable"])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Common_Selected():
	pass
#-------------------------------------------------------------------------------
func Common_Submited():
	pass
#-------------------------------------------------------------------------------
