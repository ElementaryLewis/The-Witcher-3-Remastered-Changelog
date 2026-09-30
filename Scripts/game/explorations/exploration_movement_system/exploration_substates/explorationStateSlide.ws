/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function LogSlidingTerrain( text : string )
{
	LogChannel('SlideTerrain', text );
}


enum ESlidingSubState
{
	SSS_Entering	= 0,
	SSS_Sliding		= 1,
	SSS_HardSliding	= 2,
	SSS_Exiting		= 3,
	SSS_Exited		= 4,
}


enum ESlideCameraShakeState
{
	SCSS_None	,
	SCSS_Soft	,
	SCSS_Hard	,
}


struct SSlidingMaterialPresetParams
{
	editable	var presetName				: name;
	
	editable	var angleMin				: float;		default	angleMin				= 55.0f;
	editable	var angleMinRain			: float;		default	angleMinRain			= 50.0f;
	editable	var frictionMultiplier		: float;		default	frictionMultiplier		= 1.0f;
	editable	var frictionMultiplierRain	: float;		default	frictionMultiplierRain	= 0.8f;
}


struct SSlidingMaterialNamesToPresets
{
	editable	var materialName			: name;
	editable	var presetName				: name;
}



class CExplorationStateSlide extends CExplorationStateAbstract
{	
	protected			var	subState				: ESlidingSubState;
	private	editable	var	enableWallSlide			: bool;						default	enableWallSlide			= false;
	
	
	protected editable	var	useSmothedCoefOnIdle	: bool;						default	useSmothedCoefOnIdle	= false;
	protected editable	var	angleMinDefault			: float;					default	angleMinDefault			= 70.0f;
	protected editable	var	anglefMax				: float;					default	anglefMax				= 80.0f;
	protected editable	var	coefExtraToStop			: float;					default	coefExtraToStop			= 0.2f;
	
	
	protected editable	var	slideCoefRelatedToInput	: bool;						default	slideCoefRelatedToInput	= false;
	protected editable	var	dotToStartForward		: float;					default	dotToStartForward		= 0.5f;
	protected editable	var	coefToStartBackward		: float;					default	coefToStartBackward		= 0.35f;
	protected editable	var	coefToStartCenter		: float;					default	coefToStartCenter		= 0.25f;
	protected editable	var	coefToStartForward		: float;					default	coefToStartForward		= 0.0f;
	
	
	protected editable	var	useWideTerrainCheckToEnter	: bool;					default	useWideTerrainCheckToEnter	= true;
	
	
	
	
	protected 			var	updateMaterials			: bool;
	protected editable	var	materialParams			: array<SSlidingMaterialPresetParams>;
	protected editable	var	materialNamesToPresets	: array<SSlidingMaterialNamesToPresets>;
	protected editable	var	materialParamsDefaultN	: name;						default	materialParamsDefaultN	= 'Default';
	protected 			var	materialDefault			: int;
	protected 			var	materialCurId			: int;
	protected			var	materialNameCur			: name;
	
	
	protected editable	var	minTimeToIdle			: float;					default	minTimeToIdle			= 0.3f;
	protected editable	var	orientingInitial		: float;					default	orientingInitial		= 200.0f;
	protected editable	var	initialImpulse			: float;					default	initialImpulse			= 1.0f;
	protected			var startedFromJump			: bool;
	protected			var startedFromRoll			: bool;
	
	
	protected editable	var	orientingSpeedMin		: float;					default	orientingSpeedMin		= 300.0f;
	protected editable	var	orientingSpeedMax		: float;					default	orientingSpeedMax		= 900.0f;
	protected editable	var	orientingMaxSlope		: float;					default	orientingMaxSlope		= 0.7f;
	
	
	protected editable	var timeToHardSlide			: float;					default	timeToHardSlide			= 0.2f;
	protected editable	var behGraphEventSlideHard	: name;						default	behGraphEventSlideHard	= 'SlideHard';
	
	
	protected editable	var	requireSpeedToExit 		: bool;						default	requireSpeedToExit		= true;
	protected editable	var	speedToExitForward		: float;					default	speedToExitForward		= 7.0f;
	protected editable	var	speedToExitCenter		: float;					default	speedToExitCenter		= 15.0f;
	protected editable	var	speedToExitBackward		: float;					default	speedToExitBackward		= 20.0f;
	
	protected editable	var exitingTimeMinSoft		: float;					default	exitingTimeMinSoft		= 0.2f;
	protected 			var	exitingTimeCur			: float;
	protected editable	var	exitingTimeTotal		: float;					default	exitingTimeTotal		= 2.0f;
	protected editable	var	exitingTimeTotalInput	: float;					default	exitingTimeTotalInput	= 0.5f;
	private				var	stoppingFriction		: bool;
	
	
	protected editable	var	cooldownMax				: float;					default	cooldownMax				= 0.1f;
	protected 			var	cooldownCur				: float;
	
	
	protected			var landCoolingDown			: bool;
	protected editable	var	landCoolDownTime		: float;					default	landCoolDownTime		= 0.7f;
	
	
	protected editable	var fromJumpBehGraphEvent	: name;						default	fromJumpBehGraphEvent	= 'Slide_From_Jump';
	protected editable	var fromRollBehGraphEvent	: name;						default	fromRollBehGraphEvent	= 'Slide_From_Roll';
	protected editable	var	jumpAllowed				: bool;						default	jumpAllowed				= true;
	protected editable	var	jumpCoolDownTime		: float;					default	jumpCoolDownTime		= 0.3f;
	
	
	
