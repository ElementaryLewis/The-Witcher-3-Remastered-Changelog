/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class IBehTreeRiderTaskDefinition extends IBehTreeTaskDefinition
{
};

abstract class IBehTreeRiderConditionalTaskDefinition extends IBehTreeConditionalTaskDefinition
{

};


class CBTCondMyHorseIsMounted extends IBehTreeTask
{	
	var waitForMountEnd 		: Bool;
	var waitForDismountEnd 		: Bool;
	var riderData 				: CAIStorageRiderData;
	var returnTrueWhenNoHorse	: Bool;
	
	function IsAvailable() : bool
	{
		if ( !riderData || !riderData.sharedParams || !riderData.sharedParams.GetHorse() )
		{
			if ( returnTrueWhenNoHorse )
				return true;
			else
				return false;
		}
		
		switch( riderData.sharedParams.mountStatus )
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
		if ( eventName == 'HorseMountStart' )
		{
			return true;
		}
		else if ( eventName == 'HorseMountEnd' )
		{
			return true;
		}
		else if ( eventName == 'HorseDismountStart' )
		{
			return true;
		}
		else if ( eventName == 'HorsedismountEnd' )
		{
			return true;
		}
		return false;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondMyHorseIsMountedDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondMyHorseIsMounted';

	editable var waitForMountEnd 	: Bool;
	editable var waitForDismountEnd : Bool;
	editable var returnTrueWhenNoHorse : Bool;
	default waitForMountEnd 		= false;
	default waitForDismountEnd		= true;
	default returnTrueWhenNoHorse	= false;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseMountStart' );
		listenToGameplayEvents.PushBack( 'HorseMountEnd' );
		listenToGameplayEvents.PushBack( 'HorseDismountStart' );
		listenToGameplayEvents.PushBack( 'HorsedismountEnd' );
	}
};



class CBTCondRiderHasPairedHorse extends IBehTreeTask
{	
	var riderData 	: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		if ( riderData.sharedParams.GetHorse() )
		{
			return true;
		}
		return false;
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'HorseLost' )
		{
			return true;
		}
		return false;
	}
};


class CBTCondRiderHasPairedHorseDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderHasPairedHorse';

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HorseLost' );
	}
};





class CBTCondRiderFightOnHorse extends IBehTreeTask
{	
	var riderData 	: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		
		if ( riderData.sharedParams.mountStatus == VMS_mountInProgress || riderData.sharedParams.mountStatus == VMS_mounted )
		{
			return true;
		}
		
		return false;
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondRiderFightOnHorseDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderFightOnHorse';
};



class CBTCondIsTargetMounted extends IBehTreeTask
{		
	var useCombatTarget : bool;
	function IsAvailable() : bool
	{
		var target 		: CEntity;
		var targetActor : CActor;
		var vehicleComp	: W3HorseComponent;
		if ( useCombatTarget )
		{
			target = (CEntity)GetCombatTarget();
		}
		else
		{
			target = (CEntity)GetActionTarget();
		}
		
		targetActor = ((CActor)target);
		if (  target && targetActor && targetActor.GetUsedVehicle() )
		{
			vehicleComp = targetActor.GetUsedHorseComponent();
			if ( vehicleComp.riderSharedParams.mountStatus != VMS_dismounted )
			{
				return true;
			}
		}
		return false;
	}
}


class CBTCondIsTargetMountedDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsTargetMounted';
	editable var useCombatTarget : bool;
	default useCombatTarget = false;
};



