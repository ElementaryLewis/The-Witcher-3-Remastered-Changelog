/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskAdditiveTaunt extends IBehTreeTask
{
	public var distMin, distMax	: float;
	
 	function OnActivate() : EBTNodeStatus
	{
		GetNPC().SetBehaviorVariable( 'additiveTauntOn', 1 );
		
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var l_npc 					: CNewNPC = GetNPC();
		var target 					: CActor = l_npc.GetTarget();
		var l_npcPos, l_targetPos 	: Vector;
		var l_dist					: float;
		var l_additivePercentage	: float;
		
		while( true )
		{
			Sleep(0.1);
			
			l_npcPos		= l_npc.GetWorldPosition();
			l_targetPos 	= target.GetWorldPosition();
			
			
			if( AbsF( AngleDistance( l_npc.GetHeading(), VecHeading( l_targetPos - l_npcPos ) ) ) > 120 )
			{
				l_npc.SetBehaviorVariable( 'additiveTauntOn', 0.f );
				continue;
			}
			
			l_dist = VecDistance( l_npcPos, l_targetPos );
			
			if ( l_dist > distMax )
			{
				l_npc.SetBehaviorVariable( 'additiveTauntOn', 0.f );
			}
			else if ( l_dist < distMin)
			{
				l_npc.SetBehaviorVariable( 'additiveTauntOn', 1.f );
				l_npc.SetBehaviorVariable( 'additiveTauntPer', 1 );			
			}
			else
			{
				l_additivePercentage = 1.f - ClampF( ( l_dist - distMin) / ( distMax - distMin ),0.f,1.f);
				
				l_npc.SetBehaviorVariable( 'additiveTauntOn', 1.f );
				l_npc.SetBehaviorVariable( 'additiveTauntPer', l_additivePercentage );
				
			}
			
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetBehaviorVariable( 'additiveTauntOn', 0.f );
	}
};

class BTTaskAdditiveTauntDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAdditiveTaunt';
	
	private editable var distMin : float;
	private editable var distMax : float;
	
	default distMin = 0;
	default distMax = 7;
};