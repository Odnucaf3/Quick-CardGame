extends Node2D
class_name Player_Node_2D
#-------------------------------------------------------------------------------
@export var main_deck_card_resource_array: Array[Card_Resource]
var main_deck_card_serializable_array: Array[Card_Serializable]
var main_deck_card_serializable_array_original_size: int
#-------------------------------------------------------------------------------
@export var extra_deck_card_resource_array: Array[Card_Resource]
var extra_deck_card_serializable_array: Array[Card_Serializable]
var extra_deck_card_serializable_array_original_size: int
#-------------------------------------------------------------------------------
var grave_deck_card_serializable_array: Array[Card_Serializable]
var removed_deck_card_serializable_array: Array[Card_Serializable]
#-------------------------------------------------------------------------------
@export var main_deck_node_2d: Deck_Slot_Node_2D
@export var extra_deck_node_2d: Deck_Slot_Node_2D
@export var grave_deck_node_2d: Deck_Slot_Node_2D
@export var removed_deck_node_2d: Deck_Slot_Node_2D
#-------------------------------------------------------------------------------
@export var magic_card_slot_node_2d_array: Array[Card_Slot_Node_2D]
@export var monster_card_slot_node_2d_array: Array[Card_Slot_Node_2D]
#-------------------------------------------------------------------------------
@export var hand_node_2d: Node2D
@export var hand_card_node_2d_array: Array[Card_Node_2D]
#-------------------------------------------------------------------------------
