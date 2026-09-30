/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import state UseVehicle in CPlayer extends Base
{
	event OnEnterState( prevStateName : name )
	{
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		
	}
	
	event OnVehicleStateTick( dt : float ){}
}





import state PostUseVehicle in CPlayer extends Base
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		( (CR4Player)parent ).OnCombatActionEndComplete();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	event OnVehicleStateTick( dt : float ){}
	
	
	import final function HACK_DeactivatePhysicsRepresentation();
	import final function HACK_ActivatePhysicsRepresentation();
}





state UseGenericVehicle in CR4Player extends UseVehicle
{
	protected var vehicle : CVehicleComponent;
	protected var camera : CCustomCamera;
	
	private var signSlotNames : array<name>;

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		parent.SetOrientationTarget( OT_Camera );
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		if ( (W3ReplacerCiri)parent )
		{
			parent.SetBehaviorVariable( 'test_ciri_replacer', 1.0f );
		}
		else
		{
			signSlotNames.PushBack( 'Slot2' );
			signSlotNames.PushBack( 'Slot3' );
			signSlotNames.PushBack( 'Slot4' );
			signSlotNames.PushBack( 'Slot5' );
			((W3PlayerWitcher)parent).EnableRadialSlotsWithSource( true, signSlotNames, 'throwProjectileOnVehicle' );	
			signSlotNames.Clear();
		
			if ( thePlayer.IsHoldingItemInLHand())
			{
				thePlayer.HideUsableItem(true);
			}
			if ( (W3HorseComponent)vehicle )
			{
				signSlotNames.PushBack('Yrden');
				signSlotNames.PushBack('Quen');
				signSlotNames.PushBack('Igni');
				signSlotNames.PushBack('Aard');
				signSlotNames.PushBack( 'Slot4' );
				signSlotNames.PushBack( 'Slot5' );
				if ( thePlayer.GetVehicleCachedSign() == ST_None )
					thePlayer.SetVehicleCachedSign( ((W3PlayerWitcher)parent).GetEquippedSign() );
				((W3PlayerWitcher)parent).SetEquippedSign(ST_Axii);
				((W3PlayerWitcher)parent).EnableRadialSlotsWithSource(false,signSlotNames, 'useVehicle');
			}
			else if ( (CBoatComponent)vehicle )
			{
				signSlotNames.PushBack( 'Slot1' );
				signSlotNames.PushBack( 'Slot2' );
				signSlotNames.PushBack( 'Slot4' );
				signSlotNames.PushBack( 'Slot5' );
				signSlotNames.PushBack('Yrden');
				signSlotNames.PushBack('Quen');
				signSlotNames.PushBack('Igni');
				signSlotNames.PushBack('Aard');
				signSlotNames.PushBack('Axii');	
				
				if ( thePlayer.GetVehicleCachedSign() == ST_None )
					thePlayer.SetVehicleCachedSign( ((W3PlayerWitcher)parent).GetEquippedSign() );
				((W3PlayerWitcher)parent).SelectQuickslotItem( EES_RangedWeapon );	
				((W3PlayerWitcher)parent).SetEquippedSign(ST_None);
				((W3PlayerWitcher)parent).EnableRadialSlotsWithSource(false,signSlotNames, 'useVehicle');
			}
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( (W3PlayerWitcher)parent )
		{
			((W3PlayerWitcher)parent).EnableRadialSlotsWithSource(true,signSlotNames, 'useVehicle');
			
			if ( thePlayer.GetVehicleCachedSign() != ST_None )
				((W3PlayerWitcher)parent).SetEquippedSign( thePlayer.GetVehicleCachedSign() );
		}
		
		signSlotNames.Clear();
		
		if ( nextStateName != 'None' )
			thePlayer.SetVehicleCachedSign( ST_None );
		
		if ( nextStateName != 'DismountHorse' )
			parent.OnRangedForceHolster( true, true );
			
		super.OnLeaveState(nextStateName);
	}
	
	final function SetVehicle( v : CVehicleComponent )
	{
		var vehEnt : CGameplayEntity;
		
		vehicle = v;
		
		if(vehicle)
		{
			vehEnt = (CGameplayEntity)vehicle.GetEntity();
			vehEnt.AddTag(theGame.params.TAG_PLAYERS_MOUNTED_VEHICLE);
		}
	}
	
	function DismountVehicle(){}
	
	function BeginState( prevStateName : name )
	{
		Init();
	}
	
	function ContinuedState()
	{
		var pos : Vector;
		
		pos = parent.GetWorldPosition();
		vehicle.GetEntity().Teleport( pos );
		
		vehicle.Mount( parent, VMT_ImmediateUse, EVS_driver_slot );
	}

	function EndState( nextStateName : name )
	{
		var vehEnt : CGameplayEntity;
		
		DetachFromVehicle();
		
		vehEnt = (CGameplayEntity)vehicle.GetEntity();
		vehEnt.RemoveTag(theGame.params.TAG_PLAYERS_MOUNTED_VEHICLE);
		vehicle = NULL;		
	}

	protected function Init() {}
	
	protected final function DetachFromVehicle()
	{
		parent.BreakAttachment();
	}
	
	function CanAccesFastTravel( target : W3FastTravelEntity ) : bool
	{
		if ( vehicle )
		{
			return vehicle.CanAccesFastTravel( target );
		}
		return true;
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{
		var rightStickVector	: Vector;
		var rightStickLength	: float;
		
		if ( thePlayer.IsHoldingItemInLHand())
		{
			thePlayer.HideUsableItem(true);
		}
		if ( parent.IsHardLockEnabled() )
		{
			if ( parent.IsPCModeEnabled() )
			{
				rightStickVector.X = theInput.GetActionValue( 'GI_MouseDampX' ); 
				rightStickVector.Y = theInput.GetActionValue( 'GI_MouseDampY' ); 			
			}
			else
			{
				rightStickVector.X = theInput.GetActionValue( 'GI_AxisRightX' ); 
				rightStickVector.Y = theInput.GetActionValue( 'GI_AxisRightY' ); 
			}
 
			rightStickLength = VecLength( rightStickVector );
			
			if ( rightStickLength > 0 )
				parent.bRAxisReleased = false;
			else
				parent.bRAxisReleased = true;			
				
			if ( !parent.ProcessLockTargetSelectionInput( rightStickVector, rightStickLength ) )
				parent.ProcessLockTargetSelectionInput( rightStickVector, rightStickLength );
			
			if ( rightStickLength >= 0.3 )
				FindTarget();
		}
		else
		{
			FindTarget();
		}
			
		
	}
	
	event OnHitStart()
	{
		parent.SetIsInHitAnim( true );
		vehicle.GetUserCombatManager().OnHitStart();
	}
	
	event OnHitEnd()
	{
		parent.SetIsInHitAnim( false );
	}	
	
	event OnCombatActionEnd()
	{
		vehicle.GetUserCombatManager().OnCombatActionEnd();
		return parent.OnCombatActionEnd();
	}
	
	protected function ShouldEnableBoatMusic()
	{
		if ( parent.ShouldEnableCombatMusic() )
			theSound.LeaveGameState(ESGS_Boat);
		else
			theSound.EnterGameState(ESGS_Boat);		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	function FindTarget()
	{
		var i, size : int;
		var targets : array<CActor>;
		var theChosenOne : CActor;
		var selectionWeights : STargetSelectionWeights;
		var flyingNPCs : bool;
		var targetingInfo		: STargetingInfo;
		var hud 				: CR4ScriptedHud;		
		var playerPosition		: Vector;
		var cameraPosition		: Vector;
		var cameraDirection		: Vector;

		
		targets = parent.GetMoveTargets();

		targetingInfo.source 				= parent;
		targetingInfo.canBeTargetedCheck	= true;
		targetingInfo.coneCheck 			= false;
		targetingInfo.coneHalfAngleCos		= 1.0f;
		targetingInfo.coneDist				= parent.softLockDistVehicle;
		targetingInfo.coneHeadingVector		= Vector( 0.0f, 1.0f, 0.0f );
		targetingInfo.distCheck				= true;
		targetingInfo.invisibleCheck		= true;
		targetingInfo.navMeshCheck			= false; 
		targetingInfo.inFrameCheck 			= true; 
		targetingInfo.frameScaleX 			= 1.0f; 
		targetingInfo.frameScaleY 			= 1.0f; 
		targetingInfo.knockDownCheck 		= false; 
		targetingInfo.knockDownCheckDist 	= 1.5f; 
		targetingInfo.rsHeadingCheck 		= false;
		targetingInfo.rsHeadingLimitCos 	= 1.0f;
		
		for( i = 0; i < targets.Size(); i += 1 )
		{
			targetingInfo.targetEntity 			= targets[i];		
			if ( !parent.IsEntityTargetable( targetingInfo ) || !parent.CanBeTargetedIfSwimming( targets[i] ) )
			{
				targets.Erase(i);
				i -= 1;
			}
			else if ( ( (CNewNPC)targets[i] ).GetCurrentStance() == NS_Fly )
				flyingNPCs = true;
		}			

		if( !flyingNPCs )
		{
			targetingInfo.source 				= parent;
			targetingInfo.canBeTargetedCheck	= true;
			targetingInfo.coneCheck 			= false;
			targetingInfo.coneHalfAngleCos		= 1.0f;
			targetingInfo.coneDist				= thePlayer.findMoveTargetDistMax + 7.f;
			targetingInfo.coneHeadingVector		= Vector( 0.0f, 1.0f, 0.0f );
			if ( parent.playerAiming.GetCurrentStateName() == 'Aiming' )
				targetingInfo.distCheck				= false;
			else
				targetingInfo.distCheck				= true;
			targetingInfo.invisibleCheck		= false;
			targetingInfo.navMeshCheck			= false; 
			targetingInfo.inFrameCheck 			= false; 
			targetingInfo.frameScaleX 			= 0.6f; 
			targetingInfo.frameScaleY 			= 1.f; 
			targetingInfo.knockDownCheck 		= false; 
			targetingInfo.knockDownCheckDist 	= 1.5f; 
			targetingInfo.rsHeadingCheck 		= false;
			targetingInfo.rsHeadingLimitCos		= 1.0f;		
		
			for( i = 0; i < targets.Size(); i += 1 )
			{
				targetingInfo.targetEntity 			= targets[i];
				if ( !parent.IsEntityTargetable( targetingInfo ) )
				{
					targets.Erase(i);
					i -= 1;
				}
			}			
		}

		playerPosition = thePlayer.GetWorldPosition();
		cameraPosition = theCamera.GetCameraPosition();
		cameraDirection = theCamera.GetCameraDirection();
		size = targets.Size();
		
		if( size > 0 && parent.IsThreatened() )
		{
			( (CActor)(vehicle.GetEntity()) ).SignalGameplayEvent( 'RiderCombatTargetUpdated' );
			
			if ( parent.playerAiming.GetCurrentStateName() == 'Aiming' )
			{
				theChosenOne = parent.playerAiming.GetAimedTarget();
				
				if ( !theChosenOne )
				{
					selectionWeights.angleWeight = 1.f;
					selectionWeights.distanceWeight = 0.f;
					selectionWeights.distanceRingWeight = 0.f;
					
					theChosenOne = parent.SelectTarget( targets, false, cameraPosition, cameraDirection, selectionWeights );					
				}
			}
			else if ( (W3Boat)( parent.GetUsedVehicle() ) )
			{
				selectionWeights.angleWeight = 1.0f;
				selectionWeights.distanceWeight = 0.0f;
				selectionWeights.distanceRingWeight = 0.f;
				
				theChosenOne = parent.SelectTarget( targets, false, cameraPosition, cameraDirection, selectionWeights );
			}
			else
			{
				selectionWeights.angleWeight = 0.0f;
				selectionWeights.distanceWeight = 1.0f;
				selectionWeights.distanceRingWeight = 0.f;	

				theChosenOne = parent.SelectTarget( targets, false, playerPosition, cameraDirection, selectionWeights );		
			}
		}

		if ( parent.GetDisplayTarget() 
			&& parent.rangedWeapon 
			&& parent.rangedWeapon.GetCurrentStateName() == 'State_WeaponShoot' 
			&& !parent.rangedWeapon.IsShootingComplete()
			&& parent.playerAiming.GetCurrentStateName() == 'Waiting' )
		{
			theChosenOne == parent.GetDisplayTarget();
		}
		
		if( ( parent.GetBIsCombatActionAllowed() || !parent.GetDisplayTarget() ) 
			
			&& !parent.IsActorLockedToTarget() )
		{ 
			parent.slideTarget = theChosenOne;
			parent.moveTarget = theChosenOne;
			
			parent.SetDisplayTarget( theChosenOne );
			parent.SetTarget( theChosenOne );
		}
	}

	protected var fovVel : float;
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var playerToTargetVector	: Vector;
		var playerToTargetAngles	: EulerAngles; 
		var playerToTargetDist		: float;
		var playerToTargetPitch		: float;
		var pitch					: float;
		var offset					: float;
		var distance				: float;	
		var thrownEntity		: CThrowable;
		
		thrownEntity = (CThrowable)EntityHandleGet( parent.thrownEntityHandle );
		camera = theGame.GetGameCamera();
		
		if ( !camera )
			return true;

		if ( ( parent.rangedWeapon || thrownEntity ) 
			&& ( parent.playerAiming.GetCurrentStateName() == 'Aiming' || parent.vehicleCbtMgrAiming ) )
			return true; 
		
		if ( parent.IsCameraLockedToTarget() )
		{
			DampFloatSpring( camera.fov, fovVel, 60.0, 1.0, dt );
			playerToTargetVector = parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition();
			playerToTargetDist = VecLength( playerToTargetVector );
			
			if ( parent.IsOnBoat() )
				moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), 1.f );
			else
				moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), 0.5f );
			
			if ( AbsF( playerToTargetVector.Z ) <= 1.f )
			{
				offset = ClampF( ( playerToTargetDist * ( 0.06f) ) + 2.2f, 2.2f, 2.5f );
				pitch = ClampF( ( playerToTargetDist * ( -2.f) ) + 30.f, 10.f, 30.f );
				
				moveData.pivotRotationController.SetDesiredPitch( -pitch, 0.5f );
			}
			else
			{
				playerToTargetAngles = VecToRotation( playerToTargetVector );
				playerToTargetPitch = ClampF( playerToTargetAngles.Pitch + 20, -45, 50 );			
				offset = ClampF( ( playerToTargetPitch * ( -0.023f) ) + 2.5f, 2.5f, 3.2f );
				
				moveData.pivotRotationController.SetDesiredPitch( playerToTargetPitch * -1, 0.5f );
			}
			
			moveData.pivotPositionController.offsetZ = offset;
			
			parent.OnGameCameraPostTick( moveData, dt );
			return true;			
		}
	}	
}





