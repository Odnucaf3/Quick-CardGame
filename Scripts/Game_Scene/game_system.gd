extends Node
class_name Game_System
#-------------------------------------------------------------------------------
#region VARIABLES
#-------------------------------------------------------------------------------
@export var card_node_2d_prefab: PackedScene
@export var frame_monster: Texture2D
@export var frame_fusion: Texture2D
@export var frame_magic: Texture2D
@export var frame_trap: Texture2D
#-------------------------------------------------------------------------------
@export var card_button_root: Control
var hovered_control: Control
var focused_control: Control
#-------------------------------------------------------------------------------
@export var card_info: Card_Control
@export var card_info_richtext_stats: RichTextLabel
@export var card_info_richtext_effect: RichTextLabel
#-------------------------------------------------------------------------------
@export var debug_label: Label
@export var fps_label: Label
@export var player_1: Player_Node_2D
@export var player_2: Player_Node_2D
#-------------------------------------------------------------------------------
var interactable_node_2d_array: Array[Interactable_Node_2D]
var highlighted_interactable_node_2d: Interactable_Node_2D
var new_selected_interactable_node_2d: Interactable_Node_2D
var last_selected_interactable_node_2d: Interactable_Node_2D
#-------------------------------------------------------------------------------
@export var world_2d: Node2D
var screen_size: Vector2
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var is_left_mouse_pressed: bool = false
var left_mouse_counter: int = 0
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
#-------------------------------------------------------------------------------
func _enter_tree() -> void:
	singleton.game_scene =  self
#-------------------------------------------------------------------------------
func _exit_tree() -> void:
	singleton.game_scene =  null
#-------------------------------------------------------------------------------
func _ready() -> void:
	screen_size = world_2d.get_viewport_rect().size
	parameters = PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = true
	space_state = world_2d.get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	Set_Player(player_1)
	Set_Player(player_2)
	#-------------------------------------------------------------------------------
	card_button_root.hide()
	#-------------------------------------------------------------------------------
	await Seconds(0.5)
	Draw_X_Cards(player_1, 5)
	await Draw_X_Cards(player_2, 5)
	await Seconds(0.5)
	await Draw_1_Card(player_1)
#-------------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	hovered_control = get_viewport().gui_get_hovered_control()
	focused_control = get_viewport().gui_get_focus_owner()
	interactable_node_2d_array = Get_Mouse_Pointer()
	#-------------------------------------------------------------------------------
	debug_label.text = Get_Debug_Text()
	fps_label.text = Get_FPS()
	#-------------------------------------------------------------------------------
	StateMachine()
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region DEBUG INFORMATION
#-------------------------------------------------------------------------------
func Get_Debug_Text() -> String:
	var _s: String = ""
	#-------------------------------------------------------------------------------
	_s += "#----------------------------------------------------"
	_s += "\n"
	_s += "Control Actived: "+str(focused_control)
	_s += "\n"
	_s += "Hovered Actived: "+str(hovered_control)
	_s += "\n"
	_s += "#----------------------------------------------------"
	_s += "\n"
	_s += "Highlighted Interactable Node 2D: " + str(highlighted_interactable_node_2d)
	_s += "\n"
	_s += "New Selected Interactable Node 2D: " + str(new_selected_interactable_node_2d)
	_s += "\n"
	_s += "Last Selected Interactable Node 2D: " + str(last_selected_interactable_node_2d)
	_s += "\n"
	_s += "#----------------------------------------------------"
	_s += "\n"
	_s += "Is Left Clicked: " + str(is_left_mouse_pressed)
	_s += "\n"
	_s += "Left Click Counter: " + str(left_mouse_counter)
	_s += "\n"
	_s += "#----------------------------------------------------"
	_s += "\n"
	_s += "Interactable Node 2D Array:"
	_s += "\n"
	#-------------------------------------------------------------------------------
	for _i in interactable_node_2d_array.size():
		_s += "---->"+str(interactable_node_2d_array[_i])
		_s += "\n"
	#-------------------------------------------------------------------------------
	_s += "#----------------------------------------------------"
	return _s