class CBTCondRiderDistanceToHorse extends IBehTreeTask
{	
	var riderData 		: CAIStorageRiderData;
	var minDistance 			: float;
	var maxDistance 			: float;
	function IsAvailable() : bool
	{
		return Check();
	}
	function OnActivate() : EBTNodeStatus
	{
		if ( Check() )
		{
			return BTNS_Active;
		}
		else
		{
			return BTNS_Failed;
		}
	}
	function Check() : bool
	{
		var squaredDistance : float;
		
		if ( !riderData || !riderData.sharedParams.GetHorse() )
		{
			return false;
		}
		squaredDistance = VecDistanceSquared( riderData.sharedParams.GetHorse().GetWorldPosition(), GetActor().GetWorldPosition() );
		if( minDistance * minDistance < squaredDistance && squaredDistance < maxDistance * maxDistance )
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

class CBTCondRiderDistanceToHorseDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderDistanceToHorse';
	
	editable var minDistance : float;
	editable var maxDistance : float;
	default minDistance = 0;
	default maxDistance = 10;
}



class CBTCondRiderPlayingSyncAnim extends IBehTreeTask
{	
	var riderData 		: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		if ( riderData.sharedParams.GetHorse() )
		{
			return false;
		}
		if ( riderData.sharedParams.mountStatus == VMS_mountInProgress || riderData.sharedParams.mountStatus == VMS_dismountInProgress )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondRiderPlayingSyncAnimDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderPlayingSyncAnim';
};



class CBTCondRiderIsMountInProgress extends IBehTreeTask
{	
	var riderData 		: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		if ( riderData.sharedParams.GetHorse() )
		{
			return false;
		}

		if ( riderData.sharedParams.mountStatus == VMS_mountInProgress )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondRiderIsMountInProgressDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderIsMountInProgress';
};




class CBTCondRiderIsDismountInProgress extends IBehTreeTask
{
	private var riderData : CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		var horseComp 		: CVehicleComponent;
		
		if ( riderData.GetRidingManagerCurrentTask() == RMT_DismountHorse )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondRiderIsDismountInProgressDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderIsDismountInProgress';
};




class CBTCondRiderHasFallenFromHorse extends IBehTreeTask
{	
	var waitForMountEnd 		: Bool;
	var waitForDismountEnd 		: Bool;
	var riderData 				: CAIStorageRiderData;
	
	function IsAvailable() : bool
	{
		return riderData.sharedParams.hasFallenFromHorse;
	}
	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
};


class CBTCondRiderHasFallenFromHorseDef extends IBehTreeRiderConditionalTaskDefinition
{
	default instanceClass = 'CBTCondRiderHasFallenFromHorse';
};





class CBTTaskRiderCombatOnHorseDecorator extends IBehTreeTask
{	
	function OnActivate() : EBTNodeStatus
	{	
		return BTNS_Active;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var buffType : ECriticalStateType;
		var horseActor : CActor;
		
		if ( eventName == 'CriticalState' )
		{
			horseActor = (CActor)(GetNPC().GetUsedHorseComponent().GetEntity());
			
			if( horseActor && horseActor.HasAbility( 'DisableHorsePanic' ) )
			{
				return false;
			}
			
			buffType = this.GetEventParamInt(-1);
			
			if ( buffType == ECST_Knockdown || buffType == ECST_HeavyKnockdown || buffType == ECST_Ragdoll || buffType == ECST_Stagger || buffType == ECST_LongStagger )
			{
				if( GetActor().IsImmuneToBuff( getBuffType( buffType ) ) )
				{
					return false;
				}
				GetActor().SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_ragdoll );
			}
			else
			{
				GetActor().SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_shakeOff );
			}
			return true;
		}
		return false;
	}
	
	function getBuffType( CSType : ECriticalStateType ) : EEffectType
	{
		switch( CSType )
		{
			case ECST_Immobilize 				: return EET_Immobilized;
			case ECST_BurnCritical 				: return EET_Burning;
			case ECST_Knockdown 				: return EET_Knockdown;
			case ECST_HeavyKnockdown 			: return EET_HeavyKnockdown;
			case ECST_Blindness					: return EET_Blindness;
			case ECST_Confusion					: return EET_Confusion;
			case ECST_Paralyzed					: return EET_Paralyzed;
			case ECST_Hypnotized				: return EET_Hypnotized;
			case ECST_Stagger					: return EET_Stagger;
			case ECST_CounterStrikeHit			: return EET_CounterStrikeHit;
			case ECST_LongStagger				: return EET_LongStagger;
			case ECST_Pull						: return EET_Pull;
			case ECST_Ragdoll					: return EET_Ragdoll;
			case ECST_PoisonCritical			: return EET_PoisonCritical;
			case ECST_Frozen					: return EET_Frozen;
			case ECST_Swarm						: return EET_Swarm;
			case ECST_Snowstorm					: return EET_Snowstorm;
			case ECST_Tornado					: return EET_Tornado;
			case ECST_Trap						: return EET_Trap;
			default 							: return EET_Undefined;
		}
	}
}