enum EVehicleCombatAction
{
	EHCA_ShootCrossbow,
	EHCA_ThrowBomb,
	EHCA_CastSign,
	EHCA_Attack
}

statemachine class W3VehicleCombatManager extends CEntity
{
	protected var rider : CR4Player;
	protected var vehicle : CVehicleComponent;
	protected var isInCombatAction : bool;
	
	protected var wasBombReleased	: bool; 
	
	default autoState = 'Null';
	
	public function Setup( player : CR4Player, _vehicle : CVehicleComponent )
	{
		rider = player;
		vehicle = _vehicle;
		
		if( rider )
		{
			theInput.RegisterListener( this, 'OnItemAction', 'VehicleItemAction' );
			theInput.RegisterListener( this, 'OnItemActionHold', 'VehicleItemActionHold' );
			theInput.RegisterListener( this, 'OnItemActionAbort', 'VehicleItemActionAbort' );
			theInput.RegisterListener( this, 'OnCastSign', 'VehicleCastSign' );
			theInput.RegisterListener( this, 'OnAttack', 'VehicleAttack' );
		}
	}
	
	public function IsInCombatAction() : bool
	{
		return isInCombatAction;
	}
	
	public function IsInSwordAttackCombatAction() : bool
	{
		return GetCurrentStateName() == 'SwordAttack';
	}
	
	event OnRaiseSignEvent() {}
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float ) { return false; }
	event OnAirBorn() {}
	event OnLanded() {}
	event OnProcessAnimEvent( animEventName : name ) {}
	
	event OnItemActionAbort( action : SInputAction ) {}
	event OnForceItemActionAbort(){}
	
	event OnHorseActionStart(){}
	event OnHorseActionStop(){}
	
	event OnMeleeWeaponReady(){}
	event OnMeleeWeaponNotReady(){}
	
	event OnHitStart(){}
	event OnCombatActionEnd(){}
	
	event OnMountFinished()
	{
	}
	
	event OnDismountStarted()
	{
		this.GotoStateAuto();
	}
	
	event OnDrawWeaponRequest(){}
}





