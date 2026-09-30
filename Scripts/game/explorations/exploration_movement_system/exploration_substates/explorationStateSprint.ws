/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSprint extends CExplorationStateAbstract
{	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Sprint';
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
	}
	
	
	function StateChangePrecheck( )	: name
	{
		
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
		{
			if( !m_ExplorationO.m_InputO.IsSprintPressed() )
			{
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}