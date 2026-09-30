/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskShouldUseReactionOneLiners extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		npc = GetNPC();
		
		if( npc.dontUseReactionOneLiners )
		{
			return false;
		}
		if( npc.IsAtWork() && !npc.IsConsciousAtWork()  )
		{
			return false;
		}
		return true;
	}
}

class CBTTaskShouldUseReactionOneLinersDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskShouldUseReactionOneLiners';
}
