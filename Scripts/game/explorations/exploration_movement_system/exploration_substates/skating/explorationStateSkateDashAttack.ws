/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingDashAttack extends CExplorationStateSkatingDash
{
	private 			var attacked			: bool;
	private editable	var	afterAttackTime		: float;	default	afterAttackTime		= 0.5f;
	private 			var timeToEndCur		: float;
	public	editable 	var	behParamAttackName	: name;		default	behParamAttackName	= 'Skate_Attack';
	
	private editable	var	afterAttackImpulse	: float;	default	afterAttackImpulse	= 5.0f;
	

	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateDashAttack';
		}
		
		super.InitializeSpecific( _Exploration );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		
		
		
		
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}
	
	
	function StateWantsToEnter() : bool
	{	
		return m_ExplorationO.m_InputO.IsSkateAttackJustPressed();
	}
	
	
	protected function StateEnterSpecific( prevStateName : name )	
	{
		attacked	= false;
		
		super.StateEnterSpecific( prevStateName );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		
		UpdateAttack( _Dt );
		
		super.StateUpdateSpecific( _Dt );
	}
	
	
	private function UpdateAttack( _Dt : float )
	{
		if( attacked )
		{
			timeToEndCur -= _Dt;
			if( timeToEndCur <= 0.0f )
			{
				SetReadyToChangeTo( 'SkateRun' );
			}
		}
		
		else if( !m_ExplorationO.m_InputO.IsSkateAttackPressed() )
		{
			m_ExplorationO.SendAnimEvent( behParamAttackName );
			attacked		= true;
			timeToEndCur	= afterAttackTime;
			skateGlobal.ImpulseNotExceedingMaxSpeedLevel( afterAttackImpulse );
			
			
			
			((CActor) thePlayer ).SetInteractionPriority( IP_Prio_14 );
		}
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		
		((CActor) thePlayer ).SetInteractionPriority( IP_Prio_0 );
	}
}