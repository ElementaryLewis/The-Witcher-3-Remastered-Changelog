/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class CVehicleComponent extends CComponent
{	
	import public var user : CActor;
	
	
	private var isCameraActivated : bool;
	private var isPlayingSyncAnimation : bool;
	private editable var slots : array< Vector >;
	
	protected editable var mainStateName 		: name;
	protected editable var passengerStateName 	: name;
	protected var userCombatManager 			: W3VehicleCombatManager;
	protected var canBoardTheBoat				: bool;
	
	var commandToMountActorToMount : CActor;
	var commandToMountMountType : EMountType;
	var commandToMountVehicleSlot : EVehicleSlot;
	
	import final latent function PlaySlotAnimation( slot : name, animation : name, optional blendIn : float, optional blendOut : float ) : bool;
	import final function PlaySlotAnimationAsync( slot : name, animation : name, optional blendIn : float, optional blendOut : float ) : bool;
	import final function GetSlotTransform( slotName : name, out translation : Vector, out rotQuat : Vector );
	import final function GetDeepDistance( vel : Vector ) : float;
	
	import final function SetCommandToMountDelayed( ctmd : bool );
	import final function IsCommandToMountDelayed() : bool;
	
	import final function OnDriverMount();
	
	default canBoardTheBoat = true;
	
	event OnMountStarted( entity : CEntity, vehicleSlot : EVehicleSlot ) 
	{
		if ( vehicleSlot == EVS_driver_slot )
		{
			user = (CActor)entity;
			OnDriverMount();
		}
	}

	event OnEarlyExplorationMountStart( entity : CEntity )
	{
	}

	event OnEarlyExplorationMountJump( entity : CEntity )
	{
	}

	event OnMountFinished( entity : CEntity )
	{
		if( entity == thePlayer )
		{
			if ( userCombatManager )
			{
				userCombatManager.OnMountFinished();
			}
			
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'vehicle', true);
			GetWitcherPlayer().TestStopClothSimulation(false);
		}
	}
	
	event OnDismountStarted( entity : CEntity ) {}
	event OnDismountFinished( entity : CEntity, vehicleSlot : EVehicleSlot ) 
	{
		if ( vehicleSlot == EVS_driver_slot )
		{
			user 		= NULL;
		}
		if ( entity == thePlayer )
		{
			ToggleVehicleCamera( false );
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'vehicle');
			thePlayer.AddTimer('ReapplyCSTimer', 2.f);
			thePlayer.SetInteractionPriority(IP_Prio_0);
			GetWitcherPlayer().TestStopClothSimulation(true);
		}
	}
	
	event OnCombatAction( action : EVehicleCombatAction ){}
	event OnCombatActionEnd(){}
	event OnTakeDamage( action : W3DamageAction ){}
	
	event OnInit()
	{
		var tags : array< name >;
		
		tags = GetEntity().GetTags();
		if( !tags.Contains( 'vehicle' ) )
		{
			tags.PushBack( 'vehicle' );
			GetEntity().SetTags( tags );
		}
		
		GotoStateAuto();
	}

	event OnDeinit()
	{
		if( GetUser() == thePlayer )
		{
			IssueCommandToDismount( DT_instant );
		}
		
	}
	
	event OnAnimationStarted( entity : CEntity, data : name )
	{
		this.PlaySlotAnimationAsync( 'VEHICLE_SLOT', data );
	}
	
	public function CanUseBoardingExploration() : bool
	{
		return canBoardTheBoat;
	}
	
	public function GetUserCombatManager() : W3VehicleCombatManager
	{
		return userCombatManager;
	}
	
	
	
	
		
	function Mount( actorToMount : CActor, optional mountType : EVehicleMountType, vehicleSlot : EVehicleSlot )
	{
		if( actorToMount )
		{
			LogAssert( IsMounted() == false, "CVehicleComponent::Mount - 'IsMounted' flag is true" );
			
			if( mountType == VMT_ApproachAndMount )
			{
				IssueCommandToApprochToSlot( actorToMount );
			}
			else if( mountType == VMT_TeleportAndMount )
			{
				TeleportAndMount( actorToMount );
			}
			else if( mountType == VMT_MountIfPossible )
			{
				IssueCommandToMount( actorToMount, MT_normal, vehicleSlot );
			}
			else if( mountType == VMT_ImmediateUse )
			{
				IssueCommandToMount( actorToMount, MT_instant, vehicleSlot );
			}
		}
	}
	
	
	
	
	
	function IssueCommandToApprochToSlot( entity : CEntity )
	{
		((CPlayerStateApproachTheVehicle)entity.GetState( 'ApproachTheVehicle' )).SetupState( this, 0 );
		entity.GotoState( 'ApproachTheVehicle', false );
	}
	
	event OnDelayedCommandToMount( dt : float )
	{
		if( thePlayer )
		{
			IssueCommandToMount( commandToMountActorToMount, commandToMountMountType, commandToMountVehicleSlot );
			SetCommandToMountDelayed( false );
		}
	}
	
	function IssueCommandToMount( actorToMount : CActor, mountType : EMountType, vehicleSlot : EVehicleSlot )
	{
		var playerHorseRiderSharedParams : CHorseRiderSharedParams;
		
		if( !thePlayer )
		{
			if( !IsCommandToMountDelayed() )
			{
				SetCommandToMountDelayed( true );
				commandToMountActorToMount = actorToMount;
				commandToMountMountType = mountType;
				commandToMountVehicleSlot = vehicleSlot;
			}
			
			return;
		}
		
		if( actorToMount != thePlayer )
		{
			return;
		}
		
		SetCommandToMountDelayed( false );

		if( (W3HorseComponent)this )
		{
			playerHorseRiderSharedParams 		= thePlayer.GetRiderData().sharedParams;
			if( playerHorseRiderSharedParams.mountStatus == VMS_dismounted )
			{
				((CR4PlayerStateMountHorse)thePlayer.GetState( 'MountHorse' )).SetupState( this, mountType, EVS_driver_slot );
				thePlayer.GotoState( 'MountHorse' );
			}
		}
		else if( (CBoatComponent)this )
		{
			((CR4PlayerStateMountBoat)thePlayer.GetState( 'MountBoat' )).SetupState( this, mountType, vehicleSlot );
			thePlayer.GotoState( 'MountBoat' );
		}	
	}
	
	function IssueCommandToUseVehicle( )
	{
		var riderData 	: CAIStorageRiderData;
		riderData = thePlayer.GetRiderData();
		if ( riderData.sharedParams.vehicleSlot == EVS_driver_slot )
		{
			((CR4PlayerStateUseGenericVehicle)thePlayer.GetState( mainStateName )).SetVehicle( this );
			thePlayer.GotoState( mainStateName, false );
		}
		else if ( passengerStateName )
		{
			((CR4PlayerStateUseGenericVehicle)thePlayer.GetState( passengerStateName )).SetVehicle( this );
			thePlayer.GotoState( passengerStateName, false );
		}
	}
	
	function IssueCommandToDismount( dismountType : EDismountType )
	{
		var riderData 	: CAIStorageRiderData;
		var boatComponent : CBoatComponent;

		riderData = thePlayer.GetRiderData();

		if( (W3HorseComponent)this )
		{
			((CPlayerStateDismountTheVehicle)thePlayer.GetState( 'DismountHorse' )).SetupState( this, dismountType );
			
			if ( riderData.sharedParams.vehicleSlot == EVS_driver_slot )
				((CR4PlayerStateUseGenericVehicle)thePlayer.GetState( mainStateName )).DismountVehicle();
			else if ( passengerStateName )
				((CR4PlayerStateUseGenericVehicle)thePlayer.GetState( passengerStateName )).DismountVehicle();
		}
		else if( (CBoatComponent)this )
		{
			boatComponent = (CBoatComponent)this;
			
			
			if ( riderData.sharedParams.vehicleSlot == EVS_driver_slot )
			{			
				boatComponent.dismountStateName = mainStateName;
				
				
				boatComponent.StopAndDismountBoat();
			}
			else if ( passengerStateName )
				((CR4PlayerStateUseGenericVehicle)thePlayer.GetState( passengerStateName )).DismountVehicle();
		}
	}
	
	function TeleportAndMount( entity : CEntity )
	{
		var slotPosition : Vector;
		var slotHeading : float;
		var slotRotation : EulerAngles;
		
		slotRotation.Yaw = slotHeading;
		
		GetSlotPositionAndHeading( 0, slotPosition, slotHeading );
		entity.TeleportWithRotation( slotPosition, slotRotation );
		
		IssueCommandToApprochToSlot( entity );
	}

	
	
	
	
	function CanAccesFastTravel( target : W3FastTravelEntity ) : bool { return true; }
	function InternalGetSpeed() : float; 
	function StopTheVehicle();
	function UpdateLogic();
	
	public function SetIsPlayingSyncAnimation( val : bool ) 
	{ 
		isPlayingSyncAnimation = val; 
	}
	
	public function GetIsPlayingSyncAnimation() : bool 
	{ 
		return isPlayingSyncAnimation; 
	}
	
	public function SetCombatManager( combatManager : W3VehicleCombatManager ) 
	{ 
		userCombatManager = combatManager;
		userCombatManager.OnMountFinished();
	}
	
	public function IsMounted() : bool 
	{ 
		return user; 
	}

	public function CanBeUsedBy( entity : CEntity ) : bool
	{
		return !IsMounted() && entity == thePlayer;
	}
	
	public function ToggleVehicleCamera( val : bool )
	{
		if ( val != isCameraActivated  )
		{
			isCameraActivated = val;
		}
	}
	
	public function GetVehicleType() : EVehicleType
	{
		if( (W3HorseComponent)this )
			return EVT_Horse;
		else if( (CBoatComponent)this )
			return EVT_Boat;
		else
			return EVT_Undefined;
	}
	
	public function AttachEntity( entity : CEntity, optional slot : name ) : bool
	{
		return entity.CreateAttachment( GetEntity(), slot );
	}

	latent function PlaySyncAnimWithUser( user : CActor, eventName : CName, deactivationEvent : CName )
	{
		SetIsPlayingSyncAnimation( true );
		if ( user.RaiseForceEventWithoutTestCheck( eventName ) )
		{
			
			if ( GetEntity().RaiseForceEventWithoutTestCheck( eventName ) )
			{
				
			}
			
			user.WaitForBehaviorNodeDeactivation( deactivationEvent, 10.f );
		}
		SetIsPlayingSyncAnimation( false );
	}
	
	final function GetSlotPositionAndHeading( slotNumber : int, out position : Vector, out heading : float )
	{
		LogAssert( slotNumber < slots.Size(), "CVehicleComponent: GetSlotPositionAndHeading, 'slotNumber < slots.Size()" );
		
		position = slots[ slotNumber ];
		heading = position.W;
		position.W = 1.f;
		
		position = VecTransform( GetLocalToWorld(), position );
		heading = GetHeading() + heading;
	}

	protected final function SetVariable( varName : name, varValue : float )
	{
		GetEntity().SetBehaviorVariable( varName, varValue );
		if( user )
		{
			user.SetBehaviorVariable( varName, varValue );
		}
	}
	
	protected final function GetVariable( varName : name ) : float
	{
		return GetEntity().GetBehaviorVariable( varName );
	}
	
	protected final function GenerateEvent( eventName : name )
	{
		var tmp : CEntity;
		tmp = GetEntity();
		tmp.RaiseEventWithoutTestCheck( eventName );
		
		if( user )
		{
			user.RaiseEvent( eventName );
		}
	}
	public function IsMountingPossible() : bool
	{
		return !user;
	}
	public function GetUser() : CActor
	{
		return user;
	}
}