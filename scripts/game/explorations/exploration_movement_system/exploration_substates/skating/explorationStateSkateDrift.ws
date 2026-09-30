/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingDrift extends CExplorationStateAbstract
{		
	protected					var	skateGlobal			: CExplorationSkatingGlobal;
	
	
	
	protected editable			var impulse				: float;					default	impulse				= 0.75f;
	protected editable			var impulseSpeedMax		: float;					default	impulseSpeedMax		= 8.0f;
	
	
	protected					var sharpTurn			: bool;	
	protected editable			var sharpTurnTime		: float;					default	sharpTurnTime		= 0.15f;
	protected editable			var sharpTurnSpeed		: float;					default sharpTurnSpeed		= 100.0f;
	protected editable			var holdTurnSpeed		: float;					default holdTurnSpeed		= 70.0f;
	
	
	protected editable			var chainTimeToDrift	: float;					default	chainTimeToDrift	= 0.2f;
	
	
	protected 					var exiting				: bool;	
	protected editable			var timeEndingMax		: float;					default	timeEndingMax		= 0.2f;
	protected 					var timeEndingFlow		: bool;
	protected					var	timeEndingCur		: float;
	
	protected editable			var behDriftRestart		: name;						default	behDriftRestart		= 'Skate_DriftRestart';
	protected editable			var behDriftEnd			: name;						default	behDriftEnd			= 'Skate_DriftEnd';
	protected editable			var behDriftLeftSide	: name;						default	behDriftLeftSide	= 'Skate_DriftLeft';
	
	
	protected 					var sideIsLeft			: bool;	
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateDrift';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		
		m_StateTypeE	= EST_Skate;
		
		
		
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{		
		AddStateToTheDefaultChangeList( 'SkateDash' );
		AddStateToTheDefaultChangeList( 'SkateBackwards' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	
	function StateWantsToEnter() : bool
	{	
		if( skateGlobal.ShouldStop( true ) )
		{
			return false;
		}
		
		return m_ExplorationO.m_InputO.IsDriftPressed();
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	
	protected function StateEnterSpecific( prevStateName : name )	
	{		
		var impulseResulting	: float;
		
		
		sideIsLeft		= m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() < 0.0f;
		skateGlobal.m_DrifIsLeft	= sideIsLeft;
		m_ExplorationO.SetBehaviorParamBool( behDriftLeftSide, !sideIsLeft );
		
		
		impulseResulting	= MaxF( 0.0f, impulseSpeedMax - m_ExplorationO.m_MoverO.GetMovementSpeedF() );
		impulseResulting	- MinF( impulse, impulseResulting );
		m_ExplorationO.m_MoverO.AddSpeed( impulseResulting );
		
		
		if( skateGlobal.CheckIfIsInFlowGapAndConsume() )
		{
			skateGlobal.DecreaseSpeedLevel( true, false );
		}
		
		else
		{
			skateGlobal.DecreaseSpeedLevel( false, true );
			
		}
		
		
		m_ExplorationO.m_MoverO.SetSkatingTurnSpeed( sharpTurnSpeed );
		
		exiting					= false;
		timeEndingCur			= 0.0f;
		sharpTurn				= true;
		timeEndingFlow			= false;
		skateGlobal.m_Drifting	= true;
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( timeEndingCur > timeEndingMax )
		{
			return 'SkateRun';
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		
		skateGlobal.UpdateRandomAttack();
		
		
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking, true, sideIsLeft );
		
		
		UpdateExit( _Dt, braking );
		
		
		skateGlobal.SetBehParams( accel, braking, turn );
	}
	
	
	protected function StateExitSpecific( nextStateName : name )
	{		
		skateGlobal.m_Drifting	= false;
		skateGlobal.StartFlowTimeGap();
	}	
	
	
	protected function UpdateExit( _Dt : float, braking : bool )
	{
		
		if( skateGlobal.ShouldStop( braking ) )
		{
			SetReadyToChangeTo( 'SkateIdle' );
		}
		
		
		if( StateWantsToEnter() )
		{
			if( timeEndingCur > 0.0f  )
			{
				
				if( m_ExplorationO.GetStateTimeF() >= chainTimeToDrift )
				{
					SetReadyToChangeTo(	'SkateRun' );
				}
				
				skateGlobal.CancelFlowTimeGap();
				m_ExplorationO.SendAnimEvent( behDriftRestart );
				
				timeEndingCur	= 0.0f;
				skateGlobal.m_Drifting	= true;
			}
		}
		else
		{
			timeEndingCur	+= _Dt;
			if( !timeEndingFlow && timeEndingCur > timeEndingMax - skateGlobal.GetMaxFlowTimeGap() )
			{
				timeEndingFlow	= true;
				m_ExplorationO.SendAnimEvent( behDriftEnd );
				skateGlobal.m_Drifting	= false;
			}
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
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