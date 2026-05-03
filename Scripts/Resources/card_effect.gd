extends GDScript
class_name Card_Effect
#-------------------------------------------------------------------------------
func Card_Pressed_in_Hand(_card_serializable:Card_Serializable):
	print("\""+get_resource_filename(_card_serializable.card_resource)+"\" was pressed")
#-------------------------------------------------------------------------------
func get_resource_filename(_resource: Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func get_instance_filename(_node: Node) -> String:
	return _node.scene_file_path.get_file().trim_suffix('.tscn')
#-------------------------------------------------------------------------------
