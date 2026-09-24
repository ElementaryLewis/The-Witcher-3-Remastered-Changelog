/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MountBoat in CR4Player extends MountTheVehicle
{
	var boatComp : CBoatComponent;
	
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		boatComp = (CBoatComponent)vehicle;
		
		if( boatComp )
			this.ProcessMountBoat();
		else
			LogAssert( vehicle, "MountBoat::ProcessMountTheVehicle, 'vehicle' is not set" );
		
		if( vehicleSlot == EVS_passenger_slot )
		{
			theInput.SetContext( 'BoatPassenger' );
		}
		else
		{
			theInput.SetContext( 'Boat' );
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
	}
	
	
	cleanup function MountCleanup() 
	{
		super.MountCleanup();
		
		parent.SignalGameplayEventParamInt( 'RidingManagerDismountBoat', DT_instant | DT_fromScript );
	}
	
	
	
	
	
	entry function ProcessMountBoat()
	{
		var mountError 	: bool = false;
		var riderData 	: CAIStorageRiderData;
		
		parent.SetCleanupFunction( 'MountCleanup' );
		
		SleepOneFrame();
			
		
		
		if( mountType == MT_instant )
		{
			parent.OnHitGround();
		}
		
		parent.EnableCharacterCollisions( false );
		boatComp.ToggleVehicleCamera( true );
		
		riderData = thePlayer.GetRiderData();
		riderData.sharedParams.vehicleSlot  = vehicleSlot;
		EntityHandleSet( riderData.sharedParams.boat, boatComp.GetEntity() );
		
		
		parent.SignalGameplayEventParamInt( 'RidingManagerMountBoat', mountType );
		while( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_mounted )
			{
				break;
			}
			if ( riderData.ridingManagerMountError == true )
			{
				parent.EnableCharacterCollisions( true );
				parent.ClearCleanupFunction();
				OnMountingFailed();
				parent.PopState();
				break;
			}
			SleepOneFrame();
		}

		parent.ClearCleanupFunction();
	
		theGame.ConvertToStrayActor( (CActor)boatComp.GetEntity() );
		boatComp.IssueCommandToUseVehicle( );
	}
	
	private function OnMountingFailed()
	{	
		super.OnMountingFailed();
	}
	
	private function GetMountFacing() : EPlayerBoatMountFacing
	{
		var ret : EPlayerBoatMountFacing;
		var angleToInteract	: float;
		
		angleToInteract = AngleNormalize( 180 + parent.GetHeading() - parent.GetUsedVehicle().GetHeading() ); 
		
		if( angleToInteract >= 45 && angleToInteract < 135 )
			ret = EPBMD_Right;
		else if( angleToInteract >= 135 && angleToInteract < 225 )
			ret = EPBMD_Back;
		else if( angleToInteract >= 225 && angleToInteract < 315 )
			ret = EPBMD_Left;
		else
			ret = EPBMD_Front;
		
		
		return ret;		
	}
}