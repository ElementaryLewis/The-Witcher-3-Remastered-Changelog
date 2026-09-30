/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTargetThePlayer extends IBehTreeTask
{
	public var useCombatTarget : bool;

	function IsAvailable() : bool
	{
		return GetTarget() == thePlayer;
	}
	
	function GetTarget() : CNode
	{
		if ( useCombatTarget )
			return GetCombatTarget();
		else
			return GetActionTarget();
	}

};

class CBTCondIsTargetThePlayerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetThePlayer';

	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
};