state Null in W3VehicleCombatManager
{
	var rider : CR4Player;
	var horseComp : W3HorseComponent;
	
	event OnEnterState( prevStateName : name )
	{
		rider = parent.rider;
		rider.vehicleCbtMgrAiming = false;
		rider.playerAiming.StopAiming();
		
		if ( parent.isInCombatAction )
		{
			rider.OnCombatActionEnd();
			parent.isInCombatAction = false;
		}
		
		horseComp = (W3HorseComponent)parent.vehicle;
		
		rider.UnblockAction(EIAB_ThrowBomb, 'BombThrow' );
		rider.UnblockAction(EIAB_Crossbow, 'BombThrow');	

		ShouldEnterNextState();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.isInCombatAction = true;
	}
	
	entry function ShouldEnterNextState()
	{
		SleepOneFrame(); 
		
		if ( horseComp && !horseComp.IsFullyMounted() )
		{
			parent.GotoState('MountingInProgress');
		}
		else if ( horseComp && horseComp.IsInHorseAction() )
		{
			parent.GotoState('HorseAction');
		}
		else if ( !rider.GetWeaponHolster().IsMeleeWeaponReady() )
		{
			parent.GotoState('ChangeSwordState');
		}
		else if ( theInput.IsActionPressed('VehicleAttack') )
		{
			StartAttackAction();
		}
		else if ( theInput.IsActionPressed('VehicleItemAction') )
		{
			StartItemAction();
		}
		else if ( theInput.IsActionPressed('VehicleCastSign') )
		{
			StartCastSignAction();
		}
	}
	
	event OnItemAction( action : SInputAction )
	{
		var itemId, selectedItemId : SItemUniqueId;
		var process : bool;
		
		if ( horseComp && !horseComp.IsFullyMounted() )
		{
			parent.GotoState('MountingInProgress');
			return false;
		}
		
		if ( rider.IsOnBoat() && rider.GetCurrentStateName() != 'Sailing' && rider.GetCurrentStateName() != 'SailingPassive' )
		{
			return false;
		}
		
		
		if(rider.IsInAir() || rider.GetWeaponHolster().IsOnTheMiddleOfHolstering())
			return false;
			
		itemId = rider.GetSelectedItemId();
		
		if(!rider.inv.IsIdValid(itemId))
			return false;
		
		
		if( rider.inv.IsItemCrossbow(itemId) )
		{
			if ( rider.IsActionAllowed(EIAB_Crossbow) )
			{
				if( IsPressed(action))
				{
					if ( rider.GetBIsInputAllowed() )
					{
						process = true;
					}
				}
				else
				{
					if ( rider.GetIsAimingCrossbow() )
					{
						process = true;
					}
				}
			}
			else
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, , , true);
			}
		}
		
		else if( rider.inv.IsItemBomb(itemId) )
		{
			if(!rider.IsActionAllowed(EIAB_ThrowBomb) )
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_Undefined, , , true);				
				return false;
			}
		
			if( rider.inv.SingletonItemGetAmmo(itemId) == 0 )
				return false;
						
			if(IsPressed(action))
			{
				if(thePlayer.CanSetupCombatAction_Throw() && theInput.GetLastActivationTime( action.aName ) < 0.3f )	
				{
					process = true;
				}
			}			
		}
	
		if(process && IsPressed( action ) )
		{
			StartItemAction();
		}
	}
	
	event OnCastSign( action : SInputAction )
	{
		if ( horseComp && !horseComp.IsFullyMounted() )
		{
			parent.GotoState('MountingInProgress');
			return false;
		}
		
		if( IsPressed( action ) )
		{
			StartCastSignAction();
		}
	}
	
	event OnAttack( action : SInputAction )
	{
		if ( horseComp && !horseComp.IsFullyMounted() )
		{
			parent.GotoState('MountingInProgress');
			return false;
		}
		
		if( IsPressed( action ) )
		{
			StartAttackAction();
		}
	}
	
	event OnAirBorn()
	{
		parent.GotoState( 'InAir' );
	}
	
	event OnHorseActionStart()
	{
		parent.GotoState( 'HorseAction' );
	}
	
	event OnMeleeWeaponNotReady()
	{
		parent.GotoState('ChangeSwordState');
	}
	
	event OnHitStart()
	{
		parent.GotoState('BeingHit');
	}
	
	
	
	
	
	function StartItemAction()
	{
		if( rider.GetInventory().IsItemBomb( rider.GetSelectedItemId() ) && rider.inv.SingletonItemGetAmmo( rider.GetSelectedItemId() ) > 0 && rider.IsActionAllowed( EIAB_ThrowBomb ) )
		{
			parent.GotoState( 'ThrowBomb' );
		}
		else if( rider.GetInventory().IsItemCrossbow( rider.GetSelectedItemId() ) && rider.IsActionAllowed( EIAB_Crossbow ) )
		{
			rider.SetBehaviorVariable( 'actionType', (int)EHCA_ShootCrossbow );
			rider.rangedWeapon = ( Crossbow )( rider.GetInventory().GetItemEntityUnsafe( rider.GetSelectedItemId() ) );
			rider.rangedWeapon.OnRangedWeaponPress();
			rider.BlockAction( EIAB_DismountVehicle, 'ShootingCrossbow' );
			rider.BlockAction( EIAB_MountVehicle, 'ShootingCrossbow' );
			parent.GotoState( 'ShootCrossbow' );	
		}
	}
	
	function StartCastSignAction()
	{
		parent.GotoState( 'CastSign' );
	}
	
	function StartAttackAction()
	{
		if ( rider.GetWeaponHolster().IsMeleeWeaponReady() )
		{
			if ( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'silversword' ))
			{
				parent.GotoState( 'SwordAttack' );
			}
			else
			{
				DrawWeapon();
			}
		}
	}
	
	event OnDrawWeaponRequest()
	{
		DrawWeapon();
	}
	
	function DrawWeapon()
	{
		var  weaponType	: EPlayerWeapon;
		
		if ( GetWitcherPlayer() && rider.IsActionAllowed(EIAB_DrawWeapon) )
		{
			if ( rider.GetTarget() )
			{
				weaponType = rider.GetMostConvenientMeleeWeapon( rider.GetTarget() );
				
				if ( weaponType == PW_Silver && GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
				{
					if ( rider.GetCurrentMeleeWeaponType() != PW_Silver )
						rider.OnEquipMeleeWeapon( PW_Silver, false, false );
				}
				else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
				{
					if ( rider.GetCurrentMeleeWeaponType() != PW_Steel )
						rider.OnEquipMeleeWeapon( PW_Steel, false, false );
				}
			}
			else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
			{
				if ( rider.GetCurrentMeleeWeaponType() != PW_Steel )
					rider.OnEquipMeleeWeapon( PW_Steel, false, false );
			}
			else  if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
			{
				if ( rider.GetCurrentMeleeWeaponType() != PW_Silver )
					rider.OnEquipMeleeWeapon( PW_Silver, false, false );
			}
		}
		else if ( rider.IsActionAllowed(EIAB_DrawWeapon) )
		{
			if ( rider.GetCurrentMeleeWeaponType() != PW_Steel )
				rider.OnEquipMeleeWeapon( PW_Steel, false, false );
		}
	}
}

