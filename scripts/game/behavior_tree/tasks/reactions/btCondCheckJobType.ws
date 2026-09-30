/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondCheckJobType extends IBehTreeTask
{
	public var jobType : EJobTreeType;
	
	function IsAvailable() : bool
	{
		return GetNPC().IsAtWork() && GetNPC().GetCurrentJTType() == jobType;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondCheckJobTypeDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondCheckJobType';
	
	editable var jobType : EJobTreeType;
}