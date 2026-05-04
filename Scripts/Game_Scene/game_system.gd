extends Node
class_name Game_System
#-------------------------------------------------------------------------------
enum PHASE{START, MAIN_1, BATTLE, MAIN_2, END}
enum MAIN_PHASE{IDLE, SUMMON}
#-------------------------------------------------------------------------------
#region VARIABLES
#-------------------------------------------------------------------------------
var myPHASE: PHASE = PHASE.START
var myMAIN_PHASE: MAIN_PHASE = MAIN_PHASE.IDLE
#-------------------------------------------------------------------------------
@export var card_node_2d_prefab: PackedScene
@export var frame_monster: Texture2D
@export var frame_fusion: Texture2D
@export var frame_magic: Texture2D
@export var frame_trap: Texture2D
#-------------------------------------------------------------------------------
@export var phase_button: Button
@export var card_button_root: Control
@export var card_button_array: Array[Button]
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
#-------------------------------------------------------------------------------
@export var world_2d: Node2D
var screen_size: Vector2
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var is_left_mouse_pressed: bool = false
var left_mouse_counter: int = 0
#-------------------------------------------------------------------------------
var nothing_selected: Callable = func():pass
var nothing_canceled: Callable = func():pass
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
	MainPhase1_Idle()
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
	StateMachine_Canceled()
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
			if(new_selected_interactable_node_2d == highlighted_interactable_node_2d):
				#-------------------------------------------------------------------------------
				if(new_selected_interactable_node_2d != null):
					new_selected_interactable_node_2d.selected.call()
				#-------------------------------------------------------------------------------
				else:
					nothing_selected.call()
				#-------------------------------------------------------------------------------
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
func StateMachine_Canceled():
	if(hovered_control != null):
		return
	#-------------------------------------------------------------------------------
	if(Input.is_action_just_released("Right_Click")):
		nothing_canceled.call()
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
	_player.main_deck_card_serializable_array = Create_Card_Serializable_Array_for_Card_Resource_Array(_player, _player.main_deck_card_resource_array)
	_player.main_deck_card_serializable_array.shuffle()
	_player.main_deck_card_serializable_array_original_size = _player.main_deck_card_serializable_array.size()
	#-------------------------------------------------------------------------------
	_player.extra_deck_card_serializable_array = Create_Card_Serializable_Array_for_Card_Resource_Array(_player, _player.extra_deck_card_resource_array)
	_player.extra_deck_card_serializable_array.shuffle()
	_player.extra_deck_card_serializable_array_original_size = _player.extra_deck_card_serializable_array.size()
	#-------------------------------------------------------------------------------
	for _i in _player.magic_card_slot_node_2d_array.size():
		_player.magic_card_slot_node_2d_array[_i].highlighted_panel.hide()
		_player.magic_card_slot_node_2d_array[_i].selected_panel.hide()
	#-------------------------------------------------------------------------------
	for _i in _player.monster_card_slot_node_2d_array.size():
		_player.monster_card_slot_node_2d_array[_i].highlighted_panel.hide()
		_player.monster_card_slot_node_2d_array[_i].selected_panel.hide()
	#-------------------------------------------------------------------------------
	_player.main_deck_node_2d.highlighted_panel.hide()
	_player.main_deck_node_2d.selected_panel.hide()
	Set_Main_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	_player.extra_deck_node_2d.highlighted_panel.hide()
	_player.extra_deck_node_2d.selected_panel.hide()
	Set_Extra_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	_player.grave_deck_node_2d.highlighted_panel.hide()
	_player.grave_deck_node_2d.selected_panel.hide()
	Set_Grave_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	_player.removed_deck_node_2d.highlighted_panel.hide()
	_player.removed_deck_node_2d.selected_panel.hide()
	Set_Removed_Deck_Label(_player)
	#-------------------------------------------------------------------------------
	for _i in _player.hand_card_node_2d_array.size():
		Set_Card_Node_2D_Highlighted(_player.hand_card_node_2d_array[_i])
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
#endregion
#-------------------------------------------------------------------------------
#region HIGHLIGHTED FUNCTIONS
#-------------------------------------------------------------------------------
func Set_Highlighted_in_Table():
	Set_Highlighted_in_Table_Player(player_1)
	Set_Highlighted_in_Table_Player(player_2)