class CBTTaskRiderCombatOnHorseDecoratorDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderCombatOnHorseDecorator';
}


class CBTTaskRiderMountHorse extends IBehTreeTask
{	
	var riderData 	: CAIStorageRiderData;

	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
	function OnActivate() : EBTNodeStatus
	{
		var squaredDistance : float;
		if ( !riderData.sharedParams.GetHorse() )
		{
			return BTNS_Failed;
		}
		squaredDistance = VecDistanceSquared( riderData.sharedParams.GetHorse().GetWorldPosition(), GetActor().GetWorldPosition() );
		if( squaredDistance > 5.0f * 5.0f )
		{
			return BTNS_Failed;
		}
		GetActor().SignalGameplayEvent( 'RidingManagerMountHorse' );
		return BTNS_Active;
	}
	latent function Main() : EBTNodeStatus
	{
		while ( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None )
			{
				if ( riderData.sharedParams.mountStatus == VMS_mounted )
				{
					if ( riderData.ridingManagerMountError )
					{
						return BTNS_Failed;
					}
					return BTNS_Completed;
				}
				GetActor().SignalGameplayEventParamInt( 'RidingManagerMountHorse', MT_instant | MT_fromScript );
			}
			SleepOneFrame();
		}		
		return BTNS_Completed;
	}
}

class CBTTaskRiderMountHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderMountHorse';
}



class CBTTaskRiderDismountHorse extends IBehTreeTask
{	
	var riderData 	: CAIStorageRiderData;
	var endDismountDone		: bool;
	function OnActivate() : EBTNodeStatus
	{
		GetActor().SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_normal );
		return BTNS_Active;
	}
	latent function Main() : EBTNodeStatus
	{
		while ( true )
		{
			if ( riderData.GetRidingManagerCurrentTask() == RMT_None && riderData.sharedParams.mountStatus == VMS_dismounted )
			{
				return BTNS_Completed;
			}
			
			SleepOneFrame();
		}
		return BTNS_Completed;
	}

	function Initialize()
	{		
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderDismountHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderDismountHorse';
}



class CBTTaskRiderWaitForDismount extends IBehTreeTask
{
	private var rider 			: CActor;	
	private var actionResult 	: bool;
	private var activate 		: bool;
	default actionResult 		= false;
	default activate 			= false;
	
	function IsAvailable() : bool
	{
		if ( activate && rider )
			return true;
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		GetActor().ActionCancelAll();
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		owner.WaitForBehaviorNodeActivation('OnAnimIdleActivated', 10.0f );
		
		rider.SignalGameplayEvent('DismountReady');
		
		if ( owner.RaiseForceEvent('dismount') )
			owner.WaitForBehaviorNodeDeactivation('dismountEnd', 10.0f );
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		activate = false;
		rider = NULL;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'WaitForDismount' )
		{
			activate = true;
			rider = (CActor)GetEventParamObject();
			return true;
		}
		return false;
	}
	
}

class CBTTaskRiderWaitForDismountDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderWaitForDismount';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'WaitForDismount' );
	}
}



