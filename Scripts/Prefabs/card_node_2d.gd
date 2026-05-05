extends Interactable_Node_2D
class_name Card_Node_2D
#-------------------------------------------------------------------------------
@export var card_serializable: Card_Serializable
@export var card_control: Card_Control
@export var offset: Node2D
@export var collider: CollisionShape2D
#-------------------------------------------------------------------------------
var can_be_seen: bool
