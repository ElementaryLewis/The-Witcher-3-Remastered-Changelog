/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum PrepareJumpSubState
{
	PJSS_Start	,
	PJSS_Loop	,
	PJSS_End	,
}



class CExplorationStatePrepareJump extends CExplorationStateAbstract
{
	protected editable	var	m_JumpIsInstantB	: bool;		default	m_JumpIsInstantB	= true;
	protected editable	var	m_JumpTimeGapF		: float;	default	m_JumpTimeGapF		= 0.5f;
	protected editable	var	m_EndingTimeF		: float;	default	m_EndingTimeF		= 0.9f;
	protected editable	var	m_EndEventNameN		: name;		default m_EndEventNameN		= 'Jump_Prepare_End';
	protected editable	var	m_EndedEventNameN	: name;		default m_EndedEventNameN	= 'Jump_Prepare_Ended';
	protected editable	var	m_TimeEndedB		: bool;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'PrepareJump';
		}
		
		m_StateTypeE	= EST_Idle;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		return false;
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		m_TimeEndedB	= false;
	}
	
	
	function StateChangePrecheck( )	: name
	{
		
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Jump' ) )
		{
			
			if( m_JumpIsInstantB )
			{
				return 'Jump';
			}
			
			
			if( !m_TimeEndedB )
			{ 
				if( !m_ExplorationO.m_InputO.IsSprintPressed() ) 
				{
					return 'Jump';
				}
			}
		}
		
		
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Sprint' ) )
		{
			if ( m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				if( m_ExplorationO.m_InputO.IsSprintPressed() )
				{
					return 'Sprint';
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		
		if( !m_TimeEndedB )
		{
			if( m_ExplorationO.GetStateTimeF() >= m_JumpTimeGapF )
			{			
				m_ExplorationO.SendAnimEvent( m_EndEventNameN );
				m_TimeEndedB	= true;
			}
		}
		
		
		else if ( m_ExplorationO.GetStateTimeF() >= m_JumpTimeGapF + m_EndingTimeF || m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			m_ExplorationO.SendAnimEvent( m_EndedEventNameN );
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}