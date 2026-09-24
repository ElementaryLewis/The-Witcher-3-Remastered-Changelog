/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondCheckNPCType extends IBehTreeTask
{
	public var npcType : ENPCGroupType;
	
	function IsAvailable() : bool
	{
		return GetNPC().GetNPCType() == npcType;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondCheckNPCTypeDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondCheckNPCType';
	
	editable var npcType : ENPCGroupType;
}
