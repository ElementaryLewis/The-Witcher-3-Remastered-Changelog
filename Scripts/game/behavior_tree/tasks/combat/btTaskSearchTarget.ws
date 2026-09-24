/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSearchTarget extends IBehTreeTask
{
	
	
	
	public 	var namedTarget : name;
	
	private var m_LastKnowPosition	: Vector;	
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_npc 			: CNewNPC = GetNPC();
		var l_targetPos		: Vector;
		var l_newPos		: Vector;
		var l_guardArea 	: CAreaComponent;
		var l_target		: CNode;
		var l_groundZ		: float;
		
		l_guardArea = l_npc.GetGuardArea();
		
		l_target = GetNamedTarget( namedTarget );
		
		m_LastKnowPosition = l_target.GetWorldPosition();
		
		if( l_guardArea )
		{
			if( !l_guardArea.TestPointOverlap( m_LastKnowPosition ) )
			{
				l_targetPos = l_npc.GetWorldPosition() + VecRand2D() * 10;
				
				if( theGame.GetWorld().NavigationFindSafeSpot( l_targetPos, 3, 10, l_newPos ) )
				{
					l_targetPos = l_newPos;
				}
				else
				{
					return BTNS_Failed;
				}
			}
			else
			{
				l_targetPos = m_LastKnowPosition;
			}
		}
		
		
		
		SetCustomTarget( l_targetPos, RandRangeF( 180 ) );
		
		
		
		return BTNS_Active;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_targetPos : Vector;
		var heading 	: float;
		
		while( true )
		{
			GetCustomTarget( l_targetPos, heading);
			GetNPC().GetVisualDebug().AddArrow('toCustomTarget', GetNPC().GetWorldPosition() + Vector( 0, 0, 1), l_targetPos, 1, 0.5f, 0.8f, true, Color( 205, 156, 89 ),, -1 );
			SleepOneFrame();
		}
		return BTNS_Active;
	}

}


class BTTaskSearchTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSearchTarget';
	
	
	private editable var namedTarget : name;
	
	default namedTarget = 'DangerSource';
}