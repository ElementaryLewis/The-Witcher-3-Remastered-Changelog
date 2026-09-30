/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class IBehTreeHorseTaskDefinition extends IBehTreeTaskDefinition
{
};

abstract class IBehTreeHorseConditionalTaskDefinition extends IBehTreeConditionalTaskDefinition
{

};





class CBTCondHorseIsMounted extends IBehTreeTask
{	
	var waitForMountEnd 		: Bool;
	var waitForDismountEnd 		: Bool;
	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
			
		if ( !horseComp )
		{
			return false;
		}
		if( !horseComp.riderSharedParams )
		{
			return false;
		}
		switch( horseComp.riderSharedParams.mountStatus )
		{
			case VMS_mountInProgress:
				if ( waitForMountEnd )
				{
					return false;
				}
				return true;
			case VMS_mounted:
				return true;
			case VMS_dismountInProgress:
				if ( waitForDismountEnd )
				{
					return true;
				}
				return false;
			case VMS_dismounted:
				return false;
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		switch ( eventName )
		{
			case 'HorseMountStart' :
			{
				return true;
			}
			case 'HorseMountEnd' :
			{
				return true;
			}
			case 'HorseDismountStart' :
			{
				return true;
			}
			case 'HorseDismountEnd' :
			{
				return true;
			}
		}
		return false;
	}
	
};


class CBTCondHorseIsMountedDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseIsMounted';

	editable var waitForMountEnd 	: Bool;
	editable var waitForDismountEnd : Bool;
	default waitForMountEnd 		= false;
	default waitForDismountEnd		= true;
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseMountStart' );
		listenToGameplayEvents.PushBack( 'HorseMountEnd' );
		listenToGameplayEvents.PushBack( 'HorseDismountStart' );
		listenToGameplayEvents.PushBack( 'HorseDismountEnd' );
	}
};



class CBTCondHorseIsMountedByPlayer extends CBTCondHorseIsMounted
{	
	function IsAvailable() : bool
	{
		var owner 		: CActor = GetActor();
		var horseComp 	: W3HorseComponent;
		
		if ( super.IsAvailable() )
		{
			horseComp = GetNPC().GetHorseComponent();
			return horseComp.user == thePlayer;
		}
		return false;
	}
};


class CBTCondHorseIsMountedByPlayerDef extends CBTCondHorseIsMountedDef
{
	default instanceClass = 'CBTCondHorseIsMountedByPlayer';

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseMountStart' );
		listenToGameplayEvents.PushBack( 'HorseMountEnd' );
		listenToGameplayEvents.PushBack( 'HorseDismountStart' );
		listenToGameplayEvents.PushBack( 'HorseDismountEnd' );
	}
};





class CBTCondHorseCanDoIdle extends IBehTreeTask
{	
	var waitForMountEnd 		: Bool;
	var waitForDismountEnd 		: Bool;
	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		if ( !horseComp )
		{
			return false;
		}
		
		if ( horseComp.IsTamed() == false || ( IsMounted( horseComp ) && horseComp.user != thePlayer )  )
		{
			return true;
		}
		
		return false;
	}
	
	function IsMounted( horseComp 	: W3HorseComponent ) : bool
	{
		if( !horseComp.riderSharedParams )
		{
			return false;
		}
		switch( horseComp.riderSharedParams.mountStatus )
		{
			case VMS_mountInProgress:
				if ( waitForMountEnd )
				{
					return false;
				}
				return true;
			case VMS_mounted:
				return true;
			case VMS_dismountInProgress:
				if ( waitForDismountEnd )
				{
					return true;
				}
				return false;
			case VMS_dismounted:
				return false;
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		switch ( eventName )
		{
			case 'HorseMountStart' :
			{
				return true;
			}
			case 'HorseMountEnd' :
			{
				return true;
			}
			case 'HorseDismountStart' :
			{
				return true;
			}
			case 'HorseDismountEnd' :
			{
				return true;
			}
		}
		return false;
	}
	
};


class CBTCondHorseCanDoIdleDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseCanDoIdle';
	
	editable var waitForMountEnd 	: Bool;
	editable var waitForDismountEnd : Bool;
	default waitForMountEnd 		= false;
	default waitForDismountEnd		= true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseMountStart' );
		listenToGameplayEvents.PushBack( 'HorseMountEnd' );
		listenToGameplayEvents.PushBack( 'HorseDismountStart' );
		listenToGameplayEvents.PushBack( 'HorseDismountEnd' );
	}
};



class CBTCondHorsePerformingAction extends IBehTreeTask
{	
	var mounting : bool;
	var dismounting : bool;
	var inAir : bool;
	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
			
		if ( !horseComp )
		{
			return false;
		}
		if( !horseComp.riderSharedParams )
		{
			return false;
		}
		
