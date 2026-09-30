/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ELandType
{
	LT_Death				= 0,
	LT_Damaged				= 1,
	LT_Crouch				= 2,
	LT_Normal				= 3,
	LT_Higher				= 4,
	LT_Panther				= 5,
	LT_KnockBack			= 6,
	LT_FrontAircollision	= 7,
}


enum ELandRunForcedMode
{
	LRFM_NotForced	= 0	,
	LRFM_Idle		= 1	,
	LRFM_Walk		= 2	,
	LRFM_Run		= 3	,
}


struct SLandData
{
	editable var	landType			: ELandType;			default landType				= LT_Normal;
	editable var	timeBeforeChain		: float;				default timeBeforeChain			= 0.2f;
	editable var	cameraShakeStrength	: float;				default cameraShakeStrength		= 0.1f;
	editable var	orientationSpeed	: float;				default orientationSpeed		= 2.0f;
	editable var	timeSafetyEnd		: float;				default timeSafetyEnd			= 3.0f;
	editable var	landEndForcedMode	: ELandRunForcedMode;	default landEndForcedMode		= LRFM_NotForced;
	editable var	shouldFlipFoot		: bool;					default shouldFlipFoot			= false;
}



class CExplorationStateLand extends CExplorationStateAbstract
{
	
	
	protected editable			var	m_BehLandRunS			: name;			default	m_BehLandRunS				= 'LandWalking';
	protected editable			var	m_LandRunInputAngleF	: float;		default	m_LandRunInputAngleF		= 190.0f;
	protected editable			var	m_BehLandTypeS			: name;			default	m_BehLandTypeS 				= 'LandType';
	protected editable			var	m_BehLandCancelN		: name;			default	m_BehLandCancelN 			= 'AnimEndAUX'; 
	protected editable			var	m_BehLandCanEndN		: name;			default	m_BehLandCanEndN 			= 'LandEnd';
	protected editable			var	m_BehLandSkipToRunN		: name;			default	m_BehLandSkipToRunN			= 'LandSkipToRun';
	protected editable			var	m_BehLandSkipToWalkN	: name;			default	m_BehLandSkipToWalkN		= 'LandSkipToWalk';
	protected editable			var	m_BehLandSkipToIdleN	: name;			default	m_BehLandSkipToIdleN		= 'LandSkipToIdle';
	protected editable			var	m_BehLandFallForwardN	: name;			default	m_BehLandFallForwardN		= 'LandFallIsForward';
	
	
	protected editable			var	m_HeightToLandCrouch	: float;		default	m_HeightToLandCrouch		= 2.75f;
	
	
	protected					var	m_LandTypeE				: ELandType;
	protected editable inlined	var	m_LandDataIdle			: SLandData;
	protected editable inlined	var	m_LandDataWalk			: SLandData;
	protected editable inlined	var	m_LandDataWalkHigh		: SLandData;	
	protected editable inlined	var	m_LandDataRun			: SLandData;	
	protected editable inlined	var	m_LandDataSprint		: SLandData;	
	protected editable inlined	var	m_LandDataHigher		: SLandData;
	protected editable inlined	var	m_LandDataAirCollision	: SLandData;
	protected editable inlined	var	m_LandDataCrouch		: SLandData;	
	protected editable inlined	var	m_LandDataFall			: SLandData;	
	protected editable inlined	var	m_LandDataDamage		: SLandData;	
	protected editable inlined	var	m_LandDataDeath			: SLandData;
	protected editable inlined	var	m_LandDataKnockBack		: SLandData;
	
