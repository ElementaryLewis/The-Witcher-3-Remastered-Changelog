/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondCheckTargetRotationToActor extends IBehTreeTask
{
	var toleranceAngle : float;
	
	function IsAvailable() : bool
	{
		var l_npc 		: CNewNPC = GetNPC();
		var l_target 	: CActor = GetCombatTarget();
		var l_res 		: bool;
		
		l_res = l_target.IsRotatedTowards( l_npc, toleranceAngle );
		
		return l_res;
	}
}

class BTCondCheckTargetRotationToActorDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondCheckTargetRotationToActor';

	editable var toleranceAngle : float;
	
	default toleranceAngle = 20;
}