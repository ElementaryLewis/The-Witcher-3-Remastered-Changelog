/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskRidingManagerHorseMount extends CBTTaskRidingManagerVehicleMount
{
	default attachSlot = '';
	
	function GetVehicleComponent() : CVehicleComponent
	{
		return (CVehicleComponent)riderData.sharedParams.GetHorse().GetComponentByClassName('CVehicleComponent');
	}
	
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;

		super.OnMountStarted( riderData, behGraphName, vehicleComponent );

		vehicleActor      	= (CActor)vehicleComponent.GetEntity();
		vehicleActor.SignalGameplayEvent( 'HorseMountStart' );
		riderActor.SignalGameplayEvent( 'HorseMountStart' );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{	
		var riderActor			: CActor = GetActor();
		var vehicleActor 		: CActor;
		var player				: CR4Player;
		var behaviorsToActivate : array< name >;
		var graphResult			: bool;

		vehicleActor      	= (CActor)vehicleComponent.GetEntity();
		player				= (CR4Player)riderActor;
		
		
		if ( riderData.ridingManagerInstantMount == false )
		{
			riderActor.GetMovingAgentComponent().SetAdditionalOffsetWhenAttachingToEntity( vehicleActor, 1.0f );
		}

		if ( player )
		{
			riderActor.EnableCollisions( false ); 
		}

		riderActor.SetBehaviorVariable( 'rider', 1.0f );
		vehicleActor.SignalGameplayEvent( 'HorseMountEnd' );
		riderActor.SignalGameplayEvent( 'HorseMountEnd' );
		
		
		if ( riderActor.CanStealOtherActor( vehicleActor ) )
		{
			theGame.ConvertToStrayActor( vehicleActor );
			if ( player )
			{
				player.SaveLastMountedHorse( vehicleActor );
			}
		}
		
		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();

		super.OnMountFailed( riderData, vehicleComponent );
	} 

	function OnGameplayEvent( eventName : CName ) : bool
	{
		var riderActor			: CActor 	= GetActor();
		var riderData       	: CAIStorageRiderData;
		var vehicleEntity 		: CEntity;
		var vehicleComponent  	: W3HorseComponent;

		
		
		if( eventName == 'OnPoolRequest' || eventName == 'RequestInstantDismount' )
		{
			Complete(false);
		}
		if( eventName == 'MountHorseType' )
		{
			mountType = GetEventParamCName('');
			if ( riderActor == thePlayer )
			{
				((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnMountAnimStarted();
			}
		}
		if( eventName == 'HorseRidingOn' )
		{
			if( riderActor == thePlayer )
			{
				((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnHorseRidingOn();
			}
		}
		return false;
	}   
}


abstract class CBTTaskRidingManagerHorseMountDef extends CBTTaskRidingManagerVehicleMountDef
{
}





class CBTTaskRidingManagerNPCHorseMount extends CBTTaskRidingManagerHorseMount
{    
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor             : CActor = GetActor();
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );

		
		riderActor.EnableCharacterCollisions( false );
		riderActor.EnablePhysicalMovement( false );
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( true );
	}	

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();
		
		riderActor.GetRootAnimatedComponent().SetUseExtractedMotion( true);
        riderActor.EnableCollisions( false ); 
		
        
		riderActor.GetMovingAgentComponent().ResetMoveRequests();
        riderActor.SetBehaviorVariable( 'direction', 0.0f );
        riderData.sharedParams.GetHorse().GetMovingAgentComponent().ResetMoveRequests();
        riderData.sharedParams.GetHorse().SetBehaviorVariable( 'direction', 0.0f );
        
        
        riderActor.SoundSwitch( "vo_3d", 'vo_3d_long_on_horse', 'head' );
        
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();

		riderActor.EnableCharacterCollisions( true );
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( false );

		super.OnMountFailed( riderData, vehicleComponent );
	}

    latent function Main() : EBTNodeStatus
    {
        var npc             	: CNewNPC = GetNPC();
        var stupidArray 		: array< name >;
        var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;

        riderData.ridingManagerMountError   = false;

        
        
        while ( !riderData.sharedParams.GetHorse() )
        {
			SleepOneFrame();
        }      

		
        stupidArray.PushBack( 'Exploration' );
		GetActor().ActivateBehaviors( stupidArray ); 
		
		vehicleEntity      = riderData.sharedParams.GetHorse();
        vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent();  

        
		MountActor( riderData, 'VehicleHorse', vehicleComponent );

        return BTNS_Completed;
    }
}


class CBTTaskRidingManagerNPCHorseMountDef extends CBTTaskRidingManagerHorseMountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCHorseMount';
}