	protected 					var	m_LandData				: SLandData;
	
	
	private		editable		var	m_UseBendAddOnLand		: bool;			default	m_UseBendAddOnLand			= true;
	
	
	private	  editable			var m_AutoRollB				: bool;			default	m_AutoRollB					= false;
	private	  editable			var m_AutoSlopeAngleB		: float;		default	m_AutoSlopeAngleB			= 30.0f; 	
	private	  					var m_AutoRollSlopeCoefF	: float;		
	private	  editable			var m_DamageOverridesRollB	: bool;			default	m_DamageOverridesRollB		= false;
	protected					var m_RollingB				: bool;
	private						var	m_RollIsSlopeB			: bool;
	protected editable			var	m_RollMinHeightF		: float;		default	m_RollMinHeightF			= 1.05f;	
	protected editable			var	m_RollTimeAfterF		: float;		default	m_RollTimeAfterF			= 0.1f;		
	protected editable 			var m_RollMinJumpTotalF 	: float; 		default m_RollMinJumpTotalF 		= 1.02f;	
	
	
	protected 					var m_SlidingB					: bool;
	private						var	m_SlideCheckedSecondFrameB	: bool;
	private						var m_SlideSavingVelocityV		: Vector;
	
	
	protected editable			var	m_AllowHigherJumpB		: bool;			default	m_AllowHigherJumpB			= true;
	protected editable			var	m_HighLandingHeightF	: float;		default	m_HighLandingHeightF		= 0.6f;
	
	
	protected editable			var	m_AllowSkipB			: bool;			default	m_AllowSkipB				= true;
	
	
	private						var m_RunCoefF				: float;
	private						var	m_FallIsForwardB		: bool;
	private						var	m_ToFallB				: bool;
	private						var	m_ReadyToEndB			: bool;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Land';
		}
		
		m_StateTypeE		= EST_Idle;
		m_InputContextE		= EGCI_JumpClimb; 
		
		
		m_AutoRollSlopeCoefF	= m_ExplorationO.m_MoverO.ConvertAngleDegreeToSlidECoef( m_AutoSlopeAngleB );
		
		LogExplorationLandExit( "	Initialized Log channel: ExplorationStateLandExits" );
	}
	
	
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_Signs );
		AddActionToBlock( EIAB_Fists );
		AddActionToBlock( EIAB_SwordAttack );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList('Interaction');
		
		AddStateToTheDefaultChangeList('Slide', -1.0f );
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
		var fallDiff		: float;
		var jumpTotalDiff	: float;
		var damagePerc		: float;
		var intoWater		: bool;
		var	position		: Vector;
		var skipping		: bool;
		var skippingAux		: bool;
		var skippingAux2	: bool;
		var damageRedFactor	: float;
		
		
		m_ReadyToEndB		= false;
		m_ToFallB			= false;
		m_FallIsForwardB	= false;
		m_RollIsSlopeB		= false;
		
		position			= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		
		m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
		
		
		intoWater					= false; 
		
		
		m_SlidingB					= false;
		m_SlideCheckedSecondFrameB	= false;
		m_SlideSavingVelocityV		= m_ExplorationO.m_MoverO.GetMovementVelocity();
		
		
		m_ExplorationO.m_MoverO.StopVerticalMovement();
		m_ExplorationO.m_MoverO.StopAllMovement();
		
		
		m_RollingB		= CheckIfRolling( prevStateName, fallDiff, jumpTotalDiff );		
		
		
		damagePerc		= m_ExplorationO.m_OwnerE.ApplyFallingDamage( fallDiff, m_RollingB || intoWater );
		
		
		if( m_DamageOverridesRollB && m_RollingB && damagePerc > 0.0f )
		{
			LogExploration( "Damage overrides roll" );
			m_RollingB	= false;
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'PlayerJumpAction', 3.f, 8.f, -1, 9999, true ); 
		}	
		
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		
		LogExploration( "Landed height difference " + jumpTotalDiff + ", fallDiff: " + fallDiff );
		if ( damagePerc >= 1.0f )
		{
			LogExploration( "DEAD from falling" );
		}
		else if( damagePerc > 0.0f )
		{
			LogExploration( "Damaged: " + damagePerc * 100.0f + "%" );
		}
		else
		{
			LogExploration( "Not Damaged from falling" );
		}
		
		
		ApplyProperLandParameters( damagePerc, jumpTotalDiff, fallDiff );
		
		
		
		SetLandBehGraphParams( damagePerc >= 1.0f );
		
		
		if( damagePerc >= 1.0f )
		{
			m_ExplorationO.m_SharedDataO.ResetHeightFallen();
			return;
		}
		
		
		
		LandTypeInitialize();
		
		
		SetProperLandIK();
		
		
		
		
		
		
		
		
		skipping		= fallDiff < m_ExplorationO.m_SharedDataO.m_SkipLandAnimDistMaxF;
		
		skippingAux		= m_ExplorationO.GetStateTimeF() <= m_ExplorationO.m_SharedDataO.m_SkipLandAnimTimeMaxF;
		
		if( skipping && skippingAux && m_ExplorationO.m_SharedDataO.m_JumpTypeE != EJT_Vault )
		{
			if( prevStateName == 'Jump' && m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Fall )
			{
				m_FallIsForwardB	= true;
			}
			else if( m_AllowSkipB )
			{
				LogExploration( GetStateName() + " SetReadyToChangeTo: cause of the short jump time and distance " );
				
				if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
				{
					m_ExplorationO.SendAnimEvent( m_BehLandSkipToIdleN );
				}
				else if( thePlayer.GetIsWalkToggled() || !m_ExplorationO.m_InputO.IsModuleRunning() )
				{
					m_ExplorationO.SendAnimEvent( m_BehLandSkipToWalkN );				
				}
				else
				{
					m_ExplorationO.SendAnimEvent( m_BehLandSkipToRunN );
				}
				SetReadyToChangeTo( 'Idle' );
			}
		}
		
		
		SetLandFootForward();
		
		
		
		m_ExplorationO.SetBehaviorParamBool( m_BehLandFallForwardN, true );
		
		
		BlockActions();
		
		
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();
	}
	
	
	private function SetLandFootForward()
	{
		var shouldSetFoot	: bool;
		var shouldFlipFoot	: bool;
		
		
		shouldFlipFoot	= m_ExplorationO.m_SharedDataO.m_ShouldFlipFootOnLandB;
		if( m_LandData.shouldFlipFoot )
		{
			shouldFlipFoot	= !shouldFlipFoot;
		}
		shouldSetFoot	= !m_ExplorationO.m_SharedDataO.m_DontRecalcFootOnLandB; 
		
		if( shouldSetFoot )
		{
			m_ExplorationO.m_SharedDataO.SetFotForward( !shouldFlipFoot );
		}
		else if( shouldFlipFoot )
		{
			m_ExplorationO.m_SharedDataO.ForceFotForward( !m_ExplorationO.m_SharedDataO.m_IsRightFootForwardB );
		}
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( m_BehLandCanEndN, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( m_BehLandCancelN, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{		
		var slideDir 	: Vector;
		var slideNormal	: Vector;
		
		
		
		if( CanChainJump() )
		{
			if( m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) )
			{
				LogExplorationLandExit( GetStateName() + " Exited by chaining a jump" );
				return 'Jump';
			}
		}
		
		
		if( m_ExplorationO.GetStateTimeF() > 0.0f ) 
		{
			if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{		
				
				if( m_ReadyToEndB )
				{
					if( m_ToFallB ) 
					{
						LogExplorationLandExit( GetStateName() + " Exited by fall" );
						if( m_LandTypeE == LT_KnockBack )
						{
							return 'Jump';
						}
						
						return 'StartFalling';
					}
					else if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						if( thePlayer.GetIsRunning() )
						{
							m_ExplorationO.SendAnimEvent( m_BehLandSkipToRunN );
						}
						else
						{
							m_ExplorationO.SendAnimEvent( m_BehLandSkipToWalkN );
						}
						LogExplorationLandExit( GetStateName() + " Exited by Movement once ready" );
						return 'Idle';
					}
				}
				
				
				if( ( m_LandData.timeSafetyEnd > 0.0f && m_LandData.timeSafetyEnd < m_ExplorationO.GetStateTimeF() ) || ( m_LandData.timeSafetyEnd == 0.0f && 3.0f < m_ExplorationO.GetStateTimeF() ) )
				{
					LogExplorationLandExit( GetStateName() + " Exited by safety time out: " + m_LandData.timeSafetyEnd );
					return 'Idle';
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{			
		
		
		
		
		
		
		if( m_RunCoefF > 0.0f )
		{
			m_ExplorationO.m_MoverO.UpdateOrientToInput( m_LandData.orientationSpeed, _Dt );
		}
		
		
		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		if( nextStateName == 'Idle' )
		{
			
		}
		
		thePlayer.SetBIsCombatActionAllowed( true );
		thePlayer.SetBIsInCombatAction(false);
		thePlayer.ReapplyCriticalBuff();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( false );
		
		
		
		m_ExplorationO.m_SharedDataO.SetTerrainSlopeSpeed( 2.0f );
		
		
		thePlayer.OnCombatActionEndComplete();
		
		
		if( nextStateName == 'Slide' )
		{
			LogExplorationLandExit( "Default transition to Slide" );
		}		
		if( nextStateName == 'Interaction' )
		{
			LogExplorationLandExit( "Default transition to Interaction" );
		}		
		LogExplorationLandExit( "Land Exited -------------------" );
		
		
		
		if( nextStateName != 'Slide' || nextStateName != 'StartFalling' )
		{
			thePlayer.GoToCombatIfWanted();
		}
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( m_BehLandCanEndN );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( m_BehLandCancelN );
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	private function ApplyProperLandParameters( damage, jumpTotalDiff : float, fallDiff : float )
	{
		var landType 		: ELandType;
		
		
		
		landType	= FindLandType( damage, jumpTotalDiff, fallDiff );
		LogExploration( " Land type : " + landType );
		
		
		if( m_SlidingB )
		{
			ReactToSlide();
			return;
		}
		
		
		if( m_RollingB )
		{
			if( RollShouldBeJustCrouch( jumpTotalDiff, fallDiff ) )
			{
				m_RollingB	= false;
			}
			else
			{
				SetReadyToChangeTo( 'Roll' );
				return;
			}
		}
		
		
		if( fallDiff > m_HeightToLandCrouch && damage <= 0.0f )
		{
			landType	= LT_Crouch;
		}
		
		
		LandParametersSetFromType( landType );		
		
		
		if(m_CameraSetS)
		{
			m_CameraSetS.animationData.weight = m_LandData.cameraShakeStrength;
		}
	}
	
	
	private function SetLandBehGraphParams( isDead : bool )
	{
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandTypeS, ( float ) ( int ) m_LandTypeE );
		
		
		if( m_LandTypeE == LT_KnockBack )
		{
			if( isDead || !thePlayer.IsAlive() )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'KnockBackLandType', 0.0f );
				thePlayer.SetDeathType( PDT_KnockBack );
			}
			else
			{			
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'KnockBackLandType', 1.0f );
			}
		}
		else if( isDead || !thePlayer.IsAlive() )
		{
			thePlayer.SetDeathType( PDT_Fall );
		}
	}
	
	
	private function CheckIfRolling( stateLast : name, fallDiff, jumpTotalDiff : float ) : bool
	{		
		var slideCoef	: float;
		
		
		
		
		if( jumpTotalDiff < m_RollMinJumpTotalF && fallDiff < m_RollMinJumpTotalF )
		{
			if( m_ExplorationO.m_IsDebugModeB )
			{
				LogExploration( "( Hack for loading ) Roll Cancelled height too small " + jumpTotalDiff + " < m_RollMinJumpTotalF = " + m_RollMinJumpTotalF + " AND fallDiff < " + fallDiff);
			}
			return false;
		}
		
		
		
		if( m_ExplorationO.m_CollisionManagerO.IsGoingDownSlopeInstant( m_AutoRollSlopeCoefF ) )
		{
			m_RollIsSlopeB	= true;
			LogExploration( "Autoroll because of slope" );
			return true;
		}
		
		
		if( m_AutoRollB && thePlayer.GetNeedsToReduceFallingDamage( fallDiff ) )
		{
			LogExploration("Auto Roll");
			return true;
		}
		
		
		if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_ToWater )
		{
			return true;
		}
		
		
		if( m_ExplorationO.m_InputO.IsRollPressedInTime() )
		{
			LogExploration( "Roll Pressed in time" );
			return true;
		}
		
		return false;
	}
	
	
	private function RollShouldBeJustCrouch( jumpTotalDiff : float, fallDiff : float ) : bool
	{
		var dir, normal : Vector;
		
		
		
		if( m_LandTypeE == LT_KnockBack )
		{
			return false;
		}		
		
		
		
		if( m_ExplorationO.m_CollisionManagerO.CheckCollisionsForwardInHands( 1.7f ) )
		{
			LogExploration( "Roll changed to Crouch: found a wall in front" );
			return true;
		}
		
		
		if( m_RollIsSlopeB )
		{
			return false;
		}
		
		
		if( m_ExplorationO.m_SharedDataO.m_JumpTypeE != EJT_Sprint && !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			LogExploration( "Roll changed to Crouch: input module too small and not in sprint jump" );
			return true;
		}
		
		
		
		
		
		if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Idle || m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Walk || m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_WalkHigh ) 
		{
			
			if( fallDiff < m_RollMinHeightF && !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
			{
				LogExploration( "Roll changed to Crouch: height too small " + jumpTotalDiff + " < m_RollMinHeightF = " + m_RollMinHeightF );
				return true;
			}
		}
		
		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( dir, normal );
		if( normal.Z < 0.9f && VecDot( dir, m_ExplorationO.m_OwnerE.GetWorldForward() ) <= 0.0f )
		{
			LogExploration( "Roll changed to Crouch: Terrain normal.Z + " + normal.Z + " < 0.9f, Can't roll on such a slope upwards" );
			return true;
		}
		
		
		return false;
	}
	
	
	private function FindLandType( damagePerc : float, jumpTotalDiff : float, fallDiff : float ) : ELandType
	{	
		
		if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_KnockBack || m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_KnockBackFall )
		{
			return LT_KnockBack;
		}
		
		
		if( damagePerc >=  1.0f || !m_ExplorationO.m_OwnerE.IsAlive() )
		{
			return LT_Death;
		}
		
		
		else if( m_SlidingB )
		{
			return LT_Normal;
		}
		
		
		else if( damagePerc > 0.0f )
		{
			return LT_Damaged;
		}	
		
		
		else if( m_RollingB )
		{
			return LT_Crouch;
		}
		
		
		else if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Sprint && m_ExplorationO.m_SharedDataO.m_UsePantherJumpB )
		{
			return LT_Panther;
		}
		
		
		else if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Hit )
		{
			return LT_FrontAircollision;
		}
		
		
		else if ( m_AllowHigherJumpB && m_ExplorationO.m_SharedDataO.m_JumpIsTooSoonToLandB && m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Run ) 
		{
			return LT_Higher;
		}
		
		
		return LT_Normal;
	}
	
	
	private function LandParametersSetFromType( landType : ELandType )
	{
		
		m_LandTypeE	= landType;
		
		switch( m_LandTypeE )
		{
			case LT_Death	:
				SetThisParameters( m_LandDataDeath );
				LogExploration( " Params set: m_LandDataDeath" );
				break;
			case LT_KnockBack :
				SetThisParameters( m_LandDataKnockBack );
				LogExploration( " Params set: m_LandDataKnockBack" );				
				break;
			case LT_Damaged	:
				SetThisParameters( m_LandDataDamage );
				LogExploration( " Params set: m_LandDataDamage" );
				break;
			case LT_Crouch :
				SetThisParameters( m_LandDataCrouch );
				LogExploration( " Params set: m_LandDataCrouch" );
				break;
			case LT_Normal	:
				switch( m_ExplorationO.m_SharedDataO.m_JumpTypeE )
				{
					case EJT_Idle :
						SetThisParameters( m_LandDataIdle );
						LogExploration( " Params set: m_LandDataIdle" );
						break;
					case EJT_Walk :
						SetThisParameters( m_LandDataWalk );
						LogExploration( " Params set: m_LandDataWalk" );
						break;
					case EJT_WalkHigh :
						SetThisParameters( m_LandDataWalkHigh );
						LogExploration( " Params set: m_LandDataWalkHigh" );
						break;
					case EJT_Run :
						SetThisParameters( m_LandDataRun );
						LogExploration( " Params set: m_LandDataRun" );
						break;
					case EJT_Sprint :
						SetThisParameters( m_LandDataSprint );
						LogExploration( " Params set: m_LandDataSprint" );
						break;
					case EJT_Hit :
					case EJT_Fall :
						SetThisParameters( m_LandDataFall );
						LogExploration( " Params set: m_LandDataFall" );
						break;
				}
				break;
			case LT_Higher	:
				SetThisParameters( m_LandDataHigher );
				LogExploration( " Params set: m_LandDataHigher" );
				break;
			case LT_FrontAircollision :
				if( m_ExplorationO.m_SharedDataO.m_AirCollisionIsFrontal )
				{
					m_LandDataAirCollision.landEndForcedMode	= LRFM_Idle;
				}
				else
				{
					m_LandDataAirCollision.landEndForcedMode	= LRFM_NotForced;
				}
				SetThisParameters( m_LandDataAirCollision );
				LogExploration( " Params set: m_LandDataAirCollision" );
				break;
			case LT_Panther:
				SetThisParameters( m_LandDataSprint );
				LogExploration( " Params set: m_LandDataSprint" );
				break;
			default	:
				LogExplorationError( "Using an invalid land type" );
		}
	}
	
	
	private function SetThisParameters( parameters : SLandData )
	{
		m_LandData.landType				= parameters.landType;
		m_LandData.landEndForcedMode	= parameters.landEndForcedMode;
		m_LandData.orientationSpeed		= parameters.orientationSpeed;
		m_LandData.timeBeforeChain		= parameters.timeBeforeChain;
		m_LandData.cameraShakeStrength	= parameters.cameraShakeStrength;
		m_LandData.timeSafetyEnd		= parameters.timeSafetyEnd;
		m_LandData.shouldFlipFoot		= parameters.shouldFlipFoot;
	}
	
	
	private function SetProperLandIK()
	{	
		switch( m_LandTypeE )
		{
			case LT_Death	:
			case LT_Damaged	:
				m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( true );
				break;
			default:
				break;
		}
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true, 0.4f );
	}
	
	
	private function LandTypeInitialize()
	{				
		
		CheckGoToSlideOneFrameAfter();	
		
		
		switch( m_LandData.landEndForcedMode )
		{
			case LRFM_NotForced	:
				m_RunCoefF	= GetLandRunCoefFromInput();
				break;
			case LRFM_Idle		:
				m_RunCoefF	= 0.0f;
				break;
			case LRFM_Walk		:
				m_RunCoefF	= 0.5f;
				break;
			case LRFM_Run		:
				m_RunCoefF	= 1.0f;
				break;
		}
		
		
		if( m_RunCoefF == 1.0f )
		{
			if( m_ExplorationO.m_CollisionManagerO.IsGoingUpSlope( m_ExplorationO.m_OwnerE.GetWorldForward() ) )
			{
				m_RunCoefF = 0.5f;
			}
		}
		
		if( m_RunCoefF > 0.0f && m_ReadyToEndB )
		{
			LogExplorationLandExit( GetStateName() + " SetReadyToChangeTo: Reay to end and module pressed just ended landing" );
			SetReadyToChangeTo( 'Idle' );
		}
		
		
		if( m_RunCoefF > 0.0f )
		{
			if( m_UseBendAddOnLand && m_LandTypeE == LT_Normal )
			{	
				m_ExplorationO.m_SharedDataO.LandCrouchStart( m_RunCoefF == 0.5f );
			}
		}
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandRunS, m_RunCoefF );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandTypeS, ( float ) ( int ) m_LandTypeE );
	}
	
	
	private function LandTypeUpdateChange()
	{
		var l_NewRunCoefF : float;
		
		if( m_RunCoefF < 0.5f )
		{
			l_NewRunCoefF	= GetLandRunCoefFromInput();
			if( l_NewRunCoefF >= 0.5f )
			{
				m_RunCoefF	= 0.5f;
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandRunS, m_RunCoefF );
			}
		}
		else if( m_RunCoefF < 1.0f )
		{
			l_NewRunCoefF	= GetLandRunCoefFromInput();
			if( l_NewRunCoefF > m_RunCoefF )
			{
				m_RunCoefF	= l_NewRunCoefF;
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandRunS, m_RunCoefF );
			}
		}
	}
	
	
	private function GetLandRunCoefFromInput() : float
	{
		
		if( thePlayer.GetIsWalking() )
		
		{
			
			if( AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < m_LandRunInputAngleF )
			{
				if( thePlayer.GetIsRunning() && m_LandTypeE != LT_Damaged )
				{
					return 1.0f;
				}
				else
				{
					return 0.5f;
				}
			}
			
			
			else
			{
				return 0.0f;
			}
		}
		else
		{
			return  0.0f;
		}
	}
	
	
	private function CheckGoToSlideOneFrameAfter()
	{
		
		if( m_SlideCheckedSecondFrameB || m_ExplorationO.GetStateTimeF() <= 0.0f )
		{
			return;
		}
		
		
		m_SlidingB	= m_ExplorationO.StateWantsAndCanEnter('Slide');
		if( m_SlidingB )
		{
			m_ExplorationO.m_MoverO.SetVelocity( m_SlideSavingVelocityV	);
			ReactToSlide();
		}
		
		
		m_SlideCheckedSecondFrameB	= true;
	}
	
	
	private function CanChainJump() : bool
	{ 
		
		if( m_ExplorationO.GetStateTimeF() <= m_LandData.timeBeforeChain )
		{
			return false;
		}
		
		
		return m_LandTypeE == LT_Normal ||	m_LandTypeE == LT_Higher || m_LandTypeE == LT_Crouch;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == m_BehLandCanEndN )
		{
			m_ReadyToEndB	= true;
		}
		else if( animEventName == m_BehLandCancelN )
		{		
			LogExplorationLandExit( GetStateName() + " SetReadyToChangeTo: Beh land cancel event received" );
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	
	function ReactToLoseGround() : bool
	{
		
		if( !m_ExplorationO.m_OwnerE.IsAlive() )
		{
			m_ExplorationO.m_OwnerE.SetKinematic( false );
			
			return true;
		}
		
		m_ToFallB	= true;
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledSlidingOnSlopeIK( false );
		
		if( m_LandTypeE == LT_KnockBack  )
		{
			m_ReadyToEndB	= true;
		}
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{
		m_ToFallB	= false;
		
		return true;
	}	
	
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		
		return m_ExplorationO.GetStateTimeF() < m_ExplorationO.m_SharedDataO.m_SkipLandAnimTimeMaxF;
		
	}
	
	
	function ReactToSlide() : bool
	{
		
		if( m_LandTypeE == LT_Normal ||  m_LandTypeE == LT_Higher )
		{
			LogExplorationLandExit( GetStateName() + " SetReadyToChangeTo: slide, from ReactToSlide() function" );
			SetReadyToChangeTo( 'Slide' );
		}
		
		return true;
	}
	
	
	
	function OnBehGraphNodeExited()
	{
		LogExplorationLandExit( GetStateName() + " Behavior graph node exited itself" );
	}

	
	private function LogExplorationLandExit( text : string )
	{
		LogChannel( 'ExplorationState'			,GetStateName() + text );
		LogChannel( 'ExplorationStateLandExit'	, text );
	}
}