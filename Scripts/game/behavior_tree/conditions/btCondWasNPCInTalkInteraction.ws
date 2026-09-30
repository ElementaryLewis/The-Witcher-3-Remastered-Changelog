/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondWasNPCInTalkInteraction extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().wasInTalkInteraction;
	}
}

class BTCondWasNPCInTalkInteractionDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondWasNPCInTalkInteraction';
}