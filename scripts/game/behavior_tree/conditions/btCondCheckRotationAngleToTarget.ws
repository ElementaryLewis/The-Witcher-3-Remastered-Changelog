/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondCheckRotationAngleToTarget extends IBehTreeTask
{
	var minAngle : float;
	var maxAngle : float;
	
	function IsAvailable() : bool
	{
		var npc		: CNewNPC = GetNPC();
		var target	: CActor = GetCombatTarget();
		var angle	: float;
		
		angle = NodeToNodeAngleDistance( target, npc );	
		
		if( angle > minAngle && angle < maxAngle)
		{
			return true;
		}
		return false;
	}
};


class CBTCondCheckRotationAngleToTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondCheckRotationAngleToTarget';

	editable var minAngle : float;
	editable var maxAngle : float;
	
	default minAngle = 0;
	default maxAngle = 0;
};