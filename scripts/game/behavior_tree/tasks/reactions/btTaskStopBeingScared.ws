/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskStopBeingScared extends IBehTreeTask
{
	function OnDeactivate()
	{
		GetNPC().SignalGameplayEvent('AI_StopBeingScared');
	}
}

class CBTTaskStopBeingScaredDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskStopBeingScared';
}