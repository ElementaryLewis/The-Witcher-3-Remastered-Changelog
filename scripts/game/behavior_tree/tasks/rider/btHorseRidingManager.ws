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
		var isCart				: bool;
		var prevAttachSlot		: name;

		isCart = ((W3HorseComponent)vehicleComponent).isCart;

		vehicleActor      	= (CActor)vehicleComponent.GetEntity();
		player				= (CR4Player)riderActor;
		
		
		if ( riderData.ridingManagerInstantMount == false )
		{
			
			
			if ( !isCart )
			{
				riderActor.GetMovingAgentComponent().SetAdditionalOffsetWhenAttachingToEntity( vehicleActor, 1.0f );
			}
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
		
		prevAttachSlot = attachSlot;
		if ( isCart )
		{
			attachSlot = 'root';
		}

		super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );

		
		riderActor.SetBehaviorVariable( 'isCart', isCart ? 1.0f : 0.0f );

		attachSlot = prevAttachSlot;
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


function IsMountsRemasterEnabled() : bool
{
	return ( theGame.GetInGameConfigWrapper().GetVarValue('NewHorseControls', 'UseNewControls') == "true"
		&& theGame.GetInGameConfigWrapper().GetVarValue('NewHorseControls', 'ExperimentalMounts') == "true" );
}



class CBTTaskRidingManagerPlayerHorseMount extends CBTTaskRidingManagerHorseMount
{
	var isFirstAdjPos : bool;
	var isFirstAdjRot : bool;

