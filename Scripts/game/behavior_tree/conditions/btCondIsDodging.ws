/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsDodging extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().IsCurrentlyDodging();
	}
}

class BTCondIsDodgingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsDodging';
}

class BTCondIsTargetDodging extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetCombatTarget().IsCurrentlyDodging();
	}
}

class BTCondIsTargetDodgingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsTargetDodging';
}