#-------------------------------------------------------------------------------
func Set_Highlighted_in_Table_Player(_player:Player_Node_2D):
	Set_Deck_Node_2D_Highlighted(_player.main_deck_node_2d)
	Set_Deck_Node_2D_Highlighted(_player.extra_deck_node_2d)
	Set_Deck_Node_2D_Highlighted(_player.grave_deck_node_2d)
	Set_Deck_Node_2D_Highlighted(_player.removed_deck_node_2d)
	#-------------------------------------------------------------------------------
	Set_Card_Slot_Node_2D_Array_Highlighted(_player.magic_card_slot_node_2d_array)
	Set_Card_Slot_Node_2D_Array_Highlighted(_player.monster_card_slot_node_2d_array)
	#-------------------------------------------------------------------------------
	Set_Card_Node_2D_Array_Highlighted(_player.hand_card_node_2d_array)
#-------------------------------------------------------------------------------
func Set_Card_Slot_Node_2D_Array_Highlighted(_card_slot_node_2d_array:Array[Card_Slot_Node_2D]):
	for _i in _card_slot_node_2d_array.size():
		Set_Card_Slot_Node_2D_Highlighted(_card_slot_node_2d_array[_i])
#-------------------------------------------------------------------------------
func Set_Card_Slot_Node_2D_Highlighted(_card_slot_node_2d:Card_Slot_Node_2D):
	#-------------------------------------------------------------------------------
	_card_slot_node_2d.highlighted = func():
		_card_slot_node_2d.highlighted_panel.show()
	#-------------------------------------------------------------------------------
	_card_slot_node_2d.des_highlighted = func():
		_card_slot_node_2d.highlighted_panel.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Deck_Node_2D_Highlighted(_deck_slot_node_2d:Deck_Slot_Node_2D):
	#-------------------------------------------------------------------------------
	_deck_slot_node_2d.highlighted = func():
		_deck_slot_node_2d.highlighted_panel.show()
	#-------------------------------------------------------------------------------
	_deck_slot_node_2d.des_highlighted = func():
		_deck_slot_node_2d.highlighted_panel.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Card_Node_2D_Array_Highlighted(_card_node_2d_array:Array[Card_Node_2D]):
	#-------------------------------------------------------------------------------
	for _i in _card_node_2d_array.size():
		Set_Card_Node_2D_Highlighted(_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_Card_Node_2D_Highlighted(_card_node_2d:Card_Node_2D):
	#-------------------------------------------------------------------------------
	_card_node_2d.highlighted = func():
		_card_node_2d.z_index = 2
		var _tween: Tween = create_tween()
		_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, -30), 0.05)
		_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1.1, 1.1), 0.05)
	#-------------------------------------------------------------------------------
	_card_node_2d.des_highlighted = func():
		_card_node_2d.z_index = 1
		var _tween: Tween = create_tween()
		_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, 0), 0.05)
		_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1, 1), 0.05)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
func Create_Card_Serializable_Array_for_Card_Resource_Array(_player_onde_2d:Player_Node_2D, _card_resource_array:Array[Card_Resource]) -> Array[Card_Serializable]:
	var _card_serializable_array: Array[Card_Serializable]
	#-------------------------------------------------------------------------------
	for _i in _card_resource_array.size():
		var _card_serializable: Card_Serializable = Card_Serializable.new()
		_card_serializable.Set_Variables_from_Resource(_card_resource_array[_i])
		_card_serializable.player_owner = _player_onde_2d
		_card_serializable.player_original_owner = _player_onde_2d
		_card_serializable_array.append(_card_serializable)
	#-------------------------------------------------------------------------------
	return _card_serializable_array
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
		Set_Card_Node_2D_Highlighted(_card_node_2d)
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
	card_info_richtext_effect.get_v_scroll_bar().value = 0