class CBTTaskRidingManagerPlayerHorseMount extends CBTTaskRidingManagerHorseMount
{
	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor          : CActor = GetActor();	

		riderActor.EnableCharacterCollisions( false ); 
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var horseComponent		: W3HorseComponent;
		var vehicleEntity 		: CEntity = vehicleComponent.GetEntity();     
        horseComponent = (W3HorseComponent)vehicleComponent;
        
		horseComponent.canDismount = true;
		
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();
		theGame.ActivateHorseCamera( false, 0.f );
		riderActor.ActionCancelAll();
		riderActor.EnableCharacterCollisions( true );
		riderActor.RegisterCollisionEventsListener();		

		theInput.SetContext( thePlayer.GetExplorationInputContext() );
		super.OnMountFailed( riderData, vehicleComponent );
	}

    latent function Main() : EBTNodeStatus
    {
        var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;
    
        riderData.ridingManagerMountError   = false; 

        vehicleEntity      = riderData.sharedParams.GetHorse();
        vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent(); 

        
		MountActor( riderData, 'VehicleHorse', vehicleComponent );
        return BTNS_Completed;
    }
}


class CBTTaskRidingManagerPlayerHorseMountDef extends CBTTaskRidingManagerHorseMountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerHorseMount';
}






abstract class CBTTaskRidingManagerHorseDismount extends CBTTaskRidingManagerVehicleDismount
{
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var vehicleActor 		: CActor;
		
		super.OnDismountStarted( riderData, vehicleComponent );
		vehicleActor      = (CActor)vehicleComponent.GetEntity();
		if ( vehicleActor )
		{
			vehicleActor.SignalGameplayEvent( 'HorseDismountStart' );
		}
		riderActor.SignalGameplayEvent( 'HorseDismountStart' );	
    }
    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var vehicleActor 		: CActor;
		
		riderActor.SignalGameplayEvent( 'HorseDismountEnd' );

		
		vehicleActor      = (CActor)vehicleComponent.GetEntity();
		if ( vehicleActor )
		{
			vehicleActor.SignalGameplayEvent( 'HorseDismountEnd' );
		}
		if ( (CR4Player)riderActor )
		{
			riderActor.EnableCollisions( true );
		}
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }

    latent function Main() : EBTNodeStatus
    {
		var vehicleEntity		: CEntity;
		var vehicleComponent	: CVehicleComponent;    
		vehicleEntity      	= riderData.sharedParams.GetHorse();
        vehicleComponent   	= ((CNewNPC)vehicleEntity).GetHorseComponent(); 
		DismountActor( riderData, vehicleComponent );		

        return BTNS_Completed;
    }
    function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity;
		var vehicleComponent  	: W3HorseComponent;
		
		if ( eventName == 'OnPoolRequest' || eventName == 'RequestInstantDismount' )
		{
			vehicleEntity      	= riderData.sharedParams.GetHorse();
			if ( vehicleEntity )
			{
				vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent();
			}
			if( riderData.sharedParams.mountStatus != VMS_dismounted )
			{	
				
				DismountActor_NonLatent( riderData, vehicleComponent );
				
				
				riderData.OnInstantDismount( riderActor );
			}
		}
		return false;
	}
}


abstract class CBTTaskRidingManagerHorseDismountDef extends CBTTaskRidingManagerVehicleDismountDef
{
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnPoolRequest' );
		listenToGameplayEvents.PushBack( 'RequestInstantDismount' );
	}
}



