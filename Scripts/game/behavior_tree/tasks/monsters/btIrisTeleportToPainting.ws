/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskIrisTeleportToPainting extends BTTaskIrisTask
{
	
	
	
	private var percentageToHeal : float;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_npc 			: W3NightWraithIris;
		var l_pos			: Vector;
		var l_painting		: CNode;
		var l_matrix		: Matrix;
		var l_worldOffset	: Vector;
		var l_localOffset	: Vector;
		
		
		l_npc 		= (W3NightWraithIris) GetNPC();
		
		l_painting 	= l_npc.GetRandomPaintingAround();
		
		l_npc.StopEffect('drained_paint');
		
		l_localOffset	= Vector( 0, 1, 0);
		
		l_matrix 		= l_painting.GetLocalToWorld();
		l_worldOffset 	= VecTransform( l_matrix, l_localOffset);
		l_pos			= l_npc.GetWorldPosition();
		l_worldOffset.Z = l_pos.Z;
		
		l_npc.TeleportWithRotation( l_worldOffset, l_painting.GetWorldRotation() );
		
		if( percentageToHeal > 0 )
		{
			l_npc.Heal( l_npc.GetMaxHealth() * percentageToHeal );
		}

		((CEntity) l_painting).PlayEffect('glow_appear_iris');
		
		
		return BTNS_Completed;
	}
}



class BTTaskIrisTeleportToPaintingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIrisTeleportToPainting';
	
	private editable var percentageToHeal : float;
}