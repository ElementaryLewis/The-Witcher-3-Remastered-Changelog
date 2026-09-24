/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageFocusArea extends W3SwitchEvent
{
	editable var focusAreaTag		: name;
	editable var enable				: bool; default enable = false;
	
	var focuAreaEntity : W3FocusAreaTrigger;
	
	public function Perform( parnt : CEntity )
	{	
		focuAreaEntity = (W3FocusAreaTrigger)theGame.GetEntityByTag ( focusAreaTag );
		
		if ( focuAreaEntity )
		{
			if ( enable )
			{
				focuAreaEntity.Enable();
			}
			else
			{
				focuAreaEntity.Disable();
			}
		}
	}
}