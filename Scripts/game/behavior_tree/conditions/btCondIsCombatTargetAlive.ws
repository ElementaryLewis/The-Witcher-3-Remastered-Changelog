/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsCombatTargetAlive extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if( GetCombatTarget() )
		{
			return GetCombatTarget().IsAlive();
		}
		return false;
	}
};


class CBTCondIsCombatTargetAliveDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsCombatTargetAlive';
};


















