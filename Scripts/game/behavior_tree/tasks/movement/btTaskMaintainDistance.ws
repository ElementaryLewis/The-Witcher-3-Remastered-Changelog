/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskMaintainDistance extends IBehTreeTask
{
	
	
	
	public var minDistance 			: float;
	public var maxDistance			: float;
	public var faceTarget			: bool;	
	public var fromOutsideDuration 	: float;
	public var forceTarget			: CName;
	
	private var m_Npc 				: CNewNPC;
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_target			: CNode;
		
		l_target = GetCombatTarget();
		
		if( !l_target )
		{
			return BTNS_Active;
		}
		
		m_Npc = GetNPC();
		
		if( VecDistance( l_target.GetWorldPosition(), m_Npc.GetWorldPosition() ) > maxDistance )
		{
			SlideToTarget( fromOutsideDuration );
		}
		
		while( true )
		{
			SlideToTarget();
			SleepOneFrame();
		}
		
		
		return BTNS_Active;
	}
	
	
	
	private latent function SlideToTarget( optional duration : float )
	{
		var l_movementAdjustor	: CMovementAdjustor;
		var l_ticketDistance 	: SMovementAdjustmentRequestTicket;
		var l_ticketRotation 	: SMovementAdjustmentRequestTicket;
		var l_target			: CNode;
		var l_newHeading		: Vector;
		
		
		if( IsNameValid( forceTarget ) )
		{
			l_target = theGame.GetEntityByTag( forceTarget );
		}
		else
		{
			l_target = GetCombatTarget();
		}
		
		l_movementAdjustor = m_Npc.GetMovingAgentComponent().GetMovementAdjustor();
		l_movementAdjustor.CancelAll();
		l_ticketDistance = l_movementAdjustor.CreateNewRequest( 'MaintainDistanceToTarget' );		
		
		if( duration > 0 )
		{
			l_movementAdjustor.AdjustmentDuration( l_ticketDistance, duration );
			
		}
		
		l_movementAdjustor.SlideTowards(  l_ticketDistance , l_target, minDistance, maxDistance );
		
		if ( faceTarget )
		{
			l_movementAdjustor.MaxRotationAdjustmentSpeed( l_ticketRotation, 1000000.f );
			
			
			
			if ( !l_movementAdjustor.IsRequestActive( l_movementAdjustor.GetRequest( 'RotateToTarget' ) ) )
			{
				
				l_ticketRotation = l_movementAdjustor.CreateNewRequest( 'RotateToTarget' );
				
				
				l_movementAdjustor.AdjustmentDuration( l_ticketRotation, 0.2f );
				
				
			}
			else
			{
				
				l_ticketRotation = l_movementAdjustor.GetRequest( 'RotateToTarget' );
			}
			
			l_newHeading = l_target.GetWorldPosition() - m_Npc.GetWorldPosition();
			l_movementAdjustor.RotateTo( l_ticketRotation, VecHeading( l_newHeading ) );
		
		}

		if( duration > 0 )
		{
			Sleep( duration );
		}	
	}


}



class BTTaskMaintainDistanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskMaintainDistance';
	
	private editable var minDistance			: float;
	private editable var maxDistance			: float;	
	private editable var faceTarget				: bool;
	
	private editable var fromOutsideDuration	: float;
	
	private editable var forceTarget			: CName;
	
	default minDistance 		= 1;
	default maxDistance			= 2;
	default fromOutsideDuration = 1;

}