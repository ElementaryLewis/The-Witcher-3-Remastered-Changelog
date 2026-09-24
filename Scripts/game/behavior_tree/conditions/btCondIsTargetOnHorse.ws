/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTargetOnHorse extends IBehTreeTask
{
	public var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		if( useCombatTarget )
			return GetCombatTarget().IsUsingHorse();
		else
			return ((CActor)GetActionTarget()).IsUsingHorse();
		
		return false;
	}
};

class CBTCondIsTargetOnHorseDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetOnHorse';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
};