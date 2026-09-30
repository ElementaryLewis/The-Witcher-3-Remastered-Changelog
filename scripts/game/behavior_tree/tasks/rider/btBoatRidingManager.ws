/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskRidingManagerBoatMount extends CBTTaskRidingManagerVehicleMount
{
	var behGraphAlias : name;
	default attachSlot = 'seat';
	
	function GetVehicleComponent() : CVehicleComponent
	{
		var boat			: CEntity;
        boat = EntityHandleGet( riderData.sharedParams.boat );
		return (CVehicleComponent)boat.GetComponentByClassName('CVehicleComponent');
	}
	
	function OnActivate() : EBTNodeStatus
	{
        var vehicleComponent: CVehicleComponent;
        
        if ( super.OnActivate() != BTNS_Active )
        {   
			return BTNS_Failed;
		}
		
		if ( riderData.sharedParams.vehicleSlot == EVS_driver_slot )
        {
			attachSlot 							= 'seat';
        }
        else
		{
			attachSlot 							= 'seat_passenger';
		}		
		
		return BTNS_Active;
	}
	
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor		: CActor = GetActor();
		var vehicleActor 	: CActor;
		
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );	
		
		
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;
		
		
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}
	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();
		super.OnMountFailed( riderData, vehicleComponent );
	}
	latent function Main() : EBTNodeStatus
    {
        var vehicleComponent: CVehicleComponent;
        var vehicle			: CEntity;
        var boatComp		: CBoatComponent;
        
        if( riderData.sharedParams.rider != thePlayer )
        {
			riderData.ridingManagerInstantMount = true;
		}
		
        vehicle = EntityHandleGet( riderData.sharedParams.boat );
		vehicleComponent = (CVehicleComponent)vehicle.GetComponentByClassName('CVehicleComponent');
		
		
		if( riderData.sharedParams.vehicleSlot == EVS_driver_slot && vehicleComponent.GetUser() )
		{
			return BTNS_Failed;
		}
		
		boatComp = (CBoatComponent)vehicle.GetComponentByClassName('CBoatComponent');
		if( boatComp )
		{
			if( riderData.sharedParams.vehicleSlot == EVS_passenger_slot && boatComp.GetPassenger() )
			{
				return BTNS_Failed;
			}
		}
		
        
		MountActor( riderData, behGraphAlias, vehicleComponent );
        return BTNS_Completed;
    }
}


abstract class CBTTaskRidingManagerBoatMountDef extends CBTTaskRidingManagerVehicleMountDef
{
}



class CBTTaskRidingManagerPlayerBoatMount extends CBTTaskRidingManagerBoatMount
{
	default behGraphAlias  = 'PlayerSailing';

	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{        
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		super.OnMountFailed( riderData, vehicleComponent );
	}
	
}




class CBTTaskRidingManagerPlayerBoatMountDef extends CBTTaskRidingManagerBoatMountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerBoatMount';
}



class CBTTaskRidingManagerNPCBoatMount extends CBTTaskRidingManagerBoatMount
{
	default behGraphAlias  = 'VehicleBoat';
	
	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
	
		riderActor.EnableCollisions( false ); 
		
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}
}


class CBTTaskRidingManagerNPCBoatMountDef extends CBTTaskRidingManagerBoatMountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCBoatMount';
}






abstract class CBTTaskRidingManagerBoatDismount extends CBTTaskRidingManagerVehicleDismount
{
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }

    
    
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
    latent function Main() : EBTNodeStatus
    {
        var vehicleComponent: CVehicleComponent;
        var boat			: CEntity;

        boat = EntityHandleGet( riderData.sharedParams.boat );
		vehicleComponent = (CVehicleComponent)boat.GetComponentByClassName('CVehicleComponent');
		DismountActor( riderData, vehicleComponent );			
        return BTNS_Completed;
    }
}


abstract class CBTTaskRidingManagerBoatDismountDef extends CBTTaskRidingManagerVehicleDismountDef
{  
}



class CBTTaskRidingManagerPlayerBoatDismount extends CBTTaskRidingManagerBoatDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		
		
		vehicleComponent.ToggleVehicleCamera( false );
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    
    
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}

class CBTTaskRidingManagerPlayerBoatDismountDef extends CBTTaskRidingManagerBoatDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerBoatDismount';
}



class CBTTaskRidingManagerNPCBoatDismount extends CBTTaskRidingManagerBoatDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountStarted( riderData, vehicleComponent );
    }

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor = GetActor();
		vehicleComponent.ToggleVehicleCamera( false );
		riderActor.EnableCollisions( true ); 
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    
    
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}


class CBTTaskRidingManagerNPCBoatDismountDef extends CBTTaskRidingManagerBoatDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCBoatDismount';
}