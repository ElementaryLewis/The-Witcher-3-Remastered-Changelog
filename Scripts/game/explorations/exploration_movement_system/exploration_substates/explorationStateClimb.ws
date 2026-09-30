/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EClimbRequirementType
{
	ECRT_Landed			= 0,
	ECRT_Jumping		= 1,
	ECRT_AirColliding	= 2,
	ECRT_Swimming		= 3,
	ECRT_Running		= 4,
}


enum EClimbRequirementVault
{
	ECRV_NoVault	= 0,
	ECRV_Vault		= 1,
}


enum EClimbRequirementPlatform
{
	ECRV_NoPlatform	= 0,
	ECRV_Platform	= 1,
}


enum EClimbHeightType
{
	ECHT_Step		= 0,
	ECHT_VerySmall	= 1,
	ECHT_Small		= 2,
	ECHT_Medium		= 3,
	ECHT_High		= 4,
	ECHT_VeryHigh	= 5,
}


enum EClimbDistanceType
{
	ECDT_Normal	= 0,
	ECDT_Close	= 1,
	ECDT_Far	= 2,
}


enum EClimbEndReady
{
	ECR_NotReady	= 0,
	ECR_Walk		= 1,
	ECR_Run			= 2,
	ECR_Fall		= 3,
	ECR_Idle		= 4,
}


enum EOutsideCapsuleState
{
	EOCS_Inactive		= 0,
	EOCS_Starting		= 1,
	EOCS_PerfectFollow	= 2,
	EOCS_Recover		= 3,
}



struct CClimbType
{		
	
	editable			var requiredState			: EClimbRequirementType;
	editable			var requiredVault			: EClimbRequirementVault;
	editable			var requiredPlatform		: EClimbRequirementPlatform;
	editable			var	type					: EClimbHeightType;				default	type				= ECHT_Medium;
	
	
	editable			var	heightUseDefaults		: bool;							default	heightUseDefaults	= true;
	editable			var	heightMax				: float;						default	heightMax			= 1.4f;
	editable			var	heightMin				: float;						default	heightMin			= 0.2f;
	editable			var heightExact				: float;						default	heightExact			= 1.0f; 
	
	
	editable			var forwardDistExact		: float;						default	forwardDistExact	= 0.4f;
	
	
	editable 			var	playCameraAnimation		: bool;							default	playCameraAnimation	= false;
	editable 			var	cameraAnimation			: name;
}



class CExplorationStateClimb extends CExplorationStateAbstract
{	
	public 						var	m_ClimbOracleO			: CExplorationClimbOracle;
	
	private editable			var	enabled					: bool;					default	enabled					= true;
	
	
	
	private editable inlined	var	climbTypes				: array< CClimbType >;
	private						var	climbCur				: CClimbType;
	private	editable inlined	var	heightMaxToRun			: float;
	private	editable inlined	var	platformHeightMinAir	: float;
	private	editable inlined	var	platformHeightMin		: float;
	
	
	private						var	climbPoint				: Vector;
	private						var	wallNormal				: Vector;
	private						var	heightTarget			: float;
	private						var	vaultingFound			: EClimbRequirementVault;
	private						var platformFound			: EClimbRequirementPlatform;
	private						var curPlayerStateType		: EClimbRequirementType;
	private						var	vaultEndsFalling		: bool;
	
	
	private						var	ended					: bool;
	private						var	canWalk					: bool;
	private						var	canRun					: bool;
	private						var	canFall					: bool;		
	editable					var animDurationLimit		: float;				default	animDurationLimit		= 5.0f;
	editable					var slideDistMaxOnRun		: float;				default	slideDistMaxOnRun		= 1.5f;
	
	
	private	editable			var	autoClimb				: bool;					default	autoClimb				= false;
	private	editable			var	autoClimbOnAir			: bool;					default	autoClimbOnAir			= false;
	private editable			var	inputAngleToEnter		: float;				default	inputAngleToEnter		= 180.0f;
	private editable			var	inputAngleToRun			: float;				default	inputAngleToRun			= 45.0f;
	private						var	inputAttemptsTop		: bool;
	private						var	inputDirection			: Vector;
	private editable			var	inputAirHold			: bool;					default	inputAirHold			= true;
	private editable			var	inputAirTimeGap			: bool;					default	inputAirTimeGap			= false;
	private editable			var	inputTimeGapCheck		: float;				default	inputTimeGapCheck		= 0.3f;
	
	
	private						var	characterRadius			: float;				default	characterRadius			= 0.4f;
	private						var	adjustInitiallRotat 	: float;
	private						var	adjustRotation			: float;
	private						var	adjustTranslation		: Vector;
	private						var adjustInitialRotDone	: bool;
	private						var adjustRotDone			: bool;
	private						var adjustTransDone			: bool;
	
	private						var adjustSpeedMax			: float;				default	adjustSpeedMax			= 12.0f;
	private						var adjustSpeedRequire		: bool;
	private						var adjustSpeedEndTime		: float;
	
	
	private						var adjust2Dduration		: float;
	private						var adjust2Speed			: float;
	private						var adjust2Translation		: Vector;
	
	private						var heightToAdd				: float;
	
	
	
	private						var	pelvisTransMax			: float;				default	pelvisTransMax			= 0.4f;
	private						var	pelvisTransAllow		: bool;					default	pelvisTransAllow		= true;
	private						var	pelvisTransState		: EOutsideCapsuleState;
	private						var	pelvisTranslationN		: name;					default	pelvisTranslationN		= 'ClimbMoveForward';
	private						var	pelvisTransCur			: float;
	private						var	pelvisTransTarget		: float;
	private						var	pelvisTransSpeed		: float;				default	pelvisTransSpeed		= 3.0f;
	private						var	pelvisTransSpeedOut		: float;				default	pelvisTransSpeedOut		= 10.0f;
	
	
	
	private editable			var	behAnimAdjustInitRot	: name;					default	behAnimAdjustInitRot	= 'ClimbInitialRotate';
	private editable			var	behAnimAdjustRot		: name;					default	behAnimAdjustRot		= 'ClimbStartRotate';
	private editable			var	behAnimAdjustTrans		: name;					default	behAnimAdjustTrans		= 'ClimbStartTranslate';
	private editable			var	behAnimEnded			: name;					default	behAnimEnded			= 'ClimbCanEnd';
	private editable			var	behAnimCanWalk			: name;					default	behAnimCanWalk			= 'ClimbCanWalk';
	private editable			var	behAnimCanRun			: name;					default	behAnimCanRun			= 'ClimbCanRun';
	private editable			var	behAnimCanFall			: name;					default	behAnimCanFall			= 'ClimbCanFall';
	