		if( mounting && horseComp.riderSharedParams.mountStatus == VMS_mountInProgress )
		{
			return true;
		}
		else if( dismounting && horseComp.riderSharedParams.mountStatus == VMS_dismountInProgress )
		{
			return true;
		}
		else if( inAir && ((CActor)GetNPC()).IsInAir() )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
};


class CBTCondHorsePerformingActionDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorsePerformingAction';

	editable var mounting : bool;
	editable var dismounting : bool;
	editable var inAir : bool;
	
	default mounting = true;
	default dismounting = true;
	default inAir = false;
};



class CBTCondHorsePlayingAnimWithRider extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
			
		if ( !horseComp )
		{
			return false;
		}
		if( !horseComp.riderSharedParams )
		{
			return false;
		}
		
		if ( horseComp.riderSharedParams.isPlayingAnimWithRider )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
};


class CBTCondHorsePlayingAnimWithRiderDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorsePlayingAnimWithRider';
};



class CBTCondHorseShouldShakeOffRider extends IBehTreeTask
{
	var activate : bool;
	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		var panic : float;
		
		if( GetNPC().HasAbility( 'DisableHorsePanic' ) )
		{
			return false;
		}
		
		if ( activate )
			return true;
		
		horseComp = GetNPC().GetHorseComponent();
		panic =  horseComp.GetPanicPercent();
		
		if ( panic >= 0.999 )
			return true;
		
		return false;
	}
	
	function OnDeactivate()
	{
		activate = false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var buffType : ECriticalStateType;
		
		
		if ( !GetNPC().IsInCombat() )
			return false;
			
		if( GetNPC().HasAbility( 'DisableHorsePanic' ) )
		{
			return false;
		}
		
		
		if ( eventName == 'CriticalState' )
		{
			buffType = this.GetEventParamInt(-1);
			if ( buffType == ECST_Knockdown || buffType == ECST_HeavyKnockdown || buffType == ECST_Ragdoll )
			{
				activate = true;
				return true;
			}
			else
			{
				return false;
			}
		}
		return true;
	}
};


class CBTCondHorseShouldShakeOffRiderDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseShouldShakeOffRider';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CriticalState' );
		listenToGameplayEvents.PushBack( 'BeingHit' );
	}
};



class CBTTaskHorseForceStop extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		horseComp.OnForceStop();
		
		while( VecLength( GetActor().GetMovingAgentComponent().GetVelocity() ) > 1.0 )
		{
			SleepOneFrame();
		}
		
		return BTNS_Completed;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'FinishTask')
		{
			Complete( true );
		}
		
		return false;
	}
}

class CBTTaskHorseForceStopDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseForceStop';
}



class CBTTaskHorseForceDismount extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		if ( !horseComp.riderSharedParams.rider )
		{
			return BTNS_Failed;
		}
		
		if( horseComp.riderSharedParams.rider == thePlayer )
		{
			horseComp.ShakeOffRider( DT_shakeOff );
		}
		else
		{
			horseComp.riderSharedParams.rider.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_ragdoll );
		}
		
		return BTNS_Completed;
	}
}

class CBTTaskHorseForceDismountDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseForceDismount';
}



class CBTTaskHorseForceIdle extends IBehTreeTask
{
	
	function OnActivate() : EBTNodeStatus
	{
		var owner 		: CActor = GetActor();
		owner.ActionCancelAll(); 
		
		
		return BTNS_Active;
	}
	latent function Main() : EBTNodeStatus
	{
		var owner 		: CActor = GetActor();
		owner.WaitForBehaviorNodeActivation( 'OnAnimIdleActivated', 1.5f );
		return BTNS_Completed;
	}
}

class CBTTaskHorseForceIdleDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseForceIdle';
}




class CBTTaskHorseTame extends IBehTreeTask
{
	function OnListenedGameplayEvent( gameEventName : name ) : bool
	{
		var horseComp 	: W3HorseComponent;
		var npc 		: CNewNPC;
		
		if ( gameEventName == 'HorseMountStart' )
		{
			npc = GetNPC();
			horseComp = npc.GetHorseComponent();
			
			if( horseComp && horseComp.IsTamed() == false  )
			{
				if ( (npc.HasBuff( EET_AxiiGuardMe ) || npc.HasBuff(EET_Confusion)) && horseComp.riderSharedParams.rider )
				{
					horseComp.Tame( horseComp.riderSharedParams.rider, true );
				}
			}
		}
		return false;
	}
}

class CBTTaskHorseTameDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseTame';

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseMountStart' );
	}
}



class CBTCondHorseIsTamed extends IBehTreeTask
{	
	var isTamed 	: Bool;
	default isTamed = false;
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp 		= GetNPC().GetHorseComponent();
		