state MountingInProgress in W3VehicleCombatManager
{
	event OnEnterState( prevStateName : name )
	{
		parent.isInCombatAction = false;
	}
	
	event OnLeaveState( nexStateName : name )
	{
		Log("LeaveMountingInProgress");
	}
	
	event OnMountFinished()
	{
		parent.PopState(true);
	}
}

state HorseAction in W3VehicleCombatManager
{
	event OnEnterState( prevStateName : name )
	{
		parent.isInCombatAction = false;
	}
	
	event OnHorseActionStop()
	{
		parent.PopState(true);
	}
}

state ChangeSwordState in W3VehicleCombatManager
{
	event OnEnterState( prevStateName : name )
	{
		parent.isInCombatAction = false;
		parent.rider.SetBehaviorVariable('keepSpineUpright',0.f);
	}
	
	event OnLeaveState( nexStateName : name )
	{
		parent.rider.SetBehaviorVariable('keepSpineUpright',1.f);
	}
	
	event OnMeleeWeaponReady()
	{
		parent.PopState(true);
	}
}

state BeingHit in W3VehicleCombatManager
{
	event OnEnterState( prevStateName : name )
	{
		parent.isInCombatAction = true;
	}
	
	event OnCombatActionEnd()
	{
		parent.PopState(true);
	}
}





state InAir in W3VehicleCombatManager
{
	event OnEnterState( prevStateName : name )
	{
		parent.isInCombatAction = false;
	}
	
	event OnLanded()
	{
		parent.PopState( true );
	}
}





enum HorseAttackSide
{
	HAS_Right,
	HAS_Left
}

