/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskEmpty extends IBehTreeTask
{	
	function OnActivate() : EBTNodeStatus
	{	
		return BTNS_Active;
	}
}

class BTTaskEmptyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEmpty';
}
