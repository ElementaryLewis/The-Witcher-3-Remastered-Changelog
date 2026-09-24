/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondAttackedDelay extends IBehTreeTask
{
	
	
	
	var delay 				: float;
	var wasHit 				: bool;
	var completeIfAttacked 	: bool;
	
	function IsAvailable() : bool
	{
		var l_npc 			: CNewNPC = GetNPC();
		var l_currentDelay 	: float;
		
		if( l_npc )
		{
			if( !wasHit )
			{			
				l_currentDelay = l_npc.GetDelaySinceLastAttacked();
			}
			else
			{
				l_currentDelay = l_npc.GetDelaySinceLastHit();
			}
			return l_currentDelay >= delay;
		}
		
		return false;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_npc 			: CNewNPC = GetNPC();
		var l_currentDelay 	: float;
		while( completeIfAttacked )
		{
			if( !wasHit )
			{			
				l_currentDelay = l_npc.GetDelaySinceLastAttacked();
			}
			else
			{
				l_currentDelay = l_npc.GetDelaySinceLastHit();
			}
			
			if( l_currentDelay <  delay )
			{
				Complete(false);
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;	
	}
}


class BTCondAttackedDelayDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondAttackedDelay';

	
	
	editable var delay 				: float;
	editable var completeIfAttacked : bool;
	editable var wasHit				: bool;
	
	hint delay 				= "Delay without being attacked";
	hint completeIfAttacked = "Complete(false) the branch if NPC is attacked";
	hint wasHit 			= "should only consider the delay since the last attack that hit";
	
	
}
