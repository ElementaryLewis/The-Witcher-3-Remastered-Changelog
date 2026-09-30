/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsPlayerCiri extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var ciriEntity  : W3ReplacerCiri;
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		
		if ( ciriEntity )
			return true;
		else
			return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsPlayerCiriDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsPlayerCiri';
}