#-------------------------------------------------------------------------------
func Get_Card_Stats(_card_serializable:Card_Serializable) -> String:
	var _s: String = ""
	#-------------------------------------------------------------------------------
	if(_card_serializable.myCARTA == Card_Resource.CARTA.MONSTRUO or _card_serializable.myCARTA == Card_Resource.CARTA.FUSION):
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
	#-------------------------------------------------------------------------------
	else:
		_s += "[lb] "
		_s += str(Card_Resource.MAGIC_TYPE.keys()[_card_serializable.myMAGIC_TYPE])
		_s += " - "
		_s += str(Card_Resource.CARTA.keys()[_card_serializable.myCARTA])
		_s += " [rb]"
		_s += "\n"
		_s += " "
	#-------------------------------------------------------------------------------
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
func MainPhase1_Idle():
	Set_Highlighted_in_Table()
	#-------------------------------------------------------------------------------
	nothing_selected = func():pass
	nothing_canceled = func():pass
	#-------------------------------------------------------------------------------
	player_1.main_deck_node_2d.selected = func():pass
	player_1.extra_deck_node_2d.selected = func():pass
	player_1.grave_deck_node_2d.selected = func():pass
	player_1.removed_deck_node_2d.selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_1.monster_card_slot_node_2d_array.size():
		player_1.monster_card_slot_node_2d_array[_i].selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_1.magic_card_slot_node_2d_array.size():
		player_1.magic_card_slot_node_2d_array[_i].selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_1.hand_card_node_2d_array.size():
		player_1.hand_card_node_2d_array[_i].selected = func(): MainPhase1_from_Idle_to_Hand(player_1.hand_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
	player_2.main_deck_node_2d.selected = func():pass
	player_2.extra_deck_node_2d.selected = func():pass
	player_2.grave_deck_node_2d.selected = func():pass
	player_2.removed_deck_node_2d.selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_2.monster_card_slot_node_2d_array.size():
		player_2.monster_card_slot_node_2d_array[_i].selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_2.magic_card_slot_node_2d_array.size():
		player_2.magic_card_slot_node_2d_array[_i].selected = func():pass
	#-------------------------------------------------------------------------------
	for _i in player_2.hand_card_node_2d_array.size():
		player_2.hand_card_node_2d_array[_i].selected = func(): MainPhase1_from_Idle_to_Hand(player_2.hand_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_from_Idle_to_Hand(_card_node_2d:Card_Node_2D):
	MainPhase1_Hand(_card_node_2d)
	#-------------------------------------------------------------------------------
	Card_in_Hand_Selected(_card_node_2d)
#-------------------------------------------------------------------------------
func MainPhase1_Hand(_card_node_2d:Card_Node_2D):
	Set_Highlighted_in_Table()
	#-------------------------------------------------------------------------------
	nothing_selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	nothing_canceled = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	player_1.main_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_1.extra_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_1.grave_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_1.removed_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.monster_card_slot_node_2d_array.size():
		player_1.monster_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.magic_card_slot_node_2d_array.size():
		player_1.magic_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.hand_card_node_2d_array.size():
		player_1.hand_card_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Hand(_card_node_2d, player_1.hand_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
	player_2.main_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_2.extra_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_2.grave_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	player_2.removed_deck_node_2d.selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.monster_card_slot_node_2d_array.size():
		player_2.monster_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.magic_card_slot_node_2d_array.size():
		player_2.magic_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.hand_card_node_2d_array.size():
		player_2.hand_card_node_2d_array[_i].selected = func():MainPhase1_from_Hand_to_Hand(_card_node_2d, player_2.hand_card_node_2d_array[_i])
#-------------------------------------------------------------------------------
func MainPhase1_from_Hand_to_Hand(_last_card_node_2d:Card_Node_2D, _new_card_node_2d:Card_Node_2D):
	MainPhase1_Hand(_new_card_node_2d)
	Card_in_Hand_Des_Selected(_last_card_node_2d)
	Card_in_Hand_Selected(_new_card_node_2d)
#-------------------------------------------------------------------------------
func MainPhase1_from_Hand_to_Idle(_card_node_2d:Card_Node_2D):
	MainPhase1_Idle()
	#-------------------------------------------------------------------------------
	Card_in_Hand_Des_Selected(_card_node_2d)
#-------------------------------------------------------------------------------
func Card_in_Hand_Selected(_card_node_2d:Card_Node_2D):
	_card_node_2d.highlighted = func():pass
	_card_node_2d.des_highlighted = func():pass
	_card_node_2d.selected = func():pass
	#-------------------------------------------------------------------------------
	Set_Card_Info(_card_node_2d.card_serializable)
	#-------------------------------------------------------------------------------
	if(Is_Player_1(_card_node_2d.card_serializable.player_owner)):
		Hand_Menu_Open(_card_node_2d)
		_card_node_2d.card_serializable.effect.Card_Pressed_in_Hand(_card_node_2d.card_serializable)
	#-------------------------------------------------------------------------------
	_card_node_2d.z_index = 3
	var _tween: Tween = create_tween()
	_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, -70), 0.05)
	_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1.2, 1.2), 0.05)
