/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsInSettlement extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().TestIsInSettlement();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondIsInSettlementDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondIsInSettlement';
}