state SwordAttack in W3VehicleCombatManager
{
	var rider : CR4Player;
	
	private var horizontalVal 	: float;
	
	private var speedMultCasuserId	: int;
	private var slowMoSpeedCurrVal, slowMoVelocityCurrVal : float;
	private var isSlowMoOn : bool;

	private const var ATTACK_TIMEOUT 			: float;
	private const var ATTACK_STAMINA_PER_SEC 	: float;
	private const var ATTACK_COOLDOWN	: float;	default ATTACK_COOLDOWN = 1.f;
	private const var CHANGE_SIDE_THRESHOLD	: float;	default CHANGE_SIDE_THRESHOLD = 0.02f;
	
	default speedMultCasuserId = -1;
	default ATTACK_TIMEOUT = 10.f; 
	default ATTACK_STAMINA_PER_SEC = 16.f;
	
	event OnEnterState( prevStateName : name )
	{
		parent.vehicle.OnCombatAction( EHCA_Attack );
		
		rider = parent.rider;
		
		rider.AddAbility( 'ForceDismemberment' );
		rider.BlockAction( EIAB_DrawWeapon, 'OnHorseCombatAction' );
		
		if( (W3ReplacerCiri)rider )
		{
			rider.SetBehaviorVariable( 'ciriReinsNoOffset', 1.0f, true );
		}
		
		slowMoSpeedCurrVal = 1.0;
		slowMoVelocityCurrVal = 0.0;
		
		InitAndBeginSwordAttack();
	}
	
	event OnLeaveState( nexStateName : name )
	{
		attackInProgress = false;
		
		rider.RemoveAbility( 'ForceDismemberment' );
		rider.UnblockAction( EIAB_DrawWeapon, 'OnHorseCombatAction' );
		
		if( (W3ReplacerCiri)rider )
		{
			rider.SetBehaviorVariable( 'ciriReinsNoOffset', 0.0f, true );
		}
		
		if( thePlayer.GetHorseCombatSlowMo() )
			TurnOffSlowMo();
		
		super.OnLeaveState(nexStateName);
	}
	
	private var attackInProgress : bool;
	
	entry function InitAndBeginSwordAttack()
	{
		rider.SetBehaviorVariable( 'attackRelease', 0.0 );
		
		ChooseInitialOrientation();
		BeginSwordAttack();
		parent.PopState( true );
	}
	
	private function ChooseInitialOrientation()
	{
		var heading : float;
		var riderPos, targetPos : Vector;
		var target : CActor;
		
		riderPos = rider.GetWorldPosition();
		
		target = rider.GetTarget();
		
		if( target )
		{
			targetPos = target.GetWorldPosition();
			heading = VecHeading( targetPos - riderPos );
			horizontalVal = AngleDistance( rider.GetHeading(), heading ) / 180.f;
		}
		else
		{
			if ( RandRange(100) > 50 )
				horizontalVal = 1;
			else
				horizontalVal = -1;
		}
		
		if ( horizontalVal > CHANGE_SIDE_THRESHOLD )
			rider.SetBehaviorVariable( 'aimHorizontalSword', 0.f );
		else if ( horizontalVal < -CHANGE_SIDE_THRESHOLD )
			rider.SetBehaviorVariable( 'aimHorizontalSword', 1.f );
	}
	
	latent function BeginSwordAttack()
	{
		var res : bool;
		
		if( rider.GetBehaviorVariable( 'actionType' ) != (int)EHCA_Attack )
		{
			rider.SetBehaviorVariable( 'actionType', (int)EHCA_Attack );
			rider.WaitForBehaviorNodeActivation( 'attackActionOn', 0.5f );
		}
		
		rider.RaiseEvent( 'actionStart' );
		
		res = rider.WaitForBehaviorNodeActivation( 'ActionOn', 0.5f );
		if( !res )
		{
			parent.PopState( true );
		}

		if( theInput.IsActionReleased( 'VehicleAttack' ) ) 
		{
			ChooseAttackHeight();
			rider.SetBehaviorVariable( 'attackRelease', 1.0 );
			attackInProgress = false;
			DoAttack();
			rider.WaitForBehaviorNodeActivation( 'ActionOff', 5.0 );
			parent.PopState( true );
		}
		else
		{
			attackInProgress = true;
			AdjustOrientationAndMaintainTimeout();
		}
	}
	
	latent function AdjustOrientationAndMaintainTimeout()
	{
		var heading : float;
		var riderPos, targetPos : Vector;
		var startTimeStamp, frameTimeStamp : float;
		var target : CActor;
		
		startTimeStamp = theGame.GetEngineTimeAsSeconds();
		frameTimeStamp = startTimeStamp;
		
		while( startTimeStamp + ATTACK_TIMEOUT >= theGame.GetEngineTimeAsSeconds() )
		{
			if( thePlayer.GetHorseCombatSlowMo() && ShouldActivateSlowMo() )
			{
				if( startTimeStamp + 0.1 < theGame.GetEngineTimeAsSeconds() )
				{	
					DampFloatSpring( slowMoSpeedCurrVal, slowMoVelocityCurrVal, 0.3, 0.1, theGame.GetEngineTimeAsSeconds() - frameTimeStamp );
					TurnOnSlowMo();
				}
			}
			else
			{
				TurnOffSlowMo();
			}
			
			riderPos = rider.GetWorldPosition();
			
			target = rider.GetTarget();
			
			if( target )
			{				
				target.IsAttacked( true );
				targetPos = target.GetWorldPosition();
				
				heading = VecHeading( targetPos - riderPos );
				horizontalVal = AngleDistance( rider.GetHeading(), heading ) / 180.f;
			}
			
			rider.SetBehaviorVariable( 'aimHorizontal', horizontalVal );
			
			if ( horizontalVal > CHANGE_SIDE_THRESHOLD )
				rider.SetBehaviorVariable( 'aimHorizontalSword', 0.f );
			else if ( horizontalVal < -CHANGE_SIDE_THRESHOLD )
				rider.SetBehaviorVariable( 'aimHorizontalSword', 1.f );
			
			frameTimeStamp = theGame.GetEngineTimeAsSeconds();
			SleepOneFrame();
		}
		
		AbortAttack();
	}
	
	entry function GoBackFromSlowMo()
	{
		var frameTimeStamp : float;
		
		slowMoVelocityCurrVal = 0.0;
		frameTimeStamp = theGame.GetEngineTimeAsSeconds();
		
		while( true )
		{
			DampFloatSpring( slowMoSpeedCurrVal, slowMoVelocityCurrVal, 1.0, 0.05, theGame.GetEngineTimeAsSeconds() - frameTimeStamp );
			TurnOnSlowMo();
			
			frameTimeStamp = theGame.GetEngineTimeAsSeconds();
			SleepOneFrame();
			
			if( slowMoSpeedCurrVal > 0.99 )
				break;
		}
		
		rider.WaitForBehaviorNodeActivation( 'ActionOff', 1.0 );
		parent.PopState( true );
	}
	
	event OnAttack( action : SInputAction )
	{
		if( IsReleased( action ) && attackInProgress && ( rider.GetCurrentMeleeWeaponType() == PW_Steel || rider.GetCurrentMeleeWeaponType() == PW_Silver ) )
		{
			if( CanPerformAttack() )
				FinishAttack();
			else
				AbortAttack();
		}
	}
	
	event OnHorseActionStart()
	{
		if( attackInProgress )
			AbortAttack();
	}
	
	event OnHitStart()
	{
		if( attackInProgress )
			AbortAttack();
	}
	
	event OnDismountStarted()
	{
		if( attackInProgress )
			AbortAttack();
		parent.OnDismountStarted();
	}
	
	entry function AbortAttack()
	{
		attackInProgress = false;
		
		theInput.ForceDeactivateAction( 'VehicleAttack' );
		
		rider.SetBehaviorVariable( 'attackRelease', 2.0 );
		
		if( thePlayer.GetHorseCombatSlowMo() && isSlowMoOn )
		{
			GoBackFromSlowMo();
		}
		else
		{
			rider.WaitForBehaviorNodeActivation( 'ActionOff', 10.0 );
			parent.PopState( true );
		}
	}
	
	entry function FinishAttack()
	{
		ChooseAttackHeight();
		rider.SetBehaviorVariable( 'attackRelease', 1.0 );
		if( rider == thePlayer )
			thePlayer.SendAttackReactionEvent();
		attackInProgress = false;
		DoAttack();
		if( thePlayer.GetHorseCombatSlowMo() && isSlowMoOn )
		{
			GoBackFromSlowMo();
		}
		else
		{
			rider.WaitForBehaviorNodeActivation( 'ActionOff', 5.0 );
			parent.PopState( true );
		}
	}
	
	function CanPerformAttack() : bool
	{
		var currHorizontalVal		: float;
		var entities 				: array<CGameplayEntity>;
		var i 						: int;
		var actor					: CActor;
		var npc						: CNewNPC;
		var horse					: CActor;
		var anyHostilesInRange		: bool;
		var anyFriendliesInRange	: bool;
		var attitude				: EAIAttitude;
		
		currHorizontalVal = rider.GetBehaviorVariable( 'aimHorizontal' );
		
		if ( currHorizontalVal >= 0 )
			rider.GatherEntitiesInAttackRange(entities,'horse_right');
		else
			rider.GatherEntitiesInAttackRange(entities,'horse_left');
		
		horse = (CActor)(parent.vehicle.GetEntity());
		
		if ( entities.Size() > 0 )
		{
			for ( i=0 ; i<entities.Size() ; i+=1 )
			{
				actor = (CActor)entities[i];
				
				if ( actor == rider || actor == horse )
					continue;
				
				if ( actor )
				{
					attitude = GetAttitudeBetween(rider,actor);
					npc = (CNewNPC)actor;
					
					if( npc && npc.GetNPCType() == ENGT_Guard && attitude != AIA_Hostile )
						anyFriendliesInRange = true;
					if ( attitude == AIA_Friendly )
						anyFriendliesInRange = true;
					else if ( attitude == AIA_Hostile )
						anyHostilesInRange = true;
				}
			}
		}
		
		if ( !anyFriendliesInRange || anyHostilesInRange )
			return true;
		else
			return false;
	}
	
	function ChooseAttackHeight()
	{
		var verticalVal : float;
		var riderPos, targetPos : Vector;
		var target : CActor;
		
		riderPos = rider.GetWorldPosition();
		
		target = rider.GetTarget();
		
		if( target )
		{
			targetPos = target.GetWorldPosition();
			
			if( target.IsUsingHorse() )
			{
				if( riderPos.Z < targetPos.Z + 0.3 )
				{
					verticalVal = 1.0;
				}
				else
				{
					verticalVal = 0.0;
				}
			}
			else 
			{
				if( riderPos.Z + 1.0 < targetPos.Z )
				{
					verticalVal = 1.0;
				}
				else
				{
					verticalVal = 0.0;
				}
			}
		}
		else
		{
			verticalVal = 0.0;
		}
		
		rider.SetBehaviorVariable( 'aimVertical', verticalVal );
	}
	
	const var FIRST_SWEEP_DELAY : float;	default FIRST_SWEEP_DELAY = 0.4;
	const var SECOND_SWEEP_DELAY : float;	default SECOND_SWEEP_DELAY = 0.2;
	const var BASE_DAMAGE : float;			default BASE_DAMAGE = 50.0;
	
	latent function DoAttack()
	{
		var horse : CNewNPC;
		var speed : float;
		var currHorizontalVal : float;
		var entities : array<CGameplayEntity>;
		var attackRanges : array<name>;
		var res : bool;
		
		res = rider.WaitForBehaviorNodeActivation( 'HorseAttackEndStarted', 0.5f );
		if( !res )
			return;

		horse = (CNewNPC)(rider.GetUsedVehicle());
		speed = horse.GetMovingAgentComponent().GetRelativeMoveSpeed();
		currHorizontalVal = rider.GetBehaviorVariable( 'aimHorizontalSword' );
		attackRanges = FillAttackRangesArray( currHorizontalVal );
		entities.Clear();
		
		if( thePlayer.GetHorseCombatSlowMo() )
		{
			Sleep( 0.12 );
			entities = GatherEntitiesInAttackRanges( speed, attackRanges );
		
			if( entities.Size() > 0 )
			{
				DealDamageToHostiles( entities, speed, BASE_DAMAGE );
			}
		}
		else
		{
			Sleep( FIRST_SWEEP_DELAY );
			entities = GatherEntitiesInAttackRanges( speed, attackRanges );
		
			if( entities.Size() > 0 )
			{
				DealDamageToHostiles( entities, speed, BASE_DAMAGE );
			}
			else
			{
				Sleep( SECOND_SWEEP_DELAY );
				entities = GatherEntitiesInAttackRanges( speed, attackRanges );
				
				if( entities.Size() > 0 )
				{
					DealDamageToHostiles( entities, speed, BASE_DAMAGE );
				}
			}
		}
	}

	private function FillAttackRangesArray( horizontalVal : float ) : array<name>
	{
		var attackRanges : array<name>;
		
		if( horizontalVal == 0.0 )
		{
			attackRanges.PushBack( 'horse_right' );
			attackRanges.PushBack( 'horse_right_1' );
			attackRanges.PushBack( 'horse_right_2' );
		}
		else if( horizontalVal == 1.0 )
		{
			attackRanges.PushBack( 'horse_left' );
			attackRanges.PushBack( 'horse_left_1' );
			attackRanges.PushBack( 'horse_left_2' );
		}
		
		return attackRanges;
	}
	
	private function GatherEntitiesInAttackRanges( speed : float, attackRanges : array<name> ) : array<CGameplayEntity>
	{
		var entities : array<CGameplayEntity>;
		
		if( speed < 3.0 )
		{
			rider.GatherEntitiesInAttackRange( entities, attackRanges[0] );
			thePlayer.SetDebugAttackRange( attackRanges[0] );
		}
		else if( speed >= 3.0 && speed < 4.0 )
		{
			rider.GatherEntitiesInAttackRange( entities, attackRanges[1] );
			thePlayer.SetDebugAttackRange( attackRanges[1] );
			
			if( entities.Size() == 0 )
			{
				rider.GatherEntitiesInAttackRange( entities, attackRanges[0] );
				thePlayer.SetDebugAttackRange( attackRanges[0] );
			}
		}
		else if( speed >= 4.0 )
		{
			rider.GatherEntitiesInAttackRange( entities, attackRanges[2] );
			thePlayer.SetDebugAttackRange( attackRanges[2] );
			
			if( entities.Size() == 0 )
			{
				rider.GatherEntitiesInAttackRange( entities, attackRanges[1] );
				thePlayer.SetDebugAttackRange( attackRanges[1] );
				
				if( entities.Size() == 0 )
				{
					rider.GatherEntitiesInAttackRange( entities, attackRanges[0] );
					thePlayer.SetDebugAttackRange( attackRanges[0] );
				}
			}
		}
		
		return entities;
	}
	
	private function DealDamageToHostiles( entities : array<CGameplayEntity>, speed : float, baseDamage : float )
	{
		var damage : W3Action_Attack;
		var i : int;
		var actor : CActor;
		var horse : CNewNPC;
		var bloodTrailParam : CBloodTrailEffect;
		var weaponId : SItemUniqueId;
		
		horse = (CNewNPC)(rider.GetUsedVehicle());
		damage = new W3Action_Attack in this;
		
		for( i = 0 ; i < entities.Size() ; i += 1 )
		{
			actor = (CActor)entities[i];
			
			if ( actor == rider || actor == horse || GetAttitudeBetween( rider, actor ) != AIA_Hostile )
				continue;
			
			if( actor )
			{
				actor.DrainStamina(ESAT_FixedValue, 100, 1);

				damage.Init( rider, actor ,NULL, rider.GetInventory().GetItemFromSlot( 'r_weapon' ),'attack_heavy',rider.GetName(),EHRT_Heavy, false, false, 'attack_heavy', AST_Jab, ASD_NotSet, true, false, false, false );
				if ( speed < 2 )
				{
					damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, baseDamage );
				} else
				{
					damage.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, baseDamage * MaxF( 1.1 + speed, 1 ) );
				}
				if( speed >= 4.0 )
					damage.AddEffectInfo( EET_KnockdownTypeApplicator );
				damage.SetSoundAttackType('wpn_slice')	;
				
				theGame.damageMgr.ProcessAction( damage );
				actor.PlayEffect( 'heavy_hit_horseriding' );
				
				bloodTrailParam = (CBloodTrailEffect)actor.GetGameplayEntityParam( 'CBloodTrailEffect' );
				if( bloodTrailParam )
				{
					weaponId = thePlayer.inv.GetItemFromSlot( 'r_weapon' );
					thePlayer.inv.PlayItemEffect( weaponId, 'blood_trail_horseriding' );
				}
				
			}
		}
		delete damage;
	}
	
	private function TurnOnSlowMo()
	{
		theSound.SoundEvent( "gui_slowmo_start" );
		theGame.SetTimeScale( slowMoSpeedCurrVal, theGame.GetTimescaleSource( ETS_HorseMelee ), theGame.GetTimescalePriority( ETS_HorseMelee ), false );
		speedMultCasuserId = thePlayer.SetAnimationSpeedMultiplier( 1/slowMoSpeedCurrVal * 0.5, speedMultCasuserId );
		isSlowMoOn = true;
	}
	
	private function TurnOffSlowMo()
	{
		theGame.RemoveTimeScale( theGame.GetTimescaleSource( ETS_HorseMelee ) );
		thePlayer.ResetAnimationSpeedMultiplier( speedMultCasuserId );
		
		theSound.SoundEvent( "gui_slowmo_end" );
		isSlowMoOn = false;
	}
	
	private function ShouldActivateSlowMo() : bool
	{
		var actors : array<CActor>;

		if( !thePlayer.IsInCombat() )
			return false;
			
		actors = thePlayer.GetAttackableNPCsAndPlayersInCone( 10.0, thePlayer.GetHeading(), 100.0, 10 );
		
		if( actors.Size() > 0 )
			return true;
			
		return false;
	}
}





