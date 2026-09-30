/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIrisPaintingIsAvailable extends BTTaskIrisTask
{	
	
	
	function IsAvailable() : bool
	{
		var l_npc 		: W3NightWraithIris;
		l_npc 		= (W3NightWraithIris) GetNPC();
		
		return l_npc.GetAvailablePaitingsQuantity() > 0;
	}
	
}


class BTCondIrisPaintingIsAvailableDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIrisPaintingIsAvailable';
}