		if ( horseComp.IsTamed() )
		{
			return true;
		}
		
		return false;
	}
}


class CBTCondHorseIsTamedDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseIsTamed';
}




class CBTCondHorseIsGeralts extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return thePlayer.GetHorseWithInventory() == GetActor();
	}
}


class CBTCondHorseIsGeraltsDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseIsGeralts';
}



class CBTCondHorseParking extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		horseComp = GetNPC().GetHorseComponent();
		
		return horseComp.GetLastRider() == thePlayer || thePlayer.GetHorseWithInventory() == GetActor();
	}
}


class CBTCondHorseParkingDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseParking';
}



class CBTTaskHorseReassure extends IBehTreeTask
{
	var animalData 		: CAIStorageAnimalData;
	function OnActivate() : EBTNodeStatus
	{
		animalData.scared 	= false;
		return BTNS_Active;
	}

	function Initialize()
	{
		animalData = (CAIStorageAnimalData)RequestStorageItem( 'AnimalData', 'CAIStorageAnimalData' );
	}
}

class CBTTaskHorseReassureDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseReassure';
}


class CBTTaskHorseTurnAwayFromTarget extends IBehTreeTask
{
	var direction	: Float;
	default direction = 0.0;
	var init : Bool;
	default init = false ;
	
	latent function Main() : EBTNodeStatus
	{
		var npc 		: CNewNPC = GetNPC();
		var target 		: CActor = GetCombatTarget();
		var vec 		: Vector;
		var angle, npcHeadingAngle 		: EulerAngles;
		var difYaw 		: Float;
		
		
		while ( npc.IsRotatedTowardsPoint( target.GetWorldPosition(), 1.0 ) == false )
		{
			vec 			= target.GetWorldPosition() - npc.GetWorldPosition();
			angle 			= VecToRotation( vec );
			npcHeadingAngle	= VecToRotation( npc.GetHeadingVector() );

			difYaw 				= AngleNormalize180( npcHeadingAngle.Yaw - angle.Yaw );
			if ( init == false )
			{
				init = true;
				direction = -1.0;
				
				if ( difYaw < 0 )
				{
					
					direction = 1.0;
				}
			}
			
			if ( -10.0 < difYaw && difYaw < 10.0 )
			{
				direction = 0.0;
			}
			
			npc.SetBehaviorVariable( 'rotation', direction );
			Sleep(0.01);
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		var npc 	: CNewNPC = GetNPC();
		init = false;
		npc.SetBehaviorVariable( 'rotation', 0.0 );
	}
}

class CBTTaskHorseTurnAwayFromTargetDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseTurnAwayFromTarget';
}



class CBTTaskHorseUncontrolable extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
		var horseComponent 	: W3HorseComponent;
		horseComponent = GetNPC().GetHorseComponent();
		horseComponent.controllable = false;
		return BTNS_Active;
	}
	function OnDeactivate()
	{
		var horseComponent 	: W3HorseComponent;
		horseComponent 				= GetNPC().GetHorseComponent();
		horseComponent.controllable = true;
	}
}

class CBTTaskHorseUncontrolableDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseUncontrolable';
}




class CBTCondHorseIsNervous extends IBehTreeTask
{
	private var isNervous 		: bool; 
	var waitForAxiiCalmDownEnd	: bool;
	default isNervous = false;
	function IsAvailable() : bool
	{
		
		return isNervous;
	}
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'HorseNervousStart' )
		{
			isNervous = true;
		}
		else if ( eventName == 'HorseNervousEnd' )
		{
			if ( waitForAxiiCalmDownEnd )
			{
				isNervous = false;
			}
		}
		else if ( eventName == 'HorseAxiiCalmDownEnd' )
		{
			isNervous = false;
		}
		return true;
	}	
}

class CBTCondHorseIsNervousDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseIsNervous';
	
	editable var waitForAxiiCalmDownEnd : bool;
	default waitForAxiiCalmDownEnd = false;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseNervousStart' );
		listenToGameplayEvents.PushBack( 'HorseNervousEnd' );
		listenToGameplayEvents.PushBack( 'HorseAxiiCalmDownEnd' );
	}
}



class CBTTaskHorseNervous extends IBehTreeTask
{
	private var timeTillNextNervous	: float;
	
