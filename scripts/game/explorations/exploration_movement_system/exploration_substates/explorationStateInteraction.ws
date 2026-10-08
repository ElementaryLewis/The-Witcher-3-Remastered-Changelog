/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ExplorationInteractionType
{
	EIT_Ladder	= 0,
	EIT_Boat	= 1,
	EIT_Ledge	= 2,
};


enum ELadderType
{
	ELT_Default = 0, 
	ELT_Root    = 1,
}

enum ELadderVerticalPosition
{
	ELVP_Top    = 0,
	ELVP_Bottom = 1,
}

enum EHand
{
	EH_Right = 0,
	EH_Left = 1
}

enum ELadderStartPosition
{
	ELSP_Left = 0,
	ELSP_Center = 1,
	ELSP_Right = 2,
}

enum ELadderState
{
	ELS_Jump,
	ELS_Grab,
	ELS_Loop,
	ELS_GetOn,
	ELS_GetOff,
	ELS_Slide
}

enum EBlendMode
{
	EBM_In,
	EBM_Out
}



class CExplorationStateInteraction extends CExplorationStateAbstract
{	
	private				var	explorationType			: ExplorationInteractionType;
	
	public	editable	var	autointeract			: bool;			default	autointeract			= false;
	private editable	var	safetyTimeToExit		: float;		default safetyTimeToExit		= 0.15f;
	private	editable	var	useAutomaticExploration	: bool;			default	useAutomaticExploration	= false;
	private	editable	var	allowOnDiving			: bool;			default	allowOnDiving			= true;
	
	
	private	editable	var	timeBeforeExploring		: float;		default	timeBeforeExploring		= 1.5f;
	
	
	private	editable	var	ladderCheckSides		: bool;			default	ladderCheckSides		= false;
	private	editable	var	ladderImpulseBack		: float;		default	ladderImpulseBack		= 1.0f;
	private	editable	var	ladderRangeFreeOfNPCs	: float;		default	ladderRangeFreeOfNPCs	= 1.5f;
	private editable	var ladderGrabDistance		: float;		default ladderGrabDistance		= 0.8f;
	private             var ladderDirection         : float;		default ladderDirection         = 0.0f;
	private 			var ladderPrevDirection		: float;        default ladderPrevDirection     = 0.0f; 
	private				var ladderSliding			: bool; 		default ladderSliding 			= false;
	private				var ladderJumpOn			: bool; 		default ladderJumpOn			= false;
	private 			var ladderCenterAngle 		: float;		default ladderCenterAngle 		= 0.4f;
	private				var ladderSlideSpeed		: float;		default ladderSlideSpeed		= 0.2f;
	private 			var ladderGrabInitiated 	: bool;			default ladderGrabInitiated		= false;
	private				var ladderCanMoveAfterCatch	: bool;		 	default ladderCanMoveAfterCatch	= false;
	private 			var ladderIsGroundJump		: bool; 		default ladderIsGroundJump		= true;
	private 			var ladderCanUpdateVerticalMovement : bool; default ladderCanUpdateVerticalMovement = false;
	private				var ladderMaxAngle			: float; 		default ladderMaxAngle			= 60.0f; 
	private 			var ladderHeadingMaxAngleJump	: float;	default ladderHeadingMaxAngleJump 	= 25.0f;
	private 			var ladderHeadingMaxAngleGrab	: float;	default ladderHeadingMaxAngleGrab 	= 20.0f;
	private 			var ladderTargetPositionOffset : float;	 	default ladderTargetPositionOffset  = 0.3;
	private 			var ladderCloseJumpDistance : float; 		default ladderCloseJumpDistance = 1.f;
	private 			var ladderLongJumpDistance 	: float;		default ladderLongJumpDistance = 3.f;
	private 			var ladderJumpDistance		: float;		default ladderJumpDistance = 4.f;

	
	private 			var ladderBlendHandIK		: bool;			default ladderBlendHandIK = false;	
	private 			var ladderIKBlendDuration 	: float; 		default ladderIKBlendDuration = 0.f;
	private 			var ladderIKCurrentBlendTime: float;		default ladderIKCurrentBlendTime = 0.f;
	private 			var ladderIKBlendMode		: EBlendMode;
	private 			var	boneRightHand			: name;			default	boneRightHand			= 'r_hand';
	private				var	boneLeftHand			: name;			default	boneLeftHand			= 'l_hand';
	private 			var	boneIndexRightHand		: int;
	private 			var	boneIndexLeftHand		: int;
	private 			var offsetLeft				: float;
	private 			var offsetRight 			: float;
	
	private 			var ladderRemasterFeaturesEnabled : bool;
	private				var canInterruptGetOff		: bool;			default canInterruptGetOff 		= false;
	private 			var ladderAbove				: bool;
	private				var hasValidEndpoint		: bool;			default hasValidEndpoint		= false;
	private				var ladderCurrState			: ELadderState;	
	private 			var ladderPrevState			: ELadderState;
	private 			var remasterAnimsUsed		: bool;
	private 			var traverser				: CScriptedExplorationTraverser;

	
	private				var	behAnimPlayerControl	: name;			default	behAnimPlayerControl	= 'PlayerCanTakeControl';
	private 			var behMotionOnJump			: name; 		default behMotionOnJump			= 'LadderMotionStart';
	private				var behCatchInterrupt		: name;			default behCatchInterrupt		= 'CanMoveFromCatch';
	private 			var behGetOffMotionStart	: name; 		default behGetOffMotionStart	= 'SlideGetOffMovement';
	private 			var behSlideMotionDelay		: name;			default behSlideMotionDelay     = 'SlideStartVerticalMovement';
	private 			var behJumpToLadder			: name; 		default behJumpToLadder			= 'JumpToLadder';
	private				var behClimbToLadder		: name; 		default behClimbToLadder		= 'ClimbToLadder';
	private 			var behChangeToRun			: name;			default behChangeToRun			= 'LadderToRun';
	private 			var behChangeToWalk			: name;			default behChangeToWalk			= 'LadderToWalk';
	private				var behRotMotion			: name; 		default behRotMotion			= 'RotMotion';
	private				var behTransMotion			: name;			default behTransMotion			= 'TransMotion';
	private 			var behGetOffMotion			: name;			default behGetOffMotion			= 'GetOffMotion';
	private 			var behJumpInitialRot 		: name;			default behJumpInitialRot		= 'InitialRotation';
	private 			var behSlideAdjustment		: name; 		default behSlideAdjustment		= 'AdjustSlide';
	private 			var behEnableHandIK			: name;			default behEnableHandIK			= 'BlendHandIK';
	private 			var behDisableHandIK		: name; 		default behDisableHandIK		= 'DisableHandIK';

	
	private 			var behAngleOfApproach		: name;			default behAngleOfApproach		= 'ladderStartAngle';
	private				var behJumpOnForwardFoot	: name;			default behJumpOnForwardFoot 	= 'ladderForwardFoot';
	private 			var behLadderIsGroundJump	: name;			default behLadderIsGroundJump	= 'ladderIsGroundJump';
	private 			var behIsAboveLadder		: name;			default behIsAboveLadder		= 'Above';
	private 			var behStartPosition		: name; 		default behStartPosition		= 'ladderStartPos';
	private				var behInteractsFromWater	: name;			default behInteractsFromWater	= 'fromWaterToLadder';
	private				var behUpperHand			: name;			default behUpperHand			= 'ladderUpperHandInit';
	private 			var behJumpToGrab			: name;			default behJumpToGrab			= 'ladderGroundJumpToGrab';
	private 			var behCatchToLoop			: name; 		default behCatchToLoop			= 'ladderCatchToLoop';
	private 			var behSlideCanEnd			: name; 		default behSlideCanEnd			= 'ladderSlideCanEnd'; 	
	private 			var behLadderEnd			: name;			default behLadderEnd			= 'ladderEnd';
	private 			var behLadderAtEnd			: name; 		default behLadderAtEnd			= 'ladderAtEnd'; 
	private 			var behCanStartSlide		: name;			default behCanStartSlide		= 'ladderCanStartSlide';
	private 			var behInputDirection		: name;			default behInputDirection		= 'ladderDirection';
	private 			var behIsRootLadder			: name;			default behIsRootLadder			= 'ladderIsRootLadder';
	private 			var behShortJump			: name;			default behShortJump			= 'ladderShortJump';
	private				var behSprintJump			: name; 		default behSprintJump			= 'ladderIsSprinting';

	
	protected editable inlined	var	cameraSetClimb	: CCameraParametersSet;	
	private editable	var	cameraOffsetBack		: float;		default	cameraOffsetBack		= 0.25f;
	private editable	var	cameraOffsetUp			: float;		default	cameraOffsetUp			= 0.0f;
	private editable	var	cameraPichInput			: float;		default	cameraPichInput			= 30.0f;
	private editable	var	cameraBlendSpeedTrans	: float;		default	cameraBlendSpeedTrans	= 0.75f;
	private editable	var	cameraBlendSpeedYaw		: float;		default	cameraBlendSpeedYaw		= 3.0f;
	private editable	var	cameraBlendSpeedPitch	: float;		default	cameraBlendSpeedPitch	= 2.0f;
	
