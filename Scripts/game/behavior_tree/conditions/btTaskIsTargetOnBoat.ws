/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsTargetOnBoat extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		if ( GetCombatTarget() == thePlayer && thePlayer.IsSailing() )
			return true;
			
		return false;
	}
};

class CBTCondIsTargetOnBoatDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetOnBoat';
};