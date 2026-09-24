/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFear extends CBTTaskPlayAnimationEventDecorator
{
	var useDirectionalAnims 	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var targetToAttackerAngle : float;
		
		
		if ( useDirectionalAnims )
		{
			targetToAttackerAngle = NodeToNodeAngleDistance(target,npc);
			
			if( targetToAttackerAngle >= -180 && targetToAttackerAngle < -67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_90 );
			}
			else if( targetToAttackerAngle >= -67.5 && targetToAttackerAngle < -22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_45 );
			}
			else if( targetToAttackerAngle >= -22.5 && targetToAttackerAngle < 22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_0 );
			}
			else if( targetToAttackerAngle >= 22.5 && targetToAttackerAngle < 67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m45 );
			}
			else if( targetToAttackerAngle >= 67.5 && targetToAttackerAngle < 180 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m90 );
			}
		}
		
		return super.OnActivate();
	}
}

class CBTTaskFearDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskFear';

	editable var useDirectionalAnims 	: bool;
	
	default useDirectionalAnims = false;
}