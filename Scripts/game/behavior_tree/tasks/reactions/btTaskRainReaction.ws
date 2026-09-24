/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskRainReaction extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		return BTNS_Completed;
	}
	
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
}

class CBTTaskRainReactionDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskRainReaction';
}
