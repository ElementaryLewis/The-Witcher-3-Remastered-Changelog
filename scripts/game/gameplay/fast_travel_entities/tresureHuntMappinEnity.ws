/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TreasureHuntMappinEntity extends CR4MapPinEntity
{
	default radius = 20;
	
	private saved var mappinSet : bool;
	private var isDisabled 		: bool;
	private editable var regionType	: EEP2PoiType;

	public function GetRegionType() : int
	{
		return (int) regionType;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		if ( entityName != '' && !mappinSet && !isDisabled  )
		{
			Enable ();
		}
	}
	
	public function Enable ()
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		mapManager.SetEntityMapPinDiscoveredScript (  false, entityName, true );
		mappinSet = true;
	}
	public function Disable ()
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		isDisabled = true;
		mapManager.SetEntityMapPinDiscoveredScript( false, entityName, false);
	}
}