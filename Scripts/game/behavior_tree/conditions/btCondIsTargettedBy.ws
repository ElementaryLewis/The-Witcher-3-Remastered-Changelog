/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTargettedBy extends IBehTreeTask
{
	public var isTargettedByActors 	: bool;
	public var isTargettedByPlayer	: bool;

	function IsAvailable() : bool
	{
		return IsTargetted();
	}
	
	function IsTargetted() : bool
	{
		var npc					: CNewNPC = GetNPC();
		var targetCombatData 	: CCombatDataComponent;
		var res					: bool;
		var i					: int;
		
		targetCombatData = (CCombatDataComponent) npc.GetComponentByClassName('CCombatDataComponent');
		if( targetCombatData )
		{			
			i = targetCombatData.GetAttackersCount();
		}
		
		if ( isTargettedByActors && isTargettedByPlayer )
		{
			if ( thePlayer.GetDisplayTarget())
				res = true;
			if ( res || i > 0 )
			{
				return true;
			}
		}
		if ( isTargettedByActors )
			return i > 0;
		if ( isTargettedByPlayer && thePlayer.GetDisplayTarget())
			return true;
		
		return false;
	}
};

class CBTCondIsTargettedByDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargettedBy';

	editable var isTargettedByActors 	: bool;
	editable var isTargettedByPlayer	: bool;
	
	default isTargettedByActors = true;
};