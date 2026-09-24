/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSailorMountBoat extends IBehTreeTask
{
	var boatTag 			: name;
	var riderData 			: CAIStorageRiderData;
	var instantMount		: bool;
	
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
    latent function Main() : EBTNodeStatus
    {        
        var actor       : CActor = GetActor();
        
        var boatEntity	: CEntity;
        var mountType	: EMountType = MT_instant;
        
        
		boatEntity = theGame.GetEntityByTag( boatTag );
		if( !boatEntity )
		{
			return BTNS_Failed;
		}
		EntityHandleSet( riderData.sharedParams.boat, boatEntity );
		
		if ( instantMount == false )
		{
			mountType = MT_normal;
		}
        
        actor.SignalGameplayEventParamInt( 'RidingManagerMountBoat', mountType );
		
		while ( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_mounted )
			{
				if ( riderData.ridingManagerMountError )
				{
					return BTNS_Failed;
				}
				return BTNS_Completed;
			}
			SleepOneFrame();
		}		
        return BTNS_Completed;
    }
}

class CBTTaskSailorMountBoatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSailorMountBoat';

	editable var boatTag 		: CBehTreeValCName;
	editable var instantMount	: CBehTreeValBool;
	
	default instantMount = true;
}



class CBTTaskSailorDismountBoat extends IBehTreeTask
{
	 var riderData 	: CAIStorageRiderData;
	
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
    latent function Main() : EBTNodeStatus
    {
        var actor       : CActor = GetActor();
       
        actor.SignalGameplayEventParamInt( 'RidingManagerDismountBoat', DT_instant );
		
		while ( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_dismounted )
			{
				if ( riderData.ridingManagerMountError )
				{
					return BTNS_Failed;
				}
				return BTNS_Completed;
			}
			SleepOneFrame();
		}	
		EntityHandleSet( riderData.sharedParams.boat, NULL );
        return BTNS_Completed;
    }
 
}

class CBTTaskSailorDismountBoatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSailorDismountBoat';
}




class CBTTaskCondIsMountedOnBoat extends IBehTreeTask
{
	var riderData 	: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		if ( riderData.sharedParams && EntityHandleGet( riderData.sharedParams.boat ) )
		{
			return true;
		}
		
		return false;
	}
	
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}


class CBTTaskCondIsMountedOnBoatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCondIsMountedOnBoat';
}




class CBTTaskTeleportToEntity extends IBehTreeTask
{
	var entityTag : name;
	
	function OnActivate() : EBTNodeStatus
	{
		var actor 			: CActor = GetActor();
		var targetEntity 	: CEntity;
		targetEntity = theGame.GetEntityByTag( entityTag );
		if ( targetEntity )
		{
			actor.TeleportWithRotation( targetEntity.GetWorldPosition(), targetEntity.GetWorldRotation() );
		}
		return BTNS_Completed;
	}
}

class CBTTaskTeleportToEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskTeleportToEntity';

	editable var entityTag : CBehTreeValCName;
}