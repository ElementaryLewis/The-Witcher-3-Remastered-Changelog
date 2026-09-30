/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondHasTarget extends IBehTreeTask
{
	var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		if( HasTarget() )
		{
			return true;
		}
		return false;
	}
	
	function HasTarget() : bool
	{
		if ( useCombatTarget )
			return GetCombatTarget();
		else
			return GetActionTarget();
			
		return false;
	}
}

class BTCondHasTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHasTarget';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
}