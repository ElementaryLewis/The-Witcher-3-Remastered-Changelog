/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SCameraDistanceParams 
{
	
	var horse_close_default : float;					default horse_close_default = -0.7f; 	
	var horse_close_gallop : float;						default horse_close_gallop = -0.9f;
	var horse_close_canter : float;						default horse_close_canter = -0.42f;	

	var horse_far_default : float;						default horse_far_default = 3.5f;
	var horse_far_gallop : float;						default horse_far_gallop = 4.1f;
	var horse_far_canter : float;						default horse_far_canter = 4.9f;

	var horse_fov_default : float;						default horse_fov_default = 60.0f;
	var horse_fov_gallop : float;						default horse_fov_gallop = 60.0f;
	var horse_fov_canter : float;						default horse_fov_canter = 60.0f;

	
	var cart_close_default : float;						default cart_close_default = -1.0f;
	var cart_close_gallop : float;						default cart_close_gallop = -1.6f;
	var cart_close_canter : float;						default cart_close_canter = -1.9f;

	var cart_far_default : float;						default cart_far_default = 4.5f;
	var cart_far_gallop : float;						default cart_far_gallop = 6.0f;
	var cart_far_canter : float;						default cart_far_canter = 7.0f;

	var cart_fov_default : float;						default cart_fov_default = 70.0f;
	var cart_fov_gallop : float;						default cart_fov_gallop = 80.0f;
	var cart_fov_canter : float;						default cart_fov_canter = 80.0f;
}

struct SCamDistConfig
{
	var close_default : float;
	var close_gallop : float;					
	var close_canter : float;			

	var far_default : float;					
	var far_gallop : float;						
	var far_canter : float;

	var fov_default : float;
	var fov_gallop : float;
	var fov_canter : float;
}

