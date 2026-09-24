/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsNPCGroupType extends IBehTreeTask
{
	var npcType : ENPCGroupType;

	
	function IsAvailable() : bool
	{
		var owner : CNewNPC = GetNPC();

		if ( owner.GetNPCType() == npcType )
		{
			return true;
		}
		
		return false;		
	}
}	


class BTCondIsNPCGroupTypeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsNPCGroupType';

	editable var npcType : ENPCGroupType;
	default npcType = ENGT_Commoner;
}