	default timeTillNextNervous = 0.0;
	function OnActivate(): EBTNodeStatus
	{
		GetActor().SignalGameplayEvent( 'HorseNervousStart' );
		return BTNS_Active;
	}
	function UpdateTimeUntillNextNervous()
	{
		var spellPower  	: SAbilityAttributeValue 	= thePlayer.GetPowerStatValue(CPS_SpellPower);
		timeTillNextNervous = GetLocalTime() + RandRangeF( 10.0, 8.0 ) + spellPower.valueMultiplicative * spellPower.valueMultiplicative;
	}
	function IsTimeToNextNervous() : bool
	{
		return timeTillNextNervous < GetLocalTime();
	}
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			if ( IsTimeToNextNervous() )
			{
				GetActor().SignalGameplayEvent( 'HorseNervousStart' );
				UpdateTimeUntillNextNervous();
			}
			SleepOneFrame();
		}
	
		return BTNS_Completed;
	}
}

class CBTTaskHorseNervousDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseNervous';
}



class CBTTaskHorseAxiiCalmDown extends IBehTreeTask
{
	private var inProgress			: bool;
	private var horseMounted 		: Bool;
	
	default inProgress 				= false;
	default horseMounted 			= false;
	

	function OnActivate() : EBTNodeStatus
	{
		var owner 			: CActor = GetActor();
		var calmDownComp 	: CInteractionComponent;

		calmDownComp	 = (CInteractionComponent)owner.GetComponent('HorseAxiiCalmDown');
		
		if( calmDownComp && horseMounted)
		{
			calmDownComp.SetEnabled( true );
		}
		return BTNS_Active;
	}
		
	latent function Main() : EBTNodeStatus
	{
		var horseComponent 	: W3HorseComponent;
		horseComponent 		= GetNPC().GetHorseComponent();

		while ( inProgress == false )
		{
			SleepOneFrame();
		}
		GetActor().SignalGameplayEvent( 'HorseNervousEnd' );
		horseComponent.user.RaiseEvent( 'axiiCalmDown' );
		GetActor().RaiseEvent( 'axiiCalmDown' );
		GetActor().WaitForBehaviorNodeDeactivation( 'axiiCalmDownEnd', 2.0 );
		inProgress 	= false;
		GetActor().SignalGameplayEvent( 'HorseAxiiCalmDownEnd' );
		return BTNS_Completed;
	}
	
	function OnListenedGameplayEvent( gameEventName : name ) : bool
	{			
		var owner 			: CActor 					= GetActor();
		var horseComponent 	: W3HorseComponent;
		var calmDownComp 	: CInteractionComponent;
		horseComponent 									= GetNPC().GetHorseComponent();
		calmDownComp 									= (CInteractionComponent)owner.GetComponent('HorseAxiiCalmDown');
		
		if ( gameEventName == 'HorseAxiiCalmDownStart' )
		{
			inProgress = true;
			if( calmDownComp )
			{
				calmDownComp.SetEnabled( false );
			}
			return true;
		}
		else if ( gameEventName == 'HorseMountEnd' )
		{	
			horseMounted = true;
			if( calmDownComp && isActive ) 
			{
				calmDownComp.SetEnabled( true );
			}
			return true;
		}
		else if ( gameEventName == 'HorseDismountEnd' )
		{
			horseMounted = false;
			if( calmDownComp )
			{
				calmDownComp.SetEnabled( false );
			}
			return false;
		}
		
		return false;
	}
}

class CBTTaskHorseAxiiCalmDownDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseAxiiCalmDown';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseAxiiCalmDownStart' );
		listenToGameplayEvents.PushBack( 'HorseMountEnd' );
	}
}





class CBTTaskHorsePlayAnimWithRider extends IBehTreeTask
{
	public var eventName 				: CName;
	public var deactivationEventName 	: CName;
	var workDone 						: bool;
	default workDone					= false;
	function IsAvailable() : bool
	{	
		if ( Work() )
		{
			return true;
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var horseComponent 	: W3HorseComponent;
		if ( Work() )
		{
			horseComponent 		= GetNPC().GetHorseComponent();
			horseComponent.riderSharedParams.isPlayingAnimWithRider = true;
			
			return BTNS_Active;
		}
		return BTNS_Failed;
	}
	function OnDeactivate()
	{
		var horseComponent : W3HorseComponent;
		horseComponent = GetNPC().GetHorseComponent();
		horseComponent.riderSharedParams.isPlayingAnimWithRider = false;
		
		workDone = false;
	}
	
	function Work() : bool
	{
		var horseComponent 	: W3HorseComponent;
		horseComponent 		= GetNPC().GetHorseComponent();
	
		if ( workDone )
		{
			return true;
		}
		if ( GetActor().RaiseEvent( eventName ) )
		{
			if ( horseComponent.user )
			{
				horseComponent.user.RaiseEvent( eventName );
			}
			workDone 			= true;
			return true;
		}
		
		return false;
	}
		
	latent function Main() : EBTNodeStatus
	{
		GetActor().WaitForBehaviorNodeDeactivation( deactivationEventName, 10.0 );
		return BTNS_Completed;
	}
}
				
class CBTTaskHorsePlayAnimWithRiderDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorsePlayAnimWithRider';
	editable var eventName 				: CName;
	editable var deactivationEventName 	: CName;
}



