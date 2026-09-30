/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MagicLampEntity extends CInteractiveEntity
{
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( activator.GetEntity() == thePlayer )
		{
			if ( area == GetComponent( "ShowMapPinTrigger" ) )
			{
				GetComponent( "ShowMapPinTrigger" ).SetEnabled( false );
				mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}

	
	
	
	
}