state HorseRiding in CR4Player extends UseGenericVehicle
{
	private var isCarriage : bool;
	private var dismountRequest : bool;
	private var vehicleCombatMgr : W3HorseCombatManager;
	
	private var meleeTicketRequest 	: int;
	private var rangeTicketRequest 	: int;
	
	private var scabbardsComp : CAnimatedComponent;
	
	default meleeTicketRequest		= -1;
	default rangeTicketRequest		= -1;
	
	var camDistConfig_horse : SCamDistConfig;
	var camDistConfig_cart : SCamDistConfig;

	private var initCamera : bool;
	
	private var hasInFlightLean		: bool;
	private var hasPendingLean		: bool;
	private var pendingLeanDir 	 	: float;
	private var pendingLeanSpeed 	: float;

	
	
	
	
	protected function Init()
	{
		super.Init();

		if( !vehicleCombatMgr )
		{
			vehicleCombatMgr = new W3HorseCombatManager in this;
		}
		
		vehicleCombatMgr.Setup( parent, vehicle );
		vehicleCombatMgr.GotoStateAuto();
		vehicle.SetCombatManager( vehicleCombatMgr );
		
		isCarriage = vehicle.GetEntity().HasTag( 'carriage_horse' );

		initCamera = true;
		
		CheckForWeapons();
		
		ProcessHorseRiding();

		InitCamDistConfigFroomParams();
	}

	protected function InitCamDistConfigFroomParams()
	{
		var camDistParams : SCameraDistanceParams;
		camDistParams = SCameraDistanceParams();

		
		camDistConfig_horse.close_default = camDistParams.horse_close_default;
		camDistConfig_horse.close_gallop = camDistParams.horse_close_gallop;
		camDistConfig_horse.close_canter = camDistParams.horse_close_canter;

		camDistConfig_horse.far_default = camDistParams.horse_far_default;
		camDistConfig_horse.far_gallop = camDistParams.horse_far_gallop;
		camDistConfig_horse.far_canter = camDistParams.horse_far_canter;

		camDistConfig_horse.fov_default = camDistParams.horse_fov_default;
		camDistConfig_horse.fov_gallop = camDistParams.horse_fov_gallop;
		camDistConfig_horse.fov_canter = camDistParams.horse_fov_canter;

		
		camDistConfig_cart.close_default = camDistParams.cart_close_default;
		camDistConfig_cart.close_gallop = camDistParams.cart_close_gallop;
		camDistConfig_cart.close_canter = camDistParams.cart_close_canter;

		camDistConfig_cart.far_default = camDistParams.cart_far_default;
		camDistConfig_cart.far_gallop = camDistParams.cart_far_gallop;
		camDistConfig_cart.far_canter = camDistParams.cart_far_canter;

		camDistConfig_cart.fov_default = camDistParams.cart_fov_default;
		camDistConfig_cart.fov_gallop = camDistParams.cart_fov_gallop;
		camDistConfig_cart.fov_canter = camDistParams.cart_fov_canter;
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		theTelemetry.LogWithName(TE_STATE_HORSE_RIDING);
		
		ChangeTicketPool( true );
		
		scabbardsComp = (CAnimatedComponent)( parent.GetComponent( "scabbards_skeleton" ) );
		scabbardsComp.SetBehaviorVariable( 'onHorse', 0.5 );
		
		thePlayer.SoundEvent( "amb_g_speed_wind_start", 'head' );
		
		
		parent.findMoveTargetDistMin = 20.f;
		
		parent.AddTimer( 'EnableDynamicCanter', 0.5 );
		
		parent.SetBehaviorVariable('playerRider', 1.f );
		
		BlockActions( true );

		dismountRequest = false;

		hasPendingLean = false;
		hasInFlightLean = false;
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		var camera : CCustomCamera;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		camera.EnableManualControl(true);
		cameraManualRotationDisabled = false;
		
		if( nextStateName == 'PlayerDialogScene' || nextStateName == 'NpcDialogScene' )
		{
			((W3HorseComponent)vehicle).OnStopTheVehicleInstant();
			parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
		}
		else
		{
			theGame.ActivateHorseCamera( false, 0.2f );
		}
		
		ChangeTicketPool( false );
		
		camera.fov = parent.GetExplorationCameraFov();

		scabbardsComp.SetBehaviorVariable( 'onHorse', 0.0 );
		
		thePlayer.SoundEvent( "amb_g_speed_wind_stop", 'head' );
		
		
		parent.findMoveTargetDistMin = 10.f;
		
		vehicleCombatMgr.Destroy();
		
		dismountRequest = false;
		
		BlockActions( false );

		super.OnLeaveState(nextStateName);
	}
	
	event OnCombatStart()
	{
		virtual_parent.OnCombatStart();
		parent.AddTimer( 'DrawWeaponIfNeeded', 0.f);
	}
	
	event OnCombatFinished()
	{
		virtual_parent.OnCombatFinished();
		parent.RemoveTimer('DrawWeaponIfNeeded');
	}

	event OnDismountActionScriptCallback()
	{
		((W3HorseComponent)vehicle).OnHorseDismount();
	}
	
	timer function DrawWeaponIfNeeded( dt: float, id : int )
	{
		var disableAutoSheathe : bool;
		var inGameConfigWrapper : CInGameConfigWrapper;
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		disableAutoSheathe = inGameConfigWrapper.GetVarValue( 'Accessibility', 'DisableAutomaticSwordSheathe' );
		if( disableAutoSheathe )
		{
			parent.RemoveTimer('DrawWeaponIfNeeded');
			return;
		}
		
		if( parent.IsInCombat() )
		{
			if ( parent.GetTarget() )
			{
				vehicleCombatMgr.OnDrawWeaponRequest();
				parent.RemoveTimer('DrawWeaponIfNeeded');
				thePlayer.ShouldAutoApplyOil();	
			}
		}
		else
			parent.RemoveTimer('DrawWeaponIfNeeded');
	}
	
	timer function EnableDynamicCanter( dt: float, id : int )
	{
		var horseComp : W3HorseComponent;
		
		horseComp = (W3HorseComponent)(((CR4PlayerStateHorseRiding)thePlayer.GetState( 'HorseRiding' )).vehicle);
		horseComp.OnEnableCanter();
	}
	
	event OnDeath( damageAction : W3DamageAction )
	{
		var target : CNode;
		var dismountDirection : float;
		var angleDistance : float;
		
		target = damageAction.attacker;
		
		if ( target )
		{
			angleDistance = NodeToNodeAngleDistance(target,virtual_parent);
			if ( AbsF(angleDistance) < 50 )
				dismountDirection = 0.f;
			else if ( angleDistance <= -50 )
				dismountDirection = 1.f;
			else
				dismountDirection = 2.f;
		}
		else
		{
			dismountDirection = 0.f;
		}
		virtual_parent.SetBehaviorVariable('dismountDirection', dismountDirection );
		
		virtual_parent.OnDeath( damageAction );
		
		parent.ClearCleanupFunction();
		PlayerDied();
	}
	
	
	
	
	
	entry function ProcessHorseRiding()
	{
		parent.SetCleanupFunction( 'RidingCleanup' );
		
		LogAssert( vehicle, "HorseRiding::ProcessHorseRiding - vehicle is null" );
		
		Sleep( 0.1f );
		
		while( !dismountRequest )
		{
			FindTarget();

			parent.BreakPheromoneEffect();
	
			Sleep( 0.2f );
		}
		if ( parent.IsAlive() )
		{
			parent.ClearCleanupFunction();
			parent.GotoState( 'DismountHorse', true );
		}
		
	}
	
	entry function PlayerDied()
	{
		var playerHorseRiderSharedParams : CHorseRiderSharedParams;
		parent.RaiseForceEvent( 'Death' );
		parent.BreakAttachment();
		parent.WaitForBehaviorNodeDeactivation('dismountRagdollEnd',0.5);
		parent.SetKinematic(false);
		parent.EnableCollisions( true );
		parent.EnableCharacterCollisions( true );
		parent.RegisterCollisionEventsListener();
		((W3HorseComponent)vehicle).OnDismountStarted(parent);
		parent.GetRiderData().OnInstantDismount(parent);
		playerHorseRiderSharedParams = parent.GetRiderData().sharedParams;
		playerHorseRiderSharedParams.mountStatus = VMS_dismounted;
		((W3HorseComponent)vehicle).OnDismountFinished(parent,EVS_driver_slot);
		parent.SetUsedVehicle( NULL );
	}
	
	cleanup function RidingCleanup()
	{
		vehicle.ToggleVehicleCamera( false );
		
		
		
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
		
		parent.EnableCharacterCollisions( true );
		parent.RegisterCollisionEventsListener();

		thePlayer.SetIsHorseMoving( false );
		thePlayer.SetIsOnHorse( false );

		OnStopSkippingTreeCollision();
	}
	
	
	
	

	private var currDesiredDist : float;
	private var cameraManualRotationDisabled : bool;
	
	private var wasTrailCameraActive : bool;
	private var trailCameraTimeStamp, trailCameraCooldown : float;
		
	default trailCameraCooldown = 1.5;
	default wasTrailCameraActive = false;
	
	private var m_shouldEnableAutoRotation : bool;
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{	
		var camera : CCustomCamera;
		var angleDist : float;
		var horseComp : W3HorseComponent;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		horseComp = (W3HorseComponent)(((CR4PlayerStateHorseRiding)thePlayer.GetState( 'HorseRiding' )).vehicle);
		
		
		if ( horseComp.IsFullyMounted() )
		{
			thePlayer.SetIsOnHorse( true );
		}
		else
		{
			thePlayer.SetIsOnHorse( false );
		}
		if ( horseComp.inCanter || horseComp.inGallop )
		{
			thePlayer.SetIsHorseMoving( true );
		}
		else
		{
			thePlayer.SetIsHorseMoving( false );
		}
		
		if ( !cameraManualRotationDisabled && parent.IsCameraLockedToTarget())
		{
			camera.EnableManualControl(false);
			cameraManualRotationDisabled = true;
		}
		else if ( cameraManualRotationDisabled && !parent.IsCameraLockedToTarget() )
		{
			camera.EnableManualControl(true);
			cameraManualRotationDisabled = false;
		}
		
		if( thePlayer.vehicleCbtMgrAiming && !parent.IsCameraLockedToTarget() )
		{
			m_shouldEnableAutoRotation = false;
		}
		else if( theInput.LastUsedGamepad() )
		{
			angleDist = AngleDistance( parent.GetHeading(), camera.GetHeading() );
			
			if( thePlayer.GetAutoCameraCenter() || ( !m_shouldEnableAutoRotation && thePlayer.GetIsSprinting() && AbsF(angleDist) <= 30.0f ) )
			{
				m_shouldEnableAutoRotation = true;
			}
			else if( m_shouldEnableAutoRotation && !thePlayer.GetAutoCameraCenter() && ( camera.IsManualControledHor() || !thePlayer.GetIsSprinting() ) )
			{
				m_shouldEnableAutoRotation = false;
			}
		}
		else
		{
			m_shouldEnableAutoRotation = thePlayer.GetAutoCameraCenter();
		}
		
		camera.SetAllowAutoRotation( m_shouldEnableAutoRotation );
		
		parent.UpdateLookAtTarget();
		return vehicleCombatMgr.OnGameCameraTick( moveData, dt );
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var camera 					: CCustomCamera;
		var horseSpeed				: float;
		var horseComp				: W3HorseComponent;
		var shouldStopCamera		: bool;
		var angleDistanceBetweenCameraAndHorse : float;
		
		
		var mult : float;
		var sprintingAngle : float;
		
		
		var didTrace : bool;

		var camParams : SCamDistConfig;

		if ( isCarriage )
			camParams = camDistConfig_cart;
		else
			camParams = camDistConfig_horse;
		
		if ( !parent.IsAlive() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( 4.0 );
			moveData.pivotPositionController.SetDesiredPosition( parent.GetWorldPosition() );
			
			return true;
		}
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();		
		
		if ( super.OnGameCameraPostTick( moveData, dt ) )
		{	
			if ( parent.IsCameraLockedToTarget() )
			{
				moveData.pivotDistanceController.SetDesiredDistance( 3.5f, 3.f );
				currDesiredDist = 3.5f;			
			}
			else
			{
				moveData.pivotDistanceController.SetDesiredDistance( 2.2f, 3.f );
				currDesiredDist = 2.2f;
			}
			return true;
		}
		
		horseComp = (W3HorseComponent)vehicle;
		
		if ( vehicleCombatMgr.IsInSwordAttackCombatAction() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( 5.4f );
			currDesiredDist = 5.4;
		}
		else if ( !horseComp.inCanter && !horseComp.inGallop && !horseComp.OnCheckHorseJump() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( camParams.far_default );
			currDesiredDist = camParams.far_default;
			if ( !parent.IsModernExplorationCamera() )	
				DampFloatSpring( camera.fov, fovVel, camParams.fov_default, 1.0, dt );
			
			
			
			
			CalculateCurrentPitch(horseComp); 
			didTrace = true;
			
			
			if ( !horseComp.OnCheckHorseJump() )
				moveData.pivotRotationController.SetDesiredPitch( currentPitch - 10 );  
		}
		else if ( horseComp.inCanter && !horseComp.OnCheckHorseJump() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( camParams.far_canter );
			currDesiredDist = camParams.far_canter;
			if ( !parent.IsModernExplorationCamera() )	
				DampFloatSpring( camera.fov, fovVel, camParams.fov_canter, 1.0, dt );
		}
		else if ( horseComp.inGallop && !horseComp.OnCheckHorseJump() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( camParams.far_gallop );
			currDesiredDist = camParams.far_gallop;
			if ( !parent.IsModernExplorationCamera() )	
				DampFloatSpring( camera.fov, fovVel, camParams.fov_gallop, 1.0, dt );
		}
		
		if ( horseComp.OnCheckHorseJump() )
		{
			moveData.pivotDistanceController.SetDesiredDistance( currDesiredDist );
		}
		else
		{
			
			if(!didTrace)	
				CalculateCurrentPitch(horseComp);
			
		
			moveData.pivotRotationController.SetDesiredPitch( currentPitch - 10 );  
		}
		
		if ( vehicleCombatMgr.IsInSwordAttackCombatAction() || horseComp.inCanter )
		{
			shouldStopCamera = false;
		}
		else
			shouldStopCamera = false;
		
		
		if(parent.GetHorseCamera())
		{
			moveData.pivotDistanceController.SetDesiredDistance( 1.5f );		
			moveData.pivotPositionController.offsetZ = 2.2f;
			
			sprintingAngle = AngleDistance(parent.GetHeading(), theCamera.GetCameraHeading());
			if(sprintingAngle > 8)
			{
				sprintLeft = true;
			}
			else if(sprintLeft && sprintingAngle > 7)
			{
				sprintLeft = true;
			}
			else
				sprintLeft = false;					

			if(horseComp.inCanter)
			{
				mult = AbsF( sprintingAngle );
				mult = mult/180;
				mult = SqrF(mult) * -1;	
			
				if(sprintLeft && theInput.LastUsedGamepad())
					DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.3f, camParams.close_canter + mult, 0.0f ), 0.7f, dt );
				else
					DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.8f, camParams.close_canter + mult, 0.0f ), 0.7f, dt );
			}
			else if(horseComp.inGallop)
			{
				if(sprintLeft && theInput.LastUsedGamepad())
					DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.3f, camParams.close_gallop, 0.1f ), 1.0f, dt );		
				else
					DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.8f, camParams.close_gallop, 0.1f ), 1.0f, dt );		
			}
			else
			{
				mult = AbsF( AngleDistance(camera.GetHeading(), thePlayer.GetHeading()) );
				mult = mult/180;
				mult = SqrF(mult) * -1;

				DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.8f, camParams.close_default + mult, 0.1f ), 1.0f, dt );
				sprintLeft = false;	
			}
		}
		else
		
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector(0,0,0), 1.3f, dt );			
		
		if( horseComp.cameraMode == 1 )
		{
			if( !camera.IsManualControledHor() && horseComp.inputApplied )
			{
				if( !horseComp.inCanter && !horseComp.inGallop && !vehicleCombatMgr.IsInSwordAttackCombatAction() ) 
				{
					if( trailCameraTimeStamp + trailCameraCooldown > theGame.GetEngineTimeAsSeconds() ) 
					{
						parent.OnGameCameraPostTick( moveData, dt );
						return shouldStopCamera;
					}
					else if( trailCameraTimeStamp + trailCameraCooldown < theGame.GetEngineTimeAsSeconds() && wasTrailCameraActive )
					{
						moveData.pivotRotationVelocity.Yaw = 0.0; 
						wasTrailCameraActive = false;
					}
				
					angleDistanceBetweenCameraAndHorse = AbsF( AngleDistance( VecHeading( theCamera.GetCameraDirection() ), parent.GetHeading() ) );
					
					if( angleDistanceBetweenCameraAndHorse < 30.0 )
						moveData.pivotRotationController.SetDesiredHeading( parent.GetHeading(), 0.5 );
					else if( angleDistanceBetweenCameraAndHorse < 90.0 )
						moveData.pivotRotationController.SetDesiredHeading( parent.GetHeading(), 0.35 );
					else
						moveData.pivotRotationController.SetDesiredHeading( parent.GetHeading(), 0.2 );
						
					parent.OnGameCameraPostTick( moveData, dt );
					return true;	
				}
				else 
				{
					wasTrailCameraActive = true;
					trailCameraTimeStamp = theGame.GetEngineTimeAsSeconds();
				}
			}
			else 
			{
				if( wasTrailCameraActive ) 
				{
					moveData.pivotRotationVelocity.Yaw = 0.0; 
					wasTrailCameraActive = false;
				}
			}
		}
		
		parent.OnGameCameraPostTick( moveData, dt );

		return shouldStopCamera;
	}
	
	
	
	private var currentPitch : float;
	private function CalculateCurrentPitch(horseComp : W3HorseComponent)
	{
		var pointA, pointB, outPosition, normal, playerPos : Vector;
		var collisionGroupsNames : array<name>;
		var rot : EulerAngles;
		var distance : float;
		var trace : bool;
	
		playerPos = thePlayer.GetWorldPosition();
		pointA = playerPos;				
		if(horseComp.inGallop)
			distance = 2.f;
		else if(horseComp.inCanter)
			distance = 3.f;
		else
			distance = 1.f;
		pointA += VecConeRand(thePlayer.GetHeading(), 0, distance, distance);
		pointA.Z += 3.f;
		pointB = pointA;
		pointB.Z -= 10.f;			
		collisionGroupsNames.PushBack('Terrain');
		collisionGroupsNames.PushBack('Static');
		
		trace = theGame.GetWorld().StaticTrace( pointA, pointB, outPosition, normal, collisionGroupsNames );
		rot = VecToRotation( VecNormalize( playerPos - outPosition ) );
		
		if(trace)
			currentPitch = ClampF(rot.Pitch, -40.f, 40.f);
		else
			currentPitch = 0.f;
	}
	
	
	
	var sprintLeft : bool;
	
	
	
	
	
	
	private function BlockActions( toggle : bool )
	{
		if ( isCarriage )
		{
			if ( toggle )
			{
				
				thePlayer.weaponHolster.HolsterWeapon( true );
				thePlayer.BlockAction( EIAB_DrawWeapon, 'HorseRiding' );
				thePlayer.BlockAction( EIAB_CallHorse,  'HorseRiding' );

			} 
			else
			{
				thePlayer.BlockAllActions( 'HorseRiding', false );
			}
		}
	}

	private function CheckForWeapons()
	{
		if( parent.GetCurrentMeleeWeaponType() == PW_Steel || parent.GetCurrentMeleeWeaponType() == PW_Silver )
		{
			OnDrawWeaponStart();
		}
	}
	
	function ChangeTicketPool( apply : bool )
	{
		var combatData : CCombatDataComponent;
		
		combatData = parent.GetCombatDataComponent();
		
		if ( apply )
		{
			if ( meleeTicketRequest	== -1 )
			{
				
				meleeTicketRequest = combatData.TicketSourceOverrideRequest( 'TICKET_Melee', 400, 0.0 );
			}
			if ( rangeTicketRequest == -1 )
			{
				
				rangeTicketRequest = combatData.TicketSourceOverrideRequest( 'TICKET_Range', 100, 0.0 );
			}
		}
		else
		{
			if ( meleeTicketRequest != -1 && combatData.TicketSourceClearRequest( 'TICKET_Melee', meleeTicketRequest ) )
			{
				meleeTicketRequest = -1;
			}
			if ( rangeTicketRequest != -1 && combatData.TicketSourceClearRequest( 'TICKET_Range', rangeTicketRequest ) )
			{
				rangeTicketRequest = -1;
			}
		}
	}	
	
	function DismountVehicle()
	{
		dismountRequest = true;
	}
	
	private function HorseHit()
	{
		var action : W3DamageAction;
		var targets : array<CActor>;
		var victims : array<CActor>;
		var attackpoint : Vector;
		var size, i : int;
		
		parent.GetVisibleEnemies( targets );
		
		attackpoint = parent.GetWorldPosition() + parent.GetWorldForward() * 1.5f;
		size = targets.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( VecLengthSquared( targets[i].GetWorldPosition() - attackpoint ) < 1.f )
			{
				victims.PushBack( targets[i] );
			}
		}
		
		if( victims.Size() > 0 )
		{
			action = new W3DamageAction in this;
			action.Initialize( parent, victims[0], vehicle, parent.GetName(), EHRT_Heavy, CPS_AttackPower, true,false,false,false );
			action.AddDamage( theGame.params.DAMAGE_NAME_BLUDGEONING, 50.f );
			
			theGame.damageMgr.ProcessAction( action );
			
			delete action;
		}
	}
		
	
	
	
	
	event OnAnimEvent_ActionBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart )
				parent.SetBIsCombatActionAllowed( true );
				
		virtual_parent.OnAnimEvent_ActionBlend( animEventName, animEventType, animInfo );
	}
	
	event OnAnimEvent_Sign( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		vehicleCombatMgr.OnProcessAnimEvent( animEventName );
	}
	
	event OnAnimEvent_Throwable( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		vehicleCombatMgr.OnProcessAnimEvent( animEventName );
	}
	
	event OnDrawWeaponStart()
	{
		parent.SetBehaviorVariable( 'isHoldingWeaponR', 1.f, true );
		parent.SetBehaviorVariable( 'swordAdditiveBlendWeight', 1.f );
	}
	
	event OnHolsterWeaponStart()
	{
		parent.SetBehaviorVariable( 'isHoldingWeaponR', 0.f, true );
		parent.SetBehaviorVariable( 'swordAdditiveBlendWeight', 0.f );
	}
	
	event OnTakeDamage( action : W3DamageAction)
	{
		virtual_parent.OnTakeDamage( action );
	}
	
	event OnRaiseSignEvent()
	{
		return vehicleCombatMgr.OnRaiseSignEvent();
	}
	
	
	event OnProcessCastingOrientation( isContinueCasting : bool ) {}

	event OnSkippingTreeCollision( collisionDir : float, collisionSpeed : float )
	{
		if ( !parent.IsCiri() )
		{
			DoLean( collisionSpeed, collisionDir );
		}
	}

	event OnStopSkippingTreeCollision()
	{
		AbortCurrentLean();
		hasPendingLean = false;
	}

	event OnSkippingTreeCollisionLeanStart()
	{
		hasInFlightLean = true;
	}

	event OnSkippingTreeCollisionLeanEnd()
	{
		hasInFlightLean = false;
		if ( hasPendingLean ) 
		{
			hasPendingLean = false;
			DoLeanNow( pendingLeanSpeed, pendingLeanDir );
		}
	}

	function DoLean( speed : float, dir : float )
	{
		if ( hasInFlightLean )
		{
			pendingLeanSpeed = MinF( speed + 1.0, 2.0 );
			pendingLeanDir = dir;
			hasPendingLean = true;
			AbortCurrentLean();
		}
		else
		{
			DoLeanNow( speed, dir );
		}
	}

	function DoLeanNow( speed : float, dir : float )
	{
		parent.SetBehaviorVariable( 'treeCollisionLeanSpeed', speed );
		parent.SetBehaviorVariable( 'treeCollisionLeanDirection', dir );
		parent.RaiseEvent( 'treeCollisionLean' );
		
	}

	function AbortCurrentLean()
	{
		parent.RaiseEvent( 'treeCollisionLeanAbort' );
	}
}





statemachine class W3HorseCombatManager extends W3VehicleCombatManager
{
	default autoState = 'HorseNull';
}

state HorseNull in W3HorseCombatManager extends Null
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		if( prevStateName != 'InAir' )
			((W3HorseComponent)parent.vehicle).OnCombatActionEnd();
	}
}