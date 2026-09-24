/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateIdleJump extends CExplorationStateTransitionAbstract
{
	editable		var	behEnded		: name;		default	behEnded		= 'LandEnd';
	editable		var	enabled			: bool;		default	enabled			= false;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'IdleJump';
		}
		if( !IsNameValid( m_TransitionOriginStateN ) )
		{
			m_TransitionOriginStateN	= 'Idle'; 
		}
		if( !IsNameValid( m_TransitionEndStateN ) )
		{
			m_TransitionEndStateN	= 'Jump';
		}
		
		m_StateTypeE		= EST_Idle;
		m_InputContextE		= EGCI_JumpClimb;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !enabled )
		{
			return false;
		}
		
		if( !m_ExplorationO.IsOnGround() )
		{
			return false;
		}
		
		return !m_ExplorationO.m_InputO.IsModuleConsiderable();
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{		
		
		thePlayer.AbortSign();
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnded, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{			
		if( m_ExplorationO.GetStateTimeF() > 1.0f )
		{
			m_ExplorationO.SendAnimEvent( 'Idle' );
			return 'Idle';
		}
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnded );
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == behEnded )
		{		
			
			
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{	
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	
	private function StartMovementAdjustorTranslation()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
				
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'IdleJumpTest' );		
		movAdj.AdjustmentDuration( ticket, 0.1f );
		movAdj.AdjustLocationVertically( ticket, true );
		
		
		
		movAdj.SlideBy( ticket, Vector( 1.0f, 0.0f, 2.0f ) );
	}
	
	
	private function StopMovementAdjustorTranslationTest()
	{
	}
}
