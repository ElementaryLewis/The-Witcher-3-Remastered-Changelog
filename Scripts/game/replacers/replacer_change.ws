/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ReplacerChanger extends W3GameplayTrigger
{
	editable var replacerTemplate : String;
	var recentlyChanged : bool;
	default recentlyChanged = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			if( !recentlyChanged )
			{
				recentlyChanged = true;
				theGame.ChangePlayer( replacerTemplate );
			}
			else
			{
				recentlyChanged = false;
			}
		}
	}
}