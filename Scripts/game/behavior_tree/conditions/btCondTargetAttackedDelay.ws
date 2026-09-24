/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondTargetAttackedDelay extends IBehTreeTask
{
	
	
	
	var delay 	: float;
	var wasHit 	: bool;
	
	function IsAvailable() : bool
	{
		var l_target 		: CActor = GetCombatTarget();
		var l_currentDelay 	: float;
		
		if( l_target )
		{
			if( !wasHit )
			{			
				l_currentDelay = l_target.GetDelaySinceLastAttacked();
			}
			else
			{
				l_currentDelay = l_target.GetDelaySinceLastHit();
			}
			
			return l_currentDelay >= delay;
		}
		
		return false;
	}
}

class BTCondTargetAttackedDelayDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondTargetAttackedDelay';

	editable var delay 	: float;
	editable var wasHit	: bool;
	
	hint delay 	= "Delay without being attacked";
	hint wasHit = "should only consider the delay since the last attack that hit";
}