class CBTTaskRiderSetFollowActionOnHorse extends IBehTreeTask
{
	var horseFollowAction				: CAIFollowAction;
	var riderData 		: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseFollowAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetFollowActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetFollowActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderFollowActionParams;
		var task 		: CBTTaskRiderSetFollowActionOnHorse;
		task = (CBTTaskRiderSetFollowActionOnHorse) taskGen;
		task.horseFollowAction 									= new CAIFollowAction in this;
		task.horseFollowAction.OnCreated();
		myParams = (CAIRiderFollowActionParams)GetAIParametersByClassName( 'CAIRiderFollowActionParams' );
		myParams.CopyTo( task.horseFollowAction.params );
		task.horseFollowAction.OnManualRuntimeCreation();
	}
}




class CBTTaskRiderSetFollowSideBySideActionOnHorse extends IBehTreeTask
{
	var horseFollowSideBySideAction		: CAIFollowSideBySideAction;
	var riderData 		: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseFollowSideBySideAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetFollowSideBySideActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetFollowSideBySideActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderFollowSideBySideActionParams;
		var task 		: CBTTaskRiderSetFollowSideBySideActionOnHorse;
		task = (CBTTaskRiderSetFollowSideBySideActionOnHorse) taskGen;

		
		task.horseFollowSideBySideAction 								= new CAIFollowSideBySideAction in this;
		task.horseFollowSideBySideAction.OnCreated();
		
		myParams = (CAIRiderFollowSideBySideActionParams)GetAIParametersByClassName( 'CAIRiderFollowSideBySideActionParams' );
		myParams.CopyTo_SideBySide( task.horseFollowSideBySideAction );
		task.horseFollowSideBySideAction.OnManualRuntimeCreation();
	}
}



class CBTTaskRiderSetDoNothingActionOnHorse extends IBehTreeTask
{
	var horseDoNothingAction			: CAIHorseDoNothingAction;
	var riderData 						: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseDoNothingAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetDoNothingActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetDoNothingActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderRideHorseAction;
		var task 		: CBTTaskRiderSetDoNothingActionOnHorse;
		task = (CBTTaskRiderSetDoNothingActionOnHorse) taskGen;
		task.horseDoNothingAction 									= new CAIHorseDoNothingAction in this;
		task.horseDoNothingAction.OnCreated();
		myParams = (CAIRiderRideHorseAction)GetAIParametersByClassName( 'CAIRiderRideHorseAction' );
		myParams.CopyTo( task.horseDoNothingAction );
		task.horseDoNothingAction.OnManualRuntimeCreation();
	}
}




class CBTTaskRiderSetMoveToActionOnHorse extends IBehTreeTask
{
	var horseMoveToAction				: CAIMoveToAction;
	var riderData 						: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseMoveToAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetMoveToActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetMoveToActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderMoveToActionParams;
		var task 		: CBTTaskRiderSetMoveToActionOnHorse;
		task = (CBTTaskRiderSetMoveToActionOnHorse) taskGen;
		task.horseMoveToAction 									= new CAIMoveToAction in this;
		task.horseMoveToAction.OnCreated();
		myParams = (CAIRiderMoveToActionParams)GetAIParametersByClassName( 'CAIRiderMoveToActionParams' );
		myParams.CopyTo( task.horseMoveToAction.params );
		task.horseMoveToAction.OnManualRuntimeCreation();
	}
}




class CBTTaskRiderSetMoveAlongPathActionOnHorse extends IBehTreeTask
{
	var horseMoveAlongPathAction		: CAIMoveAlongPathAction;
	var riderData 						: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseMoveAlongPathAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetMoveAlongPathActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetMoveAlongPathActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderMoveAlongPathActionParams;
		var task 		: CBTTaskRiderSetMoveAlongPathActionOnHorse;
		task = (CBTTaskRiderSetMoveAlongPathActionOnHorse) taskGen;
		task.horseMoveAlongPathAction 									= new CAIMoveAlongPathAction in this;
		task.horseMoveAlongPathAction.OnCreated();
		myParams = (CAIRiderMoveAlongPathActionParams)GetAIParametersByClassName( 'CAIRiderMoveAlongPathActionParams' );
		myParams.CopyTo( task.horseMoveAlongPathAction.params );
		task.horseMoveAlongPathAction.OnManualRuntimeCreation();
	}
}




