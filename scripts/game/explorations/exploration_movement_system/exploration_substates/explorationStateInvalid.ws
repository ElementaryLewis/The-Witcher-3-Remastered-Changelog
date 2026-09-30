/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateInvalid extends CExplorationStateAbstract
{		
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{
		m_ExplorationO = _Exploration;
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Invalid';
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
		
		thePlayer.AbortSign();
	}
	
	
	function StateChangePrecheck( )	: name
	{
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	function CanInteract( ) : bool
	{
		return true;
	}
}