	private editable			var	behEnableIK				: name;					default	behEnableIK				= 'ClimbEnableIK';
	private editable			var	behDisablePelvisTrans	: name;					default	behDisablePelvisTrans	= 'ClimbDisablePelvisTrans';
	private editable			var	behEnableHandsIK		: name;					default	behEnableHandsIK		= 'ClimbEnableHandsIK';
	private editable			var	behEnableHandLIK		: name;					default	behEnableHandLIK		= 'ClimbEnableHandLIK';
	private editable			var	behEnableHandRIK		: name;					default	behEnableHandRIK		= 'ClimbEnableHandRIK';
	private editable			var	behDisableHandsIK		: name;					default	behDisableHandsIK		= 'ClimbDisableHandsIK';
	private editable			var	behDisableHandLIK		: name;					default	behDisableHandLIK		= 'ClimbDisableHandLIK';
	private editable			var	behDisableHandRIK		: name;					default	behDisableHandRIK		= 'ClimbDisableHandRIK';
	
	
	private editable			var	behHeightTypeEnum		: name;					default	behHeightTypeEnum		= 'ClimbHeightType';
	private editable			var	behVaultTypeEnum		: name;					default	behVaultTypeEnum		= 'ClimbVaultType';
	private editable			var	behPlatformTypeEnum		: name;					default	behPlatformTypeEnum		= 'ClimbPlatformType';
	private editable			var	behStateTypeEnum		: name;					default	behStateTypeEnum		= 'ClimbStateType';
	private editable			var	behGoToRun				: name;					default	behGoToRun				= 'ClimbToRun';
	private editable			var	behGoToWalk				: name;					default	behGoToWalk				= 'ClimbToWalk';
	private editable			var	behToRun				: name;					default	behToRun				= 'ClimbEndsRunning';
	private editable			var	behVarEnd				: name;					default	behVarEnd				= 'ClimbCanEndMode';
	private editable			var	behAnimSpeed			: name;					default	behAnimSpeed			= 'ClimbAnimSpeed';
	
	
	
	private	editable			var continousHandIK			: bool;					default	continousHandIK			= true;
	private editable			var	handIKMinDistToEnable	: float;				default	handIKMinDistToEnable	= 0.05f;
	private editable			var	handIKMaxDist			: float;				default	handIKMaxDist			= 0.3f;
	private editable			var	handIKForwardOffset		: float;				default	handIKForwardOffset		= 0.2f;
	private editable			var	handIKHalfMaxHeight		: float;				default	handIKHalfMaxHeight		= 1.0f;
	private editable			var	handIKBlendSpeedIn		: float;				default	handIKBlendSpeedIn		= 3.5f;
	private editable			var	handIKBlendSpeedOut		: float;				default	handIKBlendSpeedOut		= 1.5f;
	private editable			var	handThickness			: float;				default	handThickness			= 0.02;
	protected 					var	boneRightHand			: name;					default	boneRightHand			= 'r_hand';
	protected 					var	boneLeftHand			: name;					default	boneLeftHand			= 'l_hand';
	protected 					var	boneIndexRightHand		: int;
	protected 					var	boneIndexLeftHand		: int;
	
	protected 					var rightHandOffset			: float;
	protected 					var leftHandOffset			: float;
	protected 					var rightHandOffsetCur		: float;
	protected 					var leftHandOffsetCur		: float;
	
	protected 					var handIKEnabled			: bool;
	protected 					var handIKEnabledLeft		: bool;
	protected 					var handIKEnabledRight		: bool;
	protected 					var handIKqueuedL			: bool;
	protected 					var handIKqueuedR			: bool;
	
	private						var	handIKLRayOrigin		: Vector;
	private						var	handIKLRayEnd			: Vector;
	private						var	handIKLRayCollision		: Vector;
	private						var	handIKRRayOrigin		: Vector;
	private						var	handIKRRayEnd			: Vector;
	private						var	handIKRRayCollision		: Vector;
	
	private						var	collisionObstaclesNames	: array<name>;
	
	
	protected editable inlined	var	cameraSetVault			: CCameraParametersSet;		
	protected editable inlined	var	cameraSetJump			: CCameraParametersSet;		
	private editable			var	updateCameraManual		: bool;					default	updateCameraManual		= false;
	private editable			var	updateCameraAnim		: bool;					default	updateCameraAnim		= false;
	private						var	camOriginalPosition		: Vector;
	private						var	camOriginalRotation		: EulerAngles;
	private						var	camCurRotation			: EulerAngles;
	private						var	camOriginalOffset		: Vector;
	private						var	camStart				: bool;
	private						var	camFollowBoneID			: int;
	private	editable			var	camFollowBoneName		: name;					default	camFollowBoneName		= 'torso';
	
	
	