class CBTTaskHorseSummon extends IBehTreeTask
{
	private var horseSummonner 	: CEntity;
	
	function IsAvailable() : bool
	{
		var horseComp		: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
			
		
		if ( !horseComp )
		{
			return false;
		}
		if ( horseSummonner )
		{
			if ( GetActor() != thePlayer.GetHorseWithInventory() )
			{
				horseSummonner = NULL;
				return false;
			}
			
			if ( thePlayer.WasHorseRecentlySummoned() )
			{
				GetActor().SignalGameplayEvent( 'AI_ForceInterruption' );
				SetActionTarget( horseSummonner );
				return true;
			}
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( GetActionTarget() )
		{
			return BTNS_Active;
		}
		else
			return BTNS_Failed;
	}

	function OnDeactivate() : void
	{
		SetActionTarget( NULL );
		horseSummonner = NULL;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'HorseSummon' )
		{
			horseSummonner = (CActor) GetEventParamObject();
			return true;
		} 
		return false;
	}
}

class CBTTaskHorseSummonDef extends IBehTreeHorseTaskDefinition
{	
	default instanceClass = 'CBTTaskHorseSummon';
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseSummon' );
	}
}


class CBTTaskHorseCharge extends IBehTreeTask
{
	var dealDamage			: bool;
	var collisionWithActor 	: bool;
	var xmlDamageName		: name;
	var collidedActor 		: CActor;
	
	default collisionWithActor = false;
	
	function IsAvailable() : bool
	{
		if ( NavTest() && AngleAndDistTest() )
		{
			return true;
		}
		return false;
	}
	
	function NavTest() : bool
	{
		return theGame.GetWorld().NavigationLineTest( GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), GetActor().GetRadius());
	}
	
	function AngleAndDistTest() : bool
	{
		if ( VecDistanceSquared(GetActor().GetWorldPosition(),GetCombatTarget().GetWorldPosition()) <= 16 && AbsF(NodeToNodeAngleDistance(GetCombatTarget(),GetActor())) > 80 )
			return false;
			
		return true;
	}
	
	function OnDeactivate()
	{		
		collisionWithActor = false;
		collidedActor 		= NULL;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var damage 			: float;
		var horseComp 	: W3HorseComponent;
		
		if ( collisionWithActor == false && eventName == 'CollisionWithActor' )
		{
			
			horseComp = GetNPC().GetHorseComponent();
			collidedActor = (CActor)GetEventParamObject();
			
			horseComp.ShouldDealDamageToActor(collidedActor, false);
			
			collisionWithActor = true;
			
			return true;
		}
		
		return false;
	}
}

class CBTTaskHorseChargeDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseCharge';
}




class CBTCondHorseScriptedActionPending extends IBehTreeTask
{	
	var scriptedActionPending : bool;
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		horseComp = GetNPC().GetHorseComponent();
			
		if ( !horseComp )
		{
			return false;
		}
		if( !horseComp.riderSharedParams )
		{
			
			return false;
		}
		
		return horseComp.riderSharedParams.scriptedActionPending;
	}	
};


class CBTCondHorseScriptedActionPendingDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseScriptedActionPending';
};



class CBTTaskHorseRequiredItemsForRider extends IBehTreeTask
{
	private var processLeftItem : bool;
	private var processRightItem : bool;
	
	var LeftItemType : CName;
	var RightItemType : CName;
	
	function IsAvailable() : bool
	{
		
		return RequiredItems();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var riderData 		: CAIStorageRiderData;
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		npc = (CNewNPC)horseComp.riderSharedParams.rider;
		
		if ( !npc )
			return BTNS_Failed;
		
		npc.SetBehaviorVariable( 'actionType', (int)EHCA_Attack );
		npc.SetBehaviorVariable( 'isHoldingWeaponR', 1.f );
		npc.SetBehaviorVariable( 'swordAdditiveBlendWeight', 1.f );
		
		if ( processLeftItem || processRightItem )
		{
			if ( processLeftItem && processRightItem )
				npc.SetRequiredItems('None','None');
			else if ( processLeftItem )
				npc.SetRequiredItems('None','Any');
			else if ( processRightItem )
				npc.SetRequiredItems('Any','None');
			
			npc.ProcessRequiredItems();
			
			npc.SetRequiredItems( LeftItemType, RightItemType );
			npc.ProcessRequiredItems();
			npc.OnProcessRequiredItemsFinish();
		}
		return BTNS_Active;
	}
	
