/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTargetAMonster extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = GetCombatTarget();
		if ( target.IsMonster() )
			return true;
			
		return false;
	}
};

class CBTCondIsTargetAMonsterDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetAMonster';
};