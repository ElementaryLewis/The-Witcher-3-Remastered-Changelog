/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EHorseWaterTestResult
{
	HWTR_Normal,
	HWTR_Adjusted,
	HWTR_ToDeep
}

state Exploration in W3HorseComponent
{
	private var parentActor : CActor;
	
	private var isStopping : bool;
	private var isSlowlyStopping : bool;
	private var destSpeed : float;
	private var currSpeed : float;
	private var staminaCooldown : float;
	private var staminaCooldownTimer : float;
	private var staminaBreak : bool;
	private var speedImpulseTimestamp : float;
	private var dismountRequest : bool;
	private var roadFollowBlock : float;
	private var speedLocks 	: array<name>;
	private var speedRestriction : float;
	private var useSimpleStaminaManagement : bool;
	private var inclinationCheckCollisionGroups : array<name>;
	private var waterCheckCollisionGroups : array<name>;
	private var threatSum : float;
	private var triedDoubleTap : bool;				
	private var mac : CMovingAgentComponent;
	private var isFollowingRoad : bool;
	private var shouldGoToCanterAfterStop : bool;
	private var grassCollider : CComponent;
	
	private var currSpeedSound : float;
	private var desiredSpeedSound : float;
	
	private var jumpStartPos, jumpEndPos : Vector;
	private	var noSaveLock : int;
	
	const var MIN_SPEED : float;
	const var SLOW_SPEED : float;
	const var WALK_SPEED : float;
	const var TROT_SPEED : float;
	const var GALLOP_SPEED : float;
	const var CANTER_SPEED : float;
	
	default isStopping = false;
	default staminaCooldown = 3.f;
	default dismountRequest = false;
	default speedRestriction = 5.f;
	default useSimpleStaminaManagement = false;
	
	
	default MIN_SPEED = 0.f;
	default SLOW_SPEED = 0.5f; 
	default WALK_SPEED = 1.f;
	default TROT_SPEED = 2.f;
	default GALLOP_SPEED = 3.f;
	default CANTER_SPEED = 4.f;
	
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		theInput.RegisterListener( this, 'OnSpeedPress', 'Canter' );
		theInput.RegisterListener( this, 'OnSpeedHold', 'Gallop' );
		theInput.RegisterListener( this, 'OnDecelerate', 'Decelerate' );
		theInput.RegisterListener( this, 'OnStop', 'Stop' );
		theInput.RegisterListener( this, 'OnHorseJump', 'HorseJump' );
		theInput.RegisterListener( this, 'OnHorseDismountKeyboard', 'HorseDismount' );
		
		
		theInput.RegisterListener( this, 'OnHorseKick', 'HorseKick' );

		parentActor = (CActor)(parent.GetEntity());
		mac = parentActor.GetMovingAgentComponent();
		
		parentActor.SetBehaviorVariable( 'isCanterEnabled', 0.0 );
		
		Prepare();
		InitCollisionGroups();
		ResetSoundParameters();
		
		mac.SetEnabledFeetIK(true);
		
		theGame.GetGuiManager().EnableHudHoldIndicator(IK_Pad_B_CIRCLE, IK_None, "panel_input_action_horsedismount", 0.4, 'HorseDismount');
		
		grassCollider = parent.GetEntity().GetComponent( "CDynamicColliderComponent4" );
	}

	event OnLeaveState( nextStateName : name )
	{
		CleanUpJump();
		ResetForceStop();
		Restore();
		UnregisterInput();
		
		mac.SetEnabledFeetIK(true);

		super.OnLeaveState( nextStateName );
	}

	private function CleanUpJump()
	{
		EndJump();
		OnBehJumpEnded();
	}
	
	private function UnregisterInput()
	{
		theInput.UnregisterListener( this, 'Canter' );
		theInput.UnregisterListener( this, 'Gallop' );
		theInput.UnregisterListener( this, 'Decelerate' );
		theInput.UnregisterListener( this, 'Stop' );
		theInput.UnregisterListener( this, 'HorseJump' );
		theInput.UnregisterListener( this, 'HorseDismount' );
		
		
		theInput.UnregisterListener( this, 'HorseKick' );
		
		theGame.GetGuiManager().DisableHudHoldIndicator();
	}
	
	
	private var mountingEnded, canDoKickAnim, wantsToKick : bool;	
	private var mountingAnimationTime : float;
	private var kickTimer : float;
	
	event OnHorseKick( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			if( canDoKickAnim && !dismountRequest && theInput.GetActionValue('EnablePhotoMode_Step2') == 0.f )
			{
				wantsToKick = true;
				kickTimer = 0.1f;
			}
		}
	}
	
	private function DoHorseKick()
	{
		var camera 	: CCustomCamera;
	
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		if(	AbsF(AngleDistance(camera.GetHeading(), thePlayer.GetHeading())) > 90)
			parent.GenerateEvent('kick');
		else
			parent.GenerateEvent('rearing');
			
		wantsToKick = false;
	}
	
	
	
	
	
	
	private function IsSpeedLocked( optional ignoredLock : name ) : bool
	{
		if( ignoredLock != '' )
		{
			if( speedLocks.Size() == 1 && speedLocks.Contains( ignoredLock ) )
			{
				return false;
			}
			else
			{
				return speedLocks.Size() > 0;
			}
		}
		else
		{
			return speedLocks.Size() > 0;
		}
	}
	
	public function ToggleSpeedLock( lockName : name, toggle : bool )
	{
		if( toggle )
		{
			if( !speedLocks.Contains( lockName ) )
			{
				speedLocks.PushBack( lockName );
			}
		}
		else
		{
			speedLocks.Remove( lockName );
			
			if( !speedLocks.Contains( 'OnStop' ) && lockName != 'OnGallop' && theInput.IsActionPressed( 'Gallop' ) && !dismountRequest && currSpeed <= GALLOP_SPEED )
			{
				if( shouldGoToCanterAfterStop )
				{
					destSpeed = CANTER_SPEED;
				}
				GallopPressed();
			}
		}
	}
	
	private function LeaveThisState()
	{
		timeAfterDismountFinished = 0.f;
		parent.PopState( true );
	}
	
	
	
	
	
	var threatApplicationTimestamp : float;
	
	private var dismountFinishedTimeStamp : float;
	private var timeAfterDismountFinished : float;
	
	default dismountFinishedTimeStamp = -1.f;
	default timeAfterDismountFinished = 0.f;
	
	event OnTick( dt : float )
	{
		parent.OnTick( dt );
		
		
		parent.ShouldTickInIdle();
		
		
		
		if(mountingEnded)
		{
			mountingAnimationTime += dt;
			if(mountingAnimationTime > 1.f)
			{
				mountingAnimationTime = 0.f;
				mountingEnded = false;
				canDoKickAnim = true;
			}			
		}
		if(kickTimer >= 0.f) kickTimer -= dt;
		if( wantsToKick && kickTimer < 0.f )
		{
			if( !thePlayer.GetPhotoModeHorseKick() )
			{
				DoHorseKick();
			}
			wantsToKick = false;			
			thePlayer.SetPhotoModeHorseKick(false);
		}
		
		
		
		if( dismountRequest || thePlayer.IsActionAllowed( EIAB_Movement ) )
		{
			UpdateLogic( dt );
			UpdateDebugGUI();
		}
		else
		{
			ResetRotation();
		}
		
		if ( !parent.user )
		{
			timeAfterDismountFinished += dt;
			
			
			if ( timeAfterDismountFinished > 2.f )
			{
				LeaveThisState();
			}
		}
	}
	
	event OnMountStarted( entity : CEntity, vehicleSlot : EVehicleSlot )
	{
		
		mountingEnded = false;
		canDoKickAnim = false;
	
		parent.OnMountStarted( entity, vehicleSlot );
		LeaveThisState();
	}
	
	event OnMountFinished( entity : CEntity )
	{	
		
		mountingEnded = true;
		canDoKickAnim = false;
	
		parent.OnMountFinished(entity);
	}
	
	event OnDismountStarted( entity : CEntity )
	{	
		
		mountingEnded = false;
		canDoKickAnim = false;
	
		thePlayer.SetBehaviorVariable( 'playerWouldLikeToMove', 0.0f );
		UnregisterInput();
		parent.OnDismountStarted( entity );
	}
	event OnDismountFinished( entity : CEntity, vehicleSlot : EVehicleSlot  )
	{
		parent.OnDismountFinished( entity, vehicleSlot );
		parent.ResetPanic();
		timeAfterDismountFinished = 0.f;
	}
	
	event OnIdleBegin()
	{
		parent.OnIdleBegin();
		isInJumpAnim = false;
		isStopping = false;
		isSlowlyStopping = false;
		
		if ( !parent.user )
			LeaveThisState();
		
		ResetForceStop();
		
		
	}
	
	event OnIdleEnd()
	{
		parent.OnIdleEnd();
	}
	
	event OnHorseFastStopBegin()
	{
		isStopping = true;
	}
	
	event OnHorseFastStopEnd()
	{
		if ( dismountRequest )
			parent.IssueCommandToDismount( DT_normal );
		
		isStopping = false;
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{	
		var actorAttacker : CNewNPC;
		var isMonster : bool;
		var threatMult : int;
		
		if( parentActor.HasAbility( 'DisableHorsePanic' ) || thePlayer.HasBuff( EET_Mutagen25 ) )
			return false;
		
		actorAttacker = (CNewNPC)action.attacker;
		isMonster = actorAttacker.IsMonster();
		
		if( isMonster )
			threatMult = 2;
		else
			threatMult = 1;
		
		parentActor.AddPanic( actorAttacker.GetThreatLevel() * 10 * threatMult );
	}
	
	
	event OnCriticalEffectAdded( criticalEffect : ECriticalStateType )
	{
		if( parentActor.HasAbility( 'DisableHorsePanic' ) || thePlayer.HasBuff( EET_Mutagen25 ) )
		{
			if( thePlayer.IsActionAllowed( EIAB_Movement ) )
			{
				return false;
			}
			else if( !isInJumpAnim )
			{
				parent.ShakeOffRider( DT_shakeOff );
			}
		}	
		else if( criticalEffect != ECST_Swarm ) 
		{
			parentActor.AddPanic( 100 );	
			
			
			if( !thePlayer.IsInCombat() )
			{
				parent.ShakeOffRider( DT_shakeOff );
			}	
		}
	}
	
	var cachedCombatAction : EVehicleCombatAction;
	event OnCombatAction( action : EVehicleCombatAction )
	{
		cachedCombatAction = action;
	
		if ( action == EHCA_Attack || action == EHCA_ShootCrossbow || action == EHCA_ThrowBomb )
		{
			if ( currSpeed > MIN_SPEED )
			{
				if ( action != EHCA_Attack )
					speedRestriction = GALLOP_SPEED;
				
				ToggleSpeedLock('OnAttack',true);
			}
		}
		else if ( action == EHCA_CastSign )
			speedRestriction = TROT_SPEED;
		else
			speedRestriction = GALLOP_SPEED;
	}
	
	event OnCombatActionEnd()
	{
		speedRestriction = CANTER_SPEED;
		ToggleSpeedLock('OnAttack',false);
	}
	
	event OnSettlementEnter()
	{	
		
		if( thePlayer.GetIsHorseRacing() )
		{
			return false;
		}
		else
		{
			speedRestriction = GALLOP_SPEED;
			
			
			if( currSpeed > speedRestriction )
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, , true);
		}	
	}
	
	event OnSettlementExit()
	{
		speedRestriction = CANTER_SPEED;
	}
	
	event OnCanGallop()
	{
		return speedRestriction >= CANTER_SPEED && CanCanter();
	}
	
	event OnCanCanter()
	{
		if ( speedRestriction >= GALLOP_SPEED )
			return true;
		return false;
	}
	
	event OnStopTheVehicleInstant()
	{
		Reset();
		parent.OnStopTheVehicleInstant();
	}
	
	private var stopRequest : bool;
	
	event OnForceStop()
	{
		destSpeed = MIN_SPEED;
		speedRestriction = MIN_SPEED;
		stopRequest = true;
	}
	
	event OnHorseStop()
	{
		destSpeed = MIN_SPEED;
	}
	
	private function ResetForceStop()
	{
		if ( stopRequest )
		{
			stopRequest = false;
			speedRestriction = CANTER_SPEED;
		}
	}
	
	event OnJumpHack()
	{
		if( !isInJumpAnim )
			parent.GenerateEvent( 'jumpHACK' );
	}
	
	private var isRefusingToGo : bool;
	public var collisionAnimTimestamp : float;
	public var collsionAnimCooldown : float;
	default collsionAnimCooldown = 1.0;
	
	event OnHorseWalkBackWallStart()
	{
		isRefusingToGo = true;
	}
	
	event OnHorseWalkBackWallEnd()
	{
		isRefusingToGo = false;
	}
	
	private function CanPlayCollisionAnim() : bool
	{
		return collisionAnimTimestamp + collsionAnimCooldown < theGame.GetEngineTimeAsSeconds();
	}
	
	
	
	
	
	private var prediction : CHorsePrediction;
	
	private final function Prepare()
	{
		Reset();
		
		if( !prediction )
		{
			prediction = new CHorsePrediction in this;
		}
	}
	
	private final function Restore()
	{
		Reset();
		
		parent.InternalResetVariables();
		
		thePlayer.GetVisualDebug().RemoveBar( 'horseSpeed' );
		thePlayer.GetVisualDebug().RemoveBar( 'horseStamina' );
		thePlayer.GetVisualDebug().RemoveBar( 'horseStaminaBar' );
		thePlayer.GetVisualDebug().RemoveBar( 'horsePanic' );
		thePlayer.GetVisualDebug().RemoveBar( 'pitch' );
	}
	
	private final function Reset()
	{
		currSpeed = MIN_SPEED;
		destSpeed = MIN_SPEED;
		
		speedLocks.Clear();
		
		staminaBreak 	= false;
		dismountRequest = false;
		stopRequest 	= false;
		isInJumpAnim 	= false;
		isStopping 		= false;
		
		startSlidingTimeStamp 	= -1.f;
		notSlidingTimeStamp 	= -1.f;
		
		parent.GetEntity().SetBehaviorVariable('rotationBlend',0.f);
		
		theGame.ReleaseNoSaveLock( noSaveLock );		
		
		theGame.GetGuiManager().EnableHudHoldIndicator(IK_Pad_B_CIRCLE, IK_None, "panel_input_action_horsedismount", 0.4, 'HorseDismount');
	}
	
	private final function ResetRotation()
	{
		parent.InternalSetRotation( 0.f );
		parent.InternalSetDirection( 0.f );
	}
	
	
	
	
	
	
	private var shouldBlendFromTurning : bool;	
	
	private const var INPUTMAG_TROT : float;
	private const var INPUTMAG_WALK : float;
	
	default INPUTMAG_TROT = 0.75; 
	default INPUTMAG_WALK = 0.45; 
	
	private final function ProcessControlInput( lr : float, fb : float, timeDelta : float, useLocalSpace : bool )
	{
		var inputVec, inputVecInWS : Vector;
		var mac : CMovingAgentComponent;
		var horseHeadingInCamSpace : float;
		var dir, rot : float;
		var inputMagnitude : float;
		var predInfo : SPredictionInfo;
		var braking : bool;
		var prevDir	: float;
		var steeringCorrection : bool;
		var stickInput : bool;
		
		var keyboardWalkState : int;	
		
		if( ( !thePlayer.GetIsMovable() && !dismountRequest ) || speedRestriction == MIN_SPEED )
		{
			destSpeed = MIN_SPEED;
			parent.InternalSetRotation( 0.f );
			parent.InternalSetDirection( 0.f );
			return;
		}

		if( lr || fb )
		{
			inputVec.X = lr;
			inputVec.Y = fb;
			if( useLocalSpace )
				inputVecInWS = GetInputVectorInLocalSpace( lr, fb );
			else
				inputVecInWS = GetInputVectorInCamSpace( lr, fb );
				
			stickInput = true;
		}
		else
		{
			inputVec = parent.GetEntity().GetHeadingVector();
			inputVecInWS = inputVec;
		}
		
		if( ShouldApplyCorrection( lr, fb ) )
		{
			steeringCorrection = ApplyCorrection( inputVecInWS, dir, lr, fb );
			thePlayer.GetVisualDebug().AddText( 'SteeringCorrection', "SteeringCorrection : On ", thePlayer.GetWorldPosition() + Vector( 0.f,0.f,2.f ), true, , Color( 0, 255, 0 ) );
		}
		else
		{
			if( isFollowingRoad && roadFollowBlock == 0.0 )
			{
				roadFollowBlock = 1.0; 
				isFollowingRoad = false;
				mac	= ((CActor)parent.GetEntity()).GetMovingAgentComponent();
				mac.ResetRoadFollowing();
			}
			thePlayer.GetVisualDebug().AddText( 'SteeringCorrection', "SteeringCorrection : Off", thePlayer.GetWorldPosition() + Vector( 0.f,0.f,2.f ), true, , Color( 255, 0, 0 ) );
		}
		
		if( isFollowingRoad && ( lr || fb ) && roadFollowBlock == 0.0 )
		{
			roadFollowBlock = 1.0; 
			isFollowingRoad = false;
			mac	= ((CActor)parent.GetEntity()).GetMovingAgentComponent();
			mac.ResetRoadFollowing();
		}

		if( lr || fb || steeringCorrection )
		{
			inputMagnitude = VecLength2D( inputVec );
	
			if( steeringCorrection )
			{
				
			}
			else if( useLocalSpace )
			{
				dir = -VecHeading( inputVec );
			}
			else
			{
				horseHeadingInCamSpace = AngleDistance( theCamera.GetCameraHeading(), parent.GetHeading() );
				dir = AngleDistance( -VecHeading( inputVec ), horseHeadingInCamSpace );
			}
			
			dir = AngleNormalize180( dir ) / 180.f;
			
			
			if(isReversing)
				dir = 0.f;
			
			
			if( steeringCorrection )
			{
				rot = dir * 2 * inputMagnitude;
			}
			else if( useLocalSpace )
			{
				if( theInput.LastUsedGamepad() )
				{
					rot = ClampF(dir,-0.5,0.5) * inputMagnitude;
					if ( currSpeed <= TROT_SPEED )
						rot *= 0.8;
				}
				else
					rot = dir;
			}
			else
			{
				if ( currSpeed <= TROT_SPEED )
					rot = 2 * dir * inputMagnitude;
				else
					rot = 1.5 * dir * inputMagnitude;
			}
			
			prevDir = parent.InternalGetDirection();
			
			if( ( speedLocks.Contains( 'OnStop' ) && AbsF(dir) < 0.17f ) )
			{
				parent.InternalSetRotation( 0.f );
				parent.InternalSetDirection( 0.f );
			}
			
			
			else if( parent.riderSharedParams.mountStatus != VMS_mountInProgress )
			{
				
				if ( prevDir > 0.9f && dir < -0.7f )
				{
					if ( useLocalSpace )
						parent.InternalSetRotation( 0.5f );
					else
						parent.InternalSetRotation( 1.f );
						
					parent.InternalSetDirection( 1.f );
				}
				else if ( prevDir < -0.9f && dir > 0.7f )
				{
					if ( useLocalSpace )
						parent.InternalSetRotation( -0.5f );
					else
						parent.InternalSetRotation( -1.f );
						
					parent.InternalSetDirection( -1.f );
				}
				else
				{
					parent.InternalSetRotation( rot );
					parent.InternalSetDirection( dir );
				}
			}
			
			
			if(isReversing)
				parent.InternalSetRotation( lr );
			
			
			if( braking )
			{
			}
			
			else if( !IsSpeedLocked() && stickInput && currSpeed < GALLOP_SPEED && ( currSpeed > MIN_SPEED || AbsF( dir ) < 0.05 || inputMagnitude > 0.1f || shouldBlendFromTurning ) )
			{	
				
				if(theInput.LastUsedPCInput())
				{
					keyboardWalkState = parent.GetHorseWalkState();
					if( currSpeed < TROT_SPEED )
					{
						if( inputMagnitude > INPUTMAG_TROT && keyboardWalkState == 0 )
						{
							destSpeed = TROT_SPEED;
						}
						else if( inputMagnitude > INPUTMAG_WALK && keyboardWalkState == 1 )
						{
							destSpeed = WALK_SPEED;
						}
						else
						{
							destSpeed = SLOW_SPEED;
						}

						SpursKick();							
						speedImpulseTimestamp = theGame.GetEngineTimeAsSeconds();
					}
					else if(currSpeed < GALLOP_SPEED && keyboardWalkState == 1)
					{
						destSpeed = WALK_SPEED;
					}
					else if(currSpeed < GALLOP_SPEED && keyboardWalkState == 2)
					{
						destSpeed = SLOW_SPEED;
					}
				}				
				else
				{
				
					if( currSpeed <= TROT_SPEED ) 
					{
						if( inputMagnitude > INPUTMAG_TROT )
						{
							destSpeed = TROT_SPEED;
						}
						else if( inputMagnitude > INPUTMAG_WALK )
						{
							destSpeed = WALK_SPEED;
						}
						else
						{
							destSpeed = SLOW_SPEED;
						}
						
						
						if( destSpeed == TROT_SPEED && currSpeed <= WALK_SPEED && currSpeed != MIN_SPEED )
						{}
						else
							SpursKick();	
						
						
						speedImpulseTimestamp = theGame.GetEngineTimeAsSeconds();
					}
				} 
			}	
		}
		else
		{
			ResetRotation();
			
			if( speedImpulseTimestamp + 0.2 > theGame.GetEngineTimeAsSeconds() ) 
			{
				destSpeed = MIN_SPEED;
			}
				
			if( destSpeed > MIN_SPEED )
			{
				predInfo = prediction.CollectPredictionInfo( parent, 10.f, 0.f, parent.inWater );
				
				if( predInfo.turnAngle != 0.f )
				{
					dir = -predInfo.turnAngle / 180.f;
					rot = dir;
			
					
					
					parent.InternalSetRotation( rot );
					parent.InternalSetDirection( dir );
				}
			}
		}
		
		if ( IsRiderInCombatAction() )
			OnCombatAction( cachedCombatAction );
	}
	
	private function ShouldApplyCorrection( stickInputX : float, stickInputY : float ) : bool
	{
		var inputVec : Vector;
		var inputHeading : float;
		var horseHeading : float;
		var angleDistanceBetweenInputAndHorse : float;

		inputVec = GetInputVectorInCamSpace( stickInputX, stickInputY );
		angleDistanceBetweenInputAndHorse = AbsF( AngleDistance( VecHeading( inputVec ), parent.GetHeading() ) );
		
		
		shouldBlendFromTurning = false;

		if( !stickInputX && !stickInputY )
		{
			if( theInput.IsActionPressed( 'Canter' ) )
				return true;
			else
				return false;
		}	
		else if( currSpeed > TROT_SPEED && angleDistanceBetweenInputAndHorse > 55.0 )
		{
			return false;
		}
		else if( currSpeed > MIN_SPEED && angleDistanceBetweenInputAndHorse < 55.0 )
		{
			return true;
		}
		
		else if( !CheckVector(GetHorseVelocity()) && angleDistanceBetweenInputAndHorse < 65.0 )
		{
			shouldBlendFromTurning = true;
			return true;
		}
		
		else if( isStopping )
		{
			return true;
		}
		else
			return false;
	}
	
	
	private function CheckVector(vec : Vector) : bool
	{
		if(vec.X == 0 && vec.Y == 0 && vec.Z == 0)
			return true;
			
		return false;		
	}
	
	
	private function ApplyCorrection( inputVector : Vector, out correctedDir, stickInputX : float, stickInputY : float ) : bool
	{
		var stickInput : bool;
		var horseHeadingVec	: Vector;
		var mac : CMovingAgentComponent;
		var currentDir : float;
		
		var speed : float; 
		var speedModifier : float;
		var dirModifier : float = 1.0;
		var followRoad : bool;
		var maxAngleForAdjustingDir : float;
		
		var cachedVec : Vector;
		var correctedDirV : Vector;
		var desiredDirectionVec : Vector;
		var angleDistance : float;
		
		var startPos, endPos : Vector;
		
		stickInput = stickInputX || stickInputY;
		horseHeadingVec = parent.GetEntity().GetHeadingVector();
		mac	= ((CActor)parent.GetEntity()).GetMovingAgentComponent();
		currentDir = parent.GetEntity().GetHeading();
		speedModifier = MaxF( 0.25, stickInputY );

		if( currSpeed == CANTER_SPEED )
		{
			speed = 18.75; 
			
			if( !stickInput && !thePlayer.GetIsHorseRacing() )
			{
				dirModifier = 3.0;
				followRoad = true;
				maxAngleForAdjustingDir = 90.0;
			}
			else
			{
				dirModifier = 2.0;
				speed *= speedModifier;
				maxAngleForAdjustingDir = 15.0;
			}
			
			correctedDirV = VecNormalize2D( inputVector * 0.3 + horseHeadingVec * 0.7 );
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			speed = 12.5; 
			
			if ( !stickInput && !thePlayer.GetIsHorseRacing() )
			{
				dirModifier = 2.0;
				followRoad = true;
				maxAngleForAdjustingDir = 90.0;
			}
			else
			{
				dirModifier = 2.0;
				speed *= speedModifier;
				maxAngleForAdjustingDir = 15.0;
			}
			
			correctedDirV = VecNormalize2D( inputVector * 0.3 + horseHeadingVec * 0.7 );
		}
		else
		{
			speed = 3.75 * speedModifier; 
			dirModifier = 1.5;
			maxAngleForAdjustingDir = 90.0;
			
			correctedDirV = VecNormalize2D( inputVector * 0.4 + horseHeadingVec * 0.6 );
		}
		
		cachedVec = correctedDirV;
		
		desiredDirectionVec = inputVector;
			
		if( followRoad && !thePlayer.GetIsHorseRacing() && roadFollowBlock == 0.0 )
		{
			if( mac.StartRoadFollowing( speed, 45.0, 10.0, correctedDirV ) )
				isFollowingRoad = true;
			else
				isFollowingRoad = false;
		}
		
		if( !parent.IsInCustomSpot() )
		{
			if( !isFollowingRoad )
				mac.AdjustRequestedMovementDirectionNavMesh( correctedDirV, speed, maxAngleForAdjustingDir, 10, 6, desiredDirectionVec );
		}
		else
		{
			if( currSpeed > TROT_SPEED )
			{
				isFollowingRoad = true; 
			}
		}
		
		
		if( cachedVec == correctedDirV )
		{
			correctedDirV = inputVector;
		}
		
		correctedDir = VecHeading( correctedDirV );
		angleDistance = AngleDistance( currentDir, correctedDir );
		
		correctedDir = ClampF( angleDistance * dirModifier, -180, 180 );

		
		startPos = parent.GetEntity().GetWorldPosition();
		endPos = startPos + speed * correctedDirV;
		((CActor)parent.GetEntity()).GetVisualDebug().AddArrow( 'correctionLine', startPos, endPos, 1, 0.3, 0.3, true, Color( 255, 255, 255 ), true, 1.0 );
		
		return true;
	}
	
	private function ShouldStopBecauseOfCorrection( inputVecInWS : Vector, correctionVec : Vector ) : bool
	{
		var angleDistBetwenHorseHeadingAndInput 		: float;
		var angleDistBetwenHorseHeadingAndCorrection 	: float;
		var angleDistBetwenInputAndCorrection 			: float;
		var horseHeading 								: float;
		
		horseHeading = parent.GetEntity().GetHeading();
		angleDistBetwenHorseHeadingAndInput 		= AngleDistance( horseHeading, VecHeading(inputVecInWS) );
		angleDistBetwenHorseHeadingAndCorrection 	= AngleDistance( horseHeading, VecHeading(correctionVec) );
		angleDistBetwenInputAndCorrection 			= AngleDistance( VecHeading(inputVecInWS), VecHeading(correctionVec) );
		
		
		if ( AbsF(angleDistBetwenInputAndCorrection) < 10 )
			return false;
		
		if ( AbsF(angleDistBetwenHorseHeadingAndInput) > 45 && ( AbsF(angleDistBetwenHorseHeadingAndCorrection) > 150 || AbsF(angleDistBetwenInputAndCorrection) > 45 ) )
		{
			return true;
		}
		
		return false;
	}
	
	const var HEADING_WT : float;
	const var INPUT_WT : float;
	
	default HEADING_WT = 1.0;
	default INPUT_WT = 0.25;
	
	
	



	
	const var NAVDATA_RADIUS : float;
	const var NAVDATA_LENGTH_MOD_SLOW : float;	
	const var NAVDATA_LENGTH_MOD_TROT : float;
	const var NAVDATA_LENGTH_MOD_GALLOP : float;
	const var NAVDATA_LENGTH_MOD_CANTER : float;
	
	default NAVDATA_RADIUS = 1.0;			
	default NAVDATA_LENGTH_MOD_SLOW = 1.5;	
	default NAVDATA_LENGTH_MOD_TROT = 3.5;	
	default NAVDATA_LENGTH_MOD_GALLOP = 10.0;
	default NAVDATA_LENGTH_MOD_CANTER = 15.0;
	
	private function PerformNavDataTest() : bool
	{
		var startPoint, endPoint : Vector;
		var initialHeading : Vector;
		var lengthMod : float;
		
		startPoint = parent.GetWorldPosition();
		initialHeading = parent.GetHeadingVector();
		
		
		if( currSpeed < SLOW_SPEED )
		{
			lengthMod = NAVDATA_LENGTH_MOD_SLOW;
		}
		
		else if( currSpeed <= TROT_SPEED )
		{
			lengthMod = NAVDATA_LENGTH_MOD_TROT;
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			lengthMod = NAVDATA_LENGTH_MOD_GALLOP;
		}
		else
		{
			lengthMod = NAVDATA_LENGTH_MOD_CANTER;
		}
		
		
		if(isReversing)
			lengthMod *= -1;
		
		
		endPoint = startPoint + initialHeading * lengthMod;
		
		
		
		
		
		if( theGame.GetWorld().NavigationLineTest( startPoint, endPoint, NAVDATA_RADIUS, false, true ) ) 
		{		
			return true;
		}
		
		
		
		return false;
	}
	
	const var INCLINATION_MAX_ANGLE : float;
	const var INCLINATION_BASE_DIST : float;
	const var INCLINATION_TESTS_COUNT_SLOW : int; 
	const var INCLINATION_TESTS_COUNT_TROT : int;
	const var INCLINATION_TESTS_COUNT_GALLOP : int;
	const var INCLINATION_TESTS_COUNT_CANTER : int;
	const var INCLINATION_Z_OFFSET : float;
	
	default INCLINATION_MAX_ANGLE = 45.0;
	default INCLINATION_BASE_DIST = 1.7;		
	default INCLINATION_TESTS_COUNT_SLOW = 2;	
	default INCLINATION_TESTS_COUNT_TROT = 3;	
	default INCLINATION_TESTS_COUNT_GALLOP = 4;	
	default INCLINATION_TESTS_COUNT_CANTER = 7;	
	default INCLINATION_Z_OFFSET = 2.1;			
	
	private function PerformInclinationTest( stickInputX : float, stickInputY : float ) : bool
	{
		var startPoint, rawEndPoint, tempEndPoint : Vector;
		var linkingStartPoint, linkingEndPoint, linkingTempPoint, normal : Vector;
		var initialHeading : Vector;
		var inputVec : Vector;
		var horseHeadingVec : Vector;
		var angle : float;
		var i, iterationsCount : int;
		var speed : float;
		
		startPoint = parent.GetWorldPosition();
		speed = MaxF( currSpeed, destSpeed );
		
		
		if( stickInputX || stickInputY )
		{
			inputVec = GetInputVectorInCamSpace( stickInputX, stickInputY );
			horseHeadingVec = parent.GetHeadingVector();
					
			initialHeading = VecNormalize2D( inputVec * 0.5 + horseHeadingVec * 1.0 );
		}
		else
		{
			initialHeading = parent.GetHeadingVector();
		}
		

		
		if( speed < SLOW_SPEED )
		{
			iterationsCount = INCLINATION_TESTS_COUNT_SLOW;
		}
		
		else if( speed <= TROT_SPEED )
		{
			iterationsCount = INCLINATION_TESTS_COUNT_TROT;
		}
		else if( speed == GALLOP_SPEED )
		{
			iterationsCount = INCLINATION_TESTS_COUNT_GALLOP;
		}
		else
		{
			iterationsCount = INCLINATION_TESTS_COUNT_CANTER;
		}
		
		if( thePlayer.GetIsHorseRacing() )
		{
			iterationsCount =  (int)( MaxF( 2.0, ( iterationsCount / 2 ) ) ); 
		}
		
		
		
		if(isReversing)
		{
			initialHeading *= -1;
			iterationsCount = 1;
		}
		
		

		for( i = 0; i < iterationsCount; i += 1 )
		{
			rawEndPoint = startPoint + initialHeading * INCLINATION_BASE_DIST;
			angle = GetInclinationBetweenPoints( startPoint, rawEndPoint, tempEndPoint, INCLINATION_Z_OFFSET );
			
			if( angle == 180.0 ) 
			{
				return false;
			}
			
			if( i < 2 && !thePlayer.GetIsHorseRacing() ) 
			{
				linkingStartPoint = startPoint;
				linkingStartPoint.Z += 2.35;
				linkingEndPoint = tempEndPoint;
				linkingEndPoint.Z += 0.5;
				
				if( theGame.GetWorld().StaticTrace( linkingStartPoint, linkingEndPoint, linkingTempPoint, normal, inclinationCheckCollisionGroups ) )
				{
					return false;
				}
			}
			
			if( angle < -INCLINATION_MAX_ANGLE ) 
			{
				
				return false;
			}
			else if( angle > INCLINATION_MAX_ANGLE && !thePlayer.GetIsHorseRacing() ) 
			{
				if( currSpeed > TROT_SPEED )
				{
					destSpeed = MinF( currSpeed, TROT_SPEED );
				}
				else
				{
					return false;
				}
			}
			
			
			
			
			startPoint = tempEndPoint;
		}
		
		

		return true;
	}
	
	private function GetInclinationBetweenPoints( startPoint : Vector, rawEndPoint : Vector, out endPoint : Vector, zOffset : float ) : float
	{
		
		var rawEndPointWithZOffsetUp, rawEndPointWithZOffsetDown, normal : Vector;
		var heightDiff : float;
		
		rawEndPointWithZOffsetUp = rawEndPoint;
		rawEndPointWithZOffsetUp.Z += zOffset;
		rawEndPointWithZOffsetDown = rawEndPoint;
		rawEndPointWithZOffsetDown.Z -= zOffset;
		
		if( !theGame.GetWorld().SweepTest( rawEndPointWithZOffsetUp, rawEndPointWithZOffsetDown, 0.05, endPoint, normal, inclinationCheckCollisionGroups ) )
		{
			return 180.0;
		}
		
		
		
		
		if( startPoint.Z * endPoint.Z >= 0 ) 
		{
			heightDiff = AbsF( startPoint.Z - endPoint.Z );
		}
		else
		{
			heightDiff = AbsF( startPoint.Z ) + AbsF( endPoint.Z );
		}
		
		if( startPoint.Z >= endPoint.Z )
		{
			return -Rad2Deg( AtanF( heightDiff, INCLINATION_BASE_DIST ) );
		}
		else
		{
			return Rad2Deg( AtanF( heightDiff, INCLINATION_BASE_DIST ) );
		}
	}
	
	private function GetLocalInclination( optional inPoint : Vector ) : float
	{
		var startPoint, rawEndPoint, tempEndPoint : Vector;
		var initialHeading : Vector;
		
		if( inPoint != Vector( 0, 0, 0 ) )
			startPoint = inPoint;
		else
			startPoint = parent.GetWorldPosition();
			
		initialHeading = parent.GetHeadingVector();
		rawEndPoint = startPoint + initialHeading * 1.5;
		
		return GetInclinationBetweenPoints( startPoint, rawEndPoint, tempEndPoint, 2.0 );
	}
	
	const var WATER_MAX_DEPTH : float;
	const var WATER_DIST_TROT : float;
	const var WATER_DIST_GALLOP : float;
	const var WATER_DIST_CANTER : float;
	
	default WATER_MAX_DEPTH = 1.25;		
	default WATER_DIST_TROT = 2.5;		
	default WATER_DIST_GALLOP = 8.0;	
	default WATER_DIST_CANTER = 11.0;	
	
	private function PerformWaterTest( stickInputX : float, stickInputY : float,  currentWaterDepth : float  ) : bool
	{
		var startPoint, endPoint, cachedEndPoint, bridgeCheckUp, bridgeCheckDown, bridgeCheckOutPoint, normal : Vector;
		var initialHeading : Vector;
		var inputVec : Vector;
		var horseHeadingVec : Vector;
		var waterDepth : float;
		var speed : float;
		
		
		var addedDepth : float;
		
		startPoint = parent.GetWorldPosition();
		speed = MaxF( currSpeed, destSpeed );
		
		if( stickInputX || stickInputY )
		{
			inputVec = GetInputVectorInCamSpace( stickInputX, stickInputY );
			horseHeadingVec = parent.GetHeadingVector();
					
			initialHeading = VecNormalize2D( inputVec * 0.5 + horseHeadingVec * 1.0 );
		}
		else
		{
			initialHeading = parent.GetHeadingVector();
		}
		
		
		addedDepth = 0.f;
		if(isReversing)
		{
			initialHeading *= -1;
			addedDepth = 0.25f;
		}
		

		if( speed <= TROT_SPEED )
		{
			endPoint = startPoint + initialHeading * WATER_DIST_TROT;
			cachedEndPoint = endPoint;
			endPoint.Z += WATER_DIST_TROT + 1.0;
		}
		else if( speed == GALLOP_SPEED )
		{
			endPoint = startPoint + initialHeading * WATER_DIST_GALLOP;
			cachedEndPoint = endPoint;
			endPoint.Z += WATER_DIST_GALLOP + 1.0;
		}
		else 
		{
			endPoint = startPoint + initialHeading * WATER_DIST_CANTER;
			cachedEndPoint = endPoint;
			endPoint.Z += WATER_DIST_CANTER + 1.0;
		}

		
		bridgeCheckUp = cachedEndPoint;
		bridgeCheckUp.Z += 5.0;
		bridgeCheckDown = cachedEndPoint;
		bridgeCheckDown.Z -= 10.0;
		if( theGame.GetWorld().SweepTest( bridgeCheckUp, bridgeCheckDown, 0.05, bridgeCheckOutPoint, normal, waterCheckCollisionGroups ) )
		{
			return true;
		}
		
		waterDepth = theGame.GetWorld().GetWaterDepth( endPoint, true );
		
		
		
		
		if( waterDepth < WATER_MAX_DEPTH + addedDepth || waterDepth == 10000.0  || waterDepth < AbsF(currentWaterDepth)  ) 
		{
			
			thePlayer.GetVisualDebug().AddText( 'WaterTest', "WaterIsFine", thePlayer.GetWorldPosition() + Vector( 0.f,0.f,2.3f ), true, , Color( 0, 255, 0 ) );
			return true;
		}
		else
		{
			thePlayer.GetVisualDebug().AddText( 'WaterTest', "WaterTooDeep", thePlayer.GetWorldPosition() + Vector( 0.f,0.f,2.3f ), true, , Color( 255, 0, 0 ) );
			
			
			
			return false;
		}
	}
	




	private function PerformWaterJumpTest() : bool
	{
		var startPoint, endPoint, endPointWithBuffer, bridgeCheckUp, bridgeCheckDown, bridgeCheckOutPoint, normal : Vector;
		var initialHeading : Vector;
		var horseHeadingVec : Vector;
		var waterDepth : float;
		var testedPoints : array<Vector>;
		var i : int;
		
		startPoint = parent.GetWorldPosition();
		initialHeading = parent.GetHeadingVector();

		if( currSpeed <= TROT_SPEED )
		{
			endPoint = startPoint + initialHeading * 5.0;
			endPointWithBuffer = startPoint + initialHeading * 10.0;
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			endPoint = startPoint + initialHeading * 8.0;
			endPointWithBuffer = startPoint + initialHeading * 14.0;
		}
		else 
		{
			endPoint = startPoint + initialHeading * 9.0;
			endPointWithBuffer = startPoint + initialHeading * 22.0;
		}
		
		
		
		testedPoints.PushBack( endPoint );
		testedPoints.PushBack( endPointWithBuffer );
		
		for( i = 0; i < 2; i += 1 )
		{
			
			bridgeCheckUp = testedPoints[i];
			bridgeCheckUp.Z += 5.0;
			bridgeCheckDown = testedPoints[i];
			bridgeCheckDown.Z -= 10.0;	
			if( !theGame.GetWorld().SweepTest( bridgeCheckUp, bridgeCheckDown, 0.05, bridgeCheckOutPoint, normal, waterCheckCollisionGroups ) )
			{
				waterDepth = theGame.GetWorld().GetWaterDepth( testedPoints[i], true );
				
				
				
				
				
				if( waterDepth > WATER_MAX_DEPTH && waterDepth != 10000.0 ) 
				{
					return false;
				}
			}
			else
			{
				
				
			}
		}
		
		return true;
	}
	
	private function PerformFallJumpTest() : bool
	{
		var startPoint, endPoint, endPointWithZOffsetUp, endPointWithZOffsetDown, intersectionPoint, tempVector : Vector;
		var afterLandingEndPoint : Vector;
		var initialHeading : Vector;
		var anticipationDist : float;
		var afterLandingDist : float;
		var angle : float;
		
		startPoint = parent.GetWorldPosition();
		initialHeading = parent.GetHeadingVector();

		if( currSpeed <= TROT_SPEED )
		{
			anticipationDist = 5.0;
			afterLandingDist = 4.0;
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			anticipationDist = 7.0;
			afterLandingDist = 5.0;
		}
		else 
		{
			anticipationDist = 9.0;
			afterLandingDist = 6.0;
		}
		
		endPoint = startPoint + initialHeading * anticipationDist;
		
		
		endPointWithZOffsetUp = endPoint;
		endPointWithZOffsetUp.Z += 10.0;
		endPointWithZOffsetDown = endPoint;
		
		if( theGame.GetWorld().StaticTrace( endPointWithZOffsetUp, endPointWithZOffsetDown, intersectionPoint, tempVector, inclinationCheckCollisionGroups ) )
		{
			
			afterLandingEndPoint = intersectionPoint + initialHeading * afterLandingDist;
			angle = GetInclinationBetweenPoints( intersectionPoint, afterLandingEndPoint, tempVector, 4.5 );
			
			
			
			
			
			if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE )
			{
				return false;
			}
			else
			{
				
				angle = GetInclinationBetweenPoints( afterLandingEndPoint, afterLandingEndPoint - parent.GetWorldRight()*0.5 , tempVector, 4.5 );
				if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE || angle > 90 )
				{
					return false;
				}
				
				
				angle = GetInclinationBetweenPoints( afterLandingEndPoint, afterLandingEndPoint + parent.GetWorldRight()*0.5 , tempVector, 4.5 );
				if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE || angle > 90 )
				{
					return false;
				}
				
				
				angle = GetLocalInclination( tempVector );
				if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE )
					return false;
				else
					return true;
			}
		}

		
		endPointWithZOffsetUp = endPoint;
		endPointWithZOffsetDown = startPoint + initialHeading * ( anticipationDist + 4.0 );
		endPointWithZOffsetDown.Z -= 8.0;

		if( !theGame.GetWorld().StaticTrace( endPointWithZOffsetUp, endPointWithZOffsetDown, intersectionPoint, tempVector, inclinationCheckCollisionGroups ) )
		{
			return false;
		}
		else
		{
			
			afterLandingEndPoint = intersectionPoint + initialHeading * afterLandingDist;
			angle = GetInclinationBetweenPoints( intersectionPoint, afterLandingEndPoint, tempVector, 4.5 );
			
			
			
			if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE )
			{
				return false;
			}
			else	
			{
				
				angle = GetLocalInclination( tempVector );
				if( angle < -INCLINATION_MAX_ANGLE || angle > INCLINATION_MAX_ANGLE )
					return false;
				else
					return true;
			}
		}
		
		return true;
	}
	
	private function PerformObstructionJumpTest() : bool
	{
		var startPoint, endPoint, tempEndPoint, normal : Vector;
		var initialHeading : Vector;

		startPoint = parent.GetWorldPosition();
		initialHeading = parent.GetHeadingVector();
		endPoint = startPoint + initialHeading * 3.0;

		startPoint.Z += 1.5;
		endPoint.Z += 1.5;
		
		if( theGame.GetWorld().StaticTrace( startPoint, endPoint, tempEndPoint, normal, inclinationCheckCollisionGroups ) )
		{
			return false;
		}

		return true;
	}
	
	private function PerformAutoJumpTest( stickInputX : float, stickInputY : float ) : bool
	{
		var startPoint : Vector;
		var testedHeading : Vector;
		var inputVec : Vector;
		var horseHeadingVec : Vector;
		var furthestAccessiblePointForJumpTest : Vector;
		var angleDistanceBetweenInputAndHorse : float;
		var angleDistanceBetweenCameraAndHorse : float;
		var anticipationDist : float;
		var afterLandingDist : float;
		
		startPoint = parent.GetWorldPosition();
		
		
		if( stickInputX || stickInputY )
		{
			inputVec = GetInputVectorInCamSpace( stickInputX, stickInputY );
			horseHeadingVec = parent.GetHeadingVector();
					
			testedHeading = VecNormalize2D( inputVec * 0.25 + horseHeadingVec * 1.0 );
		}
		else
		{
			testedHeading = parent.GetHeadingVector();
		}
		
		
		if( theInput.IsActionPressed( 'Canter' ) ) 
		{
			if( !LineTest( startPoint, testedHeading, 2.5, 1.0, furthestAccessiblePointForJumpTest, true ) ) 
			{
				if( SweepTest( startPoint, testedHeading, anticipationDist, 0.9, 0.45 ) ) 
				{
					return false;	
				}
				
				angleDistanceBetweenInputAndHorse = AbsF( AngleDistance( VecHeading( inputVec ), parent.GetHeading() ) );
				angleDistanceBetweenCameraAndHorse = AbsF( AngleDistance( VecHeading( theCamera.GetCameraDirection() ), parent.GetHeading() ) );
				if( ( !( stickInputX || stickInputY ) && angleDistanceBetweenCameraAndHorse <= 45 ) || ( ( stickInputX || stickInputY ) && angleDistanceBetweenInputAndHorse <= 45 ) )
				{
					if( currSpeed == CANTER_SPEED )
					{
						anticipationDist = 8.0;
						afterLandingDist = 4.0;
					}
					else
					{
						anticipationDist = 6.5;
						afterLandingDist = 3.0;
					}
					
					if( CircleTest( startPoint, testedHeading, anticipationDist, 0.5 ) ) 
					{
						if( SweepTest( startPoint, testedHeading, anticipationDist, 2.1, 0.75 ) ) 
						{
							if( LineTest( startPoint + testedHeading * anticipationDist, testedHeading, afterLandingDist, 0.0, furthestAccessiblePointForJumpTest ) ) 
							{
								return true;
							}
						}
					}
				}
			}
		}

		return false;
	}
	
	private function GetInputVectorInCamSpace( stickInputX : float, stickInputY : float ) : Vector
	{
		var inputVec : Vector;
		var inputHeading : float;
		
		inputVec.X = stickInputX;
		inputVec.Y = stickInputY;
		inputVec = VecNormalize2D(inputVec);
		inputHeading = AngleDistance( theCamera.GetCameraHeading(), -VecHeading( inputVec ) ); 
		inputVec = VecFromHeading( inputHeading );
		
		return inputVec;
	}
	
	private function GetInputVectorInLocalSpace( stickInputX : float, stickInputY : float ) : Vector
	{
		var inputVec : Vector;
		var inputHeading : float;
		
		inputVec.X = stickInputX;
		inputVec.Y = stickInputY;
		inputVec = VecNormalize2D(inputVec);
		inputHeading = AngleDistance( parent.GetEntity().GetHeading(), -VecHeading( inputVec ) ); 
		inputVec = VecFromHeading( inputHeading );
		
		return inputVec;
	}
	
	

			
	
	private const var NAVTEST_RADIUS : float;
	
	default NAVTEST_RADIUS = 0.2; 
	
	private function LineTest( startPos : Vector, heading : Vector, anticipationDist : float, speedFactor : float, out furthestAccessiblePoint : Vector, optional sideTests : bool ) : bool
	{
		var endPos : Vector;
		var endPosLeft, endPosRight : Vector;
		
		endPos = startPos + heading * anticipationDist + ( parent.GetHeadingVector() * speedFactor * currSpeed );
				
		if( theGame.GetWorld().NavigationLineTest( startPos, endPos, NAVTEST_RADIUS, false, true ) ) 
		{
			
			return true;
		}
		else if( sideTests )
		{
			
			
			endPosLeft = startPos + VecRotateAxis( endPos - startPos, Vector( 0, 0, 1 ), Deg2Rad( 30.0 ) );
			endPosRight = startPos + VecRotateAxis( endPos - startPos, Vector( 0, 0, 1 ), Deg2Rad( -30.0 ) );
			
			if( theGame.GetWorld().NavigationLineTest( startPos, endPosLeft, NAVTEST_RADIUS, false, true ) )
			{
				
				return true;
			}
			else if ( theGame.GetWorld().NavigationLineTest( startPos, endPosRight, 0.15, false, true ) )
			{
				
				
				return true;
			}
			else
			{
				
				
				theGame.GetWorld().NavigationClearLineInDirection( startPos, endPos, NAVTEST_RADIUS, furthestAccessiblePoint ); 
				return false;
			}
			
		}
		else
		{
			
			theGame.GetWorld().NavigationClearLineInDirection( startPos, endPos, NAVTEST_RADIUS, furthestAccessiblePoint ); 
			return false;
		}
	}
	
	private function CircleTest( startPos : Vector, heading : Vector, anticipationDist : float, radius : float ) : bool 
	{
		var endPos : Vector;
		var dummyFloat : float;
	
		endPos = startPos + heading * anticipationDist;
		
		
		
		
		if( theGame.GetWorld().NavigationCircleTest( endPos, radius ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( endPos, endPos.Z - 4.0, endPos.Z + 1.0, dummyFloat ) ) 
			{
				return true;
			}
			else
			{
				return false;
			}
		}	
		else
		{
			return false;
		}
	}
	
	private function SweepTest( startPos : Vector, heading : Vector, anticipationDist : float, heightOffset : float, radius : float ) : bool
	{
		var endPos, outPos, normal : Vector;
		
		endPos = startPos + heading * anticipationDist;
	
		startPos.Z += heightOffset;
		endPos.Z += heightOffset;
		
		
		
		
		if( !theGame.GetWorld().SweepTest( startPos, endPos, radius, outPos, normal, inclinationCheckCollisionGroups ) ) 
			return true;
		else
			return false;
	}
	
	
	
	
	
	
	private var isReversing : bool;
	
	
	
	private var rl, fb : float; 
	private final function UpdateLogic( dt : float )
	{
		var actorParent : CActor;
		var player : W3PlayerWitcher;
		var slidingDisablesControll : bool;
		
		
		var waterDepth : float;
		var lookatPos : Vector;
		
		if(!thePlayer.GetIsHorseRacing())
			parentActor.SetBehaviorVariable( 'isRearingEnabled', 1.0 );
		else
			parentActor.SetBehaviorVariable( 'isRearingEnabled', 0.0 );
			
		waterDepth = GetSubmergeDepth();
		parentActor.SetBehaviorVariable( 'submergeDepth', ClampF( waterDepth, -5.0, 5.0 ) );
		
		if(waterDepth < -0.6f)
		{
			lookatPos = parentActor.GetWorldPosition() + VecConeRand(parentActor.GetHeading(), 0, 5,5) + Vector(0,0,2);
			
			parentActor.SetBehaviorVectorVariable( 'lookAtTarget', lookatPos );
			parentActor.SetBehaviorVariable( 'headWaterDepth', ClampF(-waterDepth/1.5, 0, 1) );
			parentActor.SetBehaviorVariable( 'lookatOn', 1.0f );
		}
		else
		{
			parentActor.SetBehaviorVariable( 'headWaterDepth', 0.f );
		}
		
		
		
		if( waterDepth < -2.f || CheckSliding( slidingDisablesControll ) )
			OnHideHorse();
			
		if( roadFollowBlock > 0.0 )
		{
			roadFollowBlock -= dt;
			if( roadFollowBlock < 0.0 )
				roadFollowBlock = 0.0;
		}
		
		useSimpleStaminaManagement = parent.ShouldUseSimpleStaminaManagement();
		
		if( thePlayer.GetIsMovable() && IsHorseControllable() && !dismountRequest && !slidingDisablesControll )
		{
			rl = theInput.GetActionValue( 'GI_AxisLeftX' );
			fb = theInput.GetActionValue( 'GI_AxisLeftY' );
		}
		else
		{
			rl = 0.0;
			fb = 0.0;
		}

		
		
		
		
		
		
		isReversing	= false;
		if(currSpeed == MIN_SPEED && fb < 0.f && parent.lastRider == thePlayer )
		{
			isReversing	= true;
		}	
		
		
		
		SetTimeoutForCurrentSpeed();
		MaintainCameraVariables( dt );
		
		
		if( ( !useSimpleStaminaManagement && destSpeed > GALLOP_SPEED ) || ( !IsSpeedLocked() && destSpeed > MIN_SPEED && !rl && !fb ) || ( !IsSpeedLocked() && destSpeed > TROT_SPEED ) )
		{
			if( maintainSpeedTimer > speedTimeoutValue )
			{
				destSpeed = MaxF( MIN_SPEED, destSpeed - 1.f );
				maintainSpeedTimer = 0.0;
			}
			else
			{
				maintainSpeedTimer += dt;
			}
		}
		
		actorParent = (CActor)parent.GetEntity();
		
		if ( useSimpleStaminaManagement && currSpeed > GALLOP_SPEED && !isFollowingRoad )
		{
			
			if(thePlayer.GetIsHorseRacing())
				actorParent.DrainStamina( ESAT_FixedValue, 3.33f*dt, 1.f, '', 0.f, 1.f );
			else
				actorParent.DrainStamina( ESAT_FixedValue, 3.33f*dt, 1.f, '', 0.f, 0.45f );
			
			if ( actorParent.GetStat( BCS_Stamina ) <= 0.f )
			{
				staminaBreak = true;
				staminaCooldownTimer = 0.f;
				theGame.VibrateControllerVeryLight();	
			}
		}
		
		destSpeed = MinF( destSpeed, speedRestriction );
		
		if( currSpeed > destSpeed && currSpeed < GALLOP_SPEED )
			PlayVoicesetSlowerHorse();
		
		ProcessControlInput( rl, fb, dt, parent.IsControllableInLocalSpace() || parent.riderSharedParams.mountStatus == VMS_mountInProgress );
		
		if( !PerformNavDataTest() && !isInJumpAnim ) 
		{		
			if( PerformInclinationTest( rl, fb ) && PerformWaterTest( rl, fb, waterDepth  ) ) 
			{
				ToggleSpeedLock( 'OnNavStop', false );
				
				if( PerformAutoJumpTest( rl, fb ) )
				{
					Jump();
				}
				
				
				parentActor.SetBehaviorVariable( 'canSlowWalk', 1.0f );
			}
			else if( !isFollowingRoad && !parent.ShouldIgnoreTests() )
			{			
				destSpeed = MIN_SPEED;
				ToggleSpeedLock( 'OnNavStop', true );
				if( !isRefusingToGo && parent.isInIdle && CanPlayCollisionAnim() && ( rl != 0.0 || fb != 0.0 ) && !isReversing ) 
				{
					parent.GenerateEvent( 'WallCollision' );
					collisionAnimTimestamp = theGame.GetEngineTimeAsSeconds();
				}	
				
				
				if(parent.lastRider == thePlayer)
				{
					parentActor.SetBehaviorVariable( 'canSlowWalk', 0.0f );
					isReversing = false;
				}
			}
			else
			{
				ToggleSpeedLock( 'OnNavStop', false );
				
				
				parentActor.SetBehaviorVariable( 'canSlowWalk', 1.0f );
			}
		}
		else
		{
			ToggleSpeedLock( 'OnNavStop', false );
			
			
			parentActor.SetBehaviorVariable( 'canSlowWalk', 1.0f );
		}
		
		if( requestJump )
		{
			if( PerformObstructionJumpTest() && PerformWaterJumpTest() && PerformFallJumpTest() )
			{
				Jump();
			}
			else
			{
				if( !isRefusingToGo && parent.isInIdle && CanPlayCollisionAnim() && !isReversing ) 
				{
					parent.GenerateEvent( 'WallCollision' );
					collisionAnimTimestamp = theGame.GetEngineTimeAsSeconds();
				}
				requestJump = false;
			}
		}
		
		if( staminaBreak )
		{
			if ( staminaCooldownTimer > staminaCooldown )
			{
				staminaBreak = false;
			}
			
			staminaCooldownTimer += dt;
			
			
			if(!isReversing)
				currSpeed = MinF( GALLOP_SPEED, currSpeed );			
			
			
			destSpeed = currSpeed;
		}
		
	
		if ( currSpeed != destSpeed )
		{
			
			if(!isReversing)
				currSpeed = destSpeed;
			
			
			if ( currSpeed == MIN_SPEED && !parent.isInIdle )
				isSlowlyStopping = true;
			else
				isSlowlyStopping = false;
		}
		
		parent.InternalSetSpeedMultiplier( 1.f );
		parent.InternalSetSpeed( currSpeed );
		
		
		if(parent.lastRider == thePlayer)
		{
			parent.SetDistanceBasedSpeed( VecDistance(cachedPos,parent.GetWorldPosition()) );	
			cachedPos = parent.GetWorldPosition();
		
			if(isReversing)
				parentActor.SetBehaviorVariable( 'reverse', 1.0f );	
			else
				parentActor.SetBehaviorVariable( 'reverse', 0.0f );	
		}
		
		

		
		CalculateSoundParameters( dt );
		thePlayer.SoundParameter( "horse_speed", currSpeedSound, 'head' ); 
		actorParent.SoundParameter( "horse_stamina", actorParent.GetStatPercents( BCS_Stamina ) * 100 ); 
	}
	
	private var cachedPos : Vector; 
	
	
	private var startSlidingTimeStamp : float;
	private var notSlidingTimeStamp : float;
	
	private const var SLIDING_MINSLIDINGCOEF 		: float;
	private const var SLIDING_MAXSLIDINTIME 		: float;
	private const var SLIDING_MAXROTATIONSPEED		: float;
	
	default SLIDING_MINSLIDINGCOEF 		= 0.4f;
	default SLIDING_MAXSLIDINTIME 		= 2.5f;
	default SLIDING_MAXROTATIONSPEED 	= 60.f;
	
	private final function CheckSliding( out _slidingDisablesControll : bool ) : bool
	{
		var mac : CMovingPhysicalAgentComponent;
		var movementAdjustor	: CMovementAdjustor;
		var ticket, emptyTicket	: SMovementAdjustmentRequestTicket;
		var l_sliding, l_onGround : bool;
		var l_slidingTime, l_slideCoef : float;
		var l_slideDir : Vector;
		
		_slidingDisablesControll = false;
		
		mac = (CMovingPhysicalAgentComponent)parentActor.GetMovingAgentComponent();
		
		if ( mac )
		{
			l_sliding = mac.IsSliding();
			l_onGround = mac.IsOnGround();
			
			if ( l_sliding || ( !l_onGround && !isInJumpAnim ) )
			{
				notSlidingTimeStamp = -1.f;
				
				if ( startSlidingTimeStamp <= 0.f )
					startSlidingTimeStamp = theGame.GetEngineTimeAsSeconds();
				
				if ( l_sliding )
				{
					l_slideDir = mac.GetSlideDir();
					l_slideCoef = mac.GetSlideCoef();
					
					
					
					LogChannel('HorseSliding',"Sliding Coef: " + l_slideCoef );
					movementAdjustor = mac.GetMovementAdjustor();
					ticket = movementAdjustor.GetRequest('HorseSliding');
					if ( ticket == emptyTicket )
						ticket = movementAdjustor.CreateNewRequest('HorseSliding');
					movementAdjustor.MaxRotationAdjustmentSpeed( ticket,SLIDING_MAXROTATIONSPEED );
					movementAdjustor.RotateTo(ticket,VecHeading( l_slideDir ) );
					_slidingDisablesControll = true;
				}
				
				l_slidingTime = theGame.GetEngineTimeAsSeconds() - startSlidingTimeStamp;
				
				if ( l_slidingTime >= SLIDING_MAXSLIDINTIME && l_slideCoef >= SLIDING_MINSLIDINGCOEF  )
				{
					LogChannel('HideHorse',"Hide reason: slidingTime: " + l_slidingTime + " and slideCoef: " + l_slideCoef);
					return true;
				}
			}
			else
			{
				movementAdjustor = mac.GetMovementAdjustor();
				movementAdjustor.CancelByName('HorseSliding');
				mac.SetEnabledFeetIK( true, 0.5 );
				if ( notSlidingTimeStamp <= 0 )
					notSlidingTimeStamp = theGame.GetEngineTimeAsSeconds();
				
				
				if ( theGame.GetEngineTimeAsSeconds() - notSlidingTimeStamp >= 0.5 )
				{
					if ( startSlidingTimeStamp > 0.f )
					{
						l_slidingTime = theGame.GetEngineTimeAsSeconds() - startSlidingTimeStamp;
						LogChannel('HorseSliding',"Sliding Stopped. Slide time: " + l_slidingTime );
					}
					startSlidingTimeStamp = -1.f;
				}
			}
		}
		
		return false;
	}
	
	
	
	
	
	
	private var requestJump 	: bool;
	private var isInJumpAnim 	: bool;
	
	private final function Jump()
	{
		if( !((CActor)parent.GetEntity()).IsInAir() )
		{
			parent.GenerateEvent( 'jump' );	
		}
		
		requestJump = false;
	}
	
	event OnBehJumpStarted()
	{
		var horse : CActor;
		horse = (CActor)parent.GetEntity();
		
		isInJumpAnim = true;
		requestJump = false;
		startTestingLanding = false;
		jumpStartPos = parent.GetEntity().GetWorldPosition();
		
		parent.SetVariable( 'onGround', 0.f );
		
		horse.AddAnimEventChildCallback(parent,'Jumping','OnAnimEvent_Jumping');
		((CMovingPhysicalAgentComponent)horse.GetMovingAgentComponent()).SetAnimatedMovement( true );
		horse.SetIsInAir(true);
		
		parent.userCombatManager.OnAirBorn();
		theGame.CreateNoSaveLock( 'horse_in_air', noSaveLock );
		
		theGame.GetGuiManager().DisableHudHoldIndicator();	
	}
	
	event OnBehJumpEnded()
	{
		var horse : CActor;
		horse = (CActor)parent.GetEntity();
		
		horse.RemoveAnimEventChildCallback(parent,'Jumping');
		
		isInJumpAnim = false;
		theGame.ReleaseNoSaveLock( noSaveLock );
		if ( parent.user == thePlayer )
			theGame.GetGuiManager().EnableHudHoldIndicator(IK_Pad_B_CIRCLE, IK_None, "panel_input_action_horsedismount", 0.4, 'HorseDismount');
	}
	
	event OnHideHorse()
	{
		parent.OnHideHorse();
	}
	
	event OnKillHorse()
	{
		parent.OnKillHorse();
	}
	
	private var startTestingLanding : bool;
	
	event OnAnimEvent_Jumping( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var mac : CMovingPhysicalAgentComponent;
		if( animEventType == AET_DurationStart )
		{
			startTestingLanding = true;
		}
		else
		{
			mac = (CMovingPhysicalAgentComponent)((CActor)parent.GetEntity()).GetMovingAgentComponent();
			if( mac.IsOnGround() )
				OnHitGround();
		}
	}
	
	event OnHitGround()
	{
		var horse : CActor;
		horse = (CActor)parent.GetEntity();
		
		if( horse.IsInAir() && startTestingLanding )
		{
			jumpEndPos = parent.GetEntity().GetWorldPosition();
			
			if( parent.CanTakeDamageFromFalling() )
			{
				((CGameplayEntity)parent.GetEntity()).OnDamageFromFalling( parent, 0.0, -(jumpStartPos.Z - jumpEndPos.Z) + 5.0 );
			}
			else
			{
				parent.SetCanTakeDamageFromFalling( true );
			}

			EndJump();
			
			theGame.VibrateControllerLight();	
			if ( parent.user == thePlayer )
				theGame.GetGuiManager().EnableHudHoldIndicator(IK_Pad_B_CIRCLE, IK_None, "panel_input_action_horsedismount", 0.4, 'HorseDismount');
		}
	}

	function EndJump()
	{
		var horse : CActor;
		horse = (CActor) parent.GetEntity();

		if ( horse && horse.IsInAir() )
		{
			parent.SetVariable( 'onGround', 1.f );

			((CMovingPhysicalAgentComponent)horse.GetMovingAgentComponent()).SetAnimatedMovement( false );
			horse.SetIsInAir( false );
			
			parent.userCombatManager.OnLanded();
		}
	}
	
	event OnCheckHorseJump()
	{
		return isInJumpAnim;
	}
	
	
	
	
	
	private var maintainSpeedTimer : float;
	private var speedTimeoutValue : float;
	private var accelerateTimestamp : float;
	private const var DOUBLE_TAP_WINDOW	: float;
	
	default DOUBLE_TAP_WINDOW = 0.4;
	
	private function CanCanter() : bool
	{
		return ( thePlayer.m_SettlementBlockCanter < 1 ) || ( thePlayer.GetIsHorseRacing() ); 
	}
	
	
	event OnSpeedPress( action : SInputAction )
	{
		var actorParent : CActor;
		
		if( IsHorseControllable() && !dismountRequest && thePlayer.IsActionAllowed( EIAB_Movement ) )
		{
			if( IsPressed( action ) )			
			{
				
				if( accelerateTimestamp + DOUBLE_TAP_WINDOW >= theGame.GetEngineTimeAsSeconds() )
				{
					triedDoubleTap = true;
				}
				else
				{
					triedDoubleTap = false;
				}
				
				if(CanCanter() && (!IsSpeedLocked() || speedLocks.Contains( 'OnAttack' )) )
				{
					if( currSpeed >= CANTER_SPEED )
					{
						destSpeed = CANTER_SPEED;
						ToggleSpeedLock( 'OnGallop', true );
					}
					else if(triedDoubleTap)
					{
						destSpeed = CANTER_SPEED;

						SpursKick();							
						
						if( useSimpleStaminaManagement )
							ToggleSpeedLock( 'OnGallop', true );
					}
					
					if( !FactsDoesExist("debug_fact_stamina_pony") && !useSimpleStaminaManagement )
					{
						if( destSpeed > GALLOP_SPEED )
						{
							actorParent = (CActor)parent.GetEntity();
							
							
							
							
							if( actorParent.GetStat( BCS_Stamina ) < 0.1f )
							{
								staminaBreak = true;
								staminaCooldownTimer = 0.f;
							}
						}
					}
				}
				
				accelerateTimestamp = theGame.GetEngineTimeAsSeconds();
				maintainSpeedTimer = 0.f;				
			}			
			else if( IsReleased( action ) )
			{
				shouldGoToCanterAfterStop = false;
				ToggleSpeedLock( 'OnGallop', false );
			}
		}
	}
	
	
	event OnSpeedHold( action : SInputAction )
	{
		var horseCompToFollow : W3HorseComponent;

		thePlayer.SetBehaviorVariable( 'playerWouldLikeToMove', 1.0f );
		
		if( IsHorseControllable() && IsPressed( action ) && !dismountRequest )
		{	
			if ( !IsSpeedLocked() && OnCanCanter() )
			{
				
				GallopPressed();
				SpursKick();
			}
		}
		else if( IsReleased( action ) )
		{
			ToggleSpeedLock( 'OnGallop', false );
		}
		
		
		if( triedDoubleTap && !CanCanter() && IsPressed( action ) )
		{
			thePlayer.DisplayActionDisallowedHudMessage( EIAB_Undefined, , thePlayer.m_SettlementBlockCanter >= 1 );
		}
	}
	
	event OnDecelerate( action : SInputAction )
	{
		if( IsReleased( action ) )
		{
			if( IsHorseControllable() && !IsRiderInCombatAction() && !dismountRequest )
			{
				if( currSpeed == MIN_SPEED )
				{
					parent.GenerateEvent( 'rearing' );
				}
			}
		}
	}
	
	event OnStop( action : SInputAction )
	{
		if( IsPressed( action ) && IsHorseControllable() && !dismountRequest )
		{
			destSpeed = MIN_SPEED;
			ToggleSpeedLock( 'OnStop', true );
			
			if(ShouldProcessTutorial('TutorialHorseStop'))
			{
				FactsAdd("tut_horse_stopping");
			}
		}
		else if( IsReleased( action ) )
		{
			ToggleSpeedLock( 'OnStop', false );
			parent.InternalSetDirection( 0.f );
			if(ShouldProcessTutorial('TutorialHorseStop'))
			{
				FactsRemove("tut_horse_stopping");
			}
		}
	}
	
	private var jumpPressTimestamp : float;
	
	event OnHorseJump( action : SInputAction )
	{
		var dummyParameter : Vector;
		
		if ( IsPressed( action ) )
			jumpPressTimestamp = theGame.GetEngineTimeAsSeconds();
		
		if ( thePlayer.playerAiming.GetCurrentStateName() == 'Aiming' )
			return false;
		
		if( IsHorseControllable() && !IsRiderInCombatAction() && parent.IsFullyMounted() && parent.GetPanicPercent() < 0.99 )
		{
			if( !dismountRequest && IsReleased( action ) && ( jumpPressTimestamp + 0.2 > theGame.GetEngineTimeAsSeconds() )&& thePlayer.GetIsMovable() && !isInJumpAnim )
			{
				requestJump = true;	
				
			}
		}
	}
		
	event OnHorseDismountKeyboard( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			if( !DismountHorse() )
			{
				theInput.ForceDeactivateAction('HorseJump');
			}
			else
			{
				theGame.GetGuiManager().DisableHudHoldIndicator();
			}
		}
	}
	
	event OnHorseDismount()
	{
		if( !DismountHorse() )
		{
			theInput.ForceDeactivateAction('HorseJump');
		}
		else
		{
			theGame.GetGuiManager().DisableHudHoldIndicator();
		}
	}
	
	private function DismountHorse() : bool
	{
		
		if ( thePlayer.IsActionAllowed( EIAB_DismountVehicle ) && !theGame.IsDialogOrCutscenePlaying() && theInput.GetContext() != 'Scene' && !theGame.IsFading() && !theGame.IsBlackscreen() && !IsRiderInCombatAction() && !isInJumpAnim && !dismountRequest && parent.canDismount && !parent.IsInHorseAction() )
		{
			SetupDismount();
			return true;
		}
		return false;
	}
	
	event OnSmartDismount()
	{
		SetupDismount();
	}
	
	public function SetupDismount()
	{
		if( ( currSpeed == MIN_SPEED && !isSlowlyStopping ) || isStopping || isReversing ) 
		{
			OnForceStop();
			parent.user.SetBehaviorVariable('dismountType',0.f);
		}
		else if( currSpeed >= GALLOP_SPEED && VecLength2D( GetHorseVelocity() ) > 6.0 )
		{
			parent.user.SetBehaviorVariable('dismountType',2.f);
			destSpeed = GALLOP_SPEED;
		}
		else
		{
			parent.user.SetBehaviorVariable('dismountType',1.f);
			destSpeed = TROT_SPEED;
		}
		
		if( !isStopping )
			parent.IssueCommandToDismount( DT_normal );
		
		dismountRequest = true;
	}
	
	
	
	
	
	private function IsRiderInCombatAction() : bool
	{
		return parent.userCombatManager.IsInCombatAction();
	}
	
	private final function UpdateDebugGUI()
	{
		var p : float;
		var text : string;
		var rot : EulerAngles;
		
		var actorParent : CActor;
		
		rot = parent.GetWorldRotation();
		
		p = currSpeed / 2.f;
		text = "Speed: " + currSpeed;
		
		thePlayer.GetVisualDebug().AddBarColorAreas( 'horseSpeed', 50, 50, 250, 50, p, text );
		
		thePlayer.GetVisualDebug().AddBar( 'horseStamina', 305, 50, 25, 50, 1.f, Color(0,0,0) );
		
		actorParent = (CActor)parent.GetEntity();
		if ( !staminaBreak )
		{
			text = "Stamina: " + actorParent.GetStat( BCS_Stamina );
		}
		else
		{
			text = "Stamina: " + actorParent.GetStat( BCS_Stamina ) + " <break>";
		}
		p = actorParent.GetStatPercents( BCS_Stamina );
		thePlayer.GetVisualDebug().AddBarColorSmooth( 'horseStaminaBar', 50, 110, 280, 30, p, Color(255,255,0), text );
		
		text = "Panic: " + actorParent.GetStat( BCS_Panic ) + " / " + actorParent.GetStatMax( BCS_Panic );
		p = actorParent.GetStatPercents( BCS_Panic );
		thePlayer.GetVisualDebug().AddBarColorAreas( 'horsePanic', 50, 150, 280, 30, p, text );
		
		text = "pitch: " + rot.Pitch;
		thePlayer.GetVisualDebug().AddBarColorSmooth( 'pitch', 50, 180, 280, 30, 0, Color(0,255,0), text );
	}
	
	private function SetTimeoutForCurrentSpeed()
	{
		switch( currSpeed )
		{
			case CANTER_SPEED:
			{
				if( thePlayer.IsInCombat() )
					speedTimeoutValue = 2.0;
				else
					speedTimeoutValue = 0.5;
				break;
			}
			case GALLOP_SPEED:
			{
				if( thePlayer.IsInCombat() )
					speedTimeoutValue = 2.0;
				else
					speedTimeoutValue = 0.5;
				break;
			}
			case TROT_SPEED:
				if ( dismountRequest )
					speedTimeoutValue = 0.5;
				else
					speedTimeoutValue = 0.0;
				break;
			
			case WALK_SPEED:
				if ( dismountRequest )
					speedTimeoutValue = 0.5;
				else
					speedTimeoutValue = 0.0;
				break;
				
			case SLOW_SPEED:
				if ( dismountRequest )
					speedTimeoutValue = 0.5;
				else
					speedTimeoutValue = 0.0;
				break;
				
			case MIN_SPEED:
				speedTimeoutValue = 0.0;
				break;
		}
	}
	
	private function IsHorseControllable() : bool
	{
		var actor : CActor;
		
		actor = (CActor)parent.GetEntity();
		
		return actor && actor.GetBaseAttitudeGroup() != 'animals_peacefull' && parent.controllable;
	}
	
	private function MaintainCameraVariables( dt : float )
	{
		if( currSpeed == CANTER_SPEED )
		{
			parent.inCanter = true;
			parent.inGallop = false;
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			parent.inGallop = true;
			parent.inCanter = false;
		}
		else
		{
			parent.inCanter = false;
			parent.inGallop = false;
		}
	}
	
	private function MaintainGrassCollider()
	{
		if( !grassCollider )
			return;
			
		if( currSpeed == CANTER_SPEED )
		{
			grassCollider.SetPosition( Vector( 1.5, -0.3, 0.0, 1.0 ) );
		}
		else if( currSpeed == GALLOP_SPEED )
		{
			grassCollider.SetPosition( Vector( 1.1, -0.3, 0.0, 1.0 ) );
		}
		else
		{
			grassCollider.SetPosition( Vector( 0.7, -0.3, 0.0, 1.0 ) );
		}
	}
	
	private function GallopPressed()
	{
		if( OnCanCanter() )
		{
			
			if( currSpeed < GALLOP_SPEED && destSpeed != CANTER_SPEED && !isStopping  )
				destSpeed = GALLOP_SPEED;
			
			ToggleSpeedLock( 'OnGallop', true );
		}
	}
	
	private function SpursKick()
	{
		
		if(isReversing)
			return;
	
		if( !IsRiderInCombatAction() && currSpeed < destSpeed )
		{
			if( currSpeed != GALLOP_SPEED )
			{
				PlayVoicesetFasterHorse();
				
				if( destSpeed == CANTER_SPEED )
					parent.GenerateEvent( 'spursKickHard' );
				else
					parent.GenerateEvent( 'spursKick' );
			}
		}
	}
	
	private var voicsetTimeStamp : float;
	private var voicsetFasterTimeStamp : float;
	private var voicsetSlowerTimeSTamp : float;
	
	private const var VOICESET_COOLDOWN 		: float; default VOICESET_COOLDOWN			= 3.0;  
	private const var VOICESET_FASTER_COOLDOWN 	: float; default VOICESET_FASTER_COOLDOWN	= 10.0; 
	private const var VOICESET_SLOWER_COOLDOWN 	: float; default VOICESET_SLOWER_COOLDOWN	= 10.0; 
	
	private function PlayVoicesetFasterHorse()
	{
		var currentTime : float = theGame.GetEngineTimeAsSeconds();
		
		if( thePlayer.IsInGameplayScene() )
		{
			return;
		}
		
		if ( CanPlayVoiceset(currentTime) && voicsetFasterTimeStamp + VOICESET_FASTER_COOLDOWN <= currentTime && RandRange(100) < 25 )
		{
			if ( parent.IsPlayerHorse() )
				thePlayer.PlayVoiceset( 100,'FasterHorseRoach' );
			else
				thePlayer.PlayVoiceset( 100,'FasterHorse' );
			
			voicsetFasterTimeStamp = currentTime;
			voicsetTimeStamp = currentTime;
		}
	}
	
	private function PlayVoicesetSlowerHorse()
	{
		var currentTime : float = theGame.GetEngineTimeAsSeconds();
		
		if( thePlayer.IsInGameplayScene() )
		{
			return;
		}
		
		if ( CanPlayVoiceset(currentTime) && voicsetSlowerTimeSTamp + VOICESET_SLOWER_COOLDOWN <= currentTime && RandRange(100) < 25 )
		{
			if ( parent.IsPlayerHorse() )
				thePlayer.PlayVoiceset( 100,'SlowerHorseRoach' );
			else
				thePlayer.PlayVoiceset( 100,'SlowerHorse' );
			
			voicsetSlowerTimeSTamp = currentTime;
			voicsetTimeStamp = currentTime;
		}
	}
	
	private function CanPlayVoiceset( _currentTime : float ) : bool
	{
		return ( parent.user == GetWitcherPlayer() ) && !dismountRequest && thePlayer.IsUsingHorse() && !thePlayer.IsThreatened() && !thePlayer.IsSpeaking() && (voicsetTimeStamp + VOICESET_COOLDOWN <= _currentTime );
	}
	
	private function GetHorseVelocity() : Vector
	{
		return ((CActor)parent.GetEntity()).GetMovingAgentComponent().GetVelocity();
	}
	
	private function GetSubmergeDepth() : float
	{
		return ((CMovingPhysicalAgentComponent)((CActor)parent.GetEntity()).GetMovingAgentComponent()).GetSubmergeDepth();
	}
	
	private function IsHorseOnNavMesh() : bool
	{
		return ((CMovingPhysicalAgentComponent)((CActor)parent.GetEntity()).GetMovingAgentComponent()).IsOnNavigableSpace();
	}
	
	private function InitCollisionGroups()
	{
		inclinationCheckCollisionGroups.PushBack( 'Terrain' );
		inclinationCheckCollisionGroups.PushBack( 'Static' );
		inclinationCheckCollisionGroups.PushBack( 'Destructible' );
		inclinationCheckCollisionGroups.PushBack( 'Door' );
		
		waterCheckCollisionGroups.PushBack( 'Static' );
		waterCheckCollisionGroups.PushBack( 'Destructible' );
	}
	
	private function CalculateSoundParameters( dt : float )
	{
		if( desiredSpeedSound != currSpeed )
		{
			desiredSpeedSound = currSpeed;
		}
		
		currSpeedSound = InterpTo_F( currSpeedSound, desiredSpeedSound, dt, 2.0 );
	}
	
	private function ResetSoundParameters()
	{
		currSpeedSound = 0.0;
		desiredSpeedSound = 0.0;
	}
}