#-------------------------------------------------------------------------------
func Hand_Menu_Open(_card_node_2d:Card_Node_2D):
	card_button_root.reparent(_card_node_2d)
	card_button_root.global_position = _card_node_2d.global_position + Vector2(0.0, -180.0)
	#-------------------------------------------------------------------------------
	if(_card_node_2d.card_serializable.myCARTA == Card_Resource.CARTA.MONSTRUO):
		card_button_array[0].text = "Attack\nPositon"
		card_button_array[1].text = "Defense\nPositon"
	#-------------------------------------------------------------------------------
	else:
		card_button_array[0].text = "Activate"
		card_button_array[1].text = "Set"
	#-------------------------------------------------------------------------------
	singleton.Set_Button(card_button_array[0], singleton.Common_Selected, func():MainPhase1_from_Hand_to_Summon(_card_node_2d, true))
	singleton.Set_Button(card_button_array[1], singleton.Common_Selected, func():MainPhase1_from_Hand_to_Summon(_card_node_2d, false))
	card_button_root.show()
#-------------------------------------------------------------------------------
func Card_in_Hand_Des_Selected(_card_node_2d:Card_Node_2D):
	#-------------------------------------------------------------------------------
	if(Is_Player_1(_card_node_2d.card_serializable.player_owner)):
		card_button_root.hide()
	#-------------------------------------------------------------------------------
	_card_node_2d.z_index = 1
	var _tween: Tween = create_tween()
	_tween.tween_property(_card_node_2d.offset, "position", Vector2(0, 0), 0.05)
	_tween.parallel().tween_property(_card_node_2d.offset, "scale", Vector2(1, 1), 0.05)
#-------------------------------------------------------------------------------
func MainPhase1_from_Hand_to_Summon(_card_node_2d:Card_Node_2D, _is_summon_in_attack:bool):
	MainPhase1_Summon(_card_node_2d)
	Card_in_Hand_Des_Selected(_card_node_2d)
	#-------------------------------------------------------------------------------
	if(_card_node_2d.card_serializable.myCARTA == Card_Resource.CARTA.MONSTRUO):
		var _card_slot_node_2d_array: Array[Card_Slot_Node_2D] = player_1.monster_card_slot_node_2d_array
		#-------------------------------------------------------------------------------
		for _i in _card_slot_node_2d_array.size():
			_card_slot_node_2d_array[_i].normal_panel.hide()
			_card_slot_node_2d_array[_i].selected_panel.show()
			_card_slot_node_2d_array[_i].selected = func():Perform_Summoning(_card_node_2d, _card_slot_node_2d_array[_i], _is_summon_in_attack)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		var _card_slot_node_2d_array: Array[Card_Slot_Node_2D] = player_1.magic_card_slot_node_2d_array
		#-------------------------------------------------------------------------------
		for _i in _card_slot_node_2d_array.size():
			_card_slot_node_2d_array[_i].normal_panel.hide()
			_card_slot_node_2d_array[_i].selected_panel.show()
			_card_slot_node_2d_array[_i].selected = func():Perform_Summoning(_card_node_2d, _card_slot_node_2d_array[_i], _is_summon_in_attack)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Perform_Summoning(_card_node_2d:Card_Node_2D, _card_slot_node_2d:Card_Slot_Node_2D, _is_summon_in_attack:bool):
	_card_node_2d.collider.disabled = true
	_card_node_2d.reparent(_card_slot_node_2d)
	_card_node_2d.global_position = _card_slot_node_2d.global_position
	_card_node_2d.scale = Vector2(0.6, 0.6)
	_card_slot_node_2d.card_node_2d = _card_node_2d
	player_1.hand_card_node_2d_array.erase(_card_node_2d)
	#-------------------------------------------------------------------------------
	if(_card_node_2d.card_serializable.myCARTA == Card_Resource.CARTA.MONSTRUO):
		#-------------------------------------------------------------------------------
		if(_is_summon_in_attack):
			_card_node_2d.rotation_degrees = 0
		#-------------------------------------------------------------------------------
		else:
			_card_node_2d.rotation_degrees = -90
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		#-------------------------------------------------------------------------------
		if(_is_summon_in_attack):
			_card_node_2d.card_control.back_frame.hide()
		#-------------------------------------------------------------------------------
		else:
			_card_node_2d.card_control.back_frame.show()
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	await Set_Hand_Position(player_1)
#-------------------------------------------------------------------------------
func MainPhase1_from_Summon_to_Idle(_card_node_2d:Card_Node_2D):
	MainPhase1_Idle()
	#-------------------------------------------------------------------------------
	Disable_All_Card_Slots(player_1)
#-------------------------------------------------------------------------------
func MainPhase1_Summon(_card_node_2d:Card_Node_2D):
	Set_Highlighted_in_Table()
	#-------------------------------------------------------------------------------
	nothing_selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	nothing_canceled = func():MainPhase1_from_Summon_to_Hand(_card_node_2d)
	#-------------------------------------------------------------------------------
	player_1.main_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_1.extra_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_1.grave_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_1.removed_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.monster_card_slot_node_2d_array.size():
		player_1.monster_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.magic_card_slot_node_2d_array.size():
		player_1.magic_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_1.hand_card_node_2d_array.size():
		player_1.hand_card_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Hand(player_1.hand_card_node_2d_array[_i])
	#-------------------------------------------------------------------------------
	player_2.main_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_2.extra_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_2.grave_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	player_2.removed_deck_node_2d.selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.monster_card_slot_node_2d_array.size():
		player_2.monster_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.magic_card_slot_node_2d_array.size():
		player_2.magic_card_slot_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Idle(_card_node_2d)
	#-------------------------------------------------------------------------------
	for _i in player_2.hand_card_node_2d_array.size():
		player_2.hand_card_node_2d_array[_i].selected = func():MainPhase1_from_Summon_to_Hand(player_2.hand_card_node_2d_array[_i])
#-------------------------------------------------------------------------------
func MainPhase1_from_Summon_to_Hand(_card_node_2d:Card_Node_2D):
	MainPhase1_Hand(_card_node_2d)
	#-------------------------------------------------------------------------------
	Disable_All_Card_Slots(player_1)
	Card_in_Hand_Selected(_card_node_2d)
#-------------------------------------------------------------------------------
func Disable_All_Card_Slots(_player:Player_Node_2D):
	Disable_Card_Slot_Node_2d_Array(_player.magic_card_slot_node_2d_array)
	Disable_Card_Slot_Node_2d_Array(_player.monster_card_slot_node_2d_array)
#-------------------------------------------------------------------------------
func Disable_Card_Slot_Node_2d_Array(_card_slot_node_2d_array: Array[Card_Slot_Node_2D]):
	#-------------------------------------------------------------------------------
	for _i in _card_slot_node_2d_array.size():
		_card_slot_node_2d_array[_i].normal_panel.show()
		_card_slot_node_2d_array[_i].selected_panel.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
