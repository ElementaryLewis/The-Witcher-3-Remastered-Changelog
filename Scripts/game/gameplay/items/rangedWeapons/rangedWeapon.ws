/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import statemachine class RangedWeapon extends CItemEntity
{	
	protected	var owner						: CActor;
	protected	var ownerPlayer					: CR4Player;
	protected	var ownerPlayerWitcher			: W3PlayerWitcher;
	protected	var isPlayer					: bool;
	protected	var inv							: CInventoryComponent;
	protected	var previousAmmoItemName		: name;
	protected	var deployedEnt					: W3BoltProjectile;
	protected	var isSettingOwnerOrientation	: bool;
	protected	var isDeployedEntAiming			: bool;
	protected	var isAimingWeapon				: bool;
	protected	var isShootingWeapon			: bool;
	protected	var isWeaponLoaded				: bool;
	protected 	var recoilLevel					: int;
	protected 	var setFullWeight 				: bool;
	protected	var noSaveLockCombatAction		: int;
	protected 	var performedDraw				: bool;
	protected 	var shootingIsComplete			: bool;
	
	
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{ 
		super.OnSpawned( spawnData );
		Initialize( (CActor)GetParentEntity() );
	}
	
	
	event OnChangeTo( newState : name )
	{
		if ( GetCurrentStateName() != newState )
			GotoState( newState );
	}
			
	event OnRangedWeaponPress()
	{		
		SetBehaviorGraphVariables( 'isAimingWeapon', true );
		SetBehaviorGraphVariables( 'isShootingWeapon', false );
	}
	
	event OnRangedWeaponRelease()
	{
		SetBehaviorGraphVariables( 'isAimingWeapon', false );
		SetBehaviorGraphVariables( 'isShootingWeapon', true );
	}
	
	event OnWeaponWait()
	{
		
			thePlayer.UnblockAction( EIAB_DismountVehicle, 'ShootingCrossbow' );	
			thePlayer.UnblockAction( EIAB_MountVehicle, 'ShootingCrossbow' );
	}
	
	event OnWeaponDrawStart()
	{
		ownerPlayer.SetBehaviorVariable( 'failSafeDraw', 0.0 );
		if ( !isSettingOwnerOrientation )
		{
			isSettingOwnerOrientation = true;
			SetOwnerOrientation();
		}
		
		OnChangeTo( 'State_WeaponDraw' );
	}
	
	event OnWeaponReloadStart() 
	{
		RaiseForceEvent( 'WeaponCrossbow_Reload' );
		OnChangeTo( 'State_WeaponReload' );
	}
	
	event OnWeaponReload()
	{
		var id : SItemUniqueId;
	
		if ( ownerPlayerWitcher.GetItemEquippedOnSlot(EES_Bolt, id) )
		{
			ReloadWeapon( id );
		}
		else
		{
			OnForceHolster();
			LogChannel( 'Crossbow', "ERROR: No ammo to reload!!!" );
		}
	}
	
	event OnWeaponReloadEnd(){}
	
	event OnWeaponAimStart()
	{
		ProcessFullBodyAnimWeight();
		
		OnChangeTo( 'State_WeaponAim' );
	}
	
	
	event OnWeaponShootStart()
	{
		
		FactsAdd( "ranged_weapon_shoot_start", 1, 3 );
		
		
			
		SetBehaviorGraphVariables( 'isAimingWeapon', false );
		SetBehaviorGraphVariables( 'isShootingWeapon', false );
		SetBehaviorGraphVariables( 'recoilLevel', false, (int)RL_1 );
		
		OnChangeTo( 'State_WeaponShoot' );
	}
	
	event OnWeaponAimEnd() {}	
	
	event OnProcessThrowEvent( animEventName : name )
	{
		if ( deployedEnt )
		{
			deployedEnt.OnProcessThrowEvent( animEventName );
			
			if ( animEventName == 'ProjectileThrow' )
			{
				
				
				SetDeployedEntVisibility( true );
				RaiseForceEvent( 'WeaponCrossbow_Shoot' );
				ClearDeployedEntity(false);
				ReloadWeaponWithOrWithoutAnimIfNeeded();
				
				isSettingOwnerOrientation = false;
				
				
				
			}
		}
		else
		{
			
		}

		if( animEventName == 'OnWeaponReload' )
		{
			OnWeaponReload();
			
			if ( !ownerPlayer.IsUsingVehicle()
				&& ownerPlayer.GetBehaviorVariable( 'isShootingWeapon' ) == 0.f 
				&& ownerPlayer.GetBehaviorVariable( 'isAimingWeapon' ) == 0.f )
			{
				if ( ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear || ownerPlayer.IsSwimming() ) 
					AddTimer( 'HolsterAfterDelay', 0.f );
			}			
		}
	}
	
	event OnWeaponShootEnd()
	{
		if ( !ownerPlayer.bLAxisReleased )
		{
			ExitCombatAction();
		}
			
		
	}
	
	event OnWeaponHolsterStart()
	{
		ExitCombatAction();
		ownerPlayer.SetBehaviorVariable( 'forceHolsterForOverlay', 0.f );
		
		if ( ownerPlayer.PerformingCombatAction() == EBAT_EMPTY )
		{
			ownerPlayer.RemoveCustomOrientationTarget( 'RangedWeapon' );
		}
	
		OnChangeTo( 'State_WeaponHolster' );	
	}
	
	event OnWeaponHolsterEnd()
	{
		ExitCombatAction();
	}
	
	event OnWeaponToNormalTransStart()
	{
		AddTimer( 'ProcessFullBodyAnimWeightTimer', 0.f, true );
	}
	
	event OnWeaponToNormalTransEnd()
	{
		RemoveTimer( 'ProcessFullBodyAnimWeightTimer' );
	}
	
	event OnReplaceAmmo(){}
	
	event OnForceHolster( optional forceUpperBodyAnim, instant, dropItem : bool ) 
	{
		var itemId	: SItemUniqueId;

		theInput.ForceDeactivateAction('ThrowItem');
		theInput.ForceDeactivateAction('ThrowItemHold');
		
		if ( instant )
		{
			itemId = ownerPlayer.inv.GetItemFromSlot( 'l_weapon' );
			
			
			if( ownerPlayer.inv.IsIdValid( itemId ) && ( ownerPlayer.inv.IsItemCrossbow( itemId ) || ownerPlayer.inv.IsItemBomb( itemId ) ) )
			{
				ownerPlayer.HolsterItems( true, itemId );
			}
			
			thePlayer.BlockAllActions( 'RangedWeapon', false);
			thePlayer.BlockAllActions( 'RangedWeaponReload', false);
			thePlayer.BlockAllActions( 'RangedWeaponAiming', false);
			thePlayer.UnblockAction( EIAB_DismountVehicle, 'ShootingCrossbow' );
			thePlayer.UnblockAction( EIAB_MountVehicle, 'ShootingCrossbow' );	
			thePlayer.UnblockAction( EIAB_ThrowBomb, 'ShootingCrossbow' );
			thePlayer.UnblockAction( EIAB_DrawWeapon, 'RangedWeaponAiming' );
			thePlayer.UnblockAction( EIAB_DrawWeapon, 'RangedWeaponReload' );			
			
			ResetAllSettings();
			
			Unlock();
			OnChangeTo( 'State_WeaponWait' );
			thePlayer.playerAiming.StopAiming();
		}
	
		
	}
	
	
	
	
	
	
	public function Initialize( newOwner : CActor )
	{				
		owner = newOwner;
		ownerPlayer = (CR4Player)owner;
		ownerPlayerWitcher = (W3PlayerWitcher)owner;
		
		if ( ownerPlayer )
		{
			isPlayer = true;
			
			
			
		}
		
		if ( this.GetCurrentStateName() != 'State_WeaponWait' )
			OnChangeTo( 'State_WeaponWait' );
	}

	public function IsWeaponBeingUsed() : bool
	{
		if ( GetCurrentStateName() == 'State_WeaponShoot' && !IsShootingComplete() )
			return true;
		else if ( GetCurrentStateName() == 'State_WeaponReload' )
			return true;
		else if ( isShootingWeapon || isAimingWeapon )
			return true;
		else
			return false;
	}

	
	protected function	ReloadWeaponWithOrWithoutAnimIfNeeded() : bool
	{
		var t : float;
		if ( !deployedEnt )
		{
			if ( !PlayOwnerReloadAnim() )
			{
				
				OnWeaponReload();
				SetDeployedEntVisibility( false );
				return false;
			}
			t = ownerPlayer.GetBehaviorVariable( 'animSpeedMultForOverlay' );
			SetBehaviorVariable( 'animSpeedMult', ownerPlayer.GetBehaviorVariable( 'animSpeedMultForOverlay' ) );		
			return true;				
		}
		else
		{
			SetBehaviorGraphVariables( 'isWeaponLoaded', true );
			return false;
		}
	}
	
	protected function SetBehaviorGraphVariables( varName : name, flag : bool, optional num : int )
	{
		if ( varName == 'isWeaponLoaded' )
		{
			ownerPlayer.SetBehaviorVariable( 'isWeaponLoaded', (float)flag );
			ownerPlayer.SetBehaviorVariable( 'isWeaponLoadedRider', (float)flag );
			this.SetBehaviorVariable( 'isWeaponLoaded', (float)flag );
			isWeaponLoaded = flag;
		}
		else if ( varName == 'isShootingWeapon' )
		{
			ownerPlayer.SetBehaviorVariable( 'isShootingWeapon', (float)flag );
			ownerPlayer.SetBehaviorVariable( 'isShootingWeaponRider', (float)flag );
			isShootingWeapon = flag;
		}
		else if ( varName == 'isAimingWeapon' )
		{
			ownerPlayer.SetBehaviorVariable( 'isAimingWeapon', (float)flag );
			ownerPlayer.SetBehaviorVariable( 'isAimingWeaponRider', (float)flag );
			isAimingWeapon = flag;
		}
		else if ( varName == 'recoilLevel' )
		{
			ownerPlayer.SetBehaviorVariable( 'recoilLevel', (float)num );
			this.SetBehaviorVariable( 'recoilLevel', (float)num );
			recoilLevel = num;
		}				
	}
	
	protected function RaiseOwnerGraphEvents( eventName : name, force : bool ) : bool
	{
		if ( force )
			return ownerPlayer.RaiseForceEvent( eventName );
		else
			return ownerPlayer.RaiseEvent( eventName );
	}	
	
	protected function PlayOwnerReloadAnim() : bool	{return false;}
	
	protected function ReloadWeapon( id : SItemUniqueId ) : bool
	{	
		var crossbowId 	: SItemUniqueId;
		var mat 		: Matrix;
		
		if ( !deployedEnt )
		{
			
			LogThrowable( "Equipped bullet item " + inv.GetItemName( id ) );
			
			this.CalcEntitySlotMatrix( 'bolt', mat );
			MatrixGetTranslation( mat );
			
			deployedEnt = (W3BoltProjectile)( inv.GetDeploymentItemEntity( id, MatrixGetTranslation( mat ), MatrixGetRotation( mat ) ) );
			ownerPlayerWitcher.GetItemEquippedOnSlot(EES_RangedWeapon, crossbowId);
			deployedEnt.InitializeCrossbow( ownerPlayer, id, crossbowId );

			
			if ( !deployedEnt.CreateAttachment( this, 'bolt' ) )
			{
				LogThrowable("Cannot attach thrown item to weapon!" );
				LogAssert(false, "CActor.OnAnimEvent(ProjectileAttach): Cannot attach thrown item to actor!");
				return false;
			}
			
			SetBehaviorGraphVariables( 'isWeaponLoaded', true );
			
			previousAmmoItemName = inv.GetItemName( id ); 
			
			return true;
		}
		
		LogThrowable("Error : Ranged weapon already has a deployed entity attached!" );
		return false;
	}
	
	protected function Lock()
	{
		var actionBlockingExceptions : array<EInputActionBlock>;
		
		
		
		
		
		
		
		if ( ownerPlayer.IsUsingVehicle() && (W3Boat)( ownerPlayer.GetUsedVehicle() ) )
		{
			actionBlockingExceptions.PushBack(EIAB_OpenInventory);
			actionBlockingExceptions.PushBack(EIAB_OpenFastMenu);
		}
			
		actionBlockingExceptions.PushBack(EIAB_Jump);
		actionBlockingExceptions.PushBack(EIAB_RadialMenu);
		actionBlockingExceptions.PushBack(EIAB_Movement);
		actionBlockingExceptions.PushBack(EIAB_OpenPreparation);
		actionBlockingExceptions.PushBack(EIAB_Roll);
		actionBlockingExceptions.PushBack(EIAB_Climb);
		actionBlockingExceptions.PushBack(EIAB_Slide);
		actionBlockingExceptions.PushBack(EIAB_RunAndSprint);
		actionBlockingExceptions.PushBack(EIAB_OpenMap);
		actionBlockingExceptions.PushBack(EIAB_OpenCharacterPanel);
		actionBlockingExceptions.PushBack(EIAB_OpenJournal);
		actionBlockingExceptions.PushBack(EIAB_OpenAlchemy);
		actionBlockingExceptions.PushBack(EIAB_ExplorationFocus);
		actionBlockingExceptions.PushBack(EIAB_Dodge);
		actionBlockingExceptions.PushBack(EIAB_SwordAttack);
		actionBlockingExceptions.PushBack(EIAB_Sprint);
		actionBlockingExceptions.PushBack(EIAB_LightAttacks);
		actionBlockingExceptions.PushBack(EIAB_HeavyAttacks);
		actionBlockingExceptions.PushBack(EIAB_Fists);
		actionBlockingExceptions.PushBack(EIAB_QuickSlots);
		actionBlockingExceptions.PushBack(EIAB_Crossbow);
		actionBlockingExceptions.PushBack(EIAB_OpenGlossary);
		actionBlockingExceptions.PushBack(EIAB_MeditationWaiting);
		actionBlockingExceptions.PushBack(EIAB_Signs);
		actionBlockingExceptions.PushBack(EIAB_Interactions);
		actionBlockingExceptions.PushBack(EIAB_InteractionAction);
		actionBlockingExceptions.PushBack(EIAB_InteractionContainers);
		actionBlockingExceptions.PushBack(EIAB_Dive);
		actionBlockingExceptions.PushBack(EIAB_Parry);

		theGame.CreateNoSaveLock( 'RangedWeapon', noSaveLockCombatAction );
		thePlayer.BlockAllActions( 'RangedWeapon', true, actionBlockingExceptions, false);
	}
	
	protected function Unlock()
	{
		
		thePlayer.BlockAllActions( 'RangedWeapon', false);
		theGame.ReleaseNoSaveLock( noSaveLockCombatAction );
		
		
		
	}
	
	protected function SetOwnerOrientation(){}
	
	
	timer function ProcessFullBodyAnimWeightTimer( time : float , id : int)
	{	
		ProcessFullBodyAnimWeight();
	}

	
	var wasBLAxisReleased : bool;
	timer function InputLockFailsafe( time : float , id : int)
	{	
		var item : SItemUniqueId;

		if ( !ownerPlayer.IsUsingVehicle() )
		{
			if ( this.GetCurrentStateName() == 'State_WeaponAim' 
				|| this.GetCurrentStateName() == 'State_WeaponShoot'
				|| this.GetCurrentStateName() == 'State_WeaponReload' )
			{
				item = this.ownerPlayer.inv.GetItemFromSlot( 'l_weapon' );
				
				if ( !( this.ownerPlayer.inv.IsIdValid( item ) && this.ownerPlayer.inv.IsItemCrossbow( item ) ) )  
					this.OnForceHolster( false, true );
			}
			
			if ( this.GetCurrentStateName() != 'State_WeaponWait' )
			{
				if ( !ownerPlayer.GetBIsCombatActionAllowed() 
					&& ownerPlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Attack
					&& ownerPlayer.GetBehaviorVariable( 'fullBodyAnimWeight' ) == 1.f )
					OnForceHolster( true, true );
				
				if ( ownerPlayer.IsInShallowWater() && !ownerPlayer.IsSwimming() )
					OnForceHolster( true, false );
					
				if ( ownerPlayer.GetPlayerCombatStance() == PCS_Normal || ownerPlayer.GetPlayerCombatStance() == PCS_AlertFar )
				{
					if ( ( this.IsShootingComplete() || ownerPlayer.GetIsShootingFriendly() ) 
						&& wasBLAxisReleased 
						&& !ownerPlayer.bLAxisReleased )
						OnForceHolster( true, false );
				}
			}
			
			if ( !isAimingWeapon && !isShootingWeapon && !this.ownerPlayer.lastAxisInputIsMovement )
			{
				if ( ( IsShootingComplete() && this.GetCurrentStateName() == 'State_WeaponShoot' )
					|| this.GetCurrentStateName() == 'State_WeaponAim' )
					SetOwnerOrientation();
			}		
		}
		
		wasBLAxisReleased = ownerPlayer.bLAxisReleased;
	}	

	public function OnSprintHolster()
	{		
		if ( ownerPlayer.GetCurrentStateName() == 'Exploration' || ownerPlayer.GetCurrentStateName() == 'Swimming' )
		{
			if ( ownerPlayer.GetBehaviorVariable( 'isShootingWeapon' ) == 0.f 
				&& ownerPlayer.GetBehaviorVariable( 'isAimingWeapon' ) == 0.f )
			{
				if ( this.GetCurrentStateName() == 'State_WeaponShoot' )
				{
					if ( shootingIsComplete )
						OnForceHolster( true, false );
				}	
				else if ( this.GetCurrentStateName() == 'State_WeaponAim' )
					OnForceHolster( true, false );
			}
		}
	}
	
	protected function ProcessFullBodyAnimWeight( optional forceUpperBodyAnim : bool ) : bool
	{
		return true;
	}
	
	protected function ExitCombatAction() : bool
	{
		if (ownerPlayer && !ownerPlayer.IsInCombatAction() )
		{
			if ( !ownerPlayer.IsInCombat() && ownerPlayer.bLAxisReleased )
				ownerPlayer.RaiseEvent( 'ForceAlertToNormalTransition' );
			else
				ownerPlayer.RaiseEvent( 'ForceBlendOut' );
				
			return true;	
		}
		
		return false;
	}
	
	protected function ProcessCharacterRotationInCombat(){}
	
	
	public final function ClearDeployedEntity(destroyBolt : bool)
	{	
		
		if(destroyBolt && deployedEnt && deployedEnt.IsStopped())
			deployedEnt.Destroy();
			
		deployedEnt = NULL;
	}
	
	public function IsDeployedEntAiming() : bool
	{
		return isDeployedEntAiming;
	}
	
	public function GetDeployedEntity() : W3AdvancedProjectile
	{
		return deployedEnt;
	}
	
	protected function SetDeployedEntVisibility( flag : bool )
	{
		

		if ( deployedEnt )
			deployedEnt.SetVisibility( flag );
	}
	
	public function ProcessCanAttackWhenNotInCombat()
	{
		if ( ( !ownerPlayer.IsCombatMusicEnabled() || ownerPlayer.playerAiming.GetCurrentStateName() == 'Aiming' ) && !CanAttackWhenNotInCombat() )
		{
			ownerPlayer.SetIsShootingFriendly( true );
			ownerPlayer.SetBehaviorVariable( 'isShootingFriendly', 1.f );
			ownerPlayer.SetBehaviorVariable( 'isShootingFriendlyForOverlay', 1.f );
		}
		else
		{
			ownerPlayer.SetIsShootingFriendly( false );
			ownerPlayer.SetBehaviorVariable( 'isShootingFriendly', 0.f );
			ownerPlayer.SetBehaviorVariable( 'isShootingFriendlyForOverlay', 0.f );
		}				
	}
	
	public function CanAttackWhenNotInCombat() : bool
	{
		var shootTarget : CActor;
		var weaponToThrowPosDist	: float;
		
		weaponToThrowPosDist = VecDistance( ownerPlayer.playerAiming.GetThrowPosition(), ownerPlayer.playerAiming.GetThrowStartPosition() );
		
		if ( ownerPlayer.GetDisplayTarget() && ownerPlayer.IsDisplayTargetTargetable() )
			shootTarget = (CActor)( ownerPlayer.GetDisplayTarget() );
		else
			shootTarget = (CActor)( ownerPlayer.slideTarget );
			
		if ( this.isDeployedEntAiming ) 
		{
			if ( ownerPlayer.playerAiming.GetSweptFriendly() || weaponToThrowPosDist < 1.f )	
				return false;
			else	
				return true;
		}
		else if ( shootTarget && shootTarget.IsHuman() && !ownerPlayer.IsThreat( shootTarget ) ) 
			return false;
		else
			return true;
	}
	
	public function PerformedDraw() : bool
	{
		return performedDraw;
	}
	
	protected function ResetAllSettings()
	{
		ownerPlayer.SetBehaviorVariable( 'inAimThrow', 0.f );
		ownerPlayer.SetBehaviorVariable( 'inAimThrowForOverlay', 0.f );
		ownerPlayer.SetBehaviorVariable( 'dodgeBoost',0.0);
		isSettingOwnerOrientation = false;
		ExitCombatAction();
		
		ownerPlayer.RemoveCustomOrientationTarget( 'RangedWeapon' );
		ownerPlayer.SetBehaviorVariable( 'hasCrossbowHeld', 0.f );

		ownerPlayer.GetMovingAgentComponent().EnableVirtualController( 'Crossbow', false );
		
		if ( isDeployedEntAiming )
		{
			isDeployedEntAiming = false;
			deployedEnt.StopAiming( true );
		}
		
		if ( !ownerPlayer.IsUsingVehicle() )
			ownerPlayer.OnEnableAimingMode( false );
	}
	
	protected timer function HolsterAfterDelay( timeDelta : float , id : int)
	{
		ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 1.f );
		ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 1.f );
		RemoveTimer( 'HolsterAfterDelay' );
		RemoveTimer( 'HolsterWhenMovingTimer' );
	}

	protected var bLAxisWasReleased : bool;
	protected timer function HolsterWhenMovingTimer( timeDelta : float , id : int)
	{	
		var stateCur : name;
		var canHolsterAfterDelay : bool;
		
		stateCur =  ownerPlayer.substateManager.GetStateCur();
		
		if( !ownerPlayer.bLAxisReleased && ownerPlayer.GetCurrentStateName() != 'AimThrow' && bLAxisWasReleased )
			canHolsterAfterDelay = true;
		else if ( stateCur == 'Jump' || stateCur == 'Ragdoll' || stateCur == 'Slide' || stateCur == 'TurnToJump' )
			canHolsterAfterDelay = true;
		else if ( ownerPlayer.IsSwimming() && !ownerPlayer.bLAxisReleased )
			canHolsterAfterDelay = true;
		
		if ( canHolsterAfterDelay )
		{
			ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 1.f );
			RemoveTimer( 'HolsterAfterDelay' );
			RemoveTimer( 'HolsterWhenMovingTimer' );
		}
		
		bLAxisWasReleased = ownerPlayer.bLAxisReleased;
	}	
	
	protected function ProcessEnableRadialSlot()
	{
		
	}
	
	public function IsShootingComplete() : bool
	{
		return shootingIsComplete;
	}
}