state CastSign in W3VehicleCombatManager
{
	private var witcher : W3PlayerWitcher;
	private var horse : CActor;
	private var horseComp : W3HorseComponent;

	event OnEnterState( prevStateName : name )
	{
		parent.vehicle.OnCombatAction( EHCA_CastSign );
		
		witcher = (W3PlayerWitcher)parent.rider;
		horse = (CActor)(parent.vehicle.GetEntity());
		horseComp = (W3HorseComponent)parent.vehicle;
		
		if( witcher )
		{
			StartCastingSign();
		}
		else
		{
			CastingSignFailed();
		}
	}
	
	entry function StartCastingSign()
	{
		if( witcher.GetBehaviorVariable( 'actionType' ) != (int)EHCA_CastSign )
		{
			witcher.SetBehaviorVariable( 'IsCastingSign', 1.0 );
			witcher.SetBehaviorVariable( 'actionType', (int)EHCA_CastSign );
			witcher.WaitForBehaviorNodeActivation( 'castSignActionOn', 0.5f );
		}
		
		if( !witcher.CastSign() )
		{
			CastingSignFailed();
		}
		
		while( true )
		{
			SleepOneFrame();
			
			if( theInput.IsActionPressed( 'VehicleCastSign' )  )
			{
				ApplyEffectOnHorse( 0.1 );
			}
			else
			{
				break;
			}	
		}
		
		FinishCasting();
	}
	
	entry function FinishCasting()
	{
		witcher.RaiseEvent( 'actionFinished' );
		witcher.WaitForBehaviorNodeActivation( 'ActionOff', 1.0 );
		parent.PopState( true );
	}
	
	entry function CastingSignFailed()
	{
		Sleep( 0.1f );
		parent.PopState( true );
	}
	
	event OnLeaveState( nexStateName : name )
	{
		super.OnLeaveState( nexStateName );
		
		theInput.ForceDeactivateAction( 'VehicleCastSign' );
		
		witcher.SetBehaviorVariable( 'IsCastingSign', 0.0 );
		witcher.CastSignAbort();
		witcher.SetCurrentlyCastSign( ST_None, NULL );
		
		if( horseComp.GetPanicPercent() > 0.05 )
		{
			horse.RemoveAbility( 'HorseAxiiBuff' );
		}
		else
		{
			horse.AddTimer( 'RemoveAxiiFromHorse', 5.0 );
			ApplyEffectOnHorse( 5.0 );
		}
	}

	function ApplyEffectOnHorse( duration : float )
	{
		var effectParams : SCustomEffectParams;
		
		effectParams.effectType = EET_Confusion;
		effectParams.creator = witcher;
		effectParams.sourceName = "axii_on_horse";
		effectParams.duration = duration;
		horse.AddEffectCustom( effectParams );
	}
	
	event OnProcessAnimEvent( animEventName : name )
	{
		if( animEventName == 'cast_begin' )
		{
			witcher.ProcessSignEvent( 'horse_cast_begin' );
			
			
			thePlayer.PlayBattleCry( 'ChillOutHorse', 0.45f, true, true );
		}
	}
	
	event OnRaiseSignEvent()
	{
		horse.AddAbility( 'HorseAxiiBuff' );
		if( witcher.RaiseEvent( 'actionStart' ) )
		{
			theTelemetry.LogWithValueStr( TE_FIGHT_PLAYER_USE_SIGN, SignEnumToString( witcher.GetEquippedSign() ) );
 			return true;
		}
		
		return false;
	}

	event OnHitStart()
	{
		FinishCasting();
	}
}