	private						var	vectorUp				: Vector;	
	
	
	private	editable			var	forceAirCollision		: bool;					default	forceAirCollision		= false;
	private	editable			var	forceJumpGrab			: bool;					default	forceJumpGrab			= false;
	private	editable			var	noAdjustor				: bool;					default	noAdjustor				= false;
	private	editable			var	noPelvisCorection		: bool;					default	noPelvisCorection		= false;
	
	
	private	saved				var restoreUsableItemLAtEnd : bool;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		var	heightTotalMin			: float;
		var	heightTotalMax			: float;
		
		
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Climb';
		}
		
		m_StateTypeE			= EST_OnAir;
		m_InputContextE			= EGCI_JumpClimb;
		m_UpdatesWhileInactiveB	= true;
		m_HolsterIsFastB		= true;
		
		
		LogExplorationClimb( "	Initialized Log channel: ExplorationStateClimb" );
		
		
		SetCanSave( false );
		
		
		
		if( climbTypes.Size() <= 0 )
		{
			LogExplorationError( "No climb data was found in state CExplorationStateClimb" );
			return;
		}
		InitClimbs();
		
		
		ComputeMinMaxHeight( heightTotalMin, heightTotalMax );
		
		
		if( !m_ClimbOracleO )
		{
			m_ClimbOracleO	= new CExplorationClimbOracle in this;
		}		
		m_ClimbOracleO.Initialize( m_ExplorationO, heightTotalMin, heightTotalMax, MinF( platformHeightMin, platformHeightMinAir ), characterRadius );
		
		
		
		boneIndexRightHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneRightHand );
		boneIndexLeftHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneLeftHand );
		camFollowBoneID		= m_ExplorationO.m_OwnerE.GetBoneIndex( camFollowBoneName );
		
		
		
		collisionObstaclesNames.PushBack( 'Terrain' );
		collisionObstaclesNames.PushBack( 'Static' );
		collisionObstaclesNames.PushBack( 'Platforms' );
		collisionObstaclesNames.PushBack( 'Fence' );
		collisionObstaclesNames.PushBack( 'Boat' );
		collisionObstaclesNames.PushBack( 'BoatDocking' );
		
		collisionObstaclesNames.PushBack( 'Foliage' );
		collisionObstaclesNames.PushBack( 'Dynamic' );
		collisionObstaclesNames.PushBack( 'Destructible' );
		collisionObstaclesNames.PushBack( 'RigidBody' );
		
		
		
		vectorUp	= Vector( 0.0f,0.0f, 1.0f );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}
	
	
	function StateWantsToEnter() : bool
	{		
		
		ComputeInput();
		
		
		curPlayerStateType								= FindPlayerState();
		m_ExplorationO.m_SharedDataO.m_ClimbStateTypeE	= curPlayerStateType;
		
		
		
		
		if( !OracleWantsToEnter() )
		{
			return false;
		}
		
		
		if( !PreRefineIsValid() )
		{
			return false;
		}
		
		
		RefinePlayerState();
		
		
		if( !FindApropriateClimb() )
		{
			return false;
		}	
		
		
		PostRefineState();	
		
		return true;
	}
	
	
	private function DebugEnterToClimb()
	{
		heightTarget		= 2.6f;
		vaultingFound		= ECRV_NoVault;
		vaultEndsFalling	= false;
		platformFound		= ECRV_NoPlatform;
		climbPoint			= m_ExplorationO.m_OwnerE.GetWorldPosition() + m_ExplorationO.m_OwnerE.GetWorldForward() * 1.0f + m_ExplorationO.m_OwnerE.GetWorldUp() * 2.6f;
		wallNormal			= -m_ExplorationO.m_OwnerE.GetWorldForward();
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		
		if( !InputWantsToEnter() )
		{
			return false;
		}
		
		if( !thePlayer.IsActionAllowed( EIAB_Climb ) || !thePlayer.IsActionAllowed( EIAB_Movement ) || !thePlayer.IsActionAllowed( EIAB_Jump ) )
		{
			return false;
		}
		
		if( thePlayer.IsInCombat() )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{		
		
		if( prevStateName == 'Swim' )
		{
			thePlayer.GotoState('Exploration');
		}
		
		
		
		
		
		
		SetInitialMovementAdjustor();
		
		
		m_ExplorationO.m_MoverO.SetManualMovement( true );
		
		
		thePlayer.RemoveTimer( 'DelayedSheathSword' );
		
		thePlayer.SetBehaviorVariable( 'inJumpState', 1.f );
		
		
		thePlayer.OnRangedForceHolster( true, true );
		
		
		pelvisTransCur		= 0.0f;
		pelvisTransState	= EOCS_Inactive;
		
		
		SetBehaviorData();
		
		
		camStart	= true;
		
		SetProperCameraAnim( true, 1.0f );
		
		
		if( m_ExplorationO.m_IsDebugModeB )
		{			
			DebugLogSuccesfullClimb();
		}
		
		
		canFall					= false;
		ended					= false;
		canWalk					= false;
		adjustInitialRotDone	= false;
		canRun					= false;
		
		adjustRotDone			= false;	
		adjustTransDone			= false;	
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
		
		leftHandOffset			= 0.0f;
		rightHandOffset			= 0.0f;
		rightHandOffsetCur		= 0.0f;
		leftHandOffsetCur		= 0.0f;
		handIKEnabled			= false;
		handIKEnabledLeft 		= false;
		handIKEnabledRight		= false;
		handIKqueuedL			= false;
		handIKqueuedR			= false;
		
		m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( leftHandOffsetCur, rightHandOffsetCur );
		
		adjust2Dduration		= 0.0f;	
		
		
		
		if ( thePlayer.IsHoldingItemInLHand() && !thePlayer.inv.ItemHasTag( thePlayer.GetSelectedItemId(), 'UI_Torch') )
		{		
			thePlayer.OnUseSelectedItem ( true );
			restoreUsableItemLAtEnd	= true;					
		}		
		
		
		thePlayer.AbortSign();
	}
	
	
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_DrawWeapon );
	}
	
	
	public function GetIfCameraIsKept() : bool
	{
		return false;
		
		
	}
	
	
	public function GetCameraSet( out cameraSet : CCameraParametersSet) : bool
	{
		if( ( curPlayerStateType == ECRT_Jumping || curPlayerStateType == ECRT_AirColliding ) && cameraSetJump )
		{
			
			cameraSet	= cameraSetJump;
			return true;
		}
		else if( vaultingFound == ECRV_Vault && cameraSetVault )
		{
			cameraSet	= cameraSetVault;
			return true;
		}
		return super.GetCameraSet( cameraSet );
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanFall, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimEnded, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanWalk, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimCanRun, 			'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustInitRot, 	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustRot, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimAdjustTrans, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisablePelvisTrans,	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableIK, 				'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandsIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandLIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandRIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandsIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandLIK, 		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandRIK, 		'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{		
		if( canFall )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Fall );
			if( vaultingFound == ECRV_Vault )
			{
				return 'Jump';
			}
			else
			{
				if( m_ExplorationO.IsOnGround() )
				{
					return 'Idle';
				}
				else
				{
					return 'StartFalling';
				}
			}
		}
		
		
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
		{			
			if( AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputAngleToRun )
			{
				if( canRun && thePlayer.GetIsRunning() ) 
				{
					if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						m_ExplorationO.SendAnimEvent( behGoToRun );
						m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Run );
						return 'Idle';
					}
				}
				else if( canWalk )
				{
					if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Walk );
						m_ExplorationO.SendAnimEvent( behGoToWalk );
						return 'Idle';
					}
				}
			}
			else if( ( canRun || canWalk ) && m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Idle );
				return 'Idle';				
			}
		}
		
		
		if( ended || m_ExplorationO.GetStateTimeF() > animDurationLimit ) 
		{
			if( vaultEndsFalling || !m_ExplorationO.m_CollisionManagerO.CheckLandBelow( 0.2f, Vector( 0.0f,0.0f, 0.0f ), true ) )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Fall );
				if( vaultingFound == ECRV_Vault )
				{
					return 'Jump';
				}
				else
				{
					return 'StartFalling';
				}
			}
			else if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_Idle );
				return 'Idle';
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{		
		var posCur	: Vector;
		
		
		
		if( adjustSpeedRequire )
		{
			if( m_ExplorationO.GetStateTimeF() >= adjustSpeedEndTime )
			{				
				ApplyAnimationSpeed( 1.0f );
				adjustSpeedRequire	= false;
			}
		}
		
		UpdateAdjusting2D( _Dt );
		
		UpdateHandsIK( _Dt );
		
		UpdateTranslationOutsideCapsule( _Dt );
		
		UpdateRunOrWalk();
		
		
		CheckVerticalSlideEnd();
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		var movAdj 			: CMovementAdjustor;
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.CancelByName( 'ClimbAdjusInitialRotation' );
		movAdj.CancelByName( 'ClimbAdjustments' );
		movAdj.CancelByName( 'ClimbAdjusTranslation' );
		movAdj.CancelByName( 'ClimbAdjusRotation' );
		movAdj.CancelByName( 'ClimbFakeGravity' );
		
		
		CorrectPelvisStartEnd();
		
		
		
		if( adjustSpeedRequire )
		{				
			ApplyAnimationSpeed( 1.0f );
		}
		
		
		if( m_ExplorationO.GetStateTimeF() < 0.25f )
		{
			CancelCameraAnimation();
		}
		
		
		if( vaultingFound == ECRV_NoVault ) 
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
		}
		
		StopHandIK( true, true );
		
		
		m_ExplorationO.m_MoverO.SetManualMovement( false );
		
		
		if ( restoreUsableItemLAtEnd )
		{
			restoreUsableItemLAtEnd = false;
			thePlayer.OnUseSelectedItem ();
		}
		
		
		thePlayer.SetBehaviorVariable( 'inJumpState', 0.f );
		
		thePlayer.ReapplyCriticalBuff();
		
	}
	
	
	function StateUpdateInactive( _Dt : float )
	{
		UpdateAndSetHandsIKBlend( _Dt );
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanFall );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimEnded );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanWalk );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimCanRun );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustInitRot );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustRot );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimAdjustTrans );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisablePelvisTrans );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandsIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandLIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behEnableHandRIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandsIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandLIK );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behDisableHandRIK );
	}
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{	
		return true;
	}
	
	
	function CanInteract( ) : bool
	{		
		return false;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var duration		: float	= -1.0f;
		var unwantedEvent	: bool	= false;
		var text			: string;
		
		
		
		if( animEventName == behAnimCanFall )
		{
			canFall = true;
			
		}
		
		
		else if ( animEventName == behAnimEnded )
		{
			ended	= true;
			canWalk	= true;
			canRun	= true;
		}
		
		
		else if( !canWalk && animEventName == behAnimCanWalk )
		{
			canWalk	= true;
		}
		
		
		else if( !canRun && animEventName == behAnimCanRun )
		{
			canRun	= true;
		} 
		
		else if( animEventName == behAnimAdjustInitRot  && !adjustInitialRotDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorInitialRotation( duration );
		}
		
		
		else if( animEventName == behAnimAdjustRot && !adjustRotDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorRotation( duration );
		}
		
		
		else if( animEventName == behAnimAdjustTrans && !adjustTransDone )
		{
			duration	= GetEventDurationFromEventAnimInfo( animInfo );
			StartMovementAdjustorTranslation( duration );
			
			
			
			if( pelvisTransAllow && pelvisTransState == EOCS_Inactive )
			{
				pelvisTransState	= EOCS_Starting;
			}
		}
		
		
		else if( animEventName == behDisablePelvisTrans )
		{
			
			CorrectPelvisStartEnd();
		}
		
		
		else if( animEventName == behEnableIK )
		{
			if( vaultingFound == ECRV_NoVault )
			{
				m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
				ApplyFakeGravity();
			}
		}
		
		
		else if( animEventName == behEnableHandsIK )
		{
			handIKqueuedL	= true;
			handIKqueuedR	= true;
		}
		else if( animEventName == behEnableHandLIK )
		{
			handIKqueuedL	= true;
		}
		else if( animEventName == behEnableHandRIK )
		{
			handIKqueuedR	= true;
		}
		else if( animEventName == behDisableHandsIK )
		{
			StopHandIK( true, true );
		}
		else if( animEventName == behDisableHandLIK )
		{
			StopHandIK( true, false );
		}
		else if( animEventName == behDisableHandRIK )
		{
			StopHandIK( false, true );
		}
		
		
		else
		{
			unwantedEvent = true;
		}
		
		
		if( !unwantedEvent )
		{
			text	= "GotEvent: " + animEventName;
			if( duration >= 0.0f )
			{
				text	+= " duration " + duration;
			}
			LogExplorationClimb( text );
		}
	}
	
	
	private function InitClimbs()
	{
		var i	: int;
		
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{
			InitializeClimb( i );
		}
	}
	
	
	private function InitializeClimb( i : int )
	{
		if( climbTypes[ i ].heightUseDefaults )
		{
			switch( climbTypes[ i ].type )
			{
				case ECHT_Step:
					climbTypes[ i ].heightMin	= 0.3f;
					climbTypes[ i ].heightMax	= 0.75f;
					break;
				case ECHT_VerySmall:
					climbTypes[ i ].heightMin	= 0.75f;
					climbTypes[ i ].heightMax	= 1.5f;
					break;
				case ECHT_Small:
					climbTypes[ i ].heightMin	= 1.5f;
					climbTypes[ i ].heightMax	= 2.0f;
					break;
				case ECHT_Medium:
					climbTypes[ i ].heightMin	= 2.0f;
					climbTypes[ i ].heightMax	= 2.5f;
					break;
				case ECHT_High:
					climbTypes[ i ].heightMin	= 2.5f;
					climbTypes[ i ].heightMax	= 3.0f;
					break;
				case ECHT_VeryHigh:
					climbTypes[ i ].heightMin	= 3.0f;
					climbTypes[ i ].heightMax	= 4.0f;
					break;
			}
			
			
			if( climbTypes[ i ].type == ECHT_VerySmall )
			{
				climbTypes[ i ].heightExact	= 1.0f;
			}
			else
			{
				climbTypes[ i ].heightExact	= climbTypes[ i ].heightMin;
			}
		}
		else
		{
			climbTypes[ i ].heightUseDefaults	= climbTypes[ i ].heightUseDefaults;
		}
	}
	
	
	private function ComputeMinMaxHeight( out heightTotalMin : float, out heightTotalMax : float )
	{
		var i	: int;
		
		
		
		heightTotalMin			= climbTypes[ 0 ].heightMin;
		heightTotalMax			= climbTypes[ 0 ].heightMax;
		platformHeightMin		= 1000.0f;
		platformHeightMinAir	= 1000.0f;
		heightMaxToRun			= 0.0f;
		
		
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{
			if( climbTypes[ i ].requiredState == ECRT_Running && heightMaxToRun < climbTypes[ i ].heightMax )
			{
				heightMaxToRun	= climbTypes[ i ].heightMax;
			}
			if( climbTypes[ i ].requiredPlatform == ECRV_Platform )
			{
				if( climbTypes[ i ].requiredState == ECRT_Jumping || climbTypes[ i ].requiredState == ECRT_AirColliding )
				{
					if( climbTypes[ i ].heightMin < platformHeightMinAir )
					{
						platformHeightMinAir	= climbTypes[ i ].heightMin;
					}
				}
				else  if( climbTypes[ i ].heightMin < platformHeightMin )
				{
					platformHeightMin	= climbTypes[ i ].heightMin;
				}
			}
			if( heightTotalMax < climbTypes[ i ].heightMax )
			{
				heightTotalMax	= climbTypes[ i ].heightMax;
			}
			if( heightTotalMin	> climbTypes[ i ].heightMin )
			{
				heightTotalMin	= climbTypes[ i ].heightMin;
			}
		}
	}
	
	
	private function FindPlayerState() : EClimbRequirementType
	{
		
		if( m_ExplorationO.GetStateTypeCur() ==  EST_OnAir )
		{
			
			if( forceAirCollision )
			{
				return ECRT_AirColliding;
			}
			else if( forceJumpGrab )
			{
				return ECRT_Jumping;
			}
			
			if( m_ExplorationO.GetStateCur() == 'AirCollision' )
			{
				return ECRT_AirColliding;
			}
			return ECRT_Jumping;
		}
		
		
		else if( m_ExplorationO.GetStateTypeCur() ==  EST_Swim )
		{
			return ECRT_Swimming;
		}
		
		
		
		else if( thePlayer.GetIsRunning() && m_ExplorationO.m_InputO.IsModuleConsiderable() ) 
		{
			return ECRT_Running;
		}
		
		
		return ECRT_Landed;
	}
	
	
	private function InputWantsToEnter() : bool
	{
		
		if( m_ExplorationO.m_InputO.IsExplorationJustPressed() )
		{
			return true;
		}
		else if( m_ExplorationO.GetStateTypeCur() == EST_OnAir && m_ExplorationO.m_InputO.IsExplorationPressed() )
		{
			return true;
		}
		else
		{
			return false;
		}
		
		
	}
	
	
	private function ComputeInput()
	{
		inputAttemptsTop	= !thePlayer.GetIsRunning(); 
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputDirection	= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		}
		else
		{		
			inputDirection	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
	}
	
	
	private function OracleWantsToEnter() : bool
	{
		var originPosition	: Vector;
		var logFails		: bool;
		var	distanceType	: EClimbDistanceType;
		var	requireInputDir : bool;
		
		
		logFails		= m_ExplorationO.m_InputO.IsExplorationJustPressed();
		originPosition	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		distanceType	= GetDistanceType();
		
		
		requireInputDir		= m_ExplorationO.m_InputO.IsModuleConsiderable();
		
		
		m_ClimbOracleO.ComputeAll( inputAttemptsTop, originPosition, inputDirection, distanceType, requireInputDir, logFails );
		
		
		if( !m_ClimbOracleO.CanWeClimb() )
		{
			return false;
		}
		
		
		m_ClimbOracleO.GetClimbData( heightTarget, vaultingFound, vaultEndsFalling, platformFound, climbPoint, wallNormal );
		
		return true;
	}
	
	
	private function GetDistanceType() : EClimbDistanceType
	{
		
		if( curPlayerStateType == ECRT_Jumping )
		{		
			return ECDT_Close;
		}
		else if( curPlayerStateType == ECRT_Running )
		{
			return ECDT_Far;
		}
		else if( curPlayerStateType == ECRT_AirColliding )
		{
			return ECDT_Far;
		}
		
		return ECDT_Normal;
	}
	
	
	private function PreRefineIsValid() : bool
	{
		var	dot			: float;
		var distance2D	: float;
		
		
		
		if( curPlayerStateType == ECRT_Running && heightTarget < 0.75f )
		{
			LogExplorationClimb( "Climb skipped because of running state and height < 0.75f" );
			return false;
		}
		
		
		if( curPlayerStateType == ECRT_Running && heightTarget >= 3.0f )
		{
			distance2D	= VecDistanceSquared2D( climbPoint, m_ExplorationO.m_OwnerE.GetWorldPosition() );
			if( distance2D > slideDistMaxOnRun * slideDistMaxOnRun )
			{
				LogExplorationClimb( "Climb skipped because of running state and distance " + distance2D + " > " + slideDistMaxOnRun * slideDistMaxOnRun );
				return false;
			}
		}
		
		
		if( curPlayerStateType == ECRT_Running )
		{
			dot	= VecDot( wallNormal, inputDirection );
			if( dot > -0.65f )
			{
				LogExplorationClimb( "Climb skipped because of running state and dot from input to wall " + dot + " > -0.65f" );
				return false;
			}
		}
		
		return true;
	}
	
	
	private function RefinePlayerState()
	{
		
		if( curPlayerStateType == ECRT_Running && heightTarget > heightMaxToRun )
		{
     		curPlayerStateType = ECRT_Landed;
		}
		
		
		
		if( platformFound == ECRV_Platform )
		{
			if( curPlayerStateType == ECRT_Jumping || curPlayerStateType == ECRT_AirColliding )
			{
				if( heightTarget < platformHeightMinAir )
				{
					platformFound	= ECRV_NoPlatform;
				}
			}
			else
			{
				if( heightTarget < platformHeightMin )
				{
					platformFound	= ECRV_NoPlatform;
				}
			}
		}
	}
	
	
	private function PostRefineState()
	{
		var	characterPos	: Vector;
		var	distance2D		: float;
		
		return;
		
		if( curPlayerStateType == ECRT_Running )
		{
			characterPos		= m_ExplorationO.m_OwnerMAC.GetWorldPosition();
			distance2D			= VecDistance2D( characterPos, climbPoint );
			
			if( distance2D < climbCur.forwardDistExact )
			{
				curPlayerStateType	= ECRT_Landed;
				FindApropriateClimb();
			}
		}
	}
	
	
	private function FindApropriateClimb() : bool
	{	
		var i					: int;		
		var searchingForState	: EClimbRequirementType;
		
		
		
		searchingForState	= curPlayerStateType;
		
		if( searchingForState == ECRT_AirColliding )
		{
			searchingForState	= ECRT_Jumping;
		}
		
		
		for( i = 0; i < climbTypes.Size(); i += 1 )
		{			
			
			if( climbTypes[ i ].requiredState != searchingForState )
			{
				continue;
			}
			
			
			if( vaultingFound != climbTypes[ i ].requiredVault ) 
			{
				continue;
			}
			
			
			if( platformFound != climbTypes[ i ].requiredPlatform ) 
			{
				continue;
			}
			
			
			if( climbTypes[ i ].heightMax < heightTarget || climbTypes[ i ].heightMin > heightTarget )
			{
				continue;
			}
			
			
			climbCur	= climbTypes[ i ];
			
			return true;
		}
		
		LogExplorationClimb( " Could not find adequate climb type. heightTarget: " + heightTarget + ", State required: " + curPlayerStateType + ", vaultingFound: " + vaultingFound + ", platformFound: " + platformFound );
		return false;
	}
	
	
	private function SetBehaviorData()
	{
		
		m_ExplorationO.m_SharedDataO.SetFotForward();
		SetTranslationToBehaviour();
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVarEnd, ( float ) ( int ) ECR_NotReady );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behHeightTypeEnum, ( float ) ( int ) climbCur.type );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behVaultTypeEnum, ( float ) ( int ) climbCur.requiredVault );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behPlatformTypeEnum, ( float ) ( int ) climbCur.requiredPlatform );
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStateTypeEnum, ( float ) ( int ) climbCur.requiredState );
		if( climbCur.requiredVault == ECRV_Vault )
		{
			m_ExplorationO.m_SharedDataO.m_JumpTypeE	= EJT_Vault;
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'JumpType', ( float ) ( int ) EJT_Vault );
		}
		else
		{
			m_ExplorationO.m_SharedDataO.m_JumpTypeE	= EJT_Fall;
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'JumpType', ( float ) ( int ) EJT_Fall );
		}
	}
	
	
	private function SetProperCameraAnim( reset : bool, speed : float )
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		var animation	: SCameraAnimationDefinition;
		
		if( !updateCameraAnim || !climbCur.playCameraAnimation )
		{
			return;
		}
		
		animation.animation	= climbCur.cameraAnimation; 
		animation.priority	= 10;
		animation.blendIn	= 0.5f;
		animation.blendOut	= 0.5f;
		animation.weight	= 1.0f;
		animation.speed		= speed;
		animation.loop		= false;
		animation.additive	= false;
		animation.reset		= reset;
		
		camera.PlayAnimation( animation );
	}
	
	
	private function CancelCameraAnimation()
	{
		var camera		: CCustomCamera = theGame.GetGameCamera();
		
		camera.StopAnimation( climbCur.cameraAnimation );
	}
	
	
	private function SetInitialMovementAdjustor()
	{
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		
		ApplyAnimationSpeed( 1.0f );
		
		
		PrepareMovementAdjustorParameters();
	}
	
	
	private function PrepareMovementAdjustorParameters()
	{
		var initialrotation		: float;
		var rotation			: float;
		var translation			: Vector;
		var translationBackDist	: float;
		var distanceToAdd		: float;
		var characterPos		: Vector;
		var	translationGoesBack	: bool;
		var	isCiri				: bool;
		
		
		
		heightToAdd			= heightTarget - climbCur.heightExact;	
		characterRadius		= 0.4f;
		characterPos		= m_ExplorationO.m_OwnerMAC.GetWorldPosition();
		
		
		rotation			= VecHeading( -wallNormal );
		
		
		translation			= climbPoint - characterPos;
		
		
		initialrotation		= VecHeading( translation ); 
		
		
		translation			+= wallNormal * characterRadius;
		
		
		
		translationBackDist	= MaxF( 0.0f, VecDot( translation, wallNormal ) );
		
		isCiri	= false;
		if( (W3ReplacerCiri)thePlayer )
		{
			isCiri	= true;
		}
		if( isCiri )
		{
			translationBackDist	+= 0.125f; 
		}
		else
		{
			translationBackDist	+= 0.05f;
		}
		
		
		
		
		{
			distanceToAdd		= VecLength( translation ); 
			
			
			translation			-= wallNormal * ( characterRadius - climbCur.forwardDistExact );
		}
		
		translation.Z			= heightToAdd;
		
		
		adjustInitiallRotat		= initialrotation;
		adjustRotation			= rotation;
		adjustTranslation		= translation;
		
		
		adjustInitialRotDone	= false;
		adjustRotDone			= false;
		adjustTransDone			= false;
		adjustSpeedRequire		= false;
		
		
		
		
		if( translationBackDist > 0.0f )
		{
			StartMovementAdjustorInitialTranslation( translationBackDist * wallNormal );
		}
	}
	
	
	private function StartMovementAdjustorTranslation( duration : float )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		var ticket2			: SMovementAdjustmentRequestTicket;
		
		var distance		: float;
		var speed			: float;
		var timeRequired	: float;
		var animSpeedCoef	: float;
		
		if( noAdjustor )
		{
			return;
		}
		
		if( adjustTranslation == Vector( 0, 0, 0 ) )
		{
			return;
		}
		
		
		distance	= VecLength( adjustTranslation );
		speed		= distance / duration;
		if( speed > adjustSpeedMax )
		{
			timeRequired		= distance / adjustSpeedMax;
			animSpeedCoef		= duration / timeRequired;
			duration			= timeRequired;
			adjustSpeedRequire	= true;
			adjustSpeedEndTime	= m_ExplorationO.GetStateTimeF() + duration;
			ApplyAnimationSpeed( animSpeedCoef );
		}
		
		
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusTranslation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		movAdj.AdjustLocationVertically( ticket, true );
		
		movAdj.SlideBy( ticket, adjustTranslation );
		
		
		
		
		adjust2Dduration	= duration;
		adjust2Translation	= Vector( adjustTranslation.X, adjustTranslation.Y, 0.0f );
		adjust2Speed		= VecLength2D( adjust2Translation ) / duration;
		
		
		adjustTransDone	= true;
	}
	
	
	private function StartMovementAdjustorInitialRotation( duration : float )
	{
		var movAdj 		: CMovementAdjustor;
		var ticket 		: SMovementAdjustmentRequestTicket;
		var	angle		: float;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		
		if( adjustInitiallRotat == m_ExplorationO.m_OwnerE.GetHeading() )
		{
			return;
		}
		
		
		
		angle	= 	AngleDistance( adjustInitiallRotat, adjustRotation );
		if( AbsF( angle ) > 90.0f ) 
		{
			adjustInitiallRotat		= adjustRotation;
		}
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'ClimbAdjusInitialRotation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		movAdj.LockMovementInDirection( ticket, adjustInitiallRotat );
		
		
		
		movAdj.RotateTo( ticket, adjustInitiallRotat );	
		adjustInitialRotDone	= true;
	}
	
	
	private function StartMovementAdjustorInitialTranslation( translationBack : Vector )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusInitialTranslation' );		
		movAdj.AdjustmentDuration( ticket, 0.1f );
		movAdj.AdjustLocationVertically( ticket, true );
		
		
		
		movAdj.SlideBy( ticket, translationBack );
	}
	
	
	private function StartMovementAdjustorRotation( duration : float )
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.CancelByName( 'ClimbAdjusInitialRotation' );
		
		
		if( adjustRotation	== m_ExplorationO.m_OwnerE.GetHeading() )
		{
			return;
		}
		
		
		ticket = movAdj.CreateNewRequest( 'ClimbAdjusRotation' );		
		movAdj.AdjustmentDuration( ticket, duration );
		
		
		
		movAdj.RotateTo( ticket, adjustRotation );	
		adjustRotDone	= true;
	}
	
	
	private function ApplyFakeGravity()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		if( noAdjustor )
		{
			return;
		}
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'ClimbFakeGravity' );		
		movAdj.AdjustmentDuration( ticket, 0.5 );
		movAdj.AdjustLocationVertically( ticket, true );
		
		
		
		movAdj.SlideBy( ticket, Vector( 0.0f, 0.0f, -0.75f ) );
		adjustTransDone	= true;
	}
	
	
	private function UpdateAdjusting2D( _Dt : float )
	{
		var movAdj 		: CMovementAdjustor;
		var distance	: float;
		
		
		if( adjust2Dduration > 0.0f )
		{
			movAdj.AddOneFrameTranslationVelocity( adjust2Translation * adjust2Speed );
			adjust2Dduration	-= _Dt;
		}
	}
	
	
	private function ApplyAnimationSpeed( speed : float )
	{
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behAnimSpeed, speed );
		SetProperCameraAnim( false, speed );
	}
	
	
	
	private function StartMovementAdjustorCorrectPelvis()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		if( noPelvisCorection || noAdjustor )
		{
			return;
		}
		
		
		movAdj	= m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		
		
		
		
		
		ticket	= movAdj.CreateNewRequest( 'ClimbAdjusPelvisCorrection' );		
		movAdj.AdjustmentDuration( ticket, 0.2f ); 
		
		
		
		movAdj.SlideBy( ticket, m_ExplorationO.m_OwnerE.GetWorldForward() * pelvisTransCur );
	}
	
	
	private function StartHandIK( left : bool, right : bool )
	{
		var rightHand		: Vector;
		var leftHand		: Vector;
		
		var normal			: Vector;
		
		var world			: CWorld;
		
		
		
		if( left )
		{
			leftHand			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexLeftHand );
			leftHand.Z			= climbPoint.Z;
			
			handIKLRayOrigin	= leftHand + m_ExplorationO.m_OwnerE.GetWorldForward() * handIKForwardOffset;
			handIKLRayEnd		= handIKLRayOrigin;
			handIKLRayOrigin.Z	+= handIKHalfMaxHeight;
			handIKLRayEnd.Z		-= handIKHalfMaxHeight;
			world				= theGame.GetWorld();
			if( world )
			{
				if( world.SweepTest( handIKLRayOrigin, handIKLRayEnd, 0.2f, handIKLRayCollision, normal, collisionObstaclesNames ) )
				{
					leftHandOffset		= handIKLRayCollision.Z - leftHand.Z + handThickness;
					if( AbsF( leftHandOffset ) >= handIKMinDistToEnable )
					{
						handIKEnabledLeft	= true;
						
						leftHandOffset	= ClampF( leftHandOffset, -handIKMaxDist, handIKMaxDist );
					}
				}
			}
		}
		
		
		if( right )
		{
			rightHand			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexRightHand );
			rightHand.Z			= climbPoint.Z;
			
			handIKRRayOrigin	= rightHand + m_ExplorationO.m_OwnerE.GetWorldForward() * handIKForwardOffset;
			handIKRRayEnd		= handIKRRayOrigin;
			handIKRRayOrigin.Z	+= handIKHalfMaxHeight;
			handIKRRayEnd.Z		-= handIKHalfMaxHeight;
			if( theGame.GetWorld().SweepTest( handIKRRayOrigin, handIKRRayEnd, 0.2f, handIKRRayCollision, normal, collisionObstaclesNames ) )
			{
				rightHandOffset		= handIKRRayCollision.Z - rightHand.Z + handThickness;
				if( AbsF( rightHandOffset ) >= handIKMinDistToEnable )
				{
					handIKEnabledRight	= true;
					
					rightHandOffset	= ClampF( rightHandOffset, -handIKMaxDist, handIKMaxDist );
				}
			}
		}
		
		
		if( handIKEnabledLeft || handIKEnabledRight )
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( true );
			handIKEnabled	= true;
		}
	}
	
	
	private function StopHandIK(  left : bool, right : bool )
	{			
		if( left )
		{
			leftHandOffset	= 0.0f;
			handIKEnabledLeft	= false;
		}
		if( right )
		{
			rightHandOffset	= 0.0f;
			handIKEnabledRight	= false;
		}
	}
	
	
	private function UpdateHandsIK( _Dt : float )
	{
		
		if( handIKqueuedL || handIKqueuedR )
		{
			StartHandIK( handIKqueuedL, handIKqueuedR );
			
			
			if( handIKqueuedL && handIKEnabledLeft )
			{
				handIKqueuedL	= false;
			}
			if( handIKqueuedR && handIKEnabledRight )
			{
				handIKqueuedR	= false;
			}
		}
		
		else if( continousHandIK )
		{
			if( handIKEnabledLeft || handIKEnabledRight )
			{
				StartHandIK( handIKEnabledLeft, handIKEnabledRight );
			}
		}
		
		
		UpdateAndSetHandsIKBlend( _Dt );
	}
	
	
	private function UpdateAndSetHandsIKBlend( _Dt : float )
	{
		if( handIKEnabledLeft || handIKEnabledRight || AbsF( leftHandOffsetCur ) > 0.0f || AbsF( rightHandOffsetCur ) > 0.0f )
		{
			
			if( leftHandOffset == 0.0f )
			{
				leftHandOffsetCur	= BlendLinearF( leftHandOffsetCur, leftHandOffset, _Dt * handIKBlendSpeedOut );
			}
			else
			{
				leftHandOffsetCur	= BlendLinearF( leftHandOffsetCur, leftHandOffset, _Dt * handIKBlendSpeedIn );
			}
			if( rightHandOffset == 0.0f )
			{
				rightHandOffsetCur	= BlendLinearF( rightHandOffsetCur, rightHandOffset, _Dt * handIKBlendSpeedOut );
			}
			else
			{			
				rightHandOffsetCur	= BlendLinearF( rightHandOffsetCur, rightHandOffset, _Dt * handIKBlendSpeedIn );
			}
			m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( leftHandOffsetCur, rightHandOffsetCur );
		}
		
		else if( handIKEnabled && !handIKEnabledLeft && !handIKEnabledRight && leftHandOffsetCur == 0.0f && rightHandOffsetCur == 0.0f )
		{
			m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( false );
			handIKEnabled	= false;
		}
	}
	
	
	private function UpdateTranslationOutsideCapsule( _Dt : float )
	{
		switch( pelvisTransState )
		{
			case EOCS_Inactive		:
				break;
			case EOCS_Starting		:
				UpdateTargetPelvisTranslationTarget();
				pelvisTransCur	= BlendLinearF( pelvisTransCur, pelvisTransTarget, pelvisTransSpeed * _Dt );
				SetTranslationToBehaviour();
				if( pelvisTransCur < pelvisTransSpeed * _Dt )
				{
					pelvisTransState	= EOCS_PerfectFollow;
				}
				break;
			case EOCS_PerfectFollow	:
				UpdateTargetPelvisTranslationTarget();
				pelvisTransCur	= pelvisTransTarget;
				SetTranslationToBehaviour();
				break;
			case EOCS_Recover		:
				break;
		}
	}
	
	
	private function UpdateTargetPelvisTranslationTarget()
	{
		var directionToPoint : Vector;
		
		
		directionToPoint	= climbPoint - m_ExplorationO.m_OwnerE.GetWorldPosition();		
		directionToPoint.Z	= 0.0f;
		
		directionToPoint	= directionToPoint * VecDot( directionToPoint, m_ExplorationO.m_OwnerE.GetWorldForward() );
		
		pelvisTransTarget	= VecLength2D( directionToPoint ) - characterRadius + 0.1f;
		pelvisTransTarget	= ClampF( pelvisTransTarget, 0.0f, pelvisTransMax );
	}
	
	
	private function CorrectPelvisStartEnd()
	{
		if(	pelvisTransState == EOCS_PerfectFollow || pelvisTransState == EOCS_Starting )
		{
			pelvisTransState	= EOCS_Recover;
			pelvisTransTarget	= 0.0f;
			ResetTranslationToBehaviour();
			StartMovementAdjustorCorrectPelvis();
		}
	}
	
	
	private function SetTranslationToBehaviour()
	{
		if( noPelvisCorection )
		{
			return;
		}
		
		m_ExplorationO.m_OwnerMAC.SetAdditionalOffsetToConsumeMS( Vector( 0.0f, pelvisTransCur, 0.0f ), EulerAngles( 0.0f, 0.0f, 0.0f ), 1.0f );
	}
	
	
	private function ResetTranslationToBehaviour()
	{
		if( noPelvisCorection )
		{
			return;
		}
		
		m_ExplorationO.m_OwnerMAC.SetAdditionalOffsetToConsumeMS( Vector( 0.0f, pelvisTransCur, 0.0f ), EulerAngles( 0.0f, 0.0f, 0.0f ), 0.1f );
	}
	
	
	private function UpdateRunOrWalk()
	{
		var runValue	: float;
		
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() && AbsF( m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF() ) < inputAngleToRun )
		{
			if( thePlayer.GetIsRunning() ) 
			{
				runValue	= 1.0f;
			}
			else
			{
				runValue	= 0.5f;
			}
		}
		else
		{
			runValue	= 0.0f; 
		}
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behToRun, runValue );
	}
	
	
	
	private function CheckVerticalSlideEnd()
	{
		var posCur	: Vector;
		
		
		if( vaultingFound == ECRV_NoVault )
		{
			posCur	= m_ExplorationO.m_OwnerE.GetWorldPosition();
			if( posCur.Z > heightTarget + 0.1f )
			{
				m_ExplorationO.m_CollisionManagerO.EnableVerticalSliding( false );
			}
		}
	}
		
	
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		var blend			: float;
		var targetPos		: Vector;
		var position		: Vector;
		var rotation		: EulerAngles;
		var positionDesired	: Vector;
		var rotationDesired	: EulerAngles;
		var inputX			: float;
		var inputY			: float;
		
		
		if( !updateCameraManual )
		{
			return false;
		}
		
		
		targetPos		= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( camFollowBoneID );
		rotationDesired	= m_ExplorationO.m_OwnerE.GetWorldRotation();
		
		
		if( camStart == true )
		{
			
			camOriginalPosition = moveData.pivotPositionValue;
			camOriginalRotation	= moveData.pivotRotationValue;
			camCurRotation		= rotationDesired;
			camOriginalOffset	= moveData.cameraLocalSpaceOffset;
			camStart			= false;
		}
		
		
		inputX							= theInput.GetActionValue( 'GI_AxisRightX' );
		inputY							= theInput.GetActionValue( 'GI_AxisRightY' );
		camCurRotation.Yaw				= camCurRotation.Yaw - inputX * dt * 200.0f;
		camCurRotation.Pitch			= ClampF( camCurRotation.Pitch + inputY * dt * 100.0f, -45.0f, 45.0f );
		
		
		camOriginalRotation.Yaw			= LerpAngleF( dt * 5.0f, camOriginalRotation.Yaw, camCurRotation.Yaw );
		camOriginalRotation.Pitch		= LerpAngleF( dt * 5.0f, camOriginalRotation.Pitch, camCurRotation.Pitch );
		
		positionDesired					= targetPos - m_ExplorationO.GetWorldForward() * 0.8f + m_ExplorationO.m_OwnerE.GetWorldUp() * 0.8f;
		camOriginalPosition				= LerpV( camOriginalPosition, positionDesired, dt * 2.0f );
		
		
		moveData.pivotPositionValue		= camOriginalPosition;
		moveData.pivotRotationValue		= camOriginalRotation;
		moveData.cameraLocalSpaceOffset	= camOriginalOffset;
		moveData.pivotPositionVelocity	= Vector( 0.0f, 0.0f, 0.0f );
		moveData.pivotRotationVelocity	= EulerAngles( 0.0f, 0.0f, 0.0f );
		
		return true;
	}
	
	
	public function GetDebugText() : string
	{
		var text	: string;
		
		text	= climbCur.type				+ ", "
				+ climbCur.requiredVault	+ ", "
				+ climbCur.requiredPlatform	+ ", "
				+ climbCur.requiredState	+ ", "
				+ "PelvisT: " + pelvisTransCur;
		
		return text;
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		var colorAux		: Color;
		
		
		m_ClimbOracleO.OnVisualDebug( frame, flag, active );
		
		colorAux	= Color( 80, 200, 80 );
		frame.DrawText( GetClimbTypeText(), climbPoint + Vector( 0.0f, 0.0f, 1.0f ) + VecFromHeading( adjustRotation ) * 2.0f , colorAux );
		colorAux	= Color( 100, 255, 100 );
		frame.DrawSphere( climbPoint, 0.1f, colorAux );
		frame.DrawLine( climbPoint, climbPoint + wallNormal, colorAux );
		
		
		colorAux	= Color( 255, 255, 255 );
		frame.DrawLine( handIKLRayOrigin, handIKLRayEnd, colorAux );		
		frame.DrawText( "IK: " + leftHandOffsetCur,  handIKLRayCollision, colorAux );
		frame.DrawLine( handIKRRayOrigin, handIKRRayEnd, colorAux );		
		frame.DrawText( "IK: " + rightHandOffsetCur, handIKRRayCollision, colorAux );
		
		
		return true;
	}
	
	
	private function DebugLogSuccesfullClimb()
	{				
		LogExplorationClimb( "------------------ Climb Found ------------------" );
		LogExplorationClimb( GetClimbTypeText() );
		LogExplorationClimb( "Translation " + VecToString( adjustTranslation ) + ", Rotation " + adjustRotation 
							
							+ ", heightToAdd " + heightToAdd );		
		m_ClimbOracleO.DebugLogSuccesfullClimb();
		LogExplorationClimb( "------------------   ------   ------------------" );
	}
	
	
	private function GetClimbTypeText() : string
	{
		return climbCur.requiredState + ", " + climbCur.type + ", " + climbCur.requiredVault + ", " + climbCur.requiredPlatform;
		
	}
}


function LogExplorationClimb( text : string )
{
	LogChannel( 'ExplorationState'		, "Climb: " + text );
	LogChannel( 'ExplorationStateClimb'	, text );
}