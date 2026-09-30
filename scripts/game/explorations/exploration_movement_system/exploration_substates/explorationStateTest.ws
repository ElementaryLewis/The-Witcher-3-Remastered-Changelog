/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateTest extends CExplorationStateAbstract
{	
	private		editable	var		m_TesMovementParamsS		: SPlaneMovementParameters;
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Test';
		}
		m_StateTypeE	= EST_OnAir;
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
		
		m_ExplorationO.m_OwnerMAC.SetAnimatedMovement( true );
		m_ExplorationO.m_MoverO.SetPlaneMovementParams( m_TesMovementParamsS );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		m_ExplorationO.m_MoverO.UpdateMovementOnPlaneWithInput( _Dt );
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}