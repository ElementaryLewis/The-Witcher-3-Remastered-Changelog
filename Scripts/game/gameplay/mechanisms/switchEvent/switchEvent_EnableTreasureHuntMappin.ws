/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_EnableTreasureHuntMappin extends W3SwitchEvent
{
	editable var mappinEntityTag		: name;
	editable var enable					: bool; default enable = true;
	
	var mappinEntity : W3TreasureHuntMappinEntity;
	var commonMapManager : CCommonMapManager;  
	
	public function Perform( parnt : CEntity )
	{	
		mappinEntity = (W3TreasureHuntMappinEntity)theGame.GetEntityByTag ( mappinEntityTag );
		
		if ( mappinEntity )
		{
			if ( enable )
			{
				mappinEntity.Enable();
			}
			else
			{
				mappinEntity.Disable();
			}
		}
		else
		{
			commonMapManager = theGame.GetCommonMapManager();
			
			if ( enable )
			{
				commonMapManager.SetEntityMapPinDiscoveredScript (  false, mappinEntityTag, true );
			}
			else
			{
				commonMapManager.SetEntityMapPinDiscoveredScript (  false, mappinEntityTag, false );
			}
		}
	}
}