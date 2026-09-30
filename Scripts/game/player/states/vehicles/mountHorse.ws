/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MountHorse in CR4Player extends MountTheVehicle
{
	var horseComp : W3HorseComponent;
	
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		var instantMount : bool;
		instantMount = false;
		
		super.OnEnterState( prevStateName );
		
		thePlayer.HideUsableItem();
		
		thePlayer.AddBuffImmunity( EET_Pull, 'HorseRidingBuffImmunity', true );
		
		horseComp = (W3HorseComponent)vehicle;

		if( vehicle.GetEntity().HasTag( 'carriage_horse' ) ) 
		{
			thePlayer.SetBehaviorVariable( 'isRidingCart', 1.f, true );
		}
		
		if( horseComp )
		{
			horseComp.canDismount = false;
			this.ProcessMountHorse();
		}
		else
		{
			LogAssert( vehicle, "MountHorse::ProcessMountTheVehicle, 'vehicle' is not set" );
		}
		
		if( mountType == MT_instant )
		{
			instantMount = true;
		}
		
		if ( !IsMountsRemasterEnabled() )
		{
			
			theGame.ActivateHorseCamera( true, instantMount ? 0.f : 0.4f, instantMount );
		}
		
		if ( (W3ReplacerCiri)thePlayer )
		{
			theInput.SetContext( 'Horse_Replacer_Ciri' );
		}
		else
			theInput.SetContext( 'Horse' );
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
	}
	
	
	cleanup function MountCleanup() 
	{
		super.MountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_instant | DT_fromScript );
	}
	
	
	
	
	
	private var mountAnimStarted : bool;
	
	entry function ProcessMountHorse()
	{
		var riderData 			: CAIStorageRiderData;
		var distance			: float;
		var contextSwitchOffset	: float;
		var mountStartTimestamp : float;
		var mountTimeout : float;

		parent.SetCleanupFunction( 'MountCleanup' );
		
		mountAnimStarted = false;
		
		if ( mountType == MT_instant )
		{
			
			
			parent.OnHitGround();
		}
		
		riderData = thePlayer.GetRiderData();
		
		horseComp.Unpair(); 
		
		horseComp.PairWithRider( riderData.sharedParams );	
		riderData.sharedParams.rider 		= thePlayer;
		riderData.sharedParams.vehicleSlot  = vehicleSlot;
		
		parent.SignalGameplayEventParamInt( 'RidingManagerMountHorse', mountType );
		
		
		SleepOneFrame();
		
		mountTimeout = 5.0;
		if (horseComp.useEarlyExploration)
		{
			mountTimeout = 10.0;
		}
		mountStartTimestamp = theGame.GetEngineTimeAsSeconds();
		while( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_mounted )
			{
				break;
			}
			if ( mountAnimStarted )
			{
			
			}
			else if ( riderData.ridingManagerMountError == true || mountStartTimestamp + mountTimeout < theGame.GetEngineTimeAsSeconds() )
			{
				OnMountingFailed();
				parent.PopState();
				break;
			}
			SleepOneFrame();
		}
		
		parent.ClearCleanupFunction();
		horseComp.IssueCommandToUseVehicle( );
	}
	
	event OnStartTraversingExploration( t : CScriptedExplorationTraverser )
	{
		
		return parent.OnStartTraversingExploration(t);
	}
	
	private function OnMountingFailed()
	{	
		super.OnMountingFailed();

		theGame.ActivateHorseCamera( false, 0.2f );	
	}
	
	event OnMountAnimStarted()
	{
		mountAnimStarted = true;
	}
	
	event OnMountAnimCancelled()
	{
		mountAnimStarted = false;
	}

	event OnHorseRidingOn()
	{
		
		if ( !horseComp.useEarlyExploration || horseComp.GetCurrentStateName() != 'Exploration' )
		{
			horseComp.PushState( 'Exploration' );
		}
	}
	
	event OnDeath( damageAction : W3DamageAction )
	{
		parent.ActionCancelAll();
		
		parent.OnDeath( damageAction );
	}

	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		
		

		return super.OnGameCameraPostTick( moveData, dt );
	}
}