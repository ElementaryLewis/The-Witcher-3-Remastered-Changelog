/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingDash extends CExplorationStateAbstract
{		
	protected					var	skateGlobal			: CExplorationSkatingGlobal;
	
	
	protected editable			var impulse				: float;		default	impulse					= 3.0f;
	protected editable			var timeMax				: float;		default	timeMax					= 0.75f;
	protected editable			var timeToChainMin		: float;		default	timeToChainMin			= 0.2f;	
	
	
	
	protected editable			var sharpTurnSpeed		: float;		default	sharpTurnSpeed			= 300.0f;
	protected editable			var holdTurnSpeed		: float;		default	holdTurnSpeed			= 80.0f;
	protected					var sharpTurn			: bool;	
	protected editable			var sharpTurnTime		: float;		default	sharpTurnTime			= 0.2f;
	
	
	
	protected editable			var behAttackEvent		: name;			default	behAttackEvent			= 'Skate_Attack';
	protected editable			var behLeftFootParam	: name;			default	behLeftFootParam		= 'Skate_LeftFoot';
	
	
	
	protected 					var	boneRightFoot		: name;			default	boneRightFoot			= 'r_foot';
	protected 					var	boneLeftFoot		: name;			default	boneLeftFoot			= 'l_foot';
	protected 					var	boneIndexRightFoot	: int;
	protected 					var	boneIndexLeftFoot	: int;
	
	
	
	private editable			var behEventEnd			: name;			default	behEventEnd			= 'AnimEndAux';
	
	
	
	protected function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateDash';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		
		
		boneIndexRightFoot	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneRightFoot );
		boneIndexLeftFoot	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneLeftFoot );
		
		
		
		m_StateTypeE			= EST_Skate;
		m_UpdatesWhileInactiveB	= true;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		
		
		
		
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	
	function StateWantsToEnter() : bool
	{	
		return m_ExplorationO.m_InputO.IsDashJustPressed();
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !HasEnoughStamina() )
		{
			return false;
		}
		
		return skateGlobal.IsDashReady();
	}
	
	
	protected function StateEnterSpecific( prevStateName : name )	
	{		
		var finalImpulse	: float;
		
		
		
		
		
		
		
		
		
		
		
		
		
		skateGlobal.SetSpeedLevel( 1, true );
		skateGlobal.ImpulseNotExceedingMaxSpeedLevel( impulse );
		
		
		BlockStamina();
		
		
		m_ExplorationO.m_MoverO.SetSkatingTurnSpeed( sharpTurnSpeed );
		sharpTurn		= true;
		
		
		SetTheForwardFoot();
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_ExplorationO.GetStateTimeF() > timeMax )
		{
			return 'SkateRun';
		}
		
		else if( m_ExplorationO.GetStateTimeF() < timeToChainMin )
		{
			return GetStateName();
		}
		
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var accel	: float;
		var turn	: float;
		var braking	: bool;
		
		
		
		skateGlobal.UpdateRandomAttack();
		skateGlobal.UpdateDashAttack();
		
		
		if( sharpTurn && m_ExplorationO.GetStateTimeF() >= sharpTurnTime )
		{
			skateGlobal.ApplyDefaultParams();
			sharpTurn	= false;
		}
		
		
		m_ExplorationO.m_MoverO.UpdateSkatingMovement( _Dt, accel, turn, braking );
		
		
		skateGlobal.SetBehParams( accel, braking, turn );
	}

	
	function StateUpdateInactive( _Dt : float )
	{
		skateGlobal.UpdateDashCooldown( _Dt );
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{		
		skateGlobal.ConsumeDashCooldown();
		skateGlobal.StartFlowTimeGap();
	}	
	
	
	private function SetTheForwardFoot()
	{
		var startRightFoot	: bool;
		
		startRightFoot	= m_ExplorationO.m_MoverO.IsRightFootForward();
		
		m_ExplorationO.SetBehaviorParamBool( behLeftFootParam, !startRightFoot );
	}	
	
	
	private function HasEnoughStamina() : bool
	{
		return thePlayer.HasStaminaToUseAction( ESAT_Sprint );
	}
	
	
	private function BlockStamina()
	{
		thePlayer.DrainStamina(ESAT_Sprint);
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
