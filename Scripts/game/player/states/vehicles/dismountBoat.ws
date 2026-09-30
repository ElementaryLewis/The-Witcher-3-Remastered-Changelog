/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state DismountBoat in CPlayer extends DismountTheVehicle
{
	var boatComp : CBoatComponent;
	var remainingSlideDuration : float;
	var fromPassenger : bool;
	
	
	
	

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		boatComp = (CBoatComponent)vehicle;

		this.ProcessDismountBoat();
		
		parent.AddTimer( 'StandUpPositionCorrection', 0.0001f, true );
	}
	
	event OnLeaveState( nextStateName : name )
	{ 	
		parent.RemoveTimer( 'StandUpPositionCorrection' );
		theGame.RequestAutoSave( "dismounted_boat", false );		
		super.OnLeaveState( nextStateName );
	}
	
	cleanup function DismountCleanup() 
	{
		super.DismountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountBoat', DT_instant | DT_fromScript );
	}

	
	
	

	entry function ProcessDismountBoat()
	{
		var dismountError : bool = false;
		var riderData : CAIStorageRiderData;
		var position : Vector;
		var rotQuat  : Vector;
		
		parent.SetCleanupFunction( 'DismountCleanup' );
		
		
		
		
		
		dismountType = DT_normal;
		
		riderData = thePlayer.GetRiderData();
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountBoat', dismountType );
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
		parent.ClearCleanupFunction();
		
		parent.RemoveTimer( 'StandUpPositionCorrection' );
		
		boatComp.DismountFinished();
		
		boatComp = NULL;
		boatComp.ToggleVehicleCamera( false );
		EntityHandleSet( riderData.sharedParams.boat, NULL );
		
		if ( parent.IsAlive() )
			parent.PopState( true );
	}
	
	function DismountFromPassenger( fromPass : bool )
	{
		fromPassenger = fromPass;
	}
	
	timer function StandUpPositionCorrection( timeDelta : float , id : int)
	{
		var position : Vector;
		var rotQuat  : Vector;
		
		if( fromPassenger )
		{
			boatComp.GetSlotTransform( 'seat_passenger', position, rotQuat );
		}
		else
		{
			boatComp.GetSlotTransform( 'seat', position, rotQuat );
		}
			
		( ( CR4Player ) parent ).HACK_BoatDismountPositionCorrection( position );
	}
	
	event OnDeath( damageAction : W3DamageAction )
	{
		virtual_parent.OnDeath( damageAction );
		
		parent.EnableCollisions( true );
		parent.RaiseForceEvent( 'Death' );
	}
}