	latent function OnMountStarted( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent ) 
	{
		var riderActor          : CActor = GetActor();	
		super.OnMountStarted( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFinishedSuccessfully( riderData : CAIStorageRiderData, behGraphName: name, vehicleComponent : CVehicleComponent )
	{
		var horseComponent		: W3HorseComponent;
		var horseManager		: W3HorseManager = GetWitcherPlayer().GetHorseManager();
		var vehicleEntity 		: CEntity = vehicleComponent.GetEntity();     
        horseComponent = (W3HorseComponent)vehicleComponent;


		horseComponent.canDismount = true;
		
        super.OnMountFinishedSuccessfully( riderData, behGraphName, vehicleComponent );
	}

	latent function OnMountFailed( riderData : CAIStorageRiderData, vehicleComponent : CVehicleComponent )
	{
		var riderActor             : CActor = GetActor();
		theGame.ActivateHorseCamera( false, 0.2f );
		riderActor.ActionCancelAll();
		riderActor.EnableCharacterCollisions( true );
		riderActor.RegisterCollisionEventsListener();		

		theInput.SetContext( thePlayer.GetExplorationInputContext() );
		super.OnMountFailed( riderData, vehicleComponent );
	}

	

    latent function Main() : EBTNodeStatus
    {
        var vehicleEntity		: CEntity;
		var vehicleComponent	: W3HorseComponent;
		var riderActor			: CActor;
		var exploration 		: SExplorationQueryToken;
		var queryContext 		: SExplorationQueryContext;
		var success 			: bool = true;	
		var useNewMount 		: bool = true;	
		var startDist 			: float;	
		var entrySpeed 			: float;

        vehicleEntity      = riderData.sharedParams.GetHorse();
        vehicleComponent   = ((CNewNPC)vehicleEntity).GetHorseComponent(); 
		riderActor         = GetActor();

		riderData.ridingManagerMountError = false; 
		vehicleComponent.useEarlyExploration = false;

		useNewMount = !vehicleComponent.isCart && !thePlayer.IsCiri() && !riderData.ridingManagerInstantMount && IsMountsRemasterEnabled();

		
		if ( useNewMount )
		{
			startDist = VecDistance2D( vehicleEntity.GetWorldPosition(), riderActor.GetWorldPosition() );
			entrySpeed = VecLength2D( riderActor.GetMovingAgentComponent().GetVelocity() );
			useNewMount = startDist > 3.0 && entrySpeed > 1.9; 
		}

		

		
		if ( !useNewMount )
		{
			theGame.ActivateHorseCamera( true, riderData.ridingManagerInstantMount ? 0.f : 0.4f, riderData.ridingManagerInstantMount );
			riderActor.EnableCharacterCollisions( false ); 
			MountActor( riderData, 'VehicleHorse', vehicleComponent );
			return BTNS_Completed;
		}

		vehicleComponent.useEarlyExploration = true;

		

		
		
		
		
		
		
		
		
		
		if ( success )
		{
			
			if ( vehicleComponent.GetCurrentStateName() == 'Exploration' )
			{
				vehicleComponent.PopState( true );
			}

			
			OnMountStarted( riderData, 'VehicleHorse', vehicleComponent );

			if ( riderData.ridingManagerInstantMount == false )
			{
				success = MountHorse_Remaster_Running( vehicleComponent );
			}
		}
		
		if ( success )
		{		
			OnMountFinishedSuccessfully( riderData, 'VehicleHorse', vehicleComponent );
		}
		else
		{
			OnMountFailed( riderData, vehicleComponent );
		}


        return BTNS_Completed;
    }

	
	latent function MountHorse_Remaster_Running( horseComponent : W3HorseComponent ) : bool
	{
		var riderActor			: CActor;
		var vehicleEntity		: CEntity;
		var movAdj				: CMovementAdjustor;
		var isMoving			: bool;
		var animName			: name;
		var horseMac			: CMovingAgentComponent;
		var riderMac			: CMovingAgentComponent;
		var horsePredictedPos	: Vector;
		var horsePredictedRot	: float;
		var rotDelta			: float;
		var posDelta			: float;
		var approachVec			: Vector;
		var approachAngle		: float;
		var approachDist		: float;
		var iteration			: int;
		var useBackAnim 		: bool = false;
		var i					: int;
		var debugBool			: bool;
		var debugVec			: Vector;

		riderActor 		= GetActor();
        vehicleEntity 	= riderData.sharedParams.GetHorse();
		horseMac 		= ((CActor)vehicleEntity).GetMovingAgentComponent();
		riderMac 		= riderActor.GetMovingAgentComponent();

		
		debugBool = false;

		horseComponent.OnEarlyExplorationMountStart( riderActor );

		if ( 1 )
		{
			riderActor.EnableCharacterCollisions( true ); 
			
			
			
			
			
			isMoving = false;
			while ( 1 )
			{
				if ( 1 )
				
				{
					
					
					
					
					
					

					if ( VecLength2D( horseMac.GetVelocity() ) > VecLength2D( riderMac.GetVelocity() ) * 1.2 )
					{
						riderActor.ActionCancelAll();
						return false;
					}

					horsePredictedPos = vehicleEntity.GetWorldPosition();
					horsePredictedRot = vehicleEntity.GetHeading();
					posDelta = VecLength2D( horseMac.GetVelocity() ) * 0.05;
					rotDelta = ClampF( horseComponent.rotSpeed, -90, 90 ) * 0.05; 

					
					
					for ( i = 0; i < 2; i += 1 )
					{
						for ( iteration = 0; iteration < 5; iteration += 1 ) 
						{
							horsePredictedPos += VecFromHeading( horsePredictedRot ) * posDelta;
							horsePredictedRot += rotDelta;
						}

						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						

						approachVec = horsePredictedPos - riderActor.GetWorldPosition();
						approachAngle = AngleDistance( horsePredictedRot, VecHeading( -approachVec ) );
						approachDist = VecLength2D( approachVec );

						
						
						
						
						

						
						if ( i == 1 )
						{
							approachDist = approachDist - 0.35;
						}

						
						if ( approachAngle > 0 )
						{
							if ( approachAngle < 61.89 )
							{
								if ( approachDist <= 3.11 ) animName = 'mount_jump_right_front_45_remaster';
							}
							else if ( approachAngle < 101.25 )
							{
								if ( approachDist <= 3.00 ) animName = 'mount_jump_right_side_remaster';
							}
							else if ( approachAngle < 135.63 )
							{
								if ( approachDist <= 2.65 ) animName = 'mount_jump_right_back_45_remaster';
							}
							else if ( approachAngle < 165.07 || !useBackAnim )
							{
								if ( approachDist <= 1.95 ) animName = 'mount_jump_right_back_remaster';
							}
							else {
								if ( approachDist <= 3.08 ) animName = 'mount_jump_back_remaster';
							}
						}
						else
						{
							if ( approachAngle > -60.91 )
							{
								if ( approachDist <= 3.72 ) animName = 'mount_jump_left_front_45_remaster';
							}
							else if ( approachAngle > -110.87 )
							{
								if ( approachDist <= 3.50 ) animName = 'mount_jump_left_side_remaster';
							}
							else if ( approachAngle > -143.84 )
							{
								if ( approachDist <= 2.75 ) animName = 'mount_jump_left_back_45_remaster';
							}
							else if ( approachAngle > -166.42 || !useBackAnim )
							{
								if ( approachDist <= 2.56 ) animName = 'mount_jump_left_back_remaster';
							}
							else {
								if ( approachDist <= 3.08 ) animName = 'mount_jump_back_remaster';
							}
						}

						if ( animName )
						{
							break;
						}
					}

					if ( animName )
					{
						break;
					}

					if ( debugBool )
					{
						return false;
					}

					if ( !isMoving )
					{
						
						
						
						riderActor.ActionMoveToAsync( horsePredictedPos + VecNormalize2D( approachVec ) , MT_Sprint, 1.0, 0.1 ); 
						isMoving = true;
					}
					else
					{
						riderActor.ActionMoveToChangeTargetAsync( horsePredictedPos + VecNormalize2D( approachVec ), MT_Sprint, 1.0, 0.1 );
					}
				}
				else 
				{
					return false;
				}

				SleepOneFrame();
			}

			riderActor.ActionCancelAll();

			
			riderActor.EnableCharacterCollisions( false ); 
		}
		
		
		
		
		
		
		

		

		
		riderActor.SetInteractionPriority( IP_Max_Unpushable );

		
		mountType = 'horse_mount_B_01';

		
		

		isFirstAdjPos = true;
		isFirstAdjRot = true;

		
		
		
		
		
		
		

		
		
		
		((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnMountAnimStarted();
		debugBool = riderActor.ActionPlaySlotAnimation( 'PLAYER_SLOT', animName, 0.2, 0, false );
		if ( !debugBool )
		{
			
			((CR4PlayerStateMountHorse)thePlayer.GetState('MountHorse')).OnMountAnimCancelled();
			
			riderActor.RestoreOriginalInteractionPriority();
			return false;
		}
		
		movAdj = riderActor.GetMovingAgentComponent().GetMovementAdjustor();
		movAdj.CancelByName( 'AdjustMountT1' );
		movAdj.CancelByName( 'AdjustMountR1' );
		movAdj.CancelByName( 'AdjustMountT2' );
		movAdj.CancelByName( 'AdjustMountR2' );

		
		
		theGame.ActivateHorseCamera( true, 0.4f, false );

		
		riderActor.RestoreOriginalInteractionPriority();

		
		riderActor.SignalGameplayEvent( 'HorseRidingOn' );
		
		return true;
	}

	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var animName 			: name;
		var riderActor			: CActor;
		var vehicleEntity		: CEntity;
		var vehicleComponent	: W3HorseComponent;
		var movAdjReqTicket 	: SMovementAdjustmentRequestTicket;
		var movAdj				: CMovementAdjustor;

		riderActor = GetActor();
		vehicleEntity = riderData.sharedParams.GetHorse();
		vehicleComponent = ((CNewNPC)vehicleEntity).GetHorseComponent(); 
		movAdj = riderActor.GetMovingAgentComponent().GetMovementAdjustor();
		animName = GetAnimNameFromEventAnimInfo( animInfo );

		if ( animEventType == AET_DurationStart )
		{
			if ( animEventName == 'AdjPos' )
			{
				movAdjReqTicket = movAdj.CreateNewRequest( 'AdjustMountT1' );
				movAdj.BindToEventAnimInfo( movAdjReqTicket, animInfo );
				
				movAdj.SlideToEntity( movAdjReqTicket, vehicleEntity );
				movAdj.PredictForDurationOnly( movAdjReqTicket );
				movAdj.BlendIn( movAdjReqTicket, 0.2 );
				return true;
			}
			else if ( animEventName == 'AdjPos2' )
			{
				vehicleComponent.OnEarlyExplorationMountJump( riderActor );

				movAdj.CancelByName( 'AdjustMountT1' );
				movAdjReqTicket = movAdj.CreateNewRequest( 'AdjustMountT2' );
				movAdj.BindToEventAnimInfo( movAdjReqTicket, animInfo );
				
				movAdj.SlideToEntity( movAdjReqTicket, vehicleEntity );
				movAdj.AdjustLocationVertically( movAdjReqTicket, true );
				
				return true;
			}
			else if ( animEventName == 'AdjRot' )
			{
				movAdjReqTicket = movAdj.CreateNewRequest( 'AdjustMountR1' );
				movAdj.BindToEventAnimInfo( movAdjReqTicket, animInfo );
				
				movAdj.MatchEntitySlot( movAdjReqTicket, vehicleEntity, 'root' );
				movAdj.MaxLocationAdjustmentDistance( movAdjReqTicket, false, 0.0f );
				movAdj.PredictForDurationOnly( movAdjReqTicket );
				movAdj.BlendIn( movAdjReqTicket, 0.15 );
				return true;
			}
			else if ( animEventName == 'AdjRot2' )
			{
				movAdj.CancelByName( 'AdjustMountR1' );
				movAdjReqTicket = movAdj.CreateNewRequest( 'AdjustMountR2' );
				movAdj.BindToEventAnimInfo( movAdjReqTicket, animInfo );
				
				movAdj.MatchEntitySlot( movAdjReqTicket, vehicleEntity, 'root' );
				movAdj.MaxLocationAdjustmentDistance( movAdjReqTicket, false, 0.0f );
				movAdj.Continuous( movAdjReqTicket ); 
				
				return true;
			}
		}

		return false;
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