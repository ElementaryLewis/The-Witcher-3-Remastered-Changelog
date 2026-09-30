/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskIsAlarmed extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAlarmed(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
	
}

class CBTTaskIsAlarmedDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAlarmed';
}

class CBTTaskIsAngry extends IBehTreeTask
{
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAngry(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
	
}

class CBTTaskIsAngryDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAngry';
}

