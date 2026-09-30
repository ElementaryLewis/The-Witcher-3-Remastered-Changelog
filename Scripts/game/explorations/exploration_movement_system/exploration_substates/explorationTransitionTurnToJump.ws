/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CxplorationTransitionTurnToJump extends CExplorationStateTransitionAbstract
{
	private editable	var	timeToExit		: float;		default	timeToExit		= 0.3f;
	private editable	var	angleToTrigger	: float;		default	angleToTrigger	= 100.0f;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'TurnToJump';
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
		
	}
	
	
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_CallHorse );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		var angle	: float;
		
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			return false;
		}
		
		angle	= m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF();
		if( AbsF( angle ) < angleToTrigger ) 
		{
			return false;
		}
		
		return true;
	}
	
	
	function StateWantsToEnter() : bool
	{	
		return false;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{	
		BlockActions();
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() >= timeToExit )
		{
			return m_TransitionEndStateN;
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
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
}