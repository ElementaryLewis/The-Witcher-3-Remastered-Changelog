/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsActionTargetPlayer extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = (CActor)GetActionTarget();
		
		if ( !target )
			return false;
		else
			return target == thePlayer;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsActionTargetPlayerDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsActionTargetPlayer';
}