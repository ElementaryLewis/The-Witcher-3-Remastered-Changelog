/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisDeath extends IBehTreeTask
{
	
	
	function OnActivate() : EBTNodeStatus
	{
		var i						: int;
		var l_npc 					: W3NightWraithIris;
		var l_availablePaintings 	: array<CNode>;
		
		l_npc = (W3NightWraithIris) GetNPC();
		l_npc.StopEffect('drained_paint');
		
		
		
		
		
		return BTNS_Active;
	}
}



class BTTaskIrisDeathDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisDeath';
}