	protected editable	var	fallSpeedMaxConsidered	: float;					default	fallSpeedMaxConsidered	= 10.0f;
	protected editable	var	fallSpeedCoef			: float;					default	fallSpeedCoef			= 0.6f;
	protected editable	var	fallHorizImpulse		: float;					default	fallHorizImpulse		= 2.0f;
	protected editable	var	fallHorizImpulseCancel	: float;					default	fallHorizImpulseCancel	= 1.0f;
	protected editable	var	fallExtraVertImpulse	: float;					default	fallExtraVertImpulse	= -2.0f;
	
	
	protected editable	var	slidingPhysicsSpeed		: float;					default	slidingPhysicsSpeed		= 26.0f;
	protected editable	var	movementParams			: SSlidingMovementParams;
	protected editable	var	movementStoppingParams	: SSlidingMovementParams;
	
	protected editable	var	usePhysics				: bool;						default usePhysics				= false;
	
	
	protected			var slideDirectionDamped	: Vector;
	
	protected editable	var	smoothedDirBlendCoef	: float;					default smoothedDirBlendCoef	= 1.1f;	
	
	
	private	  editable	var	slideKills				: bool;						default	slideKills				= false;
	private				var	m_DeadB					: bool;
	protected editable	var	toFallEnabled			: bool;						default toFallEnabled			= true;
	protected 			var	toFallTimeCur			: float;
	protected editable	var	toConsiderFallTimeTotal	: float;					default	toConsiderFallTimeTotal	= 1.5f;
	protected editable	var	toFallTimeTotal			: float;					default	toFallTimeTotal			= 1.5f;
	protected editable	var	toFallSlopeCoefMin		: float;					default toFallSlopeCoefMin		= 0.25f;
	protected editable	var	toFallSlopeSpeedMin		: float;					default toFallSlopeSpeedMin		= 0.1f;
	protected editable	var	toFallSlopeCoef			: float;					default toFallSlopeCoef			= 2.25f;
	protected editable	var	toFallSpeedCoef			: float;					default toFallSpeedCoef			= 0.25f;
	protected editable	var	toFallRecoverCoef		: float;					default toFallRecoverCoef		= 0.5f;
	protected editable	var	toFallCameraLevel		: int;
	private				var	cameraShakeState		: ESlideCameraShakeState;
	protected editable	var	cameraAnimName			: name;						default	cameraAnimName			= 'camera_shake_loop_lvl1_1';
	protected editable	var behTripToDeath			: name;						default	behTripToDeath			= 'TripToDeath';
	
	
	protected editable	var	behHeightVar			: name;						default	behHeightVar			= 'Slide_Height';
	protected editable	var	behInclinationVar		: name;						default	behInclinationVar		= 'Slide_Inclination';
	protected editable	var	behTurnVar				: name;						default	behTurnVar				= 'Slide_Turn';
	protected editable	var	behAccelVar				: name;						default	behAccelVar				= 'Slide_Accel';
	protected editable	var	behRightFootForwardVar	: name;						default	behRightFootForwardVar	= 'Slide_RightFootForward';
	protected editable	var	inclinationBlendSpeed	: float;					default	inclinationBlendSpeed	= 40.0f;
	protected editable	var	inclinationStart		: float;					default	inclinationStart		= 45.0f;
	protected editable	var	turnInclinationMax		: float;					default	turnInclinationMax		= 12.0f;
	protected editable	var	turnInclinationBlend	: float;					default	turnInclinationBlend	= 5.0f;
	protected editable	var	turnInclinationCur		: float;
	protected editable	var	inclinationEnterTimeMax	: float;					default	inclinationEnterTimeMax	= 0.5f;
	protected 			var	inclinationEnterTimeCur	: float;
	
	protected 			var	inclination				: float;
	protected editable	var	behForwardVar			: name;						default	behForwardVar			= 'Slide_Forward';
	protected editable	var	behSlideRestart			: name;						default	behSlideRestart			= 'Slide_Restart';
	protected editable	var	behSlideEnd				: name;						default	behSlideEnd				= 'Slide_End';
	protected editable	var	behSlideEndRun			: name;						default	behSlideEndRun			= 'Slide_ToRun';
	protected editable	var	behSlideEndIdle			: name;						default	behSlideEndIdle			= 'Slide_ToIdle';
	protected editable	var	boneToStickName			: name;						default	boneToStickName			= 'l_hand';
	protected 			var	boneToStickId			: int;
	