	private function RequiredItems() : bool
	{
		var res 	: bool;
		var itemID	: SItemUniqueId;
		var i		: int;
		var items 	: array<SItemUniqueId>;
		var inventory : CInventoryComponent;
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		inventory = horseComp.riderSharedParams.rider.GetInventory();
		
		if ( !inventory )
			return false;
		
		res = true;
		
		if ( LeftItemType != 'None' )
		{
			processLeftItem = true;
			items = inventory.GetItemsByCategory( LeftItemType );
			
			if ( items.Size() == 0 )
			{
				items = inventory.GetItemsByTag( LeftItemType );
			}
			
			if ( items.Size() == 0 )
			{
				res = false;
				LogQuest("Cannot enter combat style. No " + LeftItemType + " found in l_weapon");
			}
			else
			{
				for ( i=0 ; i < items.Size(); i+=1 )
				{
					if ( inventory.IsItemHeld(items[i]) )
					{
						processLeftItem = false;
					}
				}
			}
			
		}
		else
		{
			itemID = inventory.GetItemFromSlot( 'l_weapon' );
			if ( inventory.GetItemCategory(itemID) != LeftItemType )
				processLeftItem = true;
		}
		
		if ( RightItemType != 'None' )
		{
			processRightItem = true;
			items = inventory.GetItemsByCategory( RightItemType );
			
			if ( items.Size() == 0 )
			{
				items = inventory.GetItemsByTag( RightItemType );
			}
			
			if ( items.Size() == 0 )
			{
				res = false;
				LogQuest("Cannot enter combat style. No " + RightItemType + " found in r_weapon");
			}
			else
			{
				for ( i=0 ; i < items.Size(); i+=1 )
				{
					if ( inventory.IsItemHeld(items[i]) )
					{
						processRightItem = false;
					}
				}
			}
		}
		else
		{
			itemID = inventory.GetItemFromSlot( 'r_weapon' );
			if ( inventory.GetItemCategory(itemID) != RightItemType )
				processRightItem = true;
		}
		
		return res;
	}
}

class CBTTaskHorseRequiredItemsForRiderDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseRequiredItemsForRider';

	editable var RightItemType	: name;
}



class CBTTaskHorseSheathWeaponsForRider extends IBehTreeTask
{
	private var processLeftItem : bool;
	private var processRightItem : bool;
	
	private var rider	: CActor;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var itemID	: SItemUniqueId;
		var i		: int;
		var items 	: array<SItemUniqueId>;
		var inventory : CInventoryComponent;
		
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		
		if (!horseComp.riderSharedParams )
		{
			return BTNS_Active;
		}
		
		rider = horseComp.riderSharedParams.rider;
		
		
		
		inventory = rider.GetInventory();
		
		rider.SetBehaviorVariable( 'isHoldingWeaponR', 0.f );
		
		
		itemID = inventory.GetItemFromSlot( 'l_weapon' );
		
		if ( inventory.IsItemWeapon(itemID) )
			processLeftItem = true;
		
		
		itemID = inventory.GetItemFromSlot( 'r_weapon' );
		if ( inventory.IsItemWeapon(itemID) )
			processRightItem = true;
		
		
		if ( processLeftItem && processRightItem )
		{
			rider.SetRequiredItems('None','None');
		}
		else if ( processLeftItem )
		{
			rider.SetRequiredItems('None','Any');
		}
		else if ( processRightItem )
		{
			rider.SetRequiredItems('Any','None');
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( processLeftItem || processRightItem )
		{
			rider.ProcessRequiredItems();
		}
		return BTNS_Active;
	}
}

class CBTTaskHorseSheathWeaponsForRiderDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseSheathWeaponsForRider';
}



class CBTCondRiderCanPerformAttack	extends IBehTreeTask
{
	private var rider : CActor;
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		if ( !rider )
		{
			horseComp 	= GetNPC().GetHorseComponent();
			rider 		= horseComp.riderSharedParams.rider;
		}
		
		if( ((CNewNPC)rider).IsInHitAnim() )
		{
			return false;
		}
		
		return true;
	}

}

class CBTCondRiderCanPerformAttackDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTCondRiderCanPerformAttack';
}



class CBTTaskHorseManageRiderPosition extends IBehTreeTask
{	
	private var rider 						: CActor;
	private const var activation_distance 	: float;

	default activation_distance = 6.5;
	