#-------------------------------------------------------------------------------
func Get_FPS():
	var _s: String= str(Engine.get_frames_per_second()) + " fps."
	return _s
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE-MACHINE FUNTIONS
#-------------------------------------------------------------------------------
func StateMachine():
	StateMachine_Highlighted()
	StateMachine_Selected()
#-------------------------------------------------------------------------------
func StateMachine_Highlighted():
	#-------------------------------------------------------------------------------
	if(hovered_control != null):
		#-------------------------------------------------------------------------------
		if(highlighted_interactable_node_2d != null):
			highlighted_interactable_node_2d.des_highlighted.call()
			Remove_Left_Click()
			highlighted_interactable_node_2d = null
		#-------------------------------------------------------------------------------
		return
	#-------------------------------------------------------------------------------
	if(highlighted_interactable_node_2d == null):
		#-------------------------------------------------------------------------------
		if(interactable_node_2d_array.size() > 0):
			highlighted_interactable_node_2d = interactable_node_2d_array[0]
			highlighted_interactable_node_2d.highlighted.call()
			Remove_Left_Click()
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		#-------------------------------------------------------------------------------
		if(interactable_node_2d_array.size() > 0):
			#-------------------------------------------------------------------------------
			if(interactable_node_2d_array.has(highlighted_interactable_node_2d)):
				var _old_interactable_node_2d: Interactable_Node_2D = highlighted_interactable_node_2d
				#-------------------------------------------------------------------------------
				for _i in interactable_node_2d_array.size():
					#-------------------------------------------------------------------------------
					if(interactable_node_2d_array[_i].z_index > highlighted_interactable_node_2d.z_index):
						highlighted_interactable_node_2d = interactable_node_2d_array[_i]
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				if(highlighted_interactable_node_2d != _old_interactable_node_2d):
					highlighted_interactable_node_2d.highlighted.call()
					_old_interactable_node_2d.des_highlighted.call()
					Remove_Left_Click()
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				var _old_interactable_node_2d: Interactable_Node_2D = highlighted_interactable_node_2d
				highlighted_interactable_node_2d = interactable_node_2d_array[0]
				#-------------------------------------------------------------------------------
				for _i in interactable_node_2d_array.size():
					#-------------------------------------------------------------------------------
					if(interactable_node_2d_array[_i].z_index > highlighted_interactable_node_2d.z_index):
						highlighted_interactable_node_2d = interactable_node_2d_array[_i]
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				highlighted_interactable_node_2d.highlighted.call()
				_old_interactable_node_2d.des_highlighted.call()
				Remove_Left_Click()
			#-------------------------------------------------------------------------------
		else:
			highlighted_interactable_node_2d.des_highlighted.call()
			Remove_Left_Click()
			highlighted_interactable_node_2d = null
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Remove_Left_Click():
	is_left_mouse_pressed = false
	left_mouse_counter = 0
	#new_selected_interactable_node_2d = null
