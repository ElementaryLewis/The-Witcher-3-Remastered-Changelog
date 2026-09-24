/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondTargetHasTag extends IBehTreeTask
{
	var tag		: name;
	
	function IsAvailable() : bool
	{
		var owner : CActor = GetActor();
		
		if( GetCombatTarget().HasTag( tag ))
		{
			return true;
		}
		return false;
	}
};


class CBTCondTargetHasTagDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondTargetHasTag';

	editable var tag		: name;
};


