	latent function Main() : EBTNodeStatus
	{
		var res 		: bool;
		var dist 		: float;
		var target		: CActor;
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		rider = horseComp.riderSharedParams.rider;		
		
		while( true )
		{
			SleepOneFrame();
			target 	= GetCombatTarget();
			dist 	= VecDistance(rider.GetWorldPosition() , target.GetWorldPosition());
			
			if( dist > activation_distance )
			{
				rider.SetBehaviorVariable( 'attackRelease', 2.f );
				continue;
			}
			
			if( rider.GetBehaviorVariable( 'attackRelease' ) == 2 )
			{
				rider.SetBehaviorVariable( 'actionType', (int)EHCA_Attack );
				rider.SetBehaviorVariable( 'attackRelease', 0.f );
				rider.RaiseEvent( 'actionStart' );
			}
			
			rider.SetBehaviorVariable('speed',GetActor().GetMovingAgentComponent().GetRelativeMoveSpeed());
			
			ChooseAttackDir();
			ChooseAttackHeight();			
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		rider.SetBehaviorVariable( 'attackRelease', 2.f );
		rider = NULL;
	}
	
	private function ChooseAttackDir()
	{
		var verticalVal 		: float;
		var horizontalVal 		: float;
		var localOffset 		: Vector;
		var heading 			: float;
		var riderTarget 		: CActor;
		var riderData 			: CAIStorageRiderData;
		
		riderTarget 	= GetCombatTarget();		
		heading 		= VecHeading( riderTarget.GetWorldPosition() - rider.GetWorldPosition() );		
		horizontalVal 	= AngleDistance( rider.GetHeading(), heading ) / 180.f;
		
		rider.SetBehaviorVariable( 'aimHorizontal', horizontalVal );
		
		if ( horizontalVal > 0 )
			rider.SetBehaviorVariable( 'aimHorizontalSword', 0.f );
		else if ( horizontalVal < 0 )
			rider.SetBehaviorVariable( 'aimHorizontalSword', 1.f );
	}
	
	function ChooseAttackHeight()
	{
		var verticalVal : float;
		var riderPos, targetPos : Vector;
		
		riderPos = rider.GetWorldPosition();
		
		targetPos = GetCombatTarget().GetWorldPosition();
		
		if( GetCombatTarget().IsUsingHorse() )
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
		
		rider.SetBehaviorVariable( 'aimVertical', verticalVal );
	}
}

class CBTTaskHorseManageRiderPositionDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseManageRiderPosition';
}




class CBTTaskHorsePerformRiderAttack extends IBehTreeTask
{
	private var rider : CActor;
	
	function OnActivate() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		
		if ( !rider )
		{
			horseComp = GetNPC().GetHorseComponent();
			rider = horseComp.riderSharedParams.rider;
		}
		
		rider.SetBehaviorVariable( 'attackRelease', 1.f );		
		rider.SetBehaviorVariable( 'actionType', (int)EHCA_Attack );
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : bool;
		
		rider.RaiseEvent( 'actionStart' );
		
		res = rider.WaitForBehaviorNodeActivation( 'ActionOn', 0.5f );
		if( !res )
		{
			return BTNS_Failed;
		}
		
		rider.WaitForBehaviorNodeActivation( 'ActionOff', 5.f );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		rider.SetBehaviorVariable( 'attackRelease', 2.f );
		rider = NULL;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{			
		if( eventName == 'StopAttackOnHorse' )
		{
			Complete( true );
		}
		
		return false;
	}
}

class CBTTaskHorsePerformRiderAttackDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorsePerformRiderAttack';
}



class CBTCondIsHorseInAreaWithObstacles extends IBehTreeTask
{
	public var testRadius : float;
	
	private var testFreq : float;
	
	default testFreq = 0.f;
	
	private var lastTestTime : float;
	private var lastResult : bool;
	
	function IsAvailable() : bool
	{
		if ( lastTestTime <= 0.f || ( lastTestTime + testFreq < GetLocalTime() ) )
			lastResult = PerformTest();
		
		return lastResult;
	}
	
	function PerformTest() : bool
	{
		lastTestTime = GetLocalTime();
		
		return !theGame.GetWorld().NavigationCircleTest(GetNPC().GetWorldPosition(),testRadius);
	}
	
}

class CBTCondIsHorseInAreaWithObstaclesDef extends IBehTreeHorseTaskDefinition
{
	editable var testRadius : float;
	
	default testRadius = 5.f;
	
	default instanceClass = 'CBTCondIsHorseInAreaWithObstacles';
}



class CBTTaskHorseUpdateRiderLookat extends IBehTreeTask
{
	private var rider : CActor;
	
	public var boneName : name;
	public var useCombatTarget : bool;
	public var useCustomTarget : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		
		