#-------------------------------------------------------------------------------
func StateMachine_Selected():
	if(hovered_control != null):
		return
	#-------------------------------------------------------------------------------
	if(is_left_mouse_pressed):
		left_mouse_counter += 1
		#-------------------------------------------------------------------------------
		if(Input.is_action_just_released("Left_Click")):
			is_left_mouse_pressed = false
			#-------------------------------------------------------------------------------
			if(new_selected_interactable_node_2d == highlighted_interactable_node_2d and new_selected_interactable_node_2d != last_selected_interactable_node_2d):
				#-------------------------------------------------------------------------------
				if(last_selected_interactable_node_2d != null):
					last_selected_interactable_node_2d.des_selected.call()
				#-------------------------------------------------------------------------------
				if(new_selected_interactable_node_2d != null):
					new_selected_interactable_node_2d.selected.call()
				#-------------------------------------------------------------------------------
				last_selected_interactable_node_2d = new_selected_interactable_node_2d
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		#-------------------------------------------------------------------------------
		if(Input.is_action_just_pressed("Left_Click")):
			new_selected_interactable_node_2d = highlighted_interactable_node_2d
			is_left_mouse_pressed = true
			left_mouse_counter = 0
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Card_Control_with_Card_Serializable(_card_control:Card_Control, _card_serializable:Card_Serializable):
	_card_control.artwork.texture = _card_serializable.card_resource.artwork
	#-------------------------------------------------------------------------------
	match(_card_serializable.myCARTA):
		Card_Resource.CARTA.MONSTRUO:
			_card_control.frame.texture = frame_monster
		#-------------------------------------------------------------------------------
		Card_Resource.CARTA.FUSION:
			_card_control.frame.texture = frame_fusion
		#-------------------------------------------------------------------------------
		Card_Resource.CARTA.MAGIA:
			_card_control.frame.texture = frame_magic
		#-------------------------------------------------------------------------------
		Card_Resource.CARTA.TRAMPA:
			_card_control.frame.texture = frame_trap
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Get_Mouse_Pointer() -> Array[Interactable_Node_2D]:
	var _x: float = clamp(world_2d.get_global_mouse_position().x, 0, screen_size.x)
	var _y: float = clamp(world_2d.get_global_mouse_position().y, 0, screen_size.y)
	parameters.position = Vector2(_x, _y)
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	var _interactable_node_2d_array: Array[Interactable_Node_2D]
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _collider: Area2D = _result[_i]["collider"]
		#-------------------------------------------------------------------------------
		if(_collider.get_parent().get_parent() is Interactable_Node_2D):
			var _interactable_node_2d: Interactable_Node_2D = _collider.get_parent().get_parent() as Interactable_Node_2D
			_interactable_node_2d_array.append(_interactable_node_2d)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	return _interactable_node_2d_array
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region SET PLAYER FUNCTIONS
#-------------------------------------------------------------------------------
func Set_Player(_player:Player_Node_2D):
	_player.main_deck_card_serializable_array = Create_Card_Serializable_Array_for_Card_Resource_Array(_player.main_deck_card_resource_array)
	_player.main_deck_card_serializable_array_original_size = _player.main_deck_card_serializable_array.size()
	#-------------------------------------------------------------------------------
	_player.extra_deck_card_serializable_array = Create_Card_Serializable_Array_for_Card_Resource_Array(_player.extra_deck_card_resource_array)
	_player.extra_deck_card_serializable_array_original_size = _player.extra_deck_card_serializable_array.size()
	#-------------------------------------------------------------------------------
	Set_Card_Slot_Node_2D_Array(_player.Get_Magic_Card_Slot_Array())
	Set_Card_Slot_Node_2D_Array(_player.Get_Monster_Card_Slot_Array())
	#-------------------------------------------------------------------------------
	Set_Deck_Node_2D(_player.main_deck_node_2d)
	Set_Main_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	Set_Deck_Node_2D(_player.extra_deck_node_2d)
	Set_Extra_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	Set_Deck_Node_2D(_player.grave_deck_node_2d)
	Set_Grave_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	Set_Deck_Node_2D(_player.removed_deck_node_2d)
	Set_Removed_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	for _i in _player.hand_card_node_2d_array.size():
		Set_Card_Node_2D(_player, _player.hand_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Card_Slot_Node_2D_Array(_card_slot_node_2d_array:Array[Card_Slot_Node_2D]):
	for _i in _card_slot_node_2d_array.size():
		Set_Card_Slot_Node_2D(_card_slot_node_2d_array[_i])
#-------------------------------------------------------------------------------
func Set_Card_Slot_Node_2D(_card_slot_node_2d:Card_Slot_Node_2D):
	_card_slot_node_2d.panel.hide()
	#-------------------------------------------------------------------------------
	_card_slot_node_2d.highlighted = func():
		_card_slot_node_2d.panel.show()
	#-------------------------------------------------------------------------------
	_card_slot_node_2d.des_highlighted = func():
		_card_slot_node_2d.panel.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Deck_Node_2D(_deck_slot_node_2d:Deck_Slot_Node_2D):
	_deck_slot_node_2d.panel.hide()
	#-------------------------------------------------------------------------------
	_deck_slot_node_2d.highlighted = func():
		_deck_slot_node_2d.panel.show()
	#-------------------------------------------------------------------------------
	_deck_slot_node_2d.des_highlighted = func():
		_deck_slot_node_2d.panel.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Main_Deck_Label(_player: Player_Node_2D):
	Set_Deck_Label_1(_player.main_deck_node_2d, _player.main_deck_card_serializable_array.size(), _player.main_deck_card_serializable_array_original_size)
#-------------------------------------------------------------------------------
func Set_Extra_Deck_Label(_player: Player_Node_2D):
	Set_Deck_Label_1(_player.extra_deck_node_2d, _player.extra_deck_card_serializable_array.size(), _player.extra_deck_card_serializable_array_original_size)
#-------------------------------------------------------------------------------
func Set_Grave_Deck_Label(_player: Player_Node_2D):
	Set_Deck_Label_0(_player.grave_deck_node_2d, _player.grave_deck_card_serializable_array.size())
#-------------------------------------------------------------------------------
func Set_Removed_Deck_Label(_player: Player_Node_2D):
	Set_Deck_Label_0(_player.removed_deck_node_2d, _player.removed_deck_card_serializable_array.size())
#-------------------------------------------------------------------------------
func Set_Deck_Label_1(_deck_slot_node_2d:Deck_Slot_Node_2D, _i:int, _original_size:int):
	_deck_slot_node_2d.label.text = str(_i)+" / "+str(_original_size)
#-------------------------------------------------------------------------------
func Set_Deck_Label_0(_deck_slot_node_2d:Deck_Slot_Node_2D, _i:int):
	_deck_slot_node_2d.label.text = str(_i)
#-------------------------------------------------------------------------------
func Set_Card_Node_2D(_player:Player_Node_2D, _card_node_2d:Card_Node_2D):
	#-------------------------------------------------------------------------------
	_card_node_2d.highlighted = func():
		#-------------------------------------------------------------------------------
		if(_card_node_2d != last_selected_interactable_node_2d):
			_card_node_2d.z_index = 2
			var _tween: Tween = create_tween()
			_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, -30), 0.05)
			_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1.1, 1.1), 0.05)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	_card_node_2d.des_highlighted = func():
		#-------------------------------------------------------------------------------
		if(_card_node_2d != last_selected_interactable_node_2d):
			_card_node_2d.z_index = 1
			var _tween: Tween = create_tween()
			_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, 0), 0.05)
			_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1, 1), 0.05)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	_card_node_2d.selected = func():
		Set_Card_Info(_card_node_2d.card_serializable)
		#-------------------------------------------------------------------------------
		if(Is_Player_1(_player)):
			_card_node_2d.card_serializable.effect.Card_Pressed_in_Hand(_card_node_2d.card_serializable)
			#-------------------------------------------------------------------------------
			card_button_root.reparent(_card_node_2d)
			card_button_root.global_position = _card_node_2d.global_position + Vector2(0.0, -180.0)
			card_button_root.show()
		#-------------------------------------------------------------------------------
		_card_node_2d.z_index = 3
		var _tween: Tween = create_tween()
		_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, -70), 0.05)
		_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1.2, 1.2), 0.05)
	#-------------------------------------------------------------------------------
	_card_node_2d.des_selected = func():
		#-------------------------------------------------------------------------------
		if(Is_Player_1(_player)):
			card_button_root.hide()
		#-------------------------------------------------------------------------------
		_card_node_2d.z_index = 1
		var _tween: Tween = create_tween()
		_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, 0), 0.05)
		_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1, 1), 0.05)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_Card_Serializable_Array_for_Card_Resource_Array(_card_resource_array:Array[Card_Resource]) -> Array[Card_Serializable]:
	var _card_serializable_array: Array[Card_Serializable]
	#-------------------------------------------------------------------------------
	for _i in _card_resource_array.size():
		var _card_serializable: Card_Serializable = Card_Serializable.new()
		_card_serializable.Set_Variables_from_Resource(_card_resource_array[_i])
		_card_serializable_array.append(_card_serializable)
	#-------------------------------------------------------------------------------
	return _card_serializable_array
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
func Draw_X_Cards(_player:Player_Node_2D, _num: int):
	#-------------------------------------------------------------------------------
	for _i in _num:
		await Draw_1_Card(_player)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Draw_1_Card(_player:Player_Node_2D):
	#-------------------------------------------------------------------------------
	if(_player.main_deck_card_serializable_array.size() > 0):
		var _index: int = _player.main_deck_card_serializable_array.size() -1
		var _card_serializable: Card_Serializable = _player.main_deck_card_serializable_array[_index]
		_player.main_deck_card_serializable_array.remove_at(_index)
		#-------------------------------------------------------------------------------
		var _card_node_2d: Card_Node_2D = card_node_2d_prefab.instantiate() as Card_Node_2D
		#-------------------------------------------------------------------------------
		_card_node_2d.card_serializable = _card_serializable
		Set_Card_Control_with_Card_Serializable(_card_node_2d.card_control, _card_serializable)
		Set_Card_Node_2D(_player, _card_node_2d)
		#-------------------------------------------------------------------------------
		if(Is_Player_1(_player)):
			_player.hand_card_node_2d_array.push_back(_card_node_2d)
		#-------------------------------------------------------------------------------
		else:
			_player.hand_card_node_2d_array.push_front(_card_node_2d)
			_card_node_2d.rotation_degrees = 180
		#-------------------------------------------------------------------------------
		Set_Main_Deck_Label(_player)
		_player.hand_node_2d.add_child(_card_node_2d)
		_card_node_2d.global_position = _player.main_deck_node_2d.global_position
		await Set_Hand_Position(_player)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Hand_Position(_player: Player_Node_2D):
	var _x_separation: float = 120.0
	var _x_start: float = -(_x_separation * float(_player.hand_card_node_2d_array.size()-1)) / 2.0
	#-------------------------------------------------------------------------------
	var _timer: float = 0.2
	#-------------------------------------------------------------------------------
	for _i in _player.hand_card_node_2d_array.size():
		var _y: float = _x_start + _x_separation * _i
		var _tween: Tween = create_tween()
		_tween.tween_property(_player.hand_card_node_2d_array[_i], "position", Vector2(_y, 0), _timer)
		#_player.hand_card_node_2d_array[_i].position = Vector2(_y, 0)
	#-------------------------------------------------------------------------------
	await Seconds(_timer)