class Crossbow extends RangedWeapon
{
	protected	var shotCount				: int;
	protected	var shotCountLimit			: int;
	
	default shotCountLimit = 1;
	default shotCount = 0; 
	
	event OnWeaponReloadEnd()
	{
		if ( deployedEnt )
			ResetShotCount();
			
		super.OnWeaponReloadEnd();	
	}

	event OnProcessThrowEvent( animEventName : name )
	{
		if ( animEventName == 'ProjectileThrow' )
			shotCount += 1;
	
		super.OnProcessThrowEvent( animEventName );
	}
	
	event OnForceHolster( optional forceUpperBodyAnim, instant, dropItem : bool )
	{
		if ( GetCurrentStateName() != 'State_WeaponWait' && ( instant || GetCurrentStateName() != 'State_WeaponHolster' ) )
		{
			ProcessFullBodyAnimWeight( forceUpperBodyAnim );
			ResetOwnerAndWeapon();
			
			if ( instant )
				RaiseOwnerGraphEvents( 'Crossbow_ForceBlendOut', true );				
			else
				RaiseOwnerGraphEvents( 'Crossbow_Holster', true );
		}

		super.OnForceHolster( forceUpperBodyAnim, instant, dropItem  );
	}
	
	event OnReplaceAmmo()
	{
		
		
			ClearDeployedEntity(true);
			SetBehaviorGraphVariables( 'isWeaponLoaded', false );
			previousAmmoItemName = '';
			ResetShotCount();
			
			if ( GetCurrentStateName() != 'State_WeaponWait' && GetCurrentStateName() != 'State_WeaponHolster' )
				OnForceHolster();
			else
				ResetOwnerAndWeapon();
		
	}