		if ( !rider )
		{
			horseComp = GetNPC().GetHorseComponent();
			rider = horseComp.riderSharedParams.rider;
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var lookatTarget : CEntity;
		var targetBoneIndex : int;
		var targetPos : Vector;
		var heading	: float;
		
		if ( useCombatTarget )
			lookatTarget = GetCombatTarget();
		else
			lookatTarget = (CEntity)GetActionTarget();
		
		if ( !lookatTarget && !useCustomTarget  )
			return BTNS_Active;
		
		targetBoneIndex = lookatTarget.GetBoneIndex(boneName);
		
		while ( true )
		{
			if( useCustomTarget )
			{			
				GetCustomTarget( targetPos, heading );
				targetPos.Z += 1;
			}
			else if ( targetBoneIndex != -1 )
			{
				targetPos = MatrixGetTranslation(lookatTarget.GetBoneWorldMatrixByIndex(targetBoneIndex));
			}
			else 
			{
				targetPos = lookatTarget.GetWorldPosition();
				targetPos.Z += 1.5;
			}
			
			rider.UpdateLookAtVariables(1.0, targetPos);
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		rider.SetBehaviorVariable( 'lookatOn',0.f);
	}
}

class CBTTaskHorseUpdateRiderLookatDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseUpdateRiderLookat';

	editable var useCombatTarget : bool;
	editable var useCustomTarget : bool;
	editable var boneName : name;
	
	default useCombatTarget = true;
	default boneName = 'head';
}



class CBTTaskHorseSetRiderCombatTarget extends IBehTreeTask
{
	private var wannaActivate			: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		horseComp = GetNPC().GetHorseComponent();
			
		wannaActivate = false;	
		
		if ( !horseComp )
		{
			return BTNS_Failed;
		}
		if( !horseComp.riderSharedParams )
		{
			return BTNS_Failed;
		}
		
		SetCombatTarget( horseComp.riderSharedParams.combatTarget );
		
		return BTNS_Active;
	}
	
	function IsAvailable() : bool
	{
		return isActive || wannaActivate;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		wannaActivate = true;
		
		return true;
	}
}

class CBTTaskHorseSetRiderCombatTargetDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseSetRiderCombatTarget';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'RiderCombatTargetUpdated' );
	}
}



class CBTTaskHorseHasRiderCombatTarget extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		return horseComp && horseComp.riderSharedParams && horseComp.riderSharedParams.combatTarget;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTTaskHorseHasRiderCombatTargetDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseHasRiderCombatTarget';
}



class CBTTaskHorseSendInfo extends CBTTaskSendInfo
{
	function GetTarget() : CActor
	{
		var horseComp 	: W3HorseComponent;
		horseComp = GetNPC().GetHorseComponent();
		
		if ( horseComp )
			return horseComp.riderSharedParams.combatTarget;
		else
			return NULL;
	}
	
	function GetSender() : CActor
	{
		var horseComp 	: W3HorseComponent;
		horseComp = GetNPC().GetHorseComponent();
		
		if ( horseComp )
			return horseComp.riderSharedParams.rider;
		else
			return NULL;
	}
}

class CBTTaskHorseSendInfoDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseSendInfo';

	editable var onIsAvailable		: bool;
	editable var onActivate 		: bool;
	editable var onDectivate 		: bool;
	editable var infoType			: EActionInfoType;
	editable var notifyPlayerInsteadOfCombatTarget : bool;
	
	default notifyPlayerInsteadOfCombatTarget = false;
}



class CBTTaskHorseChangeAttitudeGroup extends IBehTreeTask
{	
	
	function OnActivate() : EBTNodeStatus
	{
		var horseComp 	: W3HorseComponent;
		
		horseComp = GetNPC().GetHorseComponent();
		
		if ( horseComp && horseComp.lastRider != thePlayer && horseComp.riderSharedParams.mountStatus == VMS_dismounted )
		{
			if ( horseComp.IsPotentiallyWild() )
				GetActor().SetBaseAttitudeGroup( 'animals_peacefull' );
			else
				GetActor().SetBaseAttitudeGroup( 'animals' );
		}
		
		return BTNS_Active;
	}
};


class CBTTaskHorseChangeAttitudeGroupDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseChangeAttitudeGroup';
};



class CBTTaskHorseSetCurrentPlayerInteriorAsActionTarget extends IBehTreeTask
{	
	
	function OnActivate() : EBTNodeStatus
	{
		var target : CNode;
		
		target = thePlayer.interiorTracker.GetCurrentInterior();
		
		if ( target )
			SetActionTarget(target);
		
		return BTNS_Active;
	}
};


class CBTTaskHorseSetCurrentPlayerInteriorAsActionTargetDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskHorseSetCurrentPlayerInteriorAsActionTarget';
};



class CBTCondIsHorseOnNavMesh extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if( ((CMovingPhysicalAgentComponent)((CActor)GetNPC()).GetMovingAgentComponent()).IsOnNavigableSpace() )
		{
			return true;
		}
		return false;
	}
};

class CBTCondIsHorseOnNavMeshDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsHorseOnNavMesh';
};