#-------------------------------------------------------------------------------
func Seconds(_timer:float):
	await get_tree().create_timer(_timer, true, true).timeout
#-------------------------------------------------------------------------------
func Is_Player_1(_player:Player_Node_2D) -> bool:
	#-------------------------------------------------------------------------------
	if(_player == player_1):
		return true
	#-------------------------------------------------------------------------------
	else:
		return false
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Card_Info(_card_serializable:Card_Serializable):
	Set_Card_Control_with_Card_Serializable(card_info, _card_serializable)
	card_info_richtext_stats.text = Get_Card_Stats(_card_serializable)
	card_info_richtext_effect.text = Get_Card_Effect(_card_serializable)
#-------------------------------------------------------------------------------
func Get_Card_Stats(_card_serializable:Card_Serializable) -> String:
	var _s: String = ""
	_s += "[lb] "
	_s += str(Card_Resource.ATRIBUTO.keys()[_card_serializable.myATRIBUTO])
	_s += " - "
	_s += str(Card_Resource.TIPO.keys()[_card_serializable.myTIPO])
	_s += " - "
	_s += "Lv." + str(_card_serializable.level)
	_s += " [rb]"
	_s += "\n"
	_s += "Attack: " + str(_card_serializable.attack)
	#_s += "\n"
	_s += "  //  "
	_s += "Defense: " + str(_card_serializable.defense)
	#_s += "\n"
	return _s
#-------------------------------------------------------------------------------
func Get_Card_Effect(_card_serializable:Card_Serializable) -> String:
	var _s: String = ""
	_s += "Bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla "
	_s += "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla."
	return _s
#-------------------------------------------------------------------------------
func get_resource_filename(_resource: Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func get_instance_filename(_node: Node) -> String:
	return _node.scene_file_path.get_file().trim_suffix('.tscn')
#-------------------------------------------------------------------------------
