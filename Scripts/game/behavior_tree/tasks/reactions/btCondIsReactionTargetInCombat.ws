/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsReactionTargetInCombat extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = (CActor)GetNamedTarget('ReactionTarget');
		
		if ( !target )
			return false;
		
		return target.IsInCombat();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsReactionTargetInCombatDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsReactionTargetInCombat';
}