	private 			var	camPosOriginal			: Vector;
	private 			var	camInitialized			: bool;
	
	
	
	
	
	
	private				var cachedWeapon			: EPlayerWeapon;
	private  saved		var restoreUsableItemLAtEnd : bool;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Interaction';
		}
		
		m_StateTypeE		= EST_Locked;
		m_InputContextE		= EGCI_JumpClimb; 
		m_HolsterIsFastB	= true;

		boneIndexRightHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneRightHand );
		boneIndexLeftHand	= m_ExplorationO.m_OwnerE.GetBoneIndex( boneLeftHand );

		
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		var stateTime				: float;
		var stateName				: name;
		var tryingToInteractClimb	: bool;
		var tryingToInteractLadder	: bool;
		var tryingToJumpToLadder 	: bool;
		var tryingToGrabLadder		: bool;

		
		autointeract = ((bool)theGame.GetInGameConfigWrapper().GetVarValue('RemasterCombat', 'AutoClimbLadders'));
		ladderRemasterFeaturesEnabled = ((bool)theGame.GetInGameConfigWrapper().GetVarValue('RemasterCombat', 'RemasterLadderFeatures')) && !thePlayer.IsCiri();

		tryingToInteractClimb	= m_ExplorationO.m_InputO.IsExplorationJustPressed();
		tryingToInteractLadder	= m_ExplorationO.m_InputO.IsInteractionJustPressed();
		tryingToJumpToLadder 	= IsTryingToJumpToLadder();
		if( !tryingToJumpToLadder ) 
		{
			tryingToGrabLadder		= IsTryingToGrabLadder();
		}

		if( WantsToJumpOnLadder( tryingToJumpToLadder, tryingToGrabLadder ) && (!tryingToInteractClimb || !tryingToInteractLadder) )
		{
			return true;
		}
		if( WantsToExploreStatics( tryingToInteractClimb, tryingToInteractLadder, tryingToJumpToLadder ) )
		{
			return true;
		}
		
		if( WantsToExploreBoat( tryingToInteractClimb ) )
		{
			return true;
		}
		
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !thePlayer.IsActionAllowed( EIAB_Explorations ) )
		{
			return false;
		}
		else if( !thePlayer.IsActionAllowed( EIAB_Movement ) )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		thePlayer.OnRangedForceHolster( true, true, false );

		thePlayer.SetUseNewLadderAnimations( (bool)theGame.GetInGameConfigWrapper().GetVarValue('RemasterCombat', 'RemasterLadderAnims') );	
	
		canInterruptGetOff   = false; 

		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'turnOnJump' );
		
		if( !m_ExplorationO.m_SharedDataO.HasValidExploration() )
		{
			LogExplorationToken( "We entered exploration without a valid token" );
		}
		StartExploring( m_ExplorationO.m_SharedDataO.GetLastExploration() );

		if( m_ExplorationO.m_SharedDataO.GetCurentExplorationType() == ET_Ladder )
		{
			explorationType	= EIT_Ladder;
			InitExplorationLadder( prevStateName );
		}
		else if( m_ExplorationO.m_SharedDataO.GetCurentExplorationType() == ET_Boat_Enter_From_Beach )
		{
			explorationType	= EIT_Boat;
		}
		else
		{
			explorationType	= EIT_Ledge;
		}
	

		camInitialized	= false;
		
		
		thePlayer.RemoveTimer( 'DelayedSheathSword' );
		
		
		if ( thePlayer.IsHoldingItemInLHand() )
		{			
			thePlayer.OnUseSelectedItem ( true );
			restoreUsableItemLAtEnd	= true;		
		}
		else
		{
			thePlayer.OnHolsterLeftHandItem();
		}
		cachedWeapon = thePlayer.GetCurrentMeleeWeaponType();
		
		
		thePlayer.EnableRunCamera( false );
		
		
		AddActionsToBlock();
		BlockActions();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
		
		
		thePlayer.AbortSign();		
	}	
	
	
	protected function AddActionsToBlock()
	{
		super.AddActionsToBlock();
		AddActionToBlock( EIAB_DrawWeapon );
		if ( explorationType == EIT_Boat )
		{
			AddActionToBlock( EIAB_RunAndSprint );
			AddActionToBlock( EIAB_CallHorse );
		}
		
	}
	
	private function InitExplorationLadder(prevStateName : name)
	{
		var sideOfApproach : float;
		var frontSide : bool;

		m_ExplorationO.SetBehaviorParamBool('inInteractionState', true);
		
		ladderGrabInitiated = false;

		
		traverser = ( ( CActor )( m_ExplorationO.m_OwnerE ) ).GetTraverser();
		

		frontSide = traverser.IsFrontside();
		ladderAbove = traverser.IsAbove();
		sideOfApproach = traverser.SideOfApproach();

		if( ladderJumpOn )
		{
			SetJumpOnBehGraphVariables( sideOfApproach );
			if( ladderIsGroundJump )
			{
				ladderCurrState = ELS_Jump;
			}
			else
			{
				ladderCurrState = ELS_Grab;
			}
		}
		else
		{
			SetClimbOnBehGraphVariables( ladderAbove, sideOfApproach, frontSide, prevStateName );
			ladderCurrState = ELS_GetOn;
		}

		
		if( thePlayer.GetIsSprintToggled() )
		{
			thePlayer.SetSprintToggle( false );
		}
	}

	private function SetJumpOnBehGraphVariables( angleOfApproach : float )
	{
		var range : float;
		var weight : float;
		var distFromLadder : float;

		if( ladderIsGroundJump )
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behAngleOfApproach, angleOfApproach );
			distFromLadder = DistanceFromLadder(m_ExplorationO.m_SharedDataO.GetLastExploration());
			if( distFromLadder <= ladderCloseJumpDistance )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behShortJump, 1.f);
			}
			else if( distFromLadder >= ladderLongJumpDistance )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behShortJump, 0.f);
			}
			else
			{
				range = ladderLongJumpDistance - ladderCloseJumpDistance;
				weight = 1.0 - ( distFromLadder - ladderCloseJumpDistance) / range;

				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behShortJump, weight);
			}

			if( thePlayer.GetIsSprinting() )
			{
				m_ExplorationO.SetBehaviorParamBool(behSprintJump, true );
			}
			else
			{
				m_ExplorationO.SetBehaviorParamBool(behSprintJump, false );
			}

		}
		else
		{
			if( angleOfApproach < -ladderCenterAngle)
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behStartPosition,(float)(int)ELSP_Left); 
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int )EH_Left );
				
			}
			else if( angleOfApproach < ladderCenterAngle)
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behStartPosition, (float)(int)ELSP_Center);
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int )EH_Left );
				
			}
			else
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable(behStartPosition, (float)(int)ELSP_Right);
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int )EH_Right );
				
			}
		}
		
		m_ExplorationO.SetBehaviorParamBool( behJumpOnForwardFoot, m_ExplorationO.m_MoverO.IsRightFootForward() );
		m_ExplorationO.SendAnimEvent( behJumpToLadder, true );
		
		m_ExplorationO.SetBehaviorParamBool( behLadderIsGroundJump, ladderIsGroundJump );
	}

	private function SetClimbOnBehGraphVariables( above : bool, sideOfApproach : float, frontSide : bool, prevStateName : name )
	{
		var onLeftSide : bool;
		var sideIdx : int;
		var ladderUpperHand : EHand; 
		
		if( thePlayer.IsCiri() )
		{
			remasterAnimsUsed = m_ExplorationO.m_SharedDataO.m_UseRemasterLadderAnimsB;
			m_ExplorationO.m_SharedDataO.SetUseRemasterLadderAnims( false );
		}

		
		
		if( above )
		{
			m_ExplorationO.SetBehaviorParamBool( behIsAboveLadder, true );
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition, (float)(int)ELSP_Center );
			ladderUpperHand = EH_Left;
			
		}
		else
		{
			m_ExplorationO.SetBehaviorParamBool( behIsAboveLadder, false );

			
			if( prevStateName == 'Swim' )
			{
				m_ExplorationO.SetBehaviorParamBool( behInteractsFromWater, true );
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, (float)(int)EH_Left );
				return;
			}

			onLeftSide = sideOfApproach < 0.0f;
			if( AbsF( sideOfApproach ) < ladderCenterAngle )
			{
				sideIdx = 1;
			}
			else
			{
				if( frontSide != onLeftSide ) 
				{
					sideIdx = 2;
				}
				else
				{
					sideIdx = 0;
				}
			}

			switch( sideIdx )
			{
				case 0:
					m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition, (float)(int)ELSP_Left );
					ladderUpperHand = EH_Right;
					break; 

				case 1:
					m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition, (float)(int)ELSP_Center );
					ladderUpperHand = EH_Left;
					break; 
					
				case 2:
					m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition,(float)(int)ELSP_Right );
					ladderUpperHand = EH_Left;
					break; 
			}
		}

		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, (float)(int)ladderUpperHand );
		m_ExplorationO.SendAnimEvent( behClimbToLadder, true );
	}

	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( 'AnimEndAUX', 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimPlayerControl, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behMotionOnJump, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behCatchInterrupt, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behGetOffMotionStart, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behSlideMotionDelay, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behRotMotion, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behTransMotion, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behGetOffMotion, 'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behJumpInitialRot, 'OnAnimEvent_SubstateManager');
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behSlideAdjustment, 'OnAnimEvent_SubstateManager');
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behEnableHandIK, 'OnAnimEvent_SubstateManager');
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behDisableHandIK, 'OnAnimEvent_SubstateManager');
	}
	
	
	private function StartExploring( exploration : SExplorationQueryToken )
	{
		
		
		
		if( exploration.usesHands )
		{
			thePlayer.OnRangedForceHolster();
		}
		
		if( m_ExplorationO.m_IsDebugModeB )
		{			
			LogExplorationToken( "Token sent to cpp. " + m_ExplorationO.m_SharedDataO.GetExplorationTokenDescription( exploration ) );
		}
		
		
		((CPlayerStateTraverseExploration)thePlayer.GetState( 'TraverseExploration' )).SetExploration( exploration );
		thePlayer.GotoState( 'TraverseExploration' );
		
		
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		
		

		if( m_ExplorationO.m_SharedDataO.m_ladderGetOffInterrupted )
		{
			return 'Idle';
		}

		
		if( explorationType == EIT_Ladder && m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) && !ladderSliding && !ladderJumpOn && !(ladderCurrState == ELS_GetOn || ladderCurrState == ELS_GetOff))
		{
			if( ShouldActuallyJump() )
			{
				m_ExplorationO.m_SharedDataO.SetIsJumpToWaterFinished(false);
  				return 'Jump';
			}
			else
			{
				
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behLadderEnd, 0 );
				m_ExplorationO.SetBehaviorParamBool( behLadderAtEnd , true );
				ChangeLadderState( ladderCurrState, ELS_Loop );
			}
		}

		
		if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) && canInterruptGetOff )
		{			
			
			if(m_ExplorationO.m_InputO.IsSprintPressed() ) 
			{
				if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
				{
					m_ExplorationO.SendAnimEvent( behChangeToRun );
					return 'Sprint';
				}
			}
			else
			{
				if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
				{
					m_ExplorationO.SendAnimEvent( behChangeToWalk );
					return 'Idle';
				}
			}
		}

		
		if( m_ExplorationO.GetStateTimeF() > safetyTimeToExit && thePlayer.GetCurrentStateName() != 'TraverseExploration' )
		{
			return 'Idle';
		}

		return super.StateChangePrecheck();
	}
	
	private function ShouldActuallyJump() : bool
	{
		var traceManager : CScriptBatchQueryAccessor;
		var endPos : Vector;
		var raycastRes 	: array<SRaycastHitResult>;
    	var staticTraceCollisions 		: array<name>;

		staticTraceCollisions.PushBack('Terrain');
		staticTraceCollisions.PushBack('Static');

		traceManager = theGame.GetWorld().GetTraceManager();
		endPos = thePlayer.GetWorldPosition() - Vector( 0,0,0.8);
		traceManager.RayCastSync(thePlayer.GetWorldPosition() , endPos, raycastRes, staticTraceCollisions);

		return raycastRes.Size() == 0;
	}

	
	protected function StateUpdateSpecific( _Dt : float )
	{
		if( explorationType == EIT_Ladder )
		{			
			theGame.GetGameCamera().SetCollisionOffset( m_ExplorationO.m_OwnerE.GetWorldUp() );
			thePlayer.OnMeleeForceHolster(true);

			
			UpdateLadderExploration( _Dt );
		}
	}


	private function UpdateLadderExploration( _Dt : float)
	{
		ladderDirection = theInput.GetActionValue( 'GI_AxisLeftY' );

		if( ladderDirection < -0.5 )
		{
			ladderDirection = -1.0;
		}
		else if( ladderDirection > 0.5)
		{
			ladderDirection = 1.0;
		}
		else
		{
			ladderDirection = 0.0;
		}
		
		switch ( ladderCurrState ) {
			case ELS_Jump:
				JumpOnUpdate( _Dt );
				break;
			
			case ELS_Grab:
				GrabUpdate( _Dt );
				break;

			case ELS_GetOn:
				GetOnUpdate( _Dt );
				break;
			
			case ELS_Loop:
				LoopUpdate( _Dt );
				break;

			case ELS_Slide:
				SlideUpdate( _Dt );
				break;

			case ELS_GetOff:
				GetOffUpdate( _Dt );
				break;
		}
	}

	
	private function GrabUpdate( _Dt : float ) 
	{
		if( ladderCanMoveAfterCatch  )
		{
			if( WantsToSlide() && ladderRemasterFeaturesEnabled )  
			{
				TransitionToSlide( ELS_Grab );
			}
			else if( ladderDirection != 0)
			{
				m_ExplorationO.SetBehaviorParamBool( behCatchToLoop, true );
				ChangeLadderState( ELS_Loop, ELS_Grab );
			}
		}
	}

	private function JumpOnUpdate( _Dt : float )
	{
		var distFromLadder : float;
		var sideOfApproach : float;

		distFromLadder = DistanceFromLadder(m_ExplorationO.m_SharedDataO.GetLastExploration());
		if( distFromLadder < ladderGrabDistance && ladderJumpOn )
		{
			
			sideOfApproach = traverser.SideOfApproach();

			if( sideOfApproach < -ladderCenterAngle )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition,( float )( int )ELSP_Left ); 
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int )EH_Left );
			}
			else if( sideOfApproach < ladderCenterAngle )
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition, (float)(int)ELSP_Center );
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int )EH_Left );
			}
			else
			{
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behStartPosition, (float)(int)ELSP_Right );
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behUpperHand, ( float )( int ) EH_Right );
			}

			m_ExplorationO.SetBehaviorParamBool( behJumpToGrab, true );
			ChangeLadderState( ELS_Grab, ELS_Jump );
		}
	}

	private function LoopUpdate( _Dt : float )
	{
		var ladderEnd : int;
		
		ladderEnd = traverser.AtEndOfLadder();
		
		if( traverser.CheckWaterBelow() && ladderDirection == -1.0 )
		{
			m_ExplorationO.SendAnimEvent( 'Fall' , false);
			m_ExplorationO.m_SharedDataO.SetJumpedFromLadder( true );
			ChangeLadderState( ELS_GetOff, ELS_Loop );
			return;
		}

		
		if( ladderEnd != 0 && ladderEnd == ladderDirection ) 
		{
			if( ladderEnd == 1.0 )
			{
				
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behLadderEnd, 1 );
			}
			else if( ladderEnd == -1 )
			{
				
				
				if( traverser.ShouldJumpOffLadder() )
				{
					m_ExplorationO.SendAnimEvent( 'Fall' , false );
					m_ExplorationO.m_SharedDataO.SetJumpedFromLadder( true );
					ChangeLadderState( ELS_GetOff, ELS_Loop );
					return;
				}
				
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( behLadderEnd, 0 );
			}
			
			m_ExplorationO.SetBehaviorParamBool( behLadderAtEnd , true );
			ChangeLadderState( ELS_GetOff, ELS_Loop );
			return;
		}

		if( WantsToSlide() && ladderRemasterFeaturesEnabled )  
		{
			TransitionToSlide( ELS_Loop );
			return;
		}

		
		if( ladderPrevDirection != ladderDirection ) 
		{
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behInputDirection , ladderDirection );
			ladderPrevDirection = ladderDirection;
		}

	}

	private function GetOnUpdate( _Dt : float )
	{
		if( m_ExplorationO.m_SharedDataO.m_CanGetOffLadder ) 
		{
			if( WantsToSlide() && ladderRemasterFeaturesEnabled )
			{
				TransitionToSlide( ELS_GetOn );
			}
			else
			{
				ChangeLadderState( ELS_Loop, ELS_GetOn );
			}
		}
	}

	private function GetOffUpdate( _Dt : float )
	{
		var resLeft, resRight : float;
		ladderIKCurrentBlendTime += _Dt;

		
		if( ladderBlendHandIK )
		{
			if( ladderIKBlendMode == EBM_In )
				CalcIKOffset(true, 0.31);

			resLeft = BlendIK( _Dt, offsetLeft ,ladderIKBlendMode );
			resRight = BlendIK( _Dt, offsetRight ,ladderIKBlendMode );
			m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( Vector( -resLeft, resLeft * 0.4, 0 ), Vector( resRight, resRight * 0.4, 0 ) );
		}
		if( ladderPrevState == ELS_Slide)
		{
			resLeft = BlendIK( _Dt, offsetLeft,EBM_Out );
			resRight = BlendIK( _Dt, offsetRight,EBM_Out );
			m_ExplorationO.m_OwnerMAC.SetFeetIKOffsets( Vector( -resLeft, 0, 0 ), Vector( resRight, 0, 0 ) );
			m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( Vector( -resLeft, -resLeft, 0 ), Vector( resRight, -resRight, 0 ) );
		}
	}

	private function SlideUpdate( _Dt : float )
	{
		var ladderEnd : int;
		ladderEnd = traverser.AtEndOfLadder();

		if( ladderEnd == -1 )
		{
			
			ladderSliding = false;
			m_ExplorationO.m_MoverO.StopVerticalMovement();
			if( traverser.ShouldJumpOffLadder() )
			{
				m_ExplorationO.SendAnimEvent( 'Fall' , false );
				m_ExplorationO.m_SharedDataO.SetJumpedFromLadder( true );
			}
			m_ExplorationO.SetBehaviorParamBool( behSlideCanEnd, true );
			ChangeLadderState( ELS_GetOff, ELS_Slide );
		}
		if( ladderCanUpdateVerticalMovement )
		{
			m_ExplorationO.m_MoverO.UpdatePerfectMovementVertical( _Dt );
		}
	}

	private function ChangeLadderState( next : ELadderState, prev : ELadderState )
	{
		ladderCurrState = next;
		ladderPrevState = prev;
	}

	private function WantsToSlide() : bool
	{
		return thePlayer.IsSprintActionPressed() && ladderDirection == -1;
	}

	private function TransitionToSlide( prevState : ELadderState )
	{
		var exploration : SExplorationQueryToken;
		var ladderWidth : float;
		var ladderBbox : Box;

		exploration = m_ExplorationO.m_SharedDataO.GetLastExploration();
		m_ExplorationO.SetBehaviorParamBool( behCanStartSlide, true );
		ladderSliding = true;
		if( thePlayer.GetIsSprintToggled() ) 
		{
			thePlayer.SetIsSprinting( false );
			thePlayer.SetSprintToggle( false );
		}
		
		CalcIKOffset(true, 0.31f); 
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetOffsetIK( true );
		m_ExplorationO.m_OwnerMAC.SetFeetIKOffsets( Vector( -offsetLeft, 0, 0 ), Vector( offsetRight, 0, 0 ) );
		m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( true );
		m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( Vector( -offsetLeft, -offsetLeft, 0 ), Vector( offsetRight, -offsetRight, 0 ) );
		
		ChangeLadderState( ELS_Slide, prevState );
	}

	private function CalcIKOffset( optional estimated : bool, optional correction : float ) 
	{
		var ladderWidth : float;
		var ladderBbox : Box;
		var ladderEntity : W3LadderInteraction;
		var ladderExpComp : CExplorationComponent;

		var leftHand : Vector;
		var rightHand : Vector;

		var worldToLoc : Matrix;

		ladderEntity = m_ExplorationO.m_SharedDataO.m_ladderInProximity;
		ladderExpComp = (CExplorationComponent)ladderEntity.GetComponentByClassName( 'CExplorationComponent' );
		
		if( ladderEntity && ladderExpComp)
		{
			ladderEntity.CalcBoundingBox( ladderBbox );
			ladderWidth = MaxF( ladderBbox.Max.X - ladderBbox.Min.X, ladderBbox.Max.Y - ladderBbox.Min.Y );

			if( estimated )
			{
				offsetLeft = ladderWidth / 2 - correction; 
				offsetRight = ladderWidth / 2 - correction;
				return;
			}

			rightHand = m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexRightHand );
			leftHand = m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( boneIndexLeftHand );

			worldToLoc = MatrixGetInverted( ladderExpComp.GetLocalToWorld() );

			thePlayer.GetVisualDebug().AddSphere('lhand', 0.05f, rightHand, true, Color(255,0,0), -1.f);
			thePlayer.GetVisualDebug().AddSphere('rhand', 0.05f, leftHand, true, Color(255,0,0), -1.f);

			rightHand = VecTransform(worldToLoc, rightHand);
			leftHand = VecTransform(worldToLoc, leftHand);

			
			if( leftHand.Z + rightHand.Z < leftHand.X + rightHand.X)
			{
				offsetLeft  =  ladderWidth / 2 - AbsF( leftHand.Z );
				offsetRight =  ladderWidth / 2 - AbsF( rightHand.Z );
			}
			else
			{
				offsetLeft  =  ladderWidth / 2 - AbsF( leftHand.X );
				offsetRight =  ladderWidth / 2 - AbsF(rightHand.X );
			}
			
		}
		else
		{
			offsetLeft = 0;
			offsetRight = 0;
			
		}
	}

	private function BlendIK( _Dt : float, blendValue : float, blendMode : EBlendMode ) : float
	{
		var weight 		: float;
		var res 		: float;

		if( blendMode == EBM_Out )
		{
			weight = 1 - ( ladderIKCurrentBlendTime / ladderIKBlendDuration );
			if( weight > 0 )
			{
				res = blendValue *weight;
			}
			else
			{
				ResetIKOffsets();
				res = 0.f;
			}
		}
		else if( blendMode == EBM_In )
		{
			weight = MinF( ladderIKCurrentBlendTime / ladderIKBlendDuration, 1.f );
			if( weight == 1.f)
			{
				ladderBlendHandIK = false;
			}
			res = blendValue * weight;
		}

		return res;
	}

	private function ResetIKOffsets()
	{
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetOffsetIK( false );
		m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( false );
		m_ExplorationO.m_OwnerMAC.SetHandsIKOffsets( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
		m_ExplorationO.m_OwnerMAC.SetFeetIKOffsets( Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) );
	}

	private function DistanceFromLadder( exploration : SExplorationQueryToken ) : float
	{
		var entityPosition 				: Vector;
		var projectedPositionToLadder	: Vector;

		entityPosition = m_ExplorationO.m_OwnerE.GetWorldPosition();

		projectedPositionToLadder = ProjectPointToLine( entityPosition, exploration.start, exploration.end );

		return VecDistance(entityPosition, projectedPositionToLadder);
	}

	
	private function StateExitSpecific( nextStateName : name )
	{		
		 
		thePlayer.ActionCancelAll();
		thePlayer.SetBIsCombatActionAllowed( true );
		thePlayer.OnCombatActionEndComplete();
		
   		if ( !thePlayer.IsActionAllowed(EIAB_DrawWeapon) && thePlayer.IsActionAllowed(EIAB_SwordAttack) )
		{
			if ( cachedWeapon == PW_Steel || cachedWeapon == PW_Silver )
				thePlayer.OnEquipMeleeWeapon( cachedWeapon, true );
		}
		
		if( explorationType	== EIT_Ladder ) 
		{
			m_ExplorationO.m_MoverO.SetVelocity( -m_ExplorationO.m_OwnerE.GetWorldForward() * ladderImpulseBack );			
			m_ExplorationO.m_SharedDataO.m_CanFallSetVelocityB	= false;
			
			if(nextStateName == 'Jump')
			{	
				m_ExplorationO.m_SharedDataO.SetIsJumpToWaterFinished( false );
				m_ExplorationO.m_SharedDataO.SetJumpedFromLadder( true );
				theInput.ForceDeactivateAction('Jump'); 
			}

			theGame.GetGameCamera().ResetCollisionOffset();
			ResetLadderValues();
			m_ExplorationO.m_OwnerE.PopState();
		}
		if ( restoreUsableItemLAtEnd )
		{
			restoreUsableItemLAtEnd = false;
			thePlayer.OnUseSelectedItem ();
		}
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true, 0.1f );
		thePlayer.ReapplyCriticalBuff();
	}
	
	
	private function ResetLadderValues()
	{
		var movAdj : CMovementAdjustor;

		
		movAdj =  m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.CancelByName( 'LadderJumpOnRequest' );
		movAdj.CancelByName( 'LadderSlideGetOffRequest' );
		movAdj.CancelByName( 'LadderAnimTranslation' );
		movAdj.CancelByName( 'LadderAnimRotation' );
		movAdj.CancelByName('LadderJumpInitialRot');
		movAdj.CancelByName( 'LadderAdjustmentRequest');
		m_ExplorationO.m_SharedDataO.SetCanGetOffLadder( false );
		m_ExplorationO.m_SharedDataO.SetLadderGetOffInterrupted( false );
		m_ExplorationO.m_SharedDataO.SetLadderInProximity( NULL );
		ladderSliding = false;

		
		ladderDirection = 0.f;
		ladderPrevDirection = 0.f;
		m_ExplorationO.m_OwnerE.SetBehaviorVariable(behInputDirection, 0); 
		ladderCanMoveAfterCatch = false;
		m_ExplorationO.SetBehaviorParamBool( behCatchToLoop, false );
		m_ExplorationO.SetBehaviorParamBool( 'ladderCatchToSlide', false );
		m_ExplorationO.SetBehaviorParamBool( behSlideCanEnd, false );
		m_ExplorationO.SetBehaviorParamBool( behJumpToGrab, false );
		m_ExplorationO.SetBehaviorParamBool( behCanStartSlide, false );
		m_ExplorationO.SetBehaviorParamBool('inInteractionState', false);

		ladderCanUpdateVerticalMovement = false;
		hasValidEndpoint = false;
		ladderIKBlendDuration = 0.f;

		
		ResetIKOffsets();
		ladderIKCurrentBlendTime = 0.f;
		offsetLeft = 0.f;
		offsetRight = 0.f;
		ladderBlendHandIK = false;

		if( thePlayer.IsCiri() ) 
		{
			m_ExplorationO.m_SharedDataO.SetUseRemasterLadderAnims( remasterAnimsUsed );
		}

	}

	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( 'AnimEndAUX' );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimPlayerControl );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behMotionOnJump );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behCatchInterrupt );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behSlideMotionDelay );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behRotMotion );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behTransMotion );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behSlideAdjustment );
	}
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		var curHealth : float;
		var maxHealth : float;

		
		if( GetParent() == (CObject)thePlayer )
		{
			curHealth = thePlayer.GetHealth();
			maxHealth = thePlayer.GetMaxHealth();
			if( maxHealth != -1 && curHealth / maxHealth <= 0.025f )
			{
				SetReadyToChangeTo( 'StartFalling' );
				return false;
			}
		}
		
		
		if( !( damageAction && (W3Effect_Toxicity)damageAction.causer ) )
		{				
			SetReadyToChangeTo( 'StartFalling' );
		}
		
		return false;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{

		var targetPosition 		: Vector;
		var targetYaw	 		: float;
		var movAdj 				: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var animName			: name;
		var eventDuration 		: float;
		var eventStart 			: float;
		var eventEnd			: float;
		var ownerLocToWorld		: Matrix;
		var verticalMovementParams :SVerticalMovementParams; 
		var exactStep 			: int;
		
		var transformedVec		: Vector;
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();

		
		if( animEventName == behMotionOnJump && !movAdj.IsRequestActive( movAdj.GetRequest( 'LadderJumpOnRequest' ) ) )
		{
			animName = GetAnimNameFromEventAnimInfo( animInfo );
			eventDuration = GetEventDurationFromEventAnimInfo( animInfo );
			eventEnd = GetEventEndsAtTimeFromEventAnimInfo( animInfo );
			eventStart = eventEnd - eventDuration;
			traverser.CalculateTargetPosition( 
				targetPosition, 
				eventStart ,
				eventDuration , 
				animName, 
				false, 
				true, 
				m_ExplorationO.m_OwnerE.GetBehaviorVariable(behUpperHand) == (float)(int)EH_Left );
			
			traverser.CalculateTargetYaw( targetYaw, eventStart, eventDuration, animName );
			ticket	= movAdj.CreateNewRequest( 'LadderJumpOnRequest' );
			movAdj.AdjustLocationVertically( ticket, true );
			movAdj.BindToEventAnimInfo( ticket, animInfo );	
			movAdj.SlideTo( ticket, targetPosition );	
			movAdj.RotateTo( ticket, targetYaw );
			movAdj.BlendIn( ticket, 0.1 );

		}
		
		else if
		(
			( animEventName ==  behGetOffMotionStart || animEventName == behGetOffMotion ) &&
			  !movAdj.IsRequestActive( movAdj.GetRequest( 'LadderSlideGetOffRequest' ) ) &&
			  !hasValidEndpoint
		)
		{
			animName = GetAnimNameFromEventAnimInfo( animInfo );
			eventDuration = GetEventDurationFromEventAnimInfo( animInfo );
			eventEnd = GetEventEndsAtTimeFromEventAnimInfo( animInfo );
			eventStart = eventEnd - eventDuration;
			
			

			hasValidEndpoint = traverser.CalculateEndTargetMotion( targetPosition, eventStart, eventDuration, animName );
			if( !hasValidEndpoint ) 
				return;
			
			ticket	= movAdj.CreateNewRequest( 'LadderSlideGetOffRequest' );
			movAdj.AdjustLocationVertically( ticket, true );
			
			movAdj.BindToEventAnimInfo( ticket, animInfo );	
			movAdj.SlideTo( ticket, targetPosition );	
		}
		else if( animEventName == behJumpInitialRot ) 
		{
			ticket = movAdj.CreateNewRequest( 'LadderJumpInitialRot' );
			traverser.CalculateInitialJumpYaw( targetYaw, ladderTargetPositionOffset );
			movAdj.BindToEventAnimInfo( ticket, animInfo );	
			movAdj.RotateTo( ticket, targetYaw );
		}
		else if( animEventName == behSlideMotionDelay)
		{
			
			m_ExplorationO.m_MoverO.SetVerticalSpeed( - ladderSlideSpeed );
			ladderCanUpdateVerticalMovement = true;
			verticalMovementParams.m_VertMaxSpeedF = -30;
			verticalMovementParams.m_GravityUpF = -11;
			verticalMovementParams.m_GravityDownF = -2;
			m_ExplorationO.m_MoverO.SetVerticalMovementParams(verticalMovementParams);
		}
		
		else if( animEventName == behSlideAdjustment && !movAdj.IsRequestActive( movAdj.GetRequest( 'LadderAdjustmentRequest' ) ) )
		{
			ticket = movAdj.CreateNewRequest(  'LadderAdjustmentRequest' );
			ownerLocToWorld = m_ExplorationO.m_OwnerE.GetLocalToWorld();
			transformedVec = VecTransform( ownerLocToWorld, Vector( 0, offsetLeft - 0.05, 0 ) ) ;
			movAdj.BindToEventAnimInfo( ticket, animInfo );
			movAdj.SlideTo( ticket,  transformedVec );
		}
		else if( animEventName == behEnableHandIK && !ladderBlendHandIK )
		{
			ladderIKBlendDuration = GetEventDurationFromEventAnimInfo(animInfo);
			ladderBlendHandIK = true;
			ladderIKBlendMode = EBM_In;
			m_ExplorationO.m_OwnerMAC.SetEnabledHandsIK( true );
		}
		else if( animEventName == behDisableHandIK && !ladderBlendHandIK )
		{
			ladderIKCurrentBlendTime = 0.f;
			ladderBlendHandIK = true;
			ladderIKBlendDuration = GetEventDurationFromEventAnimInfo(animInfo);
			ladderIKBlendMode = EBM_Out;
		}
		
		else if( animEventName == behCatchInterrupt )
		{
			ladderJumpOn = false;
			ladderCanMoveAfterCatch = true;
			m_ExplorationO.m_SharedDataO.SetCanGetOffLadder(true); 
		}
		else if( animEventName == 'AnimEndAUX' )
		{		
			SetReadyToChangeTo( 'Idle' );
		}
		
		else if( animEventName == behAnimPlayerControl )
		{
			canInterruptGetOff = true;
		}
		
		else if( animEventName == behTransMotion && !movAdj.IsRequestActive( movAdj.GetRequest( 'LadderAnimTranslation' ) ) )
		{
			animName = GetAnimNameFromEventAnimInfo( animInfo );
			eventDuration = GetEventDurationFromEventAnimInfo( animInfo );
			eventEnd = GetEventEndsAtTimeFromEventAnimInfo( animInfo );
			eventStart = eventEnd - eventDuration;
			traverser.CalculateTargetPosition( targetPosition, eventStart, eventDuration, animName, ladderAbove, false, false );
			ticket	= movAdj.CreateNewRequest( 'LadderAnimTranslation' );
			movAdj.AdjustLocationVertically( ticket, true );
			movAdj.BindToEventAnimInfo( ticket, animInfo );	
			movAdj.SlideTo( ticket, targetPosition );
		}
		else if( animEventName == behRotMotion && !movAdj.IsRequestActive( movAdj.GetRequest( 'LadderAnimRotation' ) ))
		{
			animName = GetAnimNameFromEventAnimInfo( animInfo );
			eventDuration = GetEventDurationFromEventAnimInfo( animInfo );
			eventEnd = GetEventEndsAtTimeFromEventAnimInfo( animInfo );
			eventStart = eventEnd - eventDuration;
			traverser.CalculateTargetYaw( targetYaw, eventStart, eventDuration, animName );
			ticket	= movAdj.CreateNewRequest( 'LadderAnimRotation' );
			movAdj.BindToEventAnimInfo( ticket, animInfo );	
			movAdj.RotateTo( ticket, targetYaw );
		}

	}
	
	
	public function GetCameraSet( out cameraSet : CCameraParametersSet) : bool
	{
		if( explorationType == EIT_Boat || explorationType == EIT_Ledge )
		{
			cameraSet	= cameraSetClimb;
			
			return true;
		}
		
		return super.GetCameraSet( cameraSet );
	}
	
	
	public function CameraChangesRotationController() : bool
	{
		if( explorationType == EIT_Boat || explorationType == EIT_Ledge  )
		{
			if( IsNameValid( cameraSetClimb.pivotRotationController ) )
			{
				if( cameraSetClimb.pivotRotationController != m_ExplorationO.m_DefaultCameraSetS.pivotRotationController )
				{
					return true;
				}
			}
		}
		return super.CameraChangesRotationController();
	}

	function GetBehaviorIsEventForced( fromState : name ) : bool
	{
		return true;
	}
	

	private function IsTryingToJumpToLadder() : bool
	{
		var exploration				: SExplorationQueryToken;
		var queryContext			: SExplorationQueryContext;
		var inputVector				: Vector;
		
		if( m_ExplorationO.m_InputO.IsJumpJustPressed() )
		{
			inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
			queryContext.inputDirectionInWorldSpace = inputVector;
			queryContext.laddersOnly = true;
			queryContext.maxAngleToCheck	= 0.5 * Pi();
			queryContext.maxDistToCheck = ladderJumpDistance;
			exploration = theGame.QueryExplorationSync(m_ExplorationO.m_OwnerE, queryContext);
			if( exploration.valid )
			{				
				m_ExplorationO.m_SharedDataO.SetExplorationToken(exploration, GetStateName());
				return true;
			}
		}
		return false;
	}

	private function IsTryingToGrabLadder() : bool
	{
		var exploration				: SExplorationQueryToken;
		var queryContext			: SExplorationQueryContext;
		var inputVector				: Vector;

		if( 
			m_ExplorationO.GetStateCur() == 'Jump' && 
			!m_ExplorationO.m_SharedDataO.m_jumpedFromLadder 
			)
		{
			
			inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
			queryContext.inputDirectionInWorldSpace = inputVector;
			queryContext.laddersOnly = true;
			queryContext.maxAngleToCheck	= 0.5 * Pi();
			queryContext.maxDistToCheck = ladderGrabDistance;
			exploration = theGame.QueryExplorationSync(m_ExplorationO.m_OwnerE, queryContext);
			if( exploration.valid )
			{
				m_ExplorationO.m_SharedDataO.SetExplorationToken(exploration, GetStateName());
				return true;
			}
		}

		return false;
	}

	
	

	
	private function FetchActiveLadderObject( expToken : SExplorationQueryToken ) : W3LadderInteraction
	{
		var size : int;
		var i : int;
		var currentLadder : W3LadderInteraction;
		var ladderExpComp : CExplorationComponent;
		var startDiff : float;
		var endDiff : float;

		var expW2S : Matrix;
		var startWS : Vector;
		var endWS : Vector;

		size = m_ExplorationO.m_SharedDataO.m_activeLadders.Size();
		for( i = 0; i < size; i+=1 )
		{
			currentLadder = m_ExplorationO.m_SharedDataO.m_activeLadders[i];
			ladderExpComp = currentLadder.GetExpComp();
			
			expW2S = ladderExpComp.GetLocalToWorld();
			startWS = VecTransform( expW2S, ladderExpComp.start );
			endWS = VecTransform( expW2S, ladderExpComp.end );
			startDiff = VecDistance( startWS, expToken.start);
			endDiff =  VecDistance( endWS, expToken.end );
			if( startDiff < 0.00001f && endDiff < 0.00001f )
			{
				return currentLadder;
			}
		}

		return NULL;
	}

	
	
	private function WantsToJumpOnLadder( tryingToJumpToLadder : bool, tryingToGrabLadder : bool ) : bool
	{
		var queryContext			: SExplorationQueryContext;
		var exploration 			: SExplorationQueryToken;
		var inputVector 			: Vector;
		var ownerActor 				: CActor;
		var parentMAC				: CMovingPhysicalAgentComponent;
		var sDepth					: float;
		var angle					: float; 
		var playerHeading			: Vector;
		var playerLadderDiff		: Vector;
		var playerPos				: Vector;
		var playerProjToExp			: Vector;
		var distFromLadder 			: float;
		var ladderEntity			: W3LadderInteraction;

		if( !tryingToJumpToLadder && !tryingToGrabLadder )
		{
			return false;
		}

		
 		ownerActor = (CActor)m_ExplorationO.m_OwnerE;
		parentMAC = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
		sDepth = parentMAC.GetSubmergeDepth();
		if( sDepth  <= 0)
		{
			return false;
		}
		
		
		distFromLadder = DistanceFromLadder(m_ExplorationO.m_SharedDataO.GetLastExploration());
		if( 
			ladderRemasterFeaturesEnabled &&
			( 
				( 
					tryingToJumpToLadder && 
					m_ExplorationO.m_InputO.IsJumpJustPressed() && 
					theInput.GetActionValue( 'GI_AxisLeftY' ) > 0.5 &&
					distFromLadder < ladderJumpDistance 
				) ||  
				( 
					tryingToGrabLadder &&  
					m_ExplorationO.m_SharedDataO.m_JumpTypeE != EJT_Hit &&  
					distFromLadder < ladderGrabDistance  &&
					( 
						m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Fall || 
						( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_Sprint && theInput.GetActionValue( 'GI_AxisLeftY' ) > 0.5 )
					)
				)  
			)
			
		)
		{
			
		}
		else
		{
			return false;
		}

		
		if( m_ExplorationO.m_SharedDataO.HasValidLadderExploration())
		{
			exploration = m_ExplorationO.m_SharedDataO.GetLastExploration();
			ladderEntity = FetchActiveLadderObject(exploration);
			m_ExplorationO.m_SharedDataO.SetLadderInProximity( ladderEntity );
			
			if( !ladderRemasterFeaturesEnabled && !tryingToJumpToLadder )
			{
				return false;
			}

			
			if( !tryingToJumpToLadder && !tryingToGrabLadder && !queryContext.forAutoTraverseSmall && !queryContext.forAutoTraverseBig )
			{
				return false;
			}

			
			if( VecDistance( exploration.pointOnEdge, m_ExplorationO.m_OwnerE.GetWorldPosition() ) > 4 ) 
			{
				return false;
			}

			
			playerPos = m_ExplorationO.m_OwnerE.GetWorldPosition();
			playerProjToExp = ProjectPointToLine(playerPos, exploration.start, exploration.end);
			playerLadderDiff = playerPos - playerProjToExp;
			angle = VecGetAngleBetween( exploration.normal, playerLadderDiff );
			if( AbsF( angle ) > ladderMaxAngle )
			{
				return false;
			}

			
			playerHeading = thePlayer.GetWorldForward();
			angle = VecGetAngleBetween( -playerLadderDiff, playerHeading );
			if( tryingToJumpToLadder ) 
			{
				if( AbsF( angle ) > ladderHeadingMaxAngleJump)
				{
					return false;
				}
			}
			else if( tryingToGrabLadder )
			{
				if( AbsF( angle ) > ladderHeadingMaxAngleGrab)
				{
					return false;
				}
			}
			
			if( IsLadderInUse( exploration ) )
			{
				return false;
			}
			else if( !ladderRemasterFeaturesEnabled && !tryingToJumpToLadder )
			{
				return false;
			}
			if( ( exploration.type == ET_Boat_B ) || ( exploration.type == ET_Boat_P ) || ( exploration.type == ET_Boat_Passenger_B ) )
			{
				return false;
			}
			m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
			
			
			if( tryingToJumpToLadder )
			{
				ladderIsGroundJump = true;
				if( distFromLadder < ladderCloseJumpDistance ) 
				{
					ladderIsGroundJump = false;
					ladderJumpOn = false;
					return true;
				}
			}
			else if( tryingToGrabLadder )
			{
				ladderIsGroundJump = false;
			}
			ladderJumpOn = true;
			
			return true;
			
		}

	return false;
	}
	

	
	private function WantsToExploreStatics( tryingToInteractClimb, tryingToInteractLadder, tryingToJumpToLadder : bool) : bool
	{
		var exploration				: SExplorationQueryToken;
		var queryContext			: SExplorationQueryContext;
		var	inputVector				: Vector;
		var	interactionComponent	: CInteractionComponent;
		var ladderInteraction		: W3LadderInteraction;
		var parentMAC 				: CMovingPhysicalAgentComponent;
		var ownerActor 				: CActor;
		var sDepth					: Float;
		var ladderEntity 			: W3LadderInteraction;

		if( m_ExplorationO.GetStateCur() == 'Idle' ) 
		{
			m_ExplorationO.m_SharedDataO.SetIsJumpToWaterFinished(true);
		}

		
		if( !autointeract && !tryingToInteractClimb && !tryingToInteractLadder )
		{
			return false;
		}		
		
		
		if( !allowOnDiving && thePlayer.IsDiving() )
		{
			return false;
		}

		
		
		ownerActor = (CActor)m_ExplorationO.m_OwnerE;
		parentMAC = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
		sDepth = parentMAC.GetSubmergeDepth();

		
		
		
		if( parentMAC.GetSubmergeDepth() < 0.f &&  !m_ExplorationO.m_SharedDataO.m_isJumpedToWaterFinshed )
		{
			return false;
		}


		
		if( !autointeract && !tryingToInteractLadder && m_ExplorationO.GetStateCur() != 'Swim' )
		{
			return false;
		}
		
		
		interactionComponent	= theGame.GetInteractionsManager().GetActiveInteraction();
		if( interactionComponent )
		{
			ladderInteraction	= ( W3LadderInteraction ) interactionComponent.GetParent();
			if ( !ladderInteraction )
			{
				tryingToInteractLadder	= false;
			}
			m_ExplorationO.m_SharedDataO.SetLadderInProximity( ladderInteraction ); 
		}
		
		
		inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		if( tryingToInteractClimb  || tryingToInteractLadder )
		{
			queryContext.maxAngleToCheck	= m_ExplorationO.m_SharedDataO.m_AngleToExploreManualF;		
		}
		else
		{
			queryContext.maxAngleToCheck	= m_ExplorationO.m_SharedDataO.m_AngleToExploreAutoF;
		}
		
		
		
		if( !tryingToInteractClimb && !tryingToInteractLadder )
		{
			
			queryContext.forAutoTraverseSmall	= false; 
			
			
			queryContext.forAutoTraverseBig		= thePlayer.GetIsRunning(); 
			if( queryContext.forAutoTraverseBig )
			{
				if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
				{
					inputVector	= m_ExplorationO.m_OwnerE.GetWorldForward();
				}
			}
		}
		
		
		
		if( tryingToInteractClimb || tryingToInteractLadder || queryContext.forAutoTraverseSmall || queryContext.forAutoTraverseBig )
		{			
			if( m_ExplorationO.m_InputO.IsModuleConsiderable() || queryContext.forAutoTraverseSmall || queryContext.forAutoTraverseBig  )
			{				
				queryContext.inputDirectionInWorldSpace	= inputVector;
				queryContext.laddersOnly	= false;
			}
			
			
			
			if( tryingToInteractClimb || !interactionComponent ) 
			{
				exploration = theGame.QueryExplorationSync(m_ExplorationO.m_OwnerE, queryContext);
				ladderEntity = FetchActiveLadderObject(exploration);
				m_ExplorationO.m_SharedDataO.SetLadderInProximity( ladderEntity );
			}
     		else
			{
				exploration = theGame.QueryExplorationFromObjectSync( m_ExplorationO.m_OwnerE, m_ExplorationO.m_SharedDataO.m_ladderInProximity );
			}
			
			
			if ( exploration.valid )
			{
				
				if( exploration.type == ET_Ladder )
				{
					if( !autointeract && !tryingToInteractLadder )
					{
						return false;
					}
					
					
					if( !tryingToInteractLadder && !queryContext.forAutoTraverseSmall && !queryContext.forAutoTraverseBig )
					{
						return false;
					}
					
					
					if( IsLadderInUse( exploration ) )
					{
						return false;
					}
				}
				else if( !autointeract && !tryingToInteractClimb )
				{
					return false;
				}
				
				if( ( exploration.type == ET_Boat_B ) || ( exploration.type == ET_Boat_P ) || ( exploration.type == ET_Boat_Passenger_B ) )
				{
					return false;
				}
				
				m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
				return true;
			}
		}
		
		return false;
	}
	
	
	private function WantsToExploreBoat( tryingToInteractClimb : bool ) : bool
	{
		var exploration 		: SExplorationQueryToken;
		var	vehicleComponent	: CVehicleComponent;
		var vehicleEntity		: CEntity;
		var success 			: bool = true;		
		var direction			: Vector;		
		var	inputVector			: Vector;
		
		
		if( !autointeract && !tryingToInteractClimb )
		{
			return false;
		}
		
		
		if( m_ExplorationO.GetStateCur() != 'Swim' )
		{
			return false;
		}
		
		inputVector			= m_ExplorationO.m_InputO.GetMovementOnPlaneV();
		
		
		vehicleComponent	= thePlayer.FindTheNearestVehicle( 3.0f, false );
		if( !vehicleComponent )
		{
			return false;
		}
		
		
		
		if( !vehicleComponent.CanUseBoardingExploration() )
		{
			return false;
		}
		
		vehicleEntity		= ( CEntity ) vehicleComponent.GetParent();		
		if( !vehicleEntity )
		{
			return false;
		}
		
		exploration			= theGame.QueryExplorationFromObjectSync( thePlayer, vehicleEntity );		
		if( !exploration.valid )
		{		
			return false;
		}
		
		
		if( exploration.type != ET_Boat_Enter_From_Beach && exploration.type != ET_Ledge )
		{
			return false;
		}
		
		
		if( VecDistanceSquared2D( exploration.pointOnEdge, m_ExplorationO.m_OwnerE.GetWorldPosition() ) >= 1.0f )
		{
			return false;
		}
		
		
		direction		= exploration.pointOnEdge - m_ExplorationO.m_OwnerE.GetWorldPosition();
		inputVector		= m_ExplorationO.m_InputO.GetMovementOnPlaneNormalizedV();
		
		if( tryingToInteractClimb || VecDot( direction, inputVector ) > 0.0f )
		{
			m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
			
			return true;
		}
		
		return false;
	}
	
	
	
	private function IsLadderInUse( exploration : SExplorationQueryToken ) : bool
	{
		var npcsArround	: array<CActor>;
		var i			: int;
		var type 		: EExplorationType;
		
		npcsArround	= GetActorsInRange( thePlayer, ladderRangeFreeOfNPCs );
		for( i = 0; i < npcsArround.Size(); i += 1 )
		{
			if( npcsArround[i].GetTraverser().GetExplorationType( type ) )
			{
				if( type == ET_Ladder )
				{
					return true;
				}
			}
		}
		
		return false;
	}
}