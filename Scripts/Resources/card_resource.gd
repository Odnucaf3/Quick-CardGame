extends Resource
class_name Card_Resource
#-------------------------------------------------------------------------------
enum CARTA{MONSTRUO, MAGIA, TRAMPA, FUSION}
enum ATRIBUTO{AGUA, FUEGO, TIERRA, VIENTO, LUZ, OSCURIDAD}
enum TIPO{GUERRERO, MAGO, MAQUINA, BESTIA, DRAGON, DINOSAURIO}
enum ARQUETIPO{DRAGONCELLA}
enum MAGIC_TYPE{NORMAL, CONTINUOUS, EQUIP, QUICK, FIELD}
#-------------------------------------------------------------------------------
@export var artwork: Texture2D
@export var myCARTA: CARTA
@export var myARQUETIPO: Array[ARQUETIPO]
@export var effect: GDScript
#-------------------------------------------------------------------------------
@export_category("Variables de Monstruo-Fusion")
@export var attack: int = 0
@export var defense: int = 0
@export_range(1,10) var level: int = 1
@export var myATRIBUTO: ATRIBUTO
@export var myTIPO: TIPO
@export_category("")
#-------------------------------------------------------------------------------
@export_category("Variables de Magias-Trampas")
@export var myMAGIC_TYPE: MAGIC_TYPE
@export_category("")
#-------------------------------------------------------------------------------
func _init():
	resource_local_to_scene = false
#-------------------------------------------------------------------------------
