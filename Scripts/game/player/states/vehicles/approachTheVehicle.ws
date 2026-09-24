/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ApproachTheVehicle in CPlayer extends Base
{
	private var vehicle : CVehicleComponent;
	private var slotNumber : int;
	
	
	
	

	event OnEnterState( prevStateName : name )
	{
		parent.BlockAllActions( 'MountVehicle', true, , true );
	
		super.OnEnterState( prevStateName );

		ProcessApproachTheVehicle();
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		LogAssert( !vehicle, "ApproachTheVehicle::OnLeaveState, 'vehicle' is still set" );
	
		vehicle = NULL;
		
		super.OnLeaveState( nextStateName );
	}
	
	
	
	
	
	final function SetupState( v : CVehicleComponent, sn : int )
	{
		LogAssert( !vehicle, "ApproachTheVehicle::SetupState, 'vehicle' is already set" );
		LogAssert( sn >= 0, "ApproachTheVehicle::SetupState, 'slotNumber' is not equal or greater then 0" );
		
		vehicle = v;
		slotNumber = sn;
	}
	
	entry function ProcessApproachTheVehicle()
	{
		var actionResult 	: bool;
		var slotPosition 	: Vector;
		var slotHeading 	: float;
		var slidingDuration : float;
		var temp : CVehicleComponent;
		
		actionResult = false;
		
		if( vehicle )
		{
			vehicle.GetSlotPositionAndHeading( slotNumber, slotPosition, slotHeading );
			slidingDuration = CalcSlidingDuration( slotPosition );
			actionResult = parent.ActionSlideToWithHeading( slotPosition, slotHeading, slidingDuration );
		}
		else
		{
			LogAssert( vehicle, "ApproachTheVehicle::Process, 'vehicle' is not set" );
		}
		
		temp = vehicle;
		vehicle = NULL;
		
		if( actionResult )
		{
			if( temp.GetVehicleType() == EVT_Horse )
				((W3HorseComponent)temp).IssueCommandToMount( parent, MT_normal, EVS_driver_slot );
		}
		else
		{
			parent.PopState( true );
		}
	}
	
	protected final function CalcSlidingDuration( destination : Vector ) : float
	{
		
		return VecDistance( parent.GetWorldPosition(), destination ) / 4.f;
	}
	
	function CanAccesFastTravel( target : W3FastTravelEntity ) : bool
	{
		if( vehicle )
		{
			return vehicle.CanAccesFastTravel( target );
		}
		return true;
	}
}
