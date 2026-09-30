/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3POI_ContrabandShipEntity extends CR4MapPinEntity
{	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager;
		var component : CComponent;
		
		if ( activator.GetEntity() == thePlayer )
		{
			component = GetComponent( "FirstDiscoveryTrigger" );
			if( area == component )
			{
				component.SetEnabled( false );			
				mapManager = theGame.GetCommonMapManager();
				if ( mapManager )
				{
					mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
				}
			}
		}
	}	
}