	protected editable	var animEventHardSliding	: name;						default animEventHardSliding	= 'Slide_HardIsReady';
	protected			var lockedOnHardSliding		: bool;
	
	
	protected editable	var	particlesEnabled			: bool;					default	particlesEnabled		= false;
	protected editable	var particlesName				: name;					default particlesName			= 'fx_steps_other';
	protected editable	var boneLeftFoot 				: name;					default boneLeftFoot			= 'l_foot';
	protected editable	var boneRightFoot 				: name;					default boneRightFoot			= 'r_foot';
	protected 			var timeToRespawnParticlesCur	: float;
	protected editable	var timeToRespawnParticlesMax	: float;				default	timeToRespawnParticlesMax	= 0.2f;
	
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		var angleMin		: float;
		var i				: int;
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Slide';
		}
		
		SetCanSave( false );
		
		
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		
		updateMaterials		= m_ExplorationO.m_MoverO.m_UseMaterialsB;
		
		if( updateMaterials )
		{
			GrabOrCreateDefaultMaterialParams();
			
			materialCurId	= materialDefault;
			
			
			
			
			angleMin			= 90.0f;
			
			
			for ( i = 0; i < materialParams.Size(); i += 1 )
			{
				if( angleMin > materialParams[i].angleMin )
				{
					angleMin = materialParams[i].angleMin;
				}
				if( angleMin > materialParams[i].angleMinRain )
				{
					angleMin = materialParams[i].angleMinRain;
				}
			}
			
			m_ExplorationO.m_SharedDataO.terrainSlidePresetName	= materialParamsDefaultN;
		}
		
		m_ExplorationO.m_MoverO.SetSlidingLimits( angleMin, anglefMax );
		
		
		m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
		m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMin, materialParams[materialCurId].frictionMultiplier );
		
		
		
		boneToStickId	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneToStickName );
		
		
		m_StateTypeE			= EST_Idle;
		m_InputContextE			= EGCI_JumpClimb; 		
		m_UpdatesWhileInactiveB	= true;
		
		
		toFallTimeCur		= 0.0f;
	}
	
	
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_Signs );
		AddActionToBlock( EIAB_Fists );
		AddActionToBlock( EIAB_SwordAttack );
		AddActionToBlock( EIAB_Parry );
		AddActionToBlock( EIAB_Counter );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		
		if( enableWallSlide )
		{
			AddStateToTheDefaultChangeList('WallSlide', -1.0f );
		}
		
		
		
	}

	
	function StateWantsToEnter() : bool
	{			
		if( !WantsToEnterBasic() )
		{
			return false;
		}
		
		
		if( useWideTerrainCheckToEnter )
		{
			if( !WantsToEnterWide() )
			{
				return false;
			}
		}
		
		return true;		
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !thePlayer.IsActionAllowed( EIAB_Slide ) )
		{
			return false;
		}
		
		if( !m_ExplorationO.IsOnGround() )
		{
			return false;
		}
		
		return cooldownCur <= 0.0f;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		var velocity			: Vector;
		var slideDir			: Vector;
		var slideNormal			: Vector;
		var slidingDirDot		: float;
		var slidingForward		: bool;
		var isRightFootForward	: bool;
		
		
		m_DeadB		= false;
		
		
		startedFromJump	= prevStateName == 'Jump' && m_ExplorationO.GetStateTimeF() >= m_ExplorationO.m_SharedDataO.m_SkipLandAnimTimeMaxF;
		startedFromRoll	= prevStateName	== 'Roll';
		
		
		if( startedFromJump || prevStateName == 'WallSlide' )
		{
			CheckLandingDamage();
		}
		
		
		landCoolingDown	= prevStateName	== 'Land' || prevStateName	== 'Jump';
		
		
		
		m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( false );	
		
		SetTerrainParameters(); 		
		
		m_ExplorationO.m_OwnerMAC.SetSliding( usePhysics );
		m_ExplorationO.m_OwnerMAC.SetSlidingSpeed( slidingPhysicsSpeed );
		
		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slideDir, slideNormal );
		velocity		= m_ExplorationO.m_MoverO.GetMovementVelocity();		
		velocity		-= slideNormal * VecDot( slideNormal, velocity );
		velocity		+= slideDir * initialImpulse;
		m_ExplorationO.m_MoverO.SetVelocity( velocity );
		
		
		
		slideDirectionDamped	= slideDir;
		
		
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= slideDir;
		
		
		inclination				=  m_ExplorationO.m_MoverO.GetRealSlideAngle( ); 
		inclinationEnterTimeCur	= inclinationEnterTimeMax;
		turnInclinationCur		= 0.0f;
		
		
		slidingDirDot	= VecDot( slideDir, m_ExplorationO.m_OwnerE.GetWorldForward() );
		slidingForward	= slidingDirDot >= 0.0f;
		m_ExplorationO.SetBehaviorParamBool( behForwardVar, slidingForward );
		
		
		if( slidingForward )
		{
			isRightFootForward	= !m_ExplorationO.m_MoverO.IsRightFootForwardTowardsDir( slideDir );
		}
		
		
		else
		{
			isRightFootForward	= VecDot( slideDir, m_ExplorationO.m_OwnerE.GetWorldRight() ) < 0.0f;
		}
		m_ExplorationO.SetBehaviorParamBool( behRightFootForwardVar, isRightFootForward );
		
		
		BlockActions();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false ); 
		
		
		
		
		if( particlesEnabled )
		{
			thePlayer.PlayEffectOnBone( particlesName, boneLeftFoot );
			thePlayer.PlayEffectOnBone( particlesName, boneRightFoot );
			timeToRespawnParticlesCur	= timeToRespawnParticlesMax;
		}
		
		
		toFallCameraLevel	= 0;
		cameraShakeState = SCSS_None;
		
		
		if( startedFromJump || startedFromRoll )
		{
			subState			= SSS_HardSliding;
			lockedOnHardSliding	= true;
		}
		else
		{
			subState			= SSS_Entering;
			lockedOnHardSliding	= false;
		}
		exitingTimeCur		= 0.0f;		
		
		
		thePlayer.AbortSign();	
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( animEventHardSliding,	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( 'DisableFeetIK',		'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( m_DeadB )
		{
			return GetStateName();
		}
		
		
		if( jumpAllowed && m_ExplorationO.GetStateTimeF() >= jumpCoolDownTime )
		{
			
			if( !thePlayer.IsCombatMusicEnabled() )
			{
				if( m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) )
				{
					return 'Jump';
				}
				else if( m_ExplorationO.StateWantsAndCanEnter( 'Climb' ) )
				{
					return 'Climb';
				}
			}
		}
		
		
		if( subState >= SSS_Exited )
		{
			return 'Idle';
		}
		
		
		if( !lockedOnHardSliding && m_ExplorationO.GetStateTimeF() > exitingTimeMinSoft )
		{		
			if( StateWantsToExit() )
			{
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		var slideDirection		: Vector;
		var slideNormal			: Vector;
		var slideCoef			: float;
		var targetYaw			: float;
		var finalOrientingSpeed	: float;
		var newInclination		: float;
		var turn				: float;
		var accel				: float;
		
		
		if( m_DeadB )
		{
			return;
		}
		
		
		SubstateChangePrecheck( _Dt );
		
		
		slideCoef		= m_ExplorationO.m_MoverO.GetSlideCoef( true );		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slideDirection, slideNormal );
		
		
		
		
		
		UpdateForcedDirection( slideDirection );		
		
		
		finalOrientingSpeed	= ComputeOrientingSpeed( slideCoef );
		if( slideCoef > 0.0f )
		{			
			targetYaw	= VecHeading( slideDirection );
			
			
		}
		else
		{
			if( m_ExplorationO.m_MoverO.GetMovementSpeedF() > 1.0f )
			{
				targetYaw		= m_ExplorationO.m_MoverO.GetMovementSpeedHeadingF(); 
				
				
			}
			else
			{
				targetYaw		= m_ExplorationO.m_OwnerE.GetHeading();
			}
		}	
		
		
		if( !usePhysics && subState	!= SSS_Exited )
		{
			
			stoppingFriction	= subState == SSS_Exiting || !WantsToEnterBasic( true );
			
			m_ExplorationO.m_MoverO.UpdateSlidingInertialMovementWithInput( _Dt, turn, accel, stoppingFriction, targetYaw, finalOrientingSpeed );
		}
		
		
		UpdateAngleToRotateToAdaptToSlope( slideDirection, _Dt );
		
		
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( m_ExplorationO.GetStateTimeF() > toConsiderFallTimeTotal );	
		
		
		if( slideKills )
		{
			UpdateFallCoef( _Dt );
		}
		
		
		if( particlesEnabled && timeToRespawnParticlesMax > 0.0f )
		{
			timeToRespawnParticlesCur	-= _Dt;		
			if( timeToRespawnParticlesCur <= 0.0f )
			{
				
				thePlayer.PlayEffectOnBone( particlesName, boneLeftFoot );
				thePlayer.PlayEffectOnBone( particlesName, boneRightFoot );
				timeToRespawnParticlesCur	= timeToRespawnParticlesMax;
			}
		}
		
		
		turn				*= turnInclinationMax;
		turnInclinationCur	= BlendF( turnInclinationCur, turn, turnInclinationBlend * _Dt );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behTurnVar, turnInclinationCur );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behAccelVar, accel );		
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		
		theGame.GetGamerProfile().SetStat(ES_SlideTime, FloorF(m_ExplorationO.GetStateTimeF()) );
	
		m_ExplorationO.m_OwnerMAC.SetSliding( false );
		
		if( nextStateName == 'Idle' )
		{
			
			LogExploration("Left slide to Idle" );
			if( exitingTimeCur < exitingTimeTotal )
			{
				m_ExplorationO.SendAnimEvent( behSlideEndRun );
			}
			else
			{
				m_ExplorationO.SendAnimEvent( behSlideEndIdle );
			}
		}
		else if( nextStateName == 'CombatExploration' )
		{
			LogExploration("Left slide to Combat" );
			if( exitingTimeCur < exitingTimeTotal )
			{
				m_ExplorationO.SendAnimEvent( behSlideEndRun );
			}
			else
			{
				m_ExplorationO.SendAnimEvent( behSlideEndIdle );
			}
		}
		
		thePlayer.SetBIsCombatActionAllowed( true );
		
		
		if( m_ExplorationO.m_MoverO.GetMovementSpeedF() > 5.0f )
		{
			thePlayer.SetIsSprinting( true );
			m_ExplorationO.m_OwnerMAC.SetGameplayRelativeMoveSpeed( 2.0f );
		}
		
		
		cooldownCur = cooldownMax;
		
		
		subState	= SSS_Entering;
		
		
		
		
		
		if( particlesEnabled )
		{
			thePlayer.StopEffect( particlesName );
			
		}
		
		
		StopCameraAnim();
		
		
		if( nextStateName == 'StartFalling' )
		{
			PrepareFallFromSlide();
		}
		
		
		if( nextStateName != 'StartFalling' )
		{
			thePlayer.GoToCombatIfWanted();
		}
	}
	
	
	private function PrepareFallFromSlide()
	{
		var macVelocity	: Vector;
		var impulse		: Vector;
		
		
		impulse			= m_ExplorationO.m_OwnerE.GetWorldForward();
		impulse.Z		= 0.0f;
		
		
		
		
		if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			impulse *= fallHorizImpulseCancel;
		}
		
		if( VecDot( impulse, m_ExplorationO.m_InputO.GetMovementOnPlaneV() ) < 0.0f )
		{
			impulse *= fallHorizImpulseCancel;
		}
		
		else
		{
			impulse	*= fallHorizImpulse;
		}
		
		
		macVelocity		= m_ExplorationO.m_OwnerMAC.GetVelocity();
		macVelocity.Z	= 0.0f;	
		
		if( VecLengthSquared( macVelocity ) > fallSpeedMaxConsidered * fallSpeedMaxConsidered )
		{
			macVelocity	= VecNormalize( macVelocity ) * fallSpeedMaxConsidered;
		}
		
		
		impulse			+= macVelocity * fallSpeedCoef;
		
		
		m_ExplorationO.m_MoverO.SetVelocity( impulse );
		
		
		
		m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( animEventHardSliding );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( 'DisableFeetIK' );
	}
	
	
	function StateUpdateInactive( _Dt : float )
	{
		var camera 	: CCustomCamera = theGame.GetGameCamera();
		var animation : SCameraAnimationDefinition;
		
		cooldownCur	-= _Dt;
		
		
		toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
	}
	
	
	function GetBehaviorEventName() : name
	{
		if( startedFromJump )
		{
			return fromJumpBehGraphEvent;
		}
		else if( startedFromRoll )
		{
			return fromRollBehGraphEvent;
		}
		return m_BehaviorEventN;
	}
	
	
	
	function GetBehaviorIsEventForced( fromState : name ) : bool
	{
		return true;
	}
	
	
	public function GetDebugText() : string
	{
		var text	: string;
		
		
		switch( subState )
		{
			case SSS_Entering:
				text	=  "Entering";
			break;
			case SSS_Sliding:	
				text	=  "Soft Sliding";	
			break;
			case SSS_HardSliding:
				text	=  "Hard Sliding";
			break;
			case SSS_Exiting:
				text	=  "Exiting";	
			break;
			case SSS_Exited:	
				text	=  "Exited";
			break;
			default:
				text	=  "Unknown substate";
		}
		
		text	+= ".  StoppingFriction: " + stoppingFriction;
		
		return text;
	}
	
	
	private function GrabOrCreateDefaultMaterialParams()
	{
		var defaultMaterial	: SSlidingMaterialPresetParams;
		var index	: int;
		
		materialDefault	= -1;
		index = FindPresetByName( materialParamsDefaultN );
		if( index >= 0 )
		{
			materialDefault	= index;
			LogSlidingTerrain( "found default sliding terrain parameters in the array" );
		}
		
		else
		{
			LogSlidingTerrain( "NOT found default sliding terrain parameters in the array, creating defaults" );
			defaultMaterial.presetName				= materialParamsDefaultN;
			defaultMaterial.angleMin				= angleMinDefault;
			defaultMaterial.angleMinRain			= angleMinDefault;
			defaultMaterial.frictionMultiplier		= 1.0f;
			defaultMaterial.frictionMultiplierRain	= 1.0f;
			
			
			materialParams.PushBack( defaultMaterial );
			materialDefault	= materialParams.Size() - 1;
		}
	}
	
	
	private function WantsToEnterBasic( optional checkingForExit : bool ) : bool
	{
		var dot				: float;
		var coef			: float;
		var result			: bool;
		
		
		
		if( useSmothedCoefOnIdle && ( m_ExplorationO.GetStateCur() == 'Idle' || m_ExplorationO.GetStateCur() == 'CombatExploration' ) )
		{
			if( !m_ExplorationO.m_OwnerMAC.IsSliding() )
			{ 
				return false;
			}
		}
		
		
		SetTerrainParameters();
		
		
		if( checkingForExit )
		{
			coef = m_ExplorationO.m_MoverO.GetSlideCoef( true, coefExtraToStop );
		}
		else
		{
			coef = m_ExplorationO.m_MoverO.GetSlideCoef( true );
		}
		
		
		if( coef <= 0.0f )
		{
			return false;
		}
		
		
		
		
		if( coef < coefToStartBackward )
		{
			if( m_ExplorationO.GetStateCur() == 'Land' )
			{
				return false;
			}
		}		
		
		
		dot = m_ExplorationO.m_InputO.GetInputDirOnSlopeDot();
		if( slideCoefRelatedToInput )
		{
			if( dot <= -dotToStartForward )
			{
				result	=  coef >= coefToStartBackward;
			}
			else if( dot >= dotToStartForward )
			{
				result	= coef >= coefToStartForward;
			}
			else
			{
				result	= coef >= coefToStartCenter;
			}
		}
		else
		{		
			if( dot >= dotToStartForward )
			{
				result	= coef >= coefToStartForward;
			}
			else
			{
				result	=  coef >= coefToStartBackward;
			}
		}
		
		if( !result )
		{
			return false;
		}
		
		return true;
	}
	
	
	function WantsToEnterWide() : bool
	{
		var coefWideAverage	: float;
		var coefWideGlobal	: float;
		
		
		coefWideGlobal	= m_ExplorationO.m_MoverO.GetSlideWideCoefFromTerrain( false );
		if( coefWideGlobal == 0.0f || coefWideGlobal < coefToStartForward )
		{
			return false;
		}
		
		coefWideAverage	= m_ExplorationO.m_MoverO.GetSlideWideCoefFromTerrain( true );
		if( coefWideAverage == 0.0f || coefWideAverage < coefToStartForward )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function StateWantsToExit() : bool
	{
		if( requireSpeedToExit )
		{
			if( !SpeedAllowsExit() )
			{
				return false;
			}
		}
		
		
		if( WantsToEnterBasic( true ) )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function SpeedAllowsExit() : bool
	{
		var dot			: float;
		var speed		: float;
		var slowEnough	: bool;
		
		
		
		speed	= m_ExplorationO.m_MoverO.GetMovementSpeedF();
		dot 	= m_ExplorationO.m_InputO.GetInputDirOnSlopeDot();		
		if( dot <= -dotToStartForward )
		{
			slowEnough	=  speed < speedToExitBackward;
		}
		else if( dot >= dotToStartForward )
		{
			slowEnough	= speed < speedToExitForward;
		}
		else
		{
			slowEnough	= speed < speedToExitCenter;
		}
		
		if( !slowEnough )
		{
			return false;
		}
		
		return true;
	}
	
	
	
	private function UpdateFallCoef( _Dt : float )
	{
		var speed			: float;
		var	slideCoef		: float;
		var	isGoingToFall	: bool		= false;
		
		
		if( !toFallEnabled || m_DeadB )
		{
			return;
		}
		
		
		speed		= VecLength( m_ExplorationO.m_MoverO.GetDisplacementLastFrame() ) / _Dt;
		speed		= ClampF( speed / m_ExplorationO.m_MoverO.GetSlideSpeedMax(), 0.0f, 1.0f );
		slideCoef	= m_ExplorationO.m_MoverO.GetRawSlideCoef( true );	
		if( subState == SSS_Exiting )
		{
			toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
		}
		else
		{
			if( slideCoef >= toFallSlopeCoefMin && speed >= toFallSlopeSpeedMin && m_ExplorationO.GetStateTimeF() > toConsiderFallTimeTotal )
			{	
				toFallTimeCur	+= _Dt;
				isGoingToFall	= true;
				ApplySlideDamage( _Dt );
				
			}
			else
			{
				toFallTimeCur	= MaxF( 0.0f, toFallTimeCur - toFallRecoverCoef * _Dt );
			}
		}
		
		
		if( toFallTimeCur >= toFallTimeTotal )
		{
			
			
			
		}
		
		
		m_ExplorationO.m_MoverO.SetSlideSpeedMode( isGoingToFall );	
		
		
		
		SetProperCameraAnim( slideCoef >= toFallSlopeCoefMin );
	}
	
	
	private function ApplySlideDamage( _Dt : float )
	{
		var action			: W3DamageAction;
		
		var damageValue		: float;
		
		
		action = new W3DamageAction in this;
		action.Initialize(NULL, thePlayer, NULL, "SlidingDamage", EHRT_None, CPS_Undefined, false, false, false, true);
		action.SetCanPlayHitParticle(false);
		damageValue	= toFallTimeCur / toFallTimeTotal * thePlayer.GetMaxHealth() * _Dt;
		action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, damageValue );
		
		theGame.damageMgr.ProcessAction( action );
		
		delete action;
	}
	
	
	private function SetProperCameraAnim( increasing : bool )
	{
		var camera 		: CCustomCamera = theGame.GetGameCamera();
		var animation	: SCameraAnimationDefinition;
		var newState	: ESlideCameraShakeState;
		
		
		
		 if( toFallTimeCur > 0.0f )
		{
			
			newState = SCSS_Hard;
		}
		else
		{
			newState = SCSS_None;
		}
		
		
		if( cameraShakeState == newState )
		{
			return;
		}
		
		cameraShakeState	= newState;
		switch( cameraShakeState )
		{
			case SCSS_Hard:
				animation.weight = 4.0f ;
				break;
			case SCSS_Soft:
				StopCameraAnim();
				animation.weight = 1.2f;
				break;
			case SCSS_None:
				StopCameraAnim();
				return;
				break;
		}
		animation.animation = cameraAnimName;
		animation.priority = CAP_High;
		animation.blendIn = 0.1f;
		animation.blendOut = 0.1f;
		animation.speed = 3.0f;
		animation.additive = true;
		animation.reset = false;
		animation.loop = true;
		
		camera.PlayAnimation( animation );
	}
	
	
	private function StopCameraAnim()
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		
		camera.StopAnimation( cameraAnimName );
	}
	
	
	protected  function CheckLandingDamage()
	{
		var fallDiff		: float;
		var jumpTotalDiff	: float;
		var damagePerc		: float;
		
		
		
		m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
		
		
		
		damagePerc		= m_ExplorationO.m_OwnerE.ApplyFallingDamage( fallDiff, true );
		
		
		
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();
		
		
		
		if( damagePerc >= 1.0f )
		{
			m_ExplorationO.m_SharedDataO.GoToRagdoll();
		}
		
		
		LogExploration( "Landed height difference " + jumpTotalDiff );
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
	}
 
	
	private function SetTerrainParameters()
	{
		var	newMaterial			: name;
		var isItRaining			: bool;
		
		
		if( !updateMaterials )
		{
			return;
		}
		
		
		newMaterial		= m_ExplorationO.m_OwnerMAC.GetMaterialName();
		
		
		if( newMaterial == 'None' )
		{
			LogSlidingTerrain( "!!!! Error: No material found" );
			return;
		}
		
		
		if( newMaterial	== materialNameCur	)
		{
			return;
		}
		
		materialNameCur	= newMaterial;
		
		LogSlidingTerrain( "Ground material changed: " + materialNameCur );
		
		
		
		materialCurId	= FindMaterialId( materialNameCur );
		
		
		m_ExplorationO.m_SharedDataO.terrainSlidePresetName	= materialParams[materialCurId].presetName;
		
		
		
		
		if( isItRaining )
		{
			m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMin, materialParams[materialCurId].frictionMultiplier );
		}
		else
		{
			m_ExplorationO.m_MoverO.SetSlidingMaterialParams( materialParams[materialCurId].angleMinRain, materialParams[materialCurId].frictionMultiplierRain );
		}		
	}
	
	
	private function FindMaterialId( materialName : name ) : int
	{
		var presetName		: name;
		var maxCount		: int;
		var i				: int;
		
		
		maxCount	= materialNamesToPresets.Size();
		for ( i = 0; i < maxCount; i += 1 )
		{
			if( materialName == materialNamesToPresets[i].materialName )
			{
				presetName	= materialNamesToPresets[i].presetName;
				LogSlidingTerrain( "Material preset corresponding to name " + materialName + " found, named " + presetName );
				break;
			}
		}
		
		if( i >= maxCount )
		{
			LogSlidingTerrain( "Material preset corresponding to this material name ( " + materialName + " ) name not found, using default preset" );
			return materialDefault;
		}
		
		
		return FindPresetByName( presetName );
	}
	
	
	private function FindPresetByName( presetName : name ) : int
	{
		var maxCount		: int;
		var i				: int;
		
		
		maxCount	= materialParams.Size();
		for ( i = 0; i < maxCount; i += 1 )
		{
			if( presetName == materialParams[i].presetName )
			{
				LogSlidingTerrain( "Material presset " + presetName + " found" );
				return i;
			}
		}
		
		LogSlidingTerrain( "!!!ERROR: The preset name " + presetName + " does not exist in the array materialParams" );
		
		return materialDefault;
	}
	
	
	private function UpdateForcedDirection( slideDir : Vector)
	{	
		var jumpDirection	: Vector;
		
		
		switch( subState )
		{
			case SSS_Entering:
				jumpDirection		= slideDir;
			break;
			case SSS_Sliding:		
			case SSS_HardSliding:
				jumpDirection		= m_ExplorationO.m_MoverO.GetMovementVelocityNormalized();
			break;
			case SSS_Exiting:	
			case SSS_Exited:	
				jumpDirection		= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
			break;
		}
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= jumpDirection;
	}
	
	
	private function ComputeOrientingSpeed( slideCoef : float ) : float
	{	
		var speed	: float;
		
		switch( subState )
		{
			case SSS_Entering:
				speed = orientingInitial;
			break;
			case SSS_Sliding:	
			case SSS_HardSliding:	
				speed =  MapF( slideCoef, 0.0f, orientingMaxSlope, orientingSpeedMin, orientingSpeedMax );
			break;
			case SSS_Exiting:	
				speed =  MapF( slideCoef, 0.0f, orientingMaxSlope, orientingSpeedMin, orientingSpeedMax );
			break;
			default :				
				LogExplorationError("Missing state in ComputeOrientingSpeed function in script explorationStateSlide.ws");
				speed = orientingInitial;
		}
		
		
		if( m_ExplorationO.m_InputO.IsSprintPressed() )
		{
			speed	*= 0.5f;
		}
		
		return speed;		
	}	
	
	
	private function SubstateChangePrecheck( _Dt : float )
	{	
		
		if( landCoolingDown )
		{
			
			if( StateWantsToExit() )
			{
				subState		= SSS_Exited;
				return;
			}
			if( m_ExplorationO.GetStateTimeF() >= landCoolDownTime )
			{
				landCoolingDown	= false;
			}
		}
		
		switch( subState )
		{
			case SSS_Entering:
				if( m_ExplorationO.GetStateTimeF() >= minTimeToIdle )
				{
					subState	= SSS_Sliding;
				}
				break;
			case SSS_Sliding:	
				if( m_ExplorationO.GetStateTimeF() >= timeToHardSlide )
				{
					subState			= SSS_HardSliding;
					lockedOnHardSliding	= true;
					m_ExplorationO.SendAnimEvent( behGraphEventSlideHard );
				}
				break;
			case SSS_HardSliding :
				if( StateWantsToExit() )
				{
					subState		= SSS_Exiting;
					m_ExplorationO.SendAnimEvent( behSlideEnd );
					exitingTimeCur	= 0.0f;
				}	
				break;
			case SSS_Exiting:
				if( WantsToEnterBasic() )
				{
					subState		= SSS_Sliding;
					m_ExplorationO.m_MoverO.SetSlidingParams( movementParams );
					m_ExplorationO.SendAnimEvent( behSlideRestart );
				}
				else
				{
					exitingTimeCur	+= _Dt;
					if( exitingTimeCur > 0.2f )
					{					
						m_ExplorationO.m_MoverO.SetSlidingParams( movementStoppingParams );
					}
					if( exitingTimeCur > exitingTimeTotalInput )
					{
						
						if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
						{
							subState	= SSS_Exited;
						}
						if( exitingTimeCur > exitingTimeTotal )
						{
							subState	= SSS_Exited;
						}
					}
				}
				break;
			case SSS_Exited:
				break;
		}
	}
	
	
	private function UpdateAngleToRotateToAdaptToSlope( slideDirection : Vector, _Dt : float )
	{
		var world 				: CWorld;
		var res 				: bool		= false;
		var bonePos				: Vector;
		var boneIdlePos			: Vector;
		var boneRayOrigin		: Vector;
		var boneRayEnd			: Vector;
		var slideNormal			: Vector;
		var pos					: Vector;
		var normal				: Vector;
		var boneDist			: float;
		var boneHeight			: float;
		
		var IKSucceeded			: bool		= false;
		var	newInclination		: float;
		
		
		
		if( true )
		{
			
			
			newInclination = m_ExplorationO.m_MoverO.GetRealSlideAngle( );
		}
		
		if( inclinationEnterTimeCur <= 0.0f )
		{
			inclination = BlendLinearF( inclination, newInclination, inclinationBlendSpeed * _Dt );
		}
		else
		{
			inclination = BlendLinearF( inclination, newInclination, 1.0f - inclinationEnterTimeCur / inclinationEnterTimeMax );
			inclinationEnterTimeCur	-= _Dt;
		}
		
		
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behInclinationVar, inclination );
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behHeightVar, 0.1f );
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName == animEventHardSliding )
		{
			lockedOnHardSliding	= true;
		}
		
		else if( animEventName == 'DisableFeetIK' )
		{
			
			
		}
	}
	
	
	
	
	
	
	private function UpdateCollisions()
	{
	}
	
	
	function ReactToLoseGround() : bool
	{
		if( subState > SSS_Entering )
		{
			SetReadyToChangeTo( 'StartFalling' );
		}
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{		
		return true;
	}	
	
	
	function ReactToSlide() : bool
	{
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		frame.DrawText( "Slide To Fall: " + toFallTimeCur * 100 + "%", m_ExplorationO.m_OwnerE.GetWorldPosition() + Vector( 0.0f, 0.0f, 1.3f ) , Color( 80, 200, 80 ) );
	}
}
