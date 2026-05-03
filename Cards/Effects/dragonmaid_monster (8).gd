extends Card_Effect
#-------------------------------------------------------------------------------
func Card_Pressed_in_Hand(card_serializable:Card_Serializable):
	super.Card_Pressed_in_Hand(card_serializable)
	print("and it activated it's effect")
#-------------------------------------------------------------------------------