class CBTTaskRidingManagerNPCHorseDismount extends CBTTaskRidingManagerHorseDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();	
		super.OnDismountStarted( riderData, vehicleComponent );	
		riderActor.GetRootAnimatedComponent().SetUseExtractedMotion( true ); 
		riderActor.EnablePhysicalMovement(false);
		((CMovingPhysicalAgentComponent)riderActor.GetMovingAgentComponent()).SetAnimatedMovement( false );
		
		riderActor.AddBuffImmunity( EET_Frozen, 'HorseDismount', true );
    }   

    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var params : SCustomEffectParams;
		var riderActor			: CActor 	= GetActor();
		var vehicleEntity 		: CEntity 	= vehicleComponent.GetEntity();	
		
		if ( riderData.ridingManagerDismountType == DT_ragdoll || riderData.ridingManagerDismountType == DT_shakeOff )
		{
			riderData.sharedParams.hasFallenFromHorse = true;
			riderActor.SetKinematic(false);
			params.effectType = EET_Ragdoll;
			params.creator = riderActor;
			params.sourceName = "ragdoll_dismount";
			params.duration = 2;
			riderActor.AddEffectCustom( params );
			riderActor.SignalGameplayEvent( 'RagdollFromHorse' );
			riderActor.EnableCollisions( true );
			if ( riderData.ridingManagerDismountType == DT_ragdoll )
				riderActor.EnableCharacterCollisions( false );
			
		}
		else
		{
			riderActor.EnableCollisions( true );	
		}
		
		
        riderActor.SoundSwitch( "vo_3d", 'vo_3d_long', 'head' );
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }
    latent function OnDismountFinishedB_Latent( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var stupidArray     	: array< name >;
		var params				: SCustomEffectParams;
		var inv					: CInventoryComponent;
		var item				: SItemUniqueId;
		
		inv = riderActor.GetInventory();
		item = inv.GetItemFromSlot('r_weapon');
		
		if ( riderActor.IsInCombat() && inv.IsIdValid(item) && inv.ItemHasTag(item,'sword1h') )
			stupidArray.PushBack( 'sword_1handed' );
		else
			stupidArray.PushBack( 'Exploration' );
			
		riderActor.ActivateBehaviors( stupidArray );
		
		if ( riderData.ridingManagerDismountType == DT_ragdoll || riderData.ridingManagerDismountType == DT_shakeOff )
		{
			GetNPC().SetIsFallingFromHorse( true ); 
			
			params.effectType = EET_Ragdoll;
			params.creator = (CGameplayEntity)vehicleComponent.GetEntity();
			params.sourceName = "ragdoll_dismount";
			params.duration = 2;
			riderActor.AddEffectCustom(params);
		}
		
		riderActor.RemoveBuffImmunity( EET_Frozen, 'HorseDismount' );
		
		super.OnDismountFinishedB_Latent( riderData, vehicleComponent );
    }
}


class CBTTaskRidingManagerNPCHorseDismountDef extends CBTTaskRidingManagerHorseDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerNPCHorseDismount';
}




class CBTTaskRidingManagerPlayerHorseDismount extends CBTTaskRidingManagerHorseDismount
{    
	function OnDismountStarted( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();
		var newRiderPosition	: Vector;
		var pointA, pointB, outPosition, outNormal : Vector;
		var collisionGroupsNames : array<name>;
		
		super.OnDismountStarted( riderData, vehicleComponent );
		
		riderActor.SetBehaviorVariable( 'swordAdditiveBlendWeight', 0.f );
		
		if ( riderData.ridingManagerDismountType == DT_instant )
		{
			if ( !theGame.GetWorld().NavigationFindSafeSpot(riderActor.GetWorldPosition(),0.4, 2, newRiderPosition) )
			{
				newRiderPosition = riderActor.GetWorldPosition();
				newRiderPosition.Z += 1.5;
			}
			else
			{
				collisionGroupsNames.PushBack('Static');
				collisionGroupsNames.PushBack('Terrain');
				collisionGroupsNames.PushBack('Destructible');
				
				
				pointA = riderActor.GetWorldPosition();
				pointB = newRiderPosition;
				pointA.Z += 1.f;
				pointB.Z += 1.f;
				if ( !theGame.GetWorld().StaticTrace(pointA,pointB,outPosition,outNormal,collisionGroupsNames) )
				{
					newRiderPosition = riderActor.GetWorldPosition();
					newRiderPosition.Z += 1.5;
				}
			}
			riderActor.Teleport(newRiderPosition);
		}
    }
    
    function OnDismountFinishedA( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
    {
		var riderActor			: CActor 	= GetActor();		

		
		
		if ( vehicleComponent.GetEntity() != thePlayer.GetHorseWithInventory() )
		{
			((W3HorseComponent)vehicleComponent).Unpair(); 
		}
		
		super.OnDismountFinishedA( riderData, vehicleComponent );
    }	
}


class CBTTaskRidingManagerPlayerHorseDismountDef extends CBTTaskRidingManagerHorseDismountDef
{
	default instanceClass = 'CBTTaskRidingManagerPlayerHorseDismount';
}
