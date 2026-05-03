extends Resource
class_name Card_Serializable
#-------------------------------------------------------------------------------
@export var card_resource: Card_Resource
#-------------------------------------------------------------------------------
var player_original_owner: Player_Node_2D
var player_owner: Player_Node_2D
#-------------------------------------------------------------------------------
var myCARTA: Card_Resource.CARTA
var myARQUETIPO: Array[Card_Resource.ARQUETIPO]
var effect: Card_Effect
#-------------------------------------------------------------------------------
var attack: int = 0
var defense: int = 0
var level: int = 1
var myATRIBUTO: Card_Resource.ATRIBUTO
var myTIPO: Card_Resource.TIPO
#-------------------------------------------------------------------------------
var myMAGIC_TYPE: Card_Resource.MAGIC_TYPE
#-------------------------------------------------------------------------------
func _init():
	resource_local_to_scene = true
#-------------------------------------------------------------------------------
func Set_Variables_from_Serializable(_card_serializable: Card_Serializable):
	card_resource = _card_serializable.card_resource
	myCARTA = _card_serializable.myCARTA
	myARQUETIPO = _card_serializable.myARQUETIPO
	effect = _card_serializable.effect as Card_Effect
	#-------------------------------------------------------------------------------
	attack = _card_serializable.attack
	defense = _card_serializable.defense
	level = _card_serializable.level
	myATRIBUTO = _card_serializable.myATRIBUTO
	myTIPO = _card_serializable.myTIPO
	#-------------------------------------------------------------------------------
	myMAGIC_TYPE = _card_serializable.myMAGIC_TYPE
#-------------------------------------------------------------------------------
func Set_Variables_from_Resource(_card_resource: Card_Resource):
	card_resource = _card_resource
	myCARTA = _card_resource.myCARTA
	myARQUETIPO = _card_resource.myARQUETIPO
	#-------------------------------------------------------------------------------
	if(_card_resource.effect == null):
		effect = Card_Effect.new()
	#-------------------------------------------------------------------------------
	else:
		effect = _card_resource.effect.new() as Card_Effect
	#-------------------------------------------------------------------------------
	attack = _card_resource.attack
	defense = _card_resource.defense
	level = _card_resource.level
	myATRIBUTO = _card_resource.myATRIBUTO
	myTIPO = _card_resource.myTIPO
	#-------------------------------------------------------------------------------
	myMAGIC_TYPE = _card_resource.myMAGIC_TYPE
#-------------------------------------------------------------------------------
