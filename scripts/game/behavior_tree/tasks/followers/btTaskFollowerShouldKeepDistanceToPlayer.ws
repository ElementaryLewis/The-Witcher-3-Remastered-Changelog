/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTasFollowerShouldKeepDistanceToPlayer extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	
	function Initialize()
	{
		combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
	}
	
	
	
	function IsAvailable() : bool
	{
		if ( combatDataStorage.ShouldKeepDistanceToPlayer() )
		{
			if ( GetActionTarget() != thePlayer )
				SetActionTarget(thePlayer);
			
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;			
	}
}

class CBTTasFollowerShouldKeepDistanceToPlayerDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTasFollowerShouldKeepDistanceToPlayer';
}