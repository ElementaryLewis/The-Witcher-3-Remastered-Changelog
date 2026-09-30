/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisSetClosestPaintingAsTarget extends BTTaskIrisTask
{
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_npc : W3NightWraithIris;
		
		l_npc = (W3NightWraithIris) GetNPC();
		SetActionTarget( l_npc.GetClosestPainting() );		
		
		return BTNS_Active;
	}
}



class BTTaskIrisSetClosestPaintingAsTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisSetClosestPaintingAsTarget';
}