state RangedAttack in W3VehicleCombatManager
{
	protected var rider 		: CR4Player;
	protected var aiming 		: bool;
	protected var fire 			: bool;
	protected var wasAborted 	: bool;
	
	event OnEnterState( prevStateName : name )
	{	
		rider = parent.rider;
		aiming = false;
		fire = false;
		wasAborted = false;
		
		if ( theInput.IsActionPressed('VehicleItemActionHold') )
		{
			ItemActionHold();
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( wasAborted )
			theInput.ForceDeactivateAction('VehicleItemAction');
	}
	
	event OnItemAction( action : SInputAction )
	{
		if ( rider.GetCurrentStateName() == 'DismountHorse' || rider.IsInHitAnim() )
			return false;
	
		if( IsReleased( action ) )
		{
			fire = true;
		}
	}	
	
	event OnItemActionHold( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			ItemActionHold();
		}
	}
	
	function ItemActionHold()
	{
		aiming = true;
	}

	var horizontalVal 			: float;
	event OnGameCameraTick( out moveData : SCameraMovementData, timeDelta : float )
	{
		var verticalVal 			: float;
		var localOffset 			: Vector;
		var rot 					: EulerAngles;
		var headBoneIdx 			: int;
		var playerPos				: Vector;
		var playerToCamHeadingDist	: float;
		var playerToCamPitchDist	: float;
		var camOffsetVec			: Vector;
		var playerToCamAngleDiff	: float;
		
		if( !aiming && rider.GetDisplayTarget() && rider.GetDisplayTarget() != rider.GetUsedVehicle() )
		{
			rider.SetOrientationTarget( OT_Actor );
			
			headBoneIdx = rider.GetHeadBoneIndex();
			
			if ( headBoneIdx >= 0 )
			{
				playerPos = MatrixGetTranslation( rider.GetBoneWorldMatrixByIndex( headBoneIdx ) );
			}
			
			rot = VecToRotation( rider.GetLookAtPosition() - playerPos );
			rider.GetVisualDebug().AddSphere( 'whyutrat4', 1.f, rider.GetLookAtPosition(), true, Color( 255, 0, 0 ), 0.2f );
			
			
			
				if ( rider.GetCurrentStateName() == 'SailingPassive' )
					horizontalVal = AngleDistance( rider.GetHeading() + 180, rot.Yaw ) / 180.f;
				else			
					horizontalVal = AngleDistance( rider.GetHeading(), rot.Yaw ) / 180.f;
			
					
			verticalVal = ClampF( rot.Pitch, -90.f, 90.f ) / -90.f;
		}
		else
		{
			if ( rider.GetThrownEntity() && (W3Petard)( rider.GetThrownEntity() ) )
				rider.ProcessCanAttackWhenNotInCombatBomb();
			else
				rider.rangedWeapon.ProcessCanAttackWhenNotInCombat();		
		
			rider.SetOrientationTarget( OT_Camera );
			
			
			
				if ( rider.GetCurrentStateName() == 'SailingPassive' )
					horizontalVal = AngleDistance( rider.GetHeading() + 180, moveData.pivotRotationValue.Yaw ) / 180.f;
				else
					horizontalVal = AngleDistance( rider.GetHeading(), moveData.pivotRotationValue.Yaw ) / 180.f;
			
					
			verticalVal = ClampF( moveData.pivotRotationValue.Pitch, -90.f, 90.f ) / 90.f;
		}
		
		
		rider.SetBehaviorVariable( 'aimHorizontal', horizontalVal );
		rider.SetBehaviorVariable( 'aimVertical', verticalVal );
		
		rider.vehicleCbtMgrAiming = aiming;
		
		if( !aiming )
		{
			theGame.GetGameCamera().EnableScreenSpaceCorrection( true );
			return false;
		}	
		
		
		
		
		
		
		
		
		localOffset = Vector( 1.4, 0, 0.15f );

		
		DampVectorConst( moveData.cameraLocalSpaceOffset, localOffset, 4.f, timeDelta );
		
		return true;
	}
	
	event OnProcessAnimEvent( animEventName : name )
	{
		if ( rider.inv.IsItemCrossbow( rider.inv.GetItemFromSlot('l_weapon') ) )
		{		
			rider.rangedWeapon.OnProcessThrowEvent( animEventName );
		}
	}

	event OnItemActionAbort( action : SInputAction )
	{
		AbortItemAction();
	}
	
	event OnForceItemActionAbort()
	{
		AbortItemAction();
	}
	
	function AbortItemAction() : bool
	{
		var player : W3PlayerWitcher;
		var throwStage : EThrowStage;
		var allowAbort : bool;
				
		if ( thePlayer.playerAiming.GetCurrentStateName() == 'Aiming' )
			allowAbort = true;
			
		if ( rider.rangedWeapon && rider.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			if ( !rider.rangedWeapon.IsWeaponBeingUsed() )
				allowAbort = true;
		}
		
		if ( !allowAbort )
			return false;
		
		wasAborted = true;
		aiming = false;
		
		return true;
	}
	
	event OnHorseActionStart()
	{
		AbortItemAction();
	}
	
	event OnHitStart()
	{
		
		
	}
}





