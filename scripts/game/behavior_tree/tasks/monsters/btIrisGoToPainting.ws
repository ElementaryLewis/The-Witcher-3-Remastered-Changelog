/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisGoToPainting extends BTTaskIrisTask
{
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_npc 		: W3NightWraithIris;
		var l_painting	: W3IrisPainting;
		
		l_npc = (W3NightWraithIris) GetNPC();
		
		l_painting = l_npc.GetPortal();
		
		SetActionTarget( l_painting );
		
		l_npc.PlayEffect( 'suck_into_painting', l_painting );
		l_painting.PlayEffect('glow_penetration');
		l_npc.StopEffect('drained_paint');
		
		
		return BTNS_Active;
	}
	
	
	private function OnDeactivate()
	{
		var l_npc 		: W3NightWraithIris;
		var l_painting	: W3IrisPainting;
		
		l_npc = (W3NightWraithIris) GetNPC();
		l_painting = l_npc.GetPortal();
		l_painting.Close();
	}
}



class BTTaskIrisGoToPaintingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisGoToPainting';
}