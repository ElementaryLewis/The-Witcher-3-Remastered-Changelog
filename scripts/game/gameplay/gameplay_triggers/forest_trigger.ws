/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ForestTrigger extends CEntity
{
	saved var isPlayerInForest : bool;
	
		default isPlayerInForest = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( (CPlayer)(activator.GetEntity()) )
			isPlayerInForest = true;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( (CPlayer)(activator.GetEntity()) )
			isPlayerInForest = false;
	}
	
	public function IsPlayerInForest() : bool
	{
		return isPlayerInForest;
	}
}