state ThrowProjectile in W3VehicleCombatManager extends RangedAttack 
{
	
	var abortThrow		: bool;
	var thrownEntity	: CThrowable;

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		
		rider.radialSlots.Clear();
		rider.radialSlots.PushBack( 'Slot2' );
		rider.radialSlots.PushBack( 'Slot3' );
		rider.radialSlots.PushBack( 'Slot4' );
		rider.radialSlots.PushBack( 'Slot5' );
		rider.EnableRadialSlotsWithSource( false, rider.radialSlots, 'throwProjectileOnVehicle' );	
		
		if ( !parent.wasBombReleased && thrownEntity )
		{
			rider.RaiseEvent( 'actionShootEnd' );
			thrownEntity.StopAiming( false );
			thrownEntity.Destroy();
			thrownEntity = NULL;
		}
		
		parent.wasBombReleased = false;
		
		thrownEntity = (CThrowable)rider.GetInventory().GetDeploymentItemEntity( rider.GetSelectedItemId(), rider.GetWorldPosition(),,true );
		thrownEntity.Initialize( rider, rider.GetSelectedItemId() );
		EntityHandleSet( rider.thrownEntityHandle, thrownEntity );
		
		if ( theInput.IsActionPressed('VehicleItemActionHold') )
		{
			ItemActionHold();
		}

		parent.SetCleanupFunction( 'ThrowProjectileCleanup' );
		
		OneFrameDelayHACK();
	}

	cleanup function ThrowProjectileCleanup()
	{
		if( thrownEntity )
		{
			thrownEntity.StopAiming( false );
			
			if ( !parent.wasBombReleased )
			{
				rider.RaiseEvent( 'actionShootEnd' );
				parent.wasBombReleased = true;
				thrownEntity.Destroy();
				thrownEntity = NULL;
			}
		}	
	}

	
	event OnLeaveState( nextStateName : name )
	{	
		aiming = false;	
		
		abortThrow = false;
		rider.EnableRadialSlotsWithSource( true, rider.radialSlots, 'throwProjectileOnVehicle' );		
	
		if( thrownEntity )
		{
			thrownEntity.StopAiming( false );
			
			if ( !parent.wasBombReleased )
			{
				rider.RaiseEvent( 'actionShootEnd' );
				parent.wasBombReleased = true;
				thrownEntity.Destroy();
				thrownEntity = NULL;
			}
		}
	}
	
	entry function OneFrameDelayHACK()
	{
		Sleep( 0.1f );
		
		while ( !rider.RaiseEvent( 'actionStart' ) )
		{
			SleepOneFrame();
		}
		
		rider.WaitForBehaviorNodeDeactivation( 'ActionOn', 2.5f );
		
		while( !fire && !abortThrow )
		{
			SleepOneFrame();
		}
		
		FireProjectile( abortThrow );
	}
	
	event OnItemAction( action : SInputAction )
	{	
		if ( thrownEntity )
			super.OnItemAction( action );
	}
	
	event OnItemActionHold( action : SInputAction )
	{
		if( IsPressed( action ) )
		{
			ItemActionHold();
		}
	}
	
	function ItemActionHold()
	{
		if ( thrownEntity )
		{
			super.ItemActionHold();
			if( !fire )
			{
				thrownEntity.StartAiming();
			}
		}
	}
	
	event OnItemActionAbort( action : SInputAction )
	{
		if( IsReleased( action ) )
		{
			AbortItemAction();
		}
	}
	
	event OnForceItemActionAbort()
	{
		AbortItemAction();
	}
	
	function AbortItemAction() : bool
	{
		if ( super.AbortItemAction() )
		{
			abortThrow = true;
			theInput.ForceDeactivateAction('VehicleItemAction');
			rider.UnblockAction(EIAB_ThrowBomb, 'BombThrow');
			return true;
		}
		return false;
	}
	
	event OnProcessAnimEvent( animEventName : name )
	{
		thrownEntity.OnProcessThrowEvent( animEventName );
		
		if ( animEventName == 'ProjectileThrow' )
		{
			parent.wasBombReleased = true;
		}
	}
	
	latent function FireProjectile( abort : bool )
	{
		var res 		: bool;
		var eventName	: name;

		if ( rider.GetIsShootingFriendly() || abort )
			eventName = 'actionStop';
		else
			eventName = 'actionShoot';
		
		if( rider.RaiseEvent( eventName ) )
		{
			if ( eventName == 'actionStop' )
			{
				Sleep( 0.3f );

				thrownEntity.BreakAttachment();
				thrownEntity.Destroy();
				thrownEntity = NULL;
				rider.playerAiming.StopAiming();
				parent.wasBombReleased = true;
			}
			else
				rider.playerAiming.RemoveAimingSloMo();
				
			aiming = false;		
				
			res = rider.WaitForBehaviorNodeActivation( 'ActionOff', 5.f );
			
			parent.PopState( true );
		}
	}
}





state ThrowBomb in W3VehicleCombatManager extends ThrowProjectile
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.vehicle.OnCombatAction( EHCA_ThrowBomb );
		
		rider.BlockAction(EIAB_ThrowBomb, 'BombThrow' );
		rider.BlockAction(EIAB_Crossbow, 'BombThrow');
		
		rider.SetBehaviorVariable( 'actionType', (int)EHCA_ThrowBomb );
	}
	
	event OnHitStart()
	{
		AbortItemAction();
	}	
}





state ShootCrossbow in W3VehicleCombatManager extends RangedAttack
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.vehicle.OnCombatAction( EHCA_ShootCrossbow );
	}
	
	event OnItemAction( action : SInputAction )
	{
		super.OnItemAction( action );
		
		if ( IsReleased( action ) )
		{
			rider.rangedWeapon.OnRangedWeaponRelease();
			WaitForShootingComplete();
		}
		else if ( IsPressed( action ) )
		{
			if( rider.GetInventory().IsItemCrossbow( rider.GetSelectedItemId() ) )
			{
				parent.vehicle.OnCombatAction( EHCA_ShootCrossbow );
				rider.SetBehaviorVariable( 'actionType', (int)EHCA_ShootCrossbow );
				rider.rangedWeapon = ( Crossbow )( rider.GetInventory().GetItemEntityUnsafe( rider.GetSelectedItemId() ) );
				rider.rangedWeapon.OnRangedWeaponPress();
				StopWaitForShootingComplete();
			}
		}
	}
	
	event OnItemActionHold( action : SInputAction )
	{
		if ( !( (W3Boat)( thePlayer.GetUsedVehicle() ) ) )
		{
			if ( IsPressed(action)  )
				ItemActionHold();
		}
		else
			theInput.ForceDeactivateAction('VehicleItemAction');
	}
	
	function ItemActionHold()
	{
		if ( parent.rider.inv.IsItemCrossbow( parent.rider.GetSelectedItemId() ) )
			super.ItemActionHold();
	}
	
	event OnItemActionAbort( action : SInputAction )
	{
		if( IsReleased( action ) )
		{
			AbortItemAction();
		}
	}
	
	event OnForceItemActionAbort()
	{
		AbortItemAction();
	}
	
	function AbortItemAction() : bool
	{
		if ( super.AbortItemAction() )
		{
			rider.OnRangedForceHolster( false, true );
			WaitForShootingComplete();
			return true;
		}
		return false;
	}
	
	entry function StopWaitForShootingComplete()
	{
	
	}
	
	entry function WaitForShootingComplete()
	{
		var item : SItemUniqueId;
		rider.WaitForBehaviorNodeDeactivation( 'WeaponShootDeact', 1.f );
		aiming = false; 
		rider.playerAiming.StopAiming();
		

		while ( rider.rangedWeapon && rider.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			SleepOneFrame();
		}
		
		thePlayer.UnblockAction( EIAB_DismountVehicle, 'ShootingCrossbow' );	
		thePlayer.UnblockAction( EIAB_MountVehicle, 'ShootingCrossbow' );
		
		parent.PopState( true );
	}
	
	event OnProcessAnimEvent( animEventName : name )
	{
		super.OnProcessAnimEvent( animEventName );
	
		if ( rider.inv.IsItemCrossbow( rider.inv.GetItemFromSlot('l_weapon') ) )
		{		
			if ( animEventName == 'ProjectileThrow' )
			{
				( (CVehicleComponent)( parent.vehicle ) ).OnCombatActionEnd();
			}
		}
	}
}