class CBTTaskRiderSetMoveAlongPathWithCompanionActionOnHorse extends IBehTreeTask
{
	var horseMoveAlongPathAction		: CAIMoveAlongPathWithCompanionAction;
	var riderData 		: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseMoveAlongPathAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetMoveAlongPathWithCompanionActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetMoveAlongPathWithCompanionActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderMoveAlongPathWithCompanionActionParams;
		var task 		: CBTTaskRiderSetMoveAlongPathWithCompanionActionOnHorse;
		task = (CBTTaskRiderSetMoveAlongPathWithCompanionActionOnHorse) taskGen;
		task.horseMoveAlongPathAction 												= new CAIMoveAlongPathWithCompanionAction in this;
		task.horseMoveAlongPathAction.OnCreated();
		myParams = (CAIRiderMoveAlongPathWithCompanionActionParams)GetAIParametersByClassName( 'CAIRiderMoveAlongPathWithCompanionActionParams' );
		myParams.CopyTo_2( (CAIMoveAlongPathWithCompanionParams)task.horseMoveAlongPathAction.params );
		task.horseMoveAlongPathAction.OnManualRuntimeCreation();
	}
}




class CBTTaskRiderSetRaceAlongPathActionOnHorse extends IBehTreeTask
{
	var horseRaceAlongPathAction		: CAIRaceAlongPathAction;
	var riderData 		: CAIStorageRiderData;
	function OnActivate() : EBTNodeStatus
	{
		riderData.horseScriptedActionTree = horseRaceAlongPathAction;
		
		return BTNS_Active;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderSetRaceAlongPathActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetRaceAlongPathActionOnHorse';

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var myParams 	: CAIRiderRaceAlongPathActionParams;
		var task 		: CBTTaskRiderSetRaceAlongPathActionOnHorse;
		task = (CBTTaskRiderSetRaceAlongPathActionOnHorse) taskGen;
		task.horseRaceAlongPathAction 	= new CAIRaceAlongPathAction in this;
		task.horseRaceAlongPathAction.OnCreated();
		myParams = (CAIRiderRaceAlongPathActionParams)GetAIParametersByClassName( 'CAIRiderRaceAlongPathActionParams' );
		myParams.CopyTo( (CAIRaceAlongPathParams)task.horseRaceAlongPathAction.params );
		task.horseRaceAlongPathAction.OnManualRuntimeCreation();
	}
}


class CBTTaskRiderAdjustToHorse extends IBehTreeTask
{
	var riderData 		: CAIStorageRiderData;
	var ticket 			: SMovementAdjustmentRequestTicket;
	latent function Main() : EBTNodeStatus
	{
		var actor 				: CActor = GetActor();
		var movementAdjustor 	: CMovementAdjustor;
		var dir 				: Vector;
		var targetYaw, time		: float;
		var squaredDistance		: float;
		var angle 				: EulerAngles;
		movementAdjustor 		= actor.GetMovingAgentComponent().GetMovementAdjustor();
		if ( !riderData.sharedParams.GetHorse() )
		{
			return BTNS_Failed;
		}
		
		
		squaredDistance = VecDistanceSquared( riderData.sharedParams.GetHorse().GetWorldPosition(), GetActor().GetWorldPosition() );
		if( squaredDistance > 5.0f * 5.0f )
		{
			return BTNS_Failed;
		}
		
		
		dir			= riderData.sharedParams.GetHorse().GetWorldPosition() - actor.GetWorldPosition();
		angle		= VecToRotation( dir );
		targetYaw 	= angle.Yaw;
		time		= 0.5f;
		
		ticket 				= movementAdjustor.CreateNewRequest( 'AdjustToHorse' );
		movementAdjustor.AdjustmentDuration( ticket, time );
		movementAdjustor.RotateTo( ticket, targetYaw );
		Sleep( time );
		
		return BTNS_Completed;
	}
	function OnDeactivate()
	{
		var actor 				: CActor = GetActor();
		var movementAdjustor 	: CMovementAdjustor;
		movementAdjustor 		= actor.GetMovingAgentComponent().GetMovementAdjustor();
		movementAdjustor.Cancel( ticket );
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
	
};

class CBTTaskRiderAdjustToHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderAdjustToHorse';
};




