/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state DismountHorse in CR4Player extends DismountTheVehicle
{
	public var horseComp : W3HorseComponent;
	private var syncPosition : bool;
	private var desyncTimestamp : float;
	private var horseStartingVelocity : Vector;
	private var horseStartingSpeed : float;
	private var previousPlayerPosition : Vector;
	private var previousVehiclePosition : Vector;
		
	
	
	
	
	

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );

		thePlayer.GetLastPositionsBeforeDismount(previousPlayerPosition, previousVehiclePosition);

		lastUpdate = theGame.GetEngineTimeAsSeconds();
		horseComp = (W3HorseComponent)vehicle;
		syncPosition = true;
		horseStartingVelocity = ((CActor)vehicle.GetEntity()).GetMovingAgentComponent().GetVelocity();
		horseStartingSpeed = VecLength2D(horseStartingVelocity);
		initialHeading = vehicle.GetHeading();

		if( horseComp.GetEntity().HasTag('carriage_horse') )
		{
			thePlayer.SetBehaviorVariable( 'isRidingCart', 0.f, true );
		}
		
		parent.AddAnimEventCallback( 'SlideBack', 'OnAnimEvent_SlideBack' );
		parent.AddAnimEventCallback( 'AllowDesync', 'OnAnimEvent_AllowDesync' );

		this.ProcessDismountHorse();
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		var horseRiderSharedParams : CHorseRiderSharedParams;
		
		thePlayer.RemoveBuffImmunity( EET_Pull, 'HorseRidingBuffImmunity' );
		
		parent.RemoveTimer( 'CheckSwimmingOnDismount' );
		
		
		
		
		parent.RemoveAnimEventCallback( 'SlideBack' );
		
		parent.EnableCollisions(true);
		
		super.OnLeaveState( nextStateName );
	}
	
	cleanup function DismountCleanup() 
	{
		super.DismountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
	}

	
	
	

	private var targetHeading : float;
	private var previousVehicleHeading : float;
	private var lastUpdate : float;
	private var initialHeading : float;

	
	
	private const var horseCanterVelocityMagnitude : float;
	private const var horseGallopVelocityMagnitude : float;

	default horseCanterVelocityMagnitude = 10.0;
	default horseGallopVelocityMagnitude = 6.0;

	const var speedDecayFactor : float;
	default speedDecayFactor = 2.0;

	
	
	function AlignDynamicDismount(initialAlignment : bool, angleOffset : float)
	{
		var targetOffset : float;
		var playerHeading : float;
		var vehicleHeading : float;

		var vectorDeltaToApply : Vector;
		var playerTargetVelocity : Vector;
		var playerTargetSpeed : float;

		var now : float;
		var dT : float;
		var playerTargetSpeedMin : float;
		var navigableZ : float;
		var playerPosition : Vector;

		
		if ((thePlayer.GetBehaviorVariable('dismountType') == 5.f || thePlayer.GetBehaviorVariable('dismountType') == 6.f) 
			&& thePlayer.GetBehaviorVariable('dynamicDismountDirection') != 2.f)
		{
			now = theGame.GetEngineTimeAsSeconds();
			dT = now - lastUpdate;
			vectorDeltaToApply = Vector(0.0, 0.0, 0.0);

			if (thePlayer.GetBehaviorVariable('dismountType') == 6.f)
			{
				playerTargetSpeedMin = 3.0;
			}
			else
			{
				playerTargetSpeedMin = 3 / (horseCanterVelocityMagnitude / horseGallopVelocityMagnitude);
			}
			playerHeading = thePlayer.GetHeading();
			vehicleHeading = vehicle.GetHeading();

			if (syncPosition) 
			{
				playerTargetVelocity = horseStartingVelocity * dT;
			}
			else 
			{
				playerTargetSpeed = ClampF(horseStartingSpeed * (1 - ((now - desyncTimestamp) * speedDecayFactor)), playerTargetSpeedMin, horseStartingSpeed);
				playerTargetVelocity = VecNormalize(horseStartingVelocity) * playerTargetSpeed * dT;
			}
			vectorDeltaToApply = playerTargetVelocity;
			vectorDeltaToApply.Z = 0;

			if (initialAlignment) 
			{
				if (thePlayer.GetBehaviorVariable('dynamicDismountDirection') == 0.f)
				{
					targetOffset = angleOffset;
					vectorDeltaToApply = vectorDeltaToApply + thePlayer.GetWorldRight() * -0.1;
				}
				else if (thePlayer.GetBehaviorVariable('dynamicDismountDirection') == 1.f)
				{
					targetOffset = -angleOffset;
					vectorDeltaToApply = vectorDeltaToApply + thePlayer.GetWorldRight() * 0.1;
				}

				targetHeading = vehicleHeading + targetOffset;

				
				
				
				thePlayer.GetMovingAgentComponent().AddCustomDelta(VecRotateAxis(vectorDeltaToApply, Vector(0, 0, 1), Deg2Rad(AngleDistance(vehicle.GetHeading() + targetOffset, initialHeading))), EulerAngles(0, AngleDistance(targetHeading, playerHeading), 0));
			}
			
			else
			{			
				targetHeading = targetHeading - AngleDistance(previousVehicleHeading, vehicleHeading);

				thePlayer.GetMovingAgentComponent().AddCustomDelta(VecRotateAxis(vectorDeltaToApply, Vector(0, 0, 1), Deg2Rad(AngleDistance(vehicle.GetHeading() + targetOffset, initialHeading))), EulerAngles(0, AngleDistance(targetHeading, playerHeading), 0));
			}

			previousVehicleHeading = vehicleHeading;
			lastUpdate = now;

			playerPosition = thePlayer.GetWorldPosition() + VecRotateAxis(vectorDeltaToApply, Vector(0, 0, 1), Deg2Rad(AngleDistance(vehicle.GetHeading() + targetOffset, initialHeading)));
			if (!theGame.GetWorld().NavigationComputeZ( playerPosition, playerPosition.Z - 1, playerPosition.Z + 0.2, navigableZ ))
			{
				theGame.GetWorld().NavigationComputeZ( playerPosition, playerPosition.Z - 100, playerPosition.Z + 100, navigableZ );
				playerPosition.Z = navigableZ + 0.4;
				thePlayer.TeleportWithRotation( playerPosition, thePlayer.GetWorldRotation());
			}
		}
	}

	entry function ProcessDismountHorse()
	{
		var riderData : CAIStorageRiderData;
		var weaponType	: EPlayerWeapon;
		var target : CActor;
		var position : Vector;

		riderData = thePlayer.GetRiderData();
		parent.SetCleanupFunction( 'DismountCleanup' );
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', dismountType );
		
		parent.AddTimer( 'CheckSwimmingOnDismount', 0.f, true );

		AlignDynamicDismount(true, 5.0);

		
		SleepOneFrame();


		if ( dismountType == DT_shakeOff )
		{
			if ( parent.rangedWeapon && parent.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
			{
				
				parent.WaitForBehaviorNodeActivation('shakeOffStart',0.5f);
				
				parent.OnRangedForceHolster( true, true );
			}
			
			
			parent.WaitForBehaviorNodeActivation('recoverStart',3.f);
			
			target = (CActor)thePlayer.GetDisplayTarget();
			if ( target && thePlayer.IsInCombat() )
			{
				weaponType = thePlayer.GetMostConvenientMeleeWeapon( target, true );
				thePlayer.OnEquipMeleeWeapon( weaponType, false, false );
			}
		}
		else
		{
			parent.OnRangedForceHolster( true, true );
			theInput.SetContext( thePlayer.GetExplorationInputContext() );
			while( true )
			{
				if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_dismounted )
				{
					break;
				}
				if ( riderData.ridingManagerMountError == true )
				{
					parent.PopState();
					break;
				}

				AlignDynamicDismount(false, 5.0);
				SleepOneFrame();
			}
		}
		
		parent.ClearCleanupFunction();
		parent.PopState( true );
	}
	
	event OnAnimEvent_AllowFall( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		HACK_ActivatePhysicsRepresentation();
		
		
		
	}
	
	event OnAnimEvent_SlideBack( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var pointToSlide : Vector;
		var heading : Vector;
		var movementAdjustor : CMovementAdjustor;
		var ticket : SMovementAdjustmentRequestTicket;
		
		if( animEventType == AET_DurationStart )
		{
			pointToSlide = parent.GetWorldPosition();
			heading = parent.GetHeadingVector();
			pointToSlide -= heading * 1.0;
			
			movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			ticket = movementAdjustor.CreateNewRequest( 'SlideBack' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.ScaleAnimation( ticket );	
			movementAdjustor.SlideTo( ticket, pointToSlide );
			movementAdjustor.Continuous( ticket	);
		}
	}

	event OnAnimEvent_AllowDesync( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		syncPosition = false;
		desyncTimestamp = theGame.GetEngineTimeAsSeconds();
	}
	
	timer function CheckSwimmingOnDismount( dt : float , id : int)
	{
		var depth : float;
		var fallDist : float;
		var waterLevel : float;

		
		if ( !thePlayer.IsSwimming() && thePlayer.IsAlive() ) 
		{
			depth = ((CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent()).GetSubmergeDepth();
			
			if ( depth < parent.ENTER_SWIMMING_WATER_LEVEL )
			{
				parent.RemoveTimer( 'CheckSwimmingOnDismount' );
				parent.GotoState( 'Swimming' );
			}
		}
	}
}