	event OnCrossbowLoadedAnim()
	{
		SetDeployedEntVisibility( true );
	}
	
	protected function ResetOwnerAndWeapon()
	{
		SetBehaviorGraphVariables( 'isAimingWeapon' , false );
		SetBehaviorGraphVariables( 'isShootingWeapon' , false );	
		if ( isWeaponLoaded )
			RaiseForceEvent( 'WeaponCrossbow_Loaded' );
		else
			RaiseForceEvent( 'WeaponCrossbow_Unloaded' );	
	}

	var reloadAtStartComplete	: bool;
	public function Initialize( newOwner : CActor )
	{
		inv = (CInventoryComponent)( thePlayer.GetComponentByClassName( 'CInventoryComponent' ) );
		super.Initialize( newOwner );
		
		
		if ( !reloadAtStartComplete )
		{
			AddTimer( 'ReloadWeaponOnInit',0.2 );
		}
	}
	
	private timer function ReloadWeaponOnInit( time : float, timerId : int)
	{
		var id 		: SItemUniqueId;
		var player	: W3PlayerWitcher;	
	
		if ( ownerPlayerWitcher )
		{
			if ( ownerPlayerWitcher.GetItemEquippedOnSlot(EES_Bolt, id) )
			{
				ReloadWeapon( id );
				RaiseForceEvent( 'WeaponCrossbow_Loaded' );
				reloadAtStartComplete = true;
			}
			else
			{
				OnForceHolster();
				LogChannel( 'Crossbow', "ERROR: No ammo to reload!!!" );
			}
		}
		else
			Initialize( (CActor)( GetParentEntity() ) );
	}
	
	protected function RaiseOwnerGraphEvents( eventName : name, force : bool ) : bool
	{
		var tempEventName : name;
		
		if( eventName == 'Crossbow_Draw' )
		{
			if( ownerPlayerWitcher.IsInCombat() && ownerPlayerWitcher.GetIsSprinting() )
			{
				return false;
			}
		}
		
		if ( ownerPlayer.IsUsingVehicle() )
		{
			if ( eventName == 'Crossbow_Draw' )
				tempEventName = 'VehicleCrossbow_Draw';
			else if ( eventName == 'Crossbow_Reload' )
				tempEventName = 'VehicleCrossbow_Reload';
			else if ( eventName == 'Crossbow_AimShoot' )
				tempEventName = 'VehicleCrossbow_AimShoot';	
			else if ( eventName == 'Crossbow_Holster' )
				tempEventName = 'VehicleCrossbow_Holster';
			else if ( eventName == 'Crossbow_ForceBlendOut' )
			{
				tempEventName = 'VehicleCrossbow_ForceBlendOut';
				force = false; 
			}
		}
		else
			tempEventName = eventName;
			
		return super.RaiseOwnerGraphEvents( tempEventName, force );
	}	
	
	protected function PlayOwnerReloadAnim() : bool
	{
		var shouldPlayAnim : bool;
		
		if(ownerPlayerWitcher.CanUseSkill(S_Perk_17) && shotCount >= (1 + shotCountLimit) )
			shouldPlayAnim = true;
		else if (!ownerPlayerWitcher.CanUseSkill(S_Perk_17) && shotCount >= shotCountLimit )
			shouldPlayAnim = true;
		else if ( previousAmmoItemName != 'Bodkin Bolt' && previousAmmoItemName != 'Harpoon Bolt' && GetSpecialAmmoCount() <= 0 )
			shouldPlayAnim = true;
		else if ( previousAmmoItemName == '' )
			shouldPlayAnim = true;
		else
			shouldPlayAnim = false;
		
		if ( shouldPlayAnim )
		{
			SetBehaviorGraphVariables( 'isWeaponLoaded', false );
			return true;	
		}
		else
			return false;
	}
	
	protected function GetSpecialAmmoCount() : int
	{
		var count 			: int;
		var id 				: SItemUniqueId;
	
		if ( ownerPlayerWitcher )
		{
			if ( ownerPlayerWitcher.GetItemEquippedOnSlot( EES_Bolt, id ) )
			{
				if (inv.IsItemBolt(id) && !inv.ItemHasTag(id, theGame.params.TAG_INFINITE_AMMO))
					count = ownerPlayerWitcher.inv.GetItemQuantity(id);
			}
			else
				count = 0;
		}
			
		return count;
	}
	
	protected function ResetShotCount()
	{
		shotCount = 0;
	}
	
	protected function SetOwnerOrientation()
	{
		var newCustomOrientationTarget : EOrientationTarget;

		newCustomOrientationTarget = ownerPlayer.GetCombatActionOrientationTarget( CAT_Crossbow );

		if ( ownerPlayer.GetOrientationTarget() != newCustomOrientationTarget )
		{
			ownerPlayer.AddCustomOrientationTarget( newCustomOrientationTarget, 'RangedWeapon' );
		}
		
		if ( newCustomOrientationTarget == OT_CustomHeading )
			ownerPlayer.SetOrientationTargetCustomHeading( ownerPlayer.GetCombatActionHeading(), 'RangedWeapon' );		
	}
	
	protected function ProcessCharacterRotationInCombat()
	{
		var targetToPlayerHeading	: float;
		var angleDiff				: float;
		var angleOffset				: float;
		
		
	}


	protected function ProcessFullBodyAnimWeight( optional forceUpperBodyAnim : bool ) : bool
	{	
		var isAxisReleased : bool;
		
		if ( this.wasBLAxisReleased )
		{
			isAxisReleased = true;
			if ( !ownerPlayer.bLAxisReleased && ownerPlayer.IsInputHeadingReady() )
				isAxisReleased = false;
		}
		else
			isAxisReleased = ownerPlayer.bLAxisReleased;
	
		if ( ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear )
			setFullWeight = true;
		
		if ( ( isAxisReleased || ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear || ownerPlayer.GetPlayerCombatStance() == PCS_Guarded  )  && ( this.GetCurrentStateName() == 'State_WeaponAim' || this.GetCurrentStateName() == 'State_WeaponShoot' ) )
			setFullWeight = true;
			
		if ( isAxisReleased && ( ownerPlayer.IsInCombatAction() || ownerPlayer.GetPlayerCombatStance() == PCS_Guarded ) )
			setFullWeight = true;
			
		if ( isAxisReleased && ( GetCurrentStateName() == 'State_WeaponDraw' || GetCurrentStateName() == 'State_WeaponReload' )  )
			setFullWeight = true;

		
		
			
		if ( ownerPlayer.IsSwimming() )
		{
			if ( ( !isAxisReleased || theInput.IsActionPressed( 'DiveUp' ) || theInput.IsActionPressed( 'DiveDown' ) ) 
				&& ( GetCurrentStateName() == 'State_WeaponDraw' || GetCurrentStateName() == 'State_WeaponHolster' ) )
				setFullWeight = false;
			else	
				setFullWeight = true;
		}
			
		if ( !isAxisReleased && ownerPlayer.GetPlayerCombatStance() == PCS_Normal && !isDeployedEntAiming && !ownerPlayer.IsSwimming()  )
		{
			
				setFullWeight = false;
		}
		else if ( ownerPlayer.GetIsSprinting() && !isDeployedEntAiming )
			setFullWeight = false;
		else if ( !isAxisReleased && !ownerPlayer.IsSwimming() && this.GetCurrentStateName() == 'State_WeaponHolster' && ( ownerPlayer.GetPlayerCombatStance() == PCS_Normal || ownerPlayer.GetPlayerCombatStance() == PCS_AlertFar ) ) 
			setFullWeight = false;
		else if ( ownerPlayer.IsInAir() || ownerPlayer.GetCriticalBuffsCount() > 0 )
			setFullWeight = false;
		else if ( ownerPlayer.IsThrowingItem())
			setFullWeight = false;
		else if ( ownerPlayer.IsInCombatAction() && ( this.GetCurrentStateName() == 'State_WeaponHolster' ) ) 
			setFullWeight = false;
		
		
		else if ( ownerPlayer.playerMoveType == PMT_Run || ownerPlayer.playerMoveType == PMT_Sprint )
			setFullWeight = false;
			
		if ( ownerPlayer.playerMoveType == PMT_Sprint )
			setFullWeight = false;
		
		if ( ownerPlayer.GetCurrentStateName() == 'AimThrow' && !ownerPlayer.IsInAir() )
			setFullWeight = true;				
		
		if ( forceUpperBodyAnim )
			setFullWeight = false;
			
		if ( setFullWeight )
			LogChannel( 'RangedWeapon', "setFullWeight : TRUE" );
		else
		{
			LogChannel( 'RangedWeapon', "setFullWeight : FALSE" );
			if ( this.GetCurrentStateName() == 'State_WeaponReload' )
				LogChannel( 'RangedWeapon', "setFullWeight : FALSE" );
		}
		
		
		
		
		
		ownerPlayer.SetBehaviorVariable( 'fullBodyAnimWeight', (float)setFullWeight );
			
		return setFullWeight;
	}

	protected function ExitCombatAction() : bool
	{
		if ( !super.ExitCombatAction() )
		{
			if ( ownerPlayer.GetBehaviorVariable( 'combatActionType' ) == (int)CAT_Crossbow )
			{
				if ( !ownerPlayer.IsInCombat() && ownerPlayer.bLAxisReleased )
					ownerPlayer.RaiseEvent( 'ForceAlertToNormalTransition' );
				else
					ownerPlayer.RaiseEvent( 'ForceBlendOut' );
					
				return true;	
			}
		}
		
		return false;
	}	
}

state State_WeaponWait in RangedWeapon
{
	var wasPressed : bool;

	event OnEnterState( prevStateName : name )
	{
		thePlayer.BlockAllActions( 'RangedWeapon', false);
		thePlayer.BlockAllActions( 'RangedWeaponReload', false);
		thePlayer.BlockAllActions( 'RangedWeaponAiming', false);
		thePlayer.UnblockAction( EIAB_ThrowBomb, 'ShootingCrossbow' );
		thePlayer.UnblockAction( EIAB_DrawWeapon, 'RangedWeaponAiming' );
		thePlayer.UnblockAction( EIAB_DrawWeapon, 'RangedWeaponReload' );
		
		parent.ResetAllSettings();
		
		parent.Unlock();	
	
		parent.RemoveTimer( 'HolsterAfterDelay' );
		parent.RemoveTimer( 'HolsterWhenMovingTimer' );	
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );	
		parent.ownerPlayer.SetBehaviorVariable( 'hasCrossbowOnHand', 0.f );
	
		parent.RemoveTimer( 'InputLockFailsafe' );		
		DelayedProcessFullBodyAnimWeight();
		
		parent.ownerPlayer.OnDodgeBoost();	
		
		parent.shootingIsComplete = false;
		
		
		
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.performedDraw = false;
		parent.AddTimer( 'InputLockFailsafe', 0.f, true );
		parent.ownerPlayer.SetBehaviorVariable( 'hasCrossbowOnHand', 1.f );
	}
	
	event OnRangedWeaponPress()
	{
		PerformDraw( true );
	}
	
	event OnRangedWeaponRelease()
	{



		if ( !parent.performedDraw )
			PerformDraw( false );
		else if ( wasPressed )
		{
			wasPressed = false;
			parent.OnRangedWeaponRelease();
		}
	}
	
	private function PerformDraw( pressed :  bool )
	{
		wasPressed = pressed;
	
		
		
		virtual_parent.Initialize( (CActor)( parent.GetParentEntity() ) );
		
		if ( pressed )
			virtual_parent.OnRangedWeaponPress();
		else 
			virtual_parent.OnRangedWeaponRelease();
		
		if ( parent.isPlayer )
		{
			virtual_parent.ProcessFullBodyAnimWeight();
		
				
			DrawEvent();
		}	
	}
	
	entry function DelayedProcessFullBodyAnimWeight()
	{
		Sleep(1.5f);
		parent.setFullWeight = 0.f;
		parent.ownerPlayer.SetBehaviorVariable( 'fullBodyAnimWeight', (float)( parent.setFullWeight ) );
	}
	
	entry function DrawEvent()
	{
		parent.ownerPlayer.SetBehaviorVariable( 'failSafeDraw', 1.0 );
		virtual_parent.RaiseOwnerGraphEvents( 'Crossbow_Draw', true );
		parent.performedDraw = true;
	}
}

state State_WeaponDraw in RangedWeapon
{
	event OnEnterState( prevStateName : name )
	{	
		var targetToPlayerHeading 	: float;
		var playerHeading			: float;
		var activeTime				: float;
		
		
		parent.ownerPlayer.radialSlots.Clear();
		parent.ownerPlayer.radialSlots.PushBack( 'Slot1' );
		parent.ownerPlayer.radialSlots.PushBack( 'Slot2' );
		parent.ownerPlayer.radialSlots.PushBack( 'Slot4' );
		parent.ownerPlayer.radialSlots.PushBack( 'Slot5' );
		parent.ProcessEnableRadialSlot();
	
		parent.AddTimer( 'ProcessFullBodyAnimWeightTimer', 0.01f, true );
		parent.ownerPlayer.OnDodgeBoost();
		parent.ownerPlayer.RaiseEvent( 'DivingForceStop' );
		
		parent.shootingIsComplete = false;
		
		parent.RemoveTimer( 'HolsterAfterDelay' );
		parent.RemoveTimer( 'HolsterWhenMovingTimer' );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );				
		
		
		
			
		Equip();
		
		thePlayer.GoToCombatIfNeeded();
		
		thePlayer.BlockAction( EIAB_ThrowBomb, 'ShootingCrossbow' );
		
		
			thePlayer.BlockAction( EIAB_DismountVehicle, 'ShootingCrossbow' );
			thePlayer.BlockAction( EIAB_MountVehicle, 'ShootingCrossbow' );
		
		if ( !parent.ownerPlayer.IsUsingVehicle() && ( parent.ownerPlayer.bLAxisReleased || parent.ownerPlayer.IsSwimming() ) )
		{
			targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( parent.ownerPlayer.GetOrientationTarget() );
			playerHeading = parent.GetHeading();
			
			if ( prevStateName == 'State_WeaponWait'  )
			{
				if ( parent.ownerPlayer.IsSwimming() )
					activeTime = 0.5f;
				else
					activeTime = 0.2f;
					
				parent.ownerPlayer.SetCustomRotation( 'Crossbow', targetToPlayerHeading, 0.0f, activeTime, false );
			}
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var id : SItemUniqueId;
	
		id = parent.inv.GetItemFromSlot('l_weapon');
		if ( parent.inv.IsIdValid( id  ) && !parent.inv.IsItemCrossbow( id ) )
			virtual_parent.OnForceHolster();
	}
	
	entry function Equip()
	{
		var itemId: SItemUniqueId;
		var targetToPlayerHeading 	: float;
	
		if ( parent.isPlayer )
		{
			parent.SetCleanupFunction( 'CancelledEquiping' );
			parent.Lock();
			
			if ( parent.ownerPlayer.IsUsingVehicle() )
				Sleep( 0.2f );
			else
				Sleep( 0.1f );
			
			
			
			
			
			if ( parent.ownerPlayer.inv.GetItemEquippedOnSlot( EES_RangedWeapon, itemId ) )	
				parent.ownerPlayer.DrawItemsLatent( itemId );
				
			
			

			
			
			
			
			
			virtual_parent.ReloadWeaponWithOrWithoutAnimIfNeeded();
		}	
	}
	
	cleanup function CancelledEquiping()
	{	
		
		
	}	
}

state State_WeaponReload in RangedWeapon
{
	event OnEnterState( prevStateName : name )
	{
		if ( parent.ownerPlayer.bLAxisReleased )
		{
			parent.ownerPlayer.SetCombatIdleStance( 1.f );
			
		}
		
		parent.ProcessEnableRadialSlot();

		
	
		parent.ownerPlayer.RaiseEvent( 'DivingForceStop' ); 
		Lock();
		if ( parent.ownerPlayer.GetCurrentStateName() == 'AimThrow' )
			RotateOwnerToCamera();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		Unlock();
	}
	
	private function RotateOwnerToCamera()
	{
		var targetToPlayerHeading : float;
		
		targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( OT_CameraOffset );
		
		
		
		parent.AddTimer( 'UpdateCustomRotationHeadingTimer', 0.001f, true );
	}
	
	private timer function UpdateCustomRotationHeadingTimer( timeDelta : float , id : int)
	{
		var targetToPlayerHeading : float;

		targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( OT_CameraOffset );
		
		parent.ownerPlayer.UpdateCustomRotationHeading( 'Crossbow', targetToPlayerHeading );
	}

	private function Lock()
	{
		var actionBlockingExceptions : array<EInputActionBlock>;

		
		thePlayer.BlockAction( EIAB_DrawWeapon, 'RangedWeaponReload' );
	}
	
	private function Unlock()
	{
		
		thePlayer.BlockAllActions( 'RangedWeaponReload', false);
	}	
}

state State_WeaponAim in RangedWeapon
{
	event OnEnterState( prevStateName : name )
	{	
		if ( !parent.ownerPlayer.IsUsingVehicle() )
			parent.AddTimer( 'HolsterWeaponFailSafe', 1.5f );
		
		if ( parent.ownerPlayer.bLAxisReleased )
			parent.ownerPlayer.SetCombatIdleStance( 1.f );
			
		parent.AddTimer( 'ProcessFullBodyAnimWeightTimer', 0.1f, true );	
		virtual_parent.ProcessCharacterRotationInCombat();
		
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );		

		parent.ProcessEnableRadialSlot();
		
		parent.ownerPlayer.SetBehaviorVariable( 'hasCrossbowHeld', 1.f );
		parent.ownerPlayer.RaiseEvent( 'DivingForceStop' ); 
		parent.ProcessCanAttackWhenNotInCombat();
		parent.ownerPlayer.GetMovingAgentComponent().EnableVirtualController( 'Crossbow', true );
		
		parent.shootingIsComplete = false;
		
		if ( !parent.ownerPlayer.IsUsingVehicle()
			&& parent.ownerPlayer.GetBehaviorVariable( 'isShootingWeapon' ) == 0.f 
			&& parent.ownerPlayer.GetBehaviorVariable( 'isAimingWeapon' ) == 0.f )
		{
			if  ( parent.ownerPlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
			{
				if ( parent.ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear || parent.ownerPlayer.IsSwimming() ) 
					parent.AddTimer( 'HolsterAfterDelay', 0.f );
			}
			else if ( theInput.GetActionValue( 'ThrowItem' ) == 0.f )
				parent.AddTimer( 'HolsterAfterDelay', 0.f );
		}
		else
			parent.Lock();
		
		CheckGotoAimThrow();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		Unlock();
		parent.RemoveTimer( 'UpdateCustomRotationHeadingTimer' );
		parent.RemoveTimer( 'HolsterWeaponFailSafe' );
		
		parent.RemoveTimer( 'HolsterAfterDelay' );
		parent.RemoveTimer( 'HolsterWhenMovingTimer' );	
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );
	}

	event OnRangedWeaponPress()
	{
		virtual_parent.ProcessCharacterRotationInCombat();
		CheckGotoAimThrow();
		parent.OnRangedWeaponPress();
	}
	
	event OnRangedWeaponRelease()
	{
		if ( !parent.ownerPlayer.IsUsingVehicle() )
			virtual_parent.ProcessCharacterRotationInCombat();
			
		parent.OnRangedWeaponRelease();
	}
	
	entry function CheckGotoAimThrow()
	{
		var targetToPlayerHeading 	: float;
		var startTime				: float; 
		
		startTime = theGame.GetEngineTimeAsSeconds();
		while( theGame.GetEngineTimeAsSeconds() < startTime + 0.2 )
		{
			if ( !( parent.ownerPlayer.GetCurrentStateName() == 'AimThrow' && parent.deployedEnt ) )
			{
				virtual_parent.SetOwnerOrientation();	
			}
		
			Sleep( 0.0001f );
		}		
		
		if ( theInput.GetActionValue( 'ThrowItem' ) == 1.f 
			|| theInput.GetActionValue( 'VehicleItemAction' ) == 1.f )
		{		
			if( parent.ownerPlayer && !parent.ownerPlayer.IsUsingVehicle() )
			{	
				parent.RemoveTimer( 'HolsterAfterDelay' );
				parent.RemoveTimer( 'HolsterWhenMovingTimer' );
				parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
				parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );				
			
				if ( parent.ownerPlayer.GetCurrentStateName() == 'AimThrow' || parent.ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear )
					targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( OT_Actor );
				else
					targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( OT_CameraOffset );
					
				
				
			}
			
			
			Sleep( 0.1f );
			parent.RemoveTimer( 'UpdateCustomRotationHeadingTimer' );

			if ( !parent.ownerPlayer.IsUsingVehicle() )
			{
				parent.RemoveTimer( 'HolsterWeaponFailSafe' );
				Lock();
			}	

			if ( parent.deployedEnt )
			{
				if ( parent.ownerPlayer.playerAiming.GetCurrentStateName() != 'Aiming' )
				{
					parent.ownerPlayer.SetBehaviorVariable( 'inAimThrow', 1.f );
					parent.ownerPlayer.SetBehaviorVariable( 'inAimThrowForOverlay', 1.f );
					
					if ( !parent.ownerPlayer.IsUsingVehicle() )
					{
						parent.ownerPlayer.OnEnableAimingMode( true );			
					}
					
					parent.isDeployedEntAiming = true;
					parent.deployedEnt.StartAiming();
					virtual_parent.SetOwnerOrientation();
				}
				else
					parent.ownerPlayer.playerAiming.OnAddAimingSloMo();
			}	
		}
		
		
		else if ( !parent.ownerPlayer.IsUsingVehicle() )
		{
			if ( parent.ownerPlayer.playerAiming.GetCurrentStateName() == 'Aiming' )
				parent.AddTimer( 'HolsterAfterDelay', 0.75f );
			else if ( parent.ownerPlayer.IsInCombat() )
				parent.AddTimer( 'HolsterAfterDelay', 0.f );
			else
				parent.AddTimer( 'HolsterAfterDelay', 4.9f ); 

			parent.bLAxisWasReleased = parent.ownerPlayer.bLAxisReleased;
			
			if ( parent.ownerPlayer.IsSwimming() )
				parent.AddTimer( 'HolsterWhenMovingTimer', 0.5f, true );
			else
				parent.AddTimer( 'HolsterWhenMovingTimer', 0.f, true );
		}
		else if ( (W3Boat)( parent.ownerPlayer.GetUsedVehicle() ) )
		{
			parent.AddTimer( 'HolsterAfterDelay', 4.9f );
		}
	}
	
	event OnWeaponShootStart()
	{
		if ( theInput.GetActionValue( 'ThrowItem' ) == 0.f )
			
		{		
			parent.OnWeaponShootStart();
		}
	}

	timer function UpdateCustomRotationHeadingTimer( timeDelta : float , id : int)
	{
		var targetToPlayerHeading : float;
	
		virtual_parent.SetOwnerOrientation();
		targetToPlayerHeading = parent.ownerPlayer.GetOrientationTargetHeading( parent.ownerPlayer.GetOrientationTarget() );
		parent.ownerPlayer.UpdateCustomRotationHeading( 'Crossbow', targetToPlayerHeading );
	}
	
	private function Lock()
	{
		var actionBlockingExceptions : array<EInputActionBlock>;

		
		thePlayer.BlockAction( EIAB_DrawWeapon, 'RangedWeaponAiming' );
	}
	
	private function Unlock()
	{
		
		thePlayer.BlockAllActions( 'RangedWeaponAiming', false);
	}		
}

state State_WeaponShoot in RangedWeapon
{
	var cachedCombatActionTarget : CGameplayEntity;

	event OnEnterState( prevStateName : name )
	{
		var target : CActor;
		
		target = parent.ownerPlayer.GetTarget();
		parent.ownerPlayer.RaiseEvent( 'DivingForceStop' ); 
		
		
		
		parent.shootingIsComplete = false;
		cachedCombatActionTarget = NULL;
		
		
		if( target )
		{
			if( (( CNewNPC )( target )).IsShielded( thePlayer ) )
				(( CNewNPC )( target )).OnIncomingProjectile( true );
		}
		
		if ( parent.ownerPlayer.GetIsShootingFriendly() )
		{
			parent.Unlock();
			parent.ownerPlayer.DisplayActionDisallowedHudMessage( EIAB_Undefined,,, true );	
			
			if ( parent.ownerPlayer.playerAiming.GetCurrentStateName() == 'Aiming' )
				parent.AddTimer( 'HolsterAfterDelay', 0.f );
			else
			{
				
				if ( parent.ownerPlayer.IsInCombat() )
					parent.AddTimer( 'HolsterAfterDelay', 0.5f );
				else
					parent.AddTimer( 'HolsterAfterDelay', 5.f ); 
				
				parent.bLAxisWasReleased = parent.ownerPlayer.bLAxisReleased;

				if ( parent.ownerPlayer.IsSwimming() )
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.5f, true );
				else
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.f, true );		
			}	
		}
		
		parent.ProcessCanAttackWhenNotInCombat();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.RemoveTimer( 'HolsterAfterDelay' );
		parent.RemoveTimer( 'HolsterWhenMovingTimer' );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );

		
		
	}
	
	event OnProcessThrowEvent( animEventName : name )
	{
		virtual_parent.OnProcessThrowEvent( animEventName );
	
		if ( animEventName == 'ProjectileThrow' )
		{
			if ( cachedCombatActionTarget && !parent.ownerPlayer.IsUsingVehicle() )
				parent.ownerPlayer.SetSlideTarget( cachedCombatActionTarget );
		
			parent.shootingIsComplete = true;
			
			if ( parent.ownerPlayer.GetCurrentStateName() == 'AimThrow' )
			{
				if ( parent.recoilLevel == RL_1 )
					GCameraShake(0.05);
				else
					GCameraShake(0.125);
			}			
				
			if ( parent.isDeployedEntAiming )
			{
				
					parent.AddTimer( 'HolsterAfterDelay', 0.5f );
				
			}
			else
			{
				if ( parent.ownerPlayer.IsInCombat() 
					&& !parent.ownerPlayer.IsSwimming() 
					&& ( !parent.ownerPlayer.IsUsingVehicle() || !( (W3Boat)( parent.ownerPlayer.GetUsedVehicle() ) ) ) )
					parent.AddTimer( 'HolsterAfterDelay', 0.5f );
				else
					parent.AddTimer( 'HolsterAfterDelay', 5.f ); 
			}
			
			if ( parent.ownerPlayer.GetPlayerCombatStance() == PCS_AlertNear )
			{
				if ( parent.ownerPlayer.IsSwimming() )
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.5f, true );
				else
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.f, true );			
			}
			else
			{
				parent.bLAxisWasReleased = parent.ownerPlayer.bLAxisReleased;

				if ( parent.ownerPlayer.IsSwimming() )
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.5f, true );
				else
					parent.AddTimer( 'HolsterWhenMovingTimer', 0.f, true );
			}
			
			if ( !( parent.ownerPlayer.IsUsingVehicle() && (W3Boat)( parent.ownerPlayer.GetUsedVehicle() ) ) )
			{
				parent.ProcessEnableRadialSlot();
				
				if ( parent.ownerPlayer.GetPlayerCombatStance() == PCS_Normal || parent.ownerPlayer.GetPlayerCombatStance() == PCS_AlertFar )
					parent.Unlock();
			}
		}
	}
	
	event OnRangedWeaponPress()
	{
		if ( parent.shootingIsComplete )
		{
			parent.shootingIsComplete = false;
			
			if (  !parent.ownerPlayer.IsUsingVehicle() )
				parent.ownerPlayer.SetSlideTarget( parent.ownerPlayer.GetCombatActionTarget( EBAT_ItemUse ) );
			else
				((CR4PlayerStateUseGenericVehicle)parent.ownerPlayer.GetState( 'UseGenericVehicle' )).FindTarget();
		}
		else if ( !cachedCombatActionTarget )
		{
			cachedCombatActionTarget = parent.ownerPlayer.GetCombatActionTarget( EBAT_ItemUse );
		}
		
		if ( parent.ownerPlayer.GetIsShootingFriendly() )
		{
			parent.ProcessCanAttackWhenNotInCombat();		
		}

		virtual_parent.OnRangedWeaponPress();
	}
	
	event OnRangedWeaponRelease()
	{
		parent.OnRangedWeaponRelease();
	}	
}

state State_WeaponHolster in RangedWeapon
{
	var isSettingItems	: bool;

	event OnEnterState( prevStateName : name )
	{	
		parent.RemoveTimer( 'HolsterAfterDelay' );
		parent.RemoveTimer( 'HolsterWhenMovingTimer' );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelay', 0.f );
		parent.ownerPlayer.SetBehaviorVariable( 'canHolsterAfterDelayHorse', 0.f );			
	
		isSettingItems = false;
		parent.ResetAllSettings();
		
		if ( parent.ownerPlayer.bLAxisReleased )
			parent.ownerPlayer.SetCombatIdleStance( 1.f );
			
		parent.ownerPlayer.OnDodgeBoost();	
		Unequip();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( !( parent.ownerPlayer.IsUsingVehicle() && (W3Boat)( parent.ownerPlayer.GetUsedVehicle() ) ) )
			parent.ProcessEnableRadialSlot();
	
		if ( parent.ownerPlayer.bLAxisReleased )
			parent.ownerPlayer.SetCombatIdleStance( 1.f );
	
		thePlayer.UnblockAction( EIAB_ThrowBomb, 'ShootingCrossbow' );
		parent.RemoveTimer( 'ProcessFullBodyAnimWeightTimer' );	
	}
	
	entry function Unequip()
	{
		if ( parent.isPlayer )
		{	
			parent.SetCleanupFunction( 'CancelledEquiping' );
			
			Sleep( 0.2 );
			isSettingItems = true;
			
			Sleep( 0.3f );
			
			
			

			
			parent.ownerPlayer.SetRequiredItems('None', 'Any');
			parent.ownerPlayer.ProcessRequiredItems();
			
			isSettingItems = false;
			
			
			parent.Unlock();
			parent.OnChangeTo( 'State_WeaponWait' );	
		}
	}
	
	event OnRangedWeaponPress()
	{
			

		virtual_parent.ProcessFullBodyAnimWeight();
	
		if ( !isSettingItems ) 
		{
			if ( !parent.inv.IsItemCrossbow( parent.inv.GetItemFromSlot('l_weapon') ) )
				virtual_parent.RaiseOwnerGraphEvents( 'Crossbow_Draw', true );
			else if ( virtual_parent.ReloadWeaponWithOrWithoutAnimIfNeeded() )
				virtual_parent.RaiseOwnerGraphEvents( 'Crossbow_Reload', true );
			else
				virtual_parent.RaiseOwnerGraphEvents( 'Crossbow_AimShoot', true );
		}
		else
			virtual_parent.RaiseOwnerGraphEvents( 'Crossbow_Draw', true );
		
		parent.OnRangedWeaponPress();
	}	
	
	cleanup function CancelledEquiping()
	{
		parent.Unlock();
	}		
}