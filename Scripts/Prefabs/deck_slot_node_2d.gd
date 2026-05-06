extends Interactable_Node_2D
class_name Deck_Slot_Node_2D
#-------------------------------------------------------------------------------
@export var normal_panel: Control
@export var highlighted_panel: Control
@export var selected_panel: Control
@export var vbox_container: VBoxContainer
@export var rest_of_the_deck: Array[TextureRect]
@export var card_control: Card_Control
@export var label: Label
#-------------------------------------------------------------------------------
var card_serializable_array: Array[Card_Serializable]
var card_serializable_array_original_size: int
#-------------------------------------------------------------------------------