class CBTTaskRiderNotifyScriptedActionOnHorse extends IBehTreeTask
{
	var riderData 		: CAIStorageRiderData;
	
	function OnActivate() : EBTNodeStatus
	{
		riderData.sharedParams.scriptedActionPending = true;
		
		return BTNS_Active;
	}
	function OnDeactivate()
	{
		riderData.sharedParams.scriptedActionPending = false;
	}
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderNotifyScriptedActionOnHorseDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderNotifyScriptedActionOnHorse';
}



class CBTTaskRiderNotifyHorseAboutCombatTarget extends IBehTreeTask
{
	var riderData 		: CAIStorageRiderData;
	
	function OnDeactivate()
	{
		riderData.sharedParams.combatTarget = GetCombatTarget();
		riderData.sharedParams.GetHorse().SignalGameplayEvent('RiderCombatTargetUpdated');
	}
	
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderNotifyHorseAboutCombatTargetDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderNotifyHorseAboutCombatTarget';
}



class CBTTaskRiderNotifyHorseAboutMounting extends IBehTreeTask
{
	var riderData 				: CAIStorageRiderData;
	var horseComp				: W3HorseComponent;
	
	function OnActivate() : EBTNodeStatus
	{
		horseComp = ((CNewNPC)riderData.sharedParams.GetHorse()).GetHorseComponent();
		
		horseComp.OnRiderWantsToMount();
		
		return BTNS_Active;
	}
	
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderNotifyHorseAboutMountingDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderNotifyHorseAboutMounting';
}



class CBTTaskRiderSetCanBeFollowed extends IBehTreeTask
{
	var setCanBeFollowed : bool;
	var horse : CNewNPC;
	
	function OnActivate() : EBTNodeStatus
	{
		if( setCanBeFollowed )
		{
			horse = (CNewNPC)GetActor().GetUsedVehicle();
			if( horse )
			{
				horse.SetCanBeFollowed( true );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( setCanBeFollowed )
		{
			if( horse )
			{
				horse.SetCanBeFollowed( false );
				thePlayer.SignalGameplayEvent( 'StopPlayerAction' );
				thePlayer.GetUsedHorseComponent().SetManualControl( true );
				thePlayer.GetUsedHorseComponent().SetCanFollowNpc( false, NULL );
			}
		}
	}

}

class CBTTaskRiderSetCanBeFollowedDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderSetCanBeFollowed';

	editable var setCanBeFollowed : CBehTreeValBool;
	default setCanBeFollowed =  false;
}



class CBTTaskRiderStopAttack extends IBehTreeTask
{
	var riderData : CAIStorageRiderData;
	private var horse : CNewNPC;
	
	
	function OnActivate() : EBTNodeStatus
	{
		horse = (CNewNPC)riderData.sharedParams.GetHorse();
		horse.SignalGameplayEvent( 'StopAttackOnHorse' );
		GetNPC().SetIsInHitAnim( true );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetIsInHitAnim( false );
	}
	
	function Initialize()
	{
		riderData = (CAIStorageRiderData)RequestStorageItem( 'RiderData', 'CAIStorageRiderData' );
	}
}

class CBTTaskRiderStopAttackDef extends IBehTreeRiderTaskDefinition
{
	default instanceClass = 'CBTTaskRiderStopAttack';
}