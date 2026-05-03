extends GDScript
class_name Card_Effect
#-------------------------------------------------------------------------------
func Card_Pressed_in_Hand(_card_serializable:Card_Serializable):
	print("\""+singleton.game_scene.get_resource_filename(_card_serializable.card_resource)+"\" was pressed")
#-------------------------------------------------------------------------------
