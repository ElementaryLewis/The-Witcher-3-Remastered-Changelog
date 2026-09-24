/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state DismountHorse in CR4Player extends DismountTheVehicle
{
	public var horseComp : W3HorseComponent;
	
	
	
	
	
	
	

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		horseComp = (W3HorseComponent)vehicle;
		
		parent.AddAnimEventCallback( 'SlideBack', 'OnAnimEvent_SlideBack' );
		
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