/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class CActionPointSelector extends IScriptable
{
};

import class CCommunityActionPointSelector extends CActionPointSelector
{
};

import struct SEncounterActionPointSelectorPair
{
	import var chance  : float;
}

import class CWanderActionPointSelector extends CActionPointSelector
{
	import var categories 					: array< SEncounterActionPointSelectorPair >;
	import var apTags 						: TagList;
	import var areaTags						: TagList;
	import var apAreaTag					: name;
	import var delay						: float;
	import var radius						: float;
	import var chooseClosestAP				: bool;
};

import class CRainActionPointSelector extends CWanderActionPointSelector
{
}

import class CSimpleActionPointSelector extends CActionPointSelector
{
	import var categories 					: array< name >;
	import var apTags 						: TagList;
	import var areaTags						: TagList;
	import var apAreaTag					: name;
	import var keepActionPointOnceSelected 	: bool;
};

import class CHorseParkingActionPointSelector extends CActionPointSelector
{
	import var radius : float;
};








class CAIPCBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\pc";
};



class CAINpcBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\npc_base";

	editable inlined var params : CAINpcDefaults;
	
	function Init()
	{
		params = new CAINpcDefaults in this;
		params.OnCreated();
	}
};


class CAINpcDefaults extends CAIDefaults
{	
	editable inlined var npcGroupType 					: CAINPCGroupTypeRedefinition;
	editable inlined var combatTree 					: CAINpcCombat;
	editable inlined var idleTree 						: CAIIdleTree;
	editable inlined var deathTree	 					: CAIDeathTree;
	editable inlined var reactionTree 					: CAINpcReactionsTree;
	editable inlined var softReactionTree 				: CAISoftReactionTree;
	
	editable var hasDrinkingMinigame 	: bool;
	editable var morphInCombat 			: bool;
	default hasDrinkingMinigame = false;
	var tempNpcGroupType : ENPCGroupType;
	
	function Init()
	{
		combatTree = new CAINpcCombat in this;
		combatTree.OnCreated();
		idleTree = new CAIIdleTree in this;
		idleTree.OnCreated();
		deathTree = new CAINpcDeath in this;
		deathTree.OnCreated();
	}
};


class CAINpcRiderBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\npc_rider_base";
	
	editable inlined var params : CAINpcRiderDefaults;
	
	function Init()
	{
		params = new CAINpcRiderDefaults in this;
		params.OnCreated();
	}
};
 


class CAINpcRiderDefaults extends CAIDefaults
{	
	editable inlined var npcGroupType 		: CAINPCGroupTypeRedefinition;
	editable inlined var combatTree 		: CAINpcCombat;		  
	editable inlined var riderCombatTree 	: CAINpcRiderCombat;  
	editable inlined var idleTree 			: CAIIdleTree;
	editable inlined var riderIdleTree 		: CAINpcIdleHorseRider;
	editable inlined var deathTree	 		: CAIDeathTree;
	editable inlined var reactionTree 		: CAINpcReactionsTree;
	editable inlined var softReactionTree 	: CAISoftReactionTree;

	editable var hasDrinkingMinigame 		: bool;
	default hasDrinkingMinigame = false;
	
	function Init()
	{
		var stdStyle : CAINpcCombatStyle;
		
		combatTree = new CAINpcCombat in this;
		combatTree.OnCreated();
		riderCombatTree = new CAINpcRiderCombat in this;
		riderCombatTree.OnCreated();
		
		
		
		
		deathTree = new CAINpcDeath in this;
		deathTree.OnCreated();
		
		
		
		
	}
};





class CAINpcRiderCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\combat/npc_rider_combat";

	editable inlined var params : CAINpcRiderCombatParams;
	
	function Init()
	{
		params = new CAINpcRiderCombatParams in this;
		params.Init();
	}
}


class CAINpcRiderCombatParams extends CAICombatParameters
{
	editable var reachabilityTolerance : float;
	
	default reachabilityTolerance = 2.0f;

	function Init()
	{
		
	}
}



class CAICombatDecoratorCommunity extends CAICombatDecoratorTree
{
	default aiTreeName = "resdef:ai\npc_guard_encounter_combat";
};



class CAICombatDecoratorGeneric extends CAICombatDecoratorTree
{
	default aiTreeName = "resdef:ai\npc_guard_encounter_combat";
};




class CAIRiderCombatDecoratorSimple extends CAICombatDecoratorTree
{
	default aiTreeName = "resdef:ai\npc_rider_simple_combat";
};



class CAIRiderCombatDecoratorGeneric extends CAICombatDecoratorGeneric 
{
	default aiTreeName = "resdef:ai\npc_rider_guard_encounter_combat";
};




abstract class CAINpcIdle extends CAIIdleTree
{
	editable inlined var params : CAINpcIdleParams;
	
	function Init()
	{
		params = new CAINpcIdleParams in this;
		params.OnCreated();
	}
};

class CAINpcIdleParams extends CAIIdleParameters
{

};



abstract class CAIRiderIdle extends CAINpcIdle
{
	function Init()
	{
		params = new CAIRiderIdleParams in this;
		params.OnCreated();
	}
};


class CAIRiderIdleParams extends CAINpcIdleParams
{

};



class CAINpcActiveIdle extends CAIIdleTree
{
	default aiTreeName = "resdef:ai\idle/npc_active_idle";

	editable inlined var params : CAINpcActiveIdleParams;
	editable var delayWorkOnFailure				: float;
	editable var delayWorkOnSuccess				: float;
	editable var delayWorkOnInterruption		: float;
	default delayWorkOnFailure					= 10.0;
	default delayWorkOnSuccess					= 10.0;
	default delayWorkOnInterruption				= 1.0;
	
	function Init()
	{
		params = new CAINpcActiveIdleParams in this;
		params.OnCreated();
	}
};

class CAINpcActiveIdleParams extends CAIIdleParameters
{
	editable inlined var wanderTree 		: CAIWanderTree;
	editable inlined var workTree 			: CAINpcWork;
	function Init()
	{
		super.Init();
		wanderTree 			= new CAIWanderWithHistory in this;
		workTree			= new CAINpcWork in this;
		wanderTree.OnCreated();
		workTree.OnCreated();
		workTree.InitWander();
	}
};


class CAIWanderWithHistory extends CAIWanderTree
{
	default aiTreeName = "resdef:ai\idle/npc_wander_history";

	editable inlined var params : CAINpcHistoryWanderParams;
	
	
	
	
	
	
	
	
	
	function Init()
	{
		params = new CAINpcHistoryWanderParams in this;
		params.OnCreated();
	}
};

class CAINpcWanderParams extends CAIWanderParameters
{
};


class CAINpcTaggedWanderParams extends CAINpcWanderParams
{
	editable var wanderPointsGroupTag : CName;
};


class CAINpcHistoryWanderParams extends CAINpcTaggedWanderParams
{
	editable var rightSideMovement : bool;

	default rightSideMovement = true;
};


class CAIWanderRandom extends CAIWanderTree
{
	default aiTreeName = "resdef:ai\idle/npc_wander_random";

	editable inlined var params : CAINpcRandomWanderParams;
	
	function Init()
	{
		params = new CAINpcRandomWanderParams in this;
		params.OnCreated();
	}
};

class CAINpcRandomWanderParams extends CAINpcTaggedWanderParams
{
};



class CAILeadPackWander extends CAIDynamicWander
{
	public editable var leaderRegroupEvent	: name;
	public editable var followers			: int;
	public editable var canWanderRun		: bool;
	public editable var chanceToRun			: float;
	
	default leaderRegroupEvent 	= 'LeaderMoves';
	default followers 			= -1;
	default aiTreeName 			= "resdef:ai\idle/lead_pack_wandering";
	

	function Init()
	{
		super.Init();
	}
};



class CAIDynamicWander extends CAIWanderTree
{
	default aiTreeName = "resdef:ai\idle/dynamic_wander";

	var params : CAIDynamicWanderParams;
	
	editable var dynamicWanderArea 				: EntityHandle;
	editable var dynamicWanderUseGuardArea		: Bool;
	editable var dynamicWanderIdleDuration 		: Float;
	editable var dynamicWanderIdleChance 		: Float;
	editable var dynamicWanderMoveDuration		: Float;
	editable var dynamicWanderMoveChance		: Float;
	editable var dynamicWanderMinimalDistance 	: float;
	
	
	default dynamicWanderUseGuardArea		= true;
	default dynamicWanderIdleDuration 		= 0.0;
	default dynamicWanderIdleChance 		= 1.0;
	default dynamicWanderMoveDuration		= 60.0;
	default dynamicWanderMoveChance			= 1.0;
	default dynamicWanderMinimalDistance 	= 0;
	
	function OnPostLoad() : bool
	{
		if ( params )
		{
			dynamicWanderArea = params.dynamicWanderArea;
			dynamicWanderIdleDuration = params.dynamicWanderIdleDuration;
			dynamicWanderIdleChance = params.dynamicWanderIdleChance;
			dynamicWanderMoveDuration = params.dynamicWanderMoveDuration;
			dynamicWanderMoveChance	= params.dynamicWanderMoveChance;
			
			params = NULL;
			
			return true;
		}
		return false;
	}
}

class CAIDynamicWanderParams extends CAINpcWanderParams
{
	editable var dynamicWanderArea 			: EntityHandle;
	editable var dynamicWanderIdleDuration 	: Float;
	editable var dynamicWanderIdleChance 	: Float;
	editable var dynamicWanderMoveDuration	: Float;
	editable var dynamicWanderMoveChance	: Float;
	
	default dynamicWanderIdleDuration 	= 0.0;
	default dynamicWanderIdleChance 	= 1.0;
	default dynamicWanderMoveDuration	= 60.0;
	default dynamicWanderMoveChance		= 1.0;
	function Init()
	{
		super.Init();
	}
}


class CAIAmphibiousDynamicWander extends CAIDynamicWander
{
	default aiTreeName = "resdef:ai\idle/dynamic_amphibious_wander";
}


class CAIDynamicFlyingWander extends CAISubTree
{
	default aiTreeName = "resdef:ai\idle/dynamic_flying_wander";
	
	editable var chanceToTakeOff 				: float;	
	editable var chanceToLand 					: float;	
	editable var landingGroundOffset			: float;
	editable var onSpotLanding 					: bool;	
	editable var minFlyDistance					: float;
	editable var maxFlyDistance					: float;
	editable var minHeight						: float;
	editable var maxHeight						: float;
	editable var proximityToAllowTakeOff		: float;
	editable var proximityToForceTakeOff		: float;
	editable var distanceFromPlayerToLand		: float;
	
	default chanceToTakeOff 				= 50.0;
	default chanceToLand 					= 10.0;
	default landingGroundOffset 			= 7.0;
	default minFlyDistance 					= 10;
	default maxFlyDistance 					= 60;
	default minHeight 						= 5;
	default maxHeight 						= 60;
	default proximityToAllowTakeOff			= 80;
	default proximityToForceTakeOff			= 60;
	default distanceFromPlayerToLand		= 70;
}


class CAISirenDynamicWander extends CAISubTree
{
	default aiTreeName = "resdef:ai\idle/dynamic_siren_wander";
	
	editable var chanceToTakeOff 				: float;	
	editable var chanceToLand 					: float;
	editable var chanceToDive 					: float;
	editable var minFlyDistance					: float;
	editable var maxFlyDistance					: float;
	editable var minHeight						: float;
	editable var maxHeight						: float;
	editable var proximityToAllowTakeOff		: float;
	editable var proximityToForceTakeOff		: float;
	editable var distanceFromPlayerToLand		: float;
	
	default chanceToTakeOff 			= 20.0;
	default chanceToLand 				= 10.0;
	default chanceToDive 				= 10.0;
	default minFlyDistance 				= 10;
	default maxFlyDistance 				= 60;
	default minHeight 					= 5;
	default maxHeight 					= 60;
	default proximityToAllowTakeOff		= 80;
	default proximityToForceTakeOff		= 70;
	default distanceFromPlayerToLand	= 70;
}


class CAIFollowPartyMemeberTree extends CAIIdleTree
{
	default aiTreeName = "resdef:ai\idle/npc_walk_side_by_side_party";
	
	editable var followPartyMember : name;
	editable var followDistance : float;
	editable var moveType : EMoveType;
	
	default followDistance = 2.0;
	default moveType = MT_Walk;
}




class CAIFollowPartyMemberSideBySideTree extends CAIFollowPartyMemeberTree
{
	editable var useCustomSteeringGraph : bool;
	editable var customSteeringGraph : CMoveSteeringBehavior;
	
	function Init()
	{
		super.Init();
		
		useCustomSteeringGraph = true;
		customSteeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/follow_side_by_side.w2steer" );
		followDistance = 0.0;
		moveType = MT_Run;
	}

};




class CAIPatrol extends CAIWanderTree
{
	default aiTreeName = "resdef:ai\idle/npc_patrol";
};



class CAINpcWork extends CAISubTree
{
	default aiTreeName = "resdef:ai\idle/npc_work";
	
	editable inlined var actionPointSelector 	: CActionPointSelector;
	editable var spawnToWork					: bool;

	
	var params : CAINpcWorkParams;
	function Init()
	{
		spawnToWork = true;
		actionPointSelector = new CSimpleActionPointSelector in this;
	}
	function InitWander()
	{
		spawnToWork = true;
		actionPointSelector = new CWanderActionPointSelector in this;
	}
};

class CAINpcWorkParams extends CAISubTreeParameters
{
	editable inlined var actionPointSelector 	: CActionPointSelector;
	editable var spawnToWork					: bool;
}


class CAINpcWorkIdle extends CAIIdleTree
{
	default aiTreeName = "resdef:ai\idle/npc_work_idle";
	
	editable inlined var actionPointSelector 	: CActionPointSelector;
	editable var actionPointMoveType			: EMoveType;
	
	default actionPointMoveType = MT_Walk;

	var params : CAINpcWorkIdleParams;

	function Init()
	{
		var selector : CSimpleActionPointSelector = new CSimpleActionPointSelector in this;
		actionPointSelector = selector;
	}
};

class CAINpcWorkIdleParams extends CAIIdleParameters
{
	editable inlined var actionPointSelector 	: CActionPointSelector;
	editable var actionPointMoveType			: EMoveType;
	
	default actionPointMoveType = MT_Walk;
}


class CAINpcBoxCarry extends CAINpcIdle
{
	default aiTreeName = "resdef:ai\idle\custom\npc_idle_box";

	function Init()
	{
		params = new CAINpcBoxCarryParams in this;
		params.OnCreated();
	}
};

class CAINpcBoxCarryParams extends CAINpcIdleParams
{
	editable var workCarryItemTemplate : CEntityTemplate;
	editable var workCarryPickupPoint : name;
	editable var workCarryDropPoint : name;
};


abstract class IAIIdleFormationTree extends CAIIdleTree
{
	editable var formation : CFormation;
};


class CAIFollowLeaderTree extends IAIIdleFormationTree
{
	default aiTreeName 								= "resdef:ai\idle/follow_leader";

	editable var leaderName 						: name;
	
	editable var disableGestures 					: bool;
	editable var removePlayedAnimationFromPool		: bool;
	editable var gossipGesturesOnly 				: bool;
	editable var cooldownBetweenGesture 			: float;
	editable var chanceToPlayGesture 				: float;
	editable var dontActivateGestureWhenNotTalking 	: bool;
	editable var onlyOneActorGesticulatingAtATime 	: bool;
	editable var stopGestureOnDeactivate 			: bool;
	editable var dontOverrideRightHand 				: bool;
	editable var dontOverrideLeftHand 				: bool;
	
	default disableGestures 						= true;
	default removePlayedAnimationFromPool 			= true;
	default cooldownBetweenGesture 					= 2.0f;
	default chanceToPlayGesture 					= 1.0f;
	default stopGestureOnDeactivate 				= true;
	default onlyOneActorGesticulatingAtATime 		= true;
	
	hint removePlayedAnimationFromPool = "prevents repeating of the same animations in row";
	hint gossipGesturesOnly = "plays simple, short animations";
	hint stopGestureOnDeactivate = "stops gesture animation on deactivation of ai tree";
};

class CAIFollowLeaderParameters extends CAIIdleParameters
{
	editable var leaderName 						: name;
	editable var formation 							: CFormation;
};


class CAILeadFormationTree extends IAIIdleFormationTree
{
	default aiTreeName = "resdef:ai\idle/formation_lead";
	
	editable var leadFormationSteeringGraph : CMoveSteeringBehavior;
	editable inlined var leadSubtree : CAIIdleTree;
	
	function Init()
	{
		super.Init();
	
		leadFormationSteeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/formation/steering_leader/leader_default.w2steer" );
	}
};

class CAIIdleSpontanousFormationTree extends IAIIdleFormationTree
{
	default aiTreeName = "resdef:ai\idle/formation_spontaneous";

	editable var partyMemberName : name;
	editable var leaderSteering : CMoveSteeringBehavior;
	editable inlined var leadFormationTree : CAIIdleTree;
	editable inlined var loneWolfTree : CAIIdleTree;
	
	function Init()
	{
		super.Init();
		
		leaderSteering = LoadSteeringGraph( "gameplay/behaviors/npc/formation/steering_leader/leader_default.w2steer" );
	}
};






class CAINpcIdleHorseRider extends CAIRiderIdle
{
	default aiTreeName = "resdef:ai\idle/npc_idle_horserider";
	
	function Init()
	{
		params = new CAINpcIdleHorseRiderParams in this;
		params.OnCreated();
	}
};

class CAINpcIdleHorseRiderParams extends CAIRiderIdleParams
{
};



class CAINpcDeath extends CAIDeathTree
{
	default aiTreeName = "resdef:ai\death/death";

	editable inlined var params : CAINpcDeathParams;
	
	function Init()
	{
		params = new CAINpcDeathParams in this;
		params.OnCreated();
	}
};

class CAINpcDeathParams extends CAIDeathParameters
{
	editable var createReactionEvent			: name;
	editable var fxName 						: name;
	editable var playFXOnActivate				: name;
	editable var playFXOnDeactivate				: name;
	editable var stopFXOnActivate				: name;
	editable var stopFXOnDeactivate				: name;
	editable var playSFXOnActivate 				: name;
	editable var setAppearanceTo 				: name;
	editable var changeAppearanceAfter 			: float;
	editable var disableAgony 					: bool;
	editable var disableCollision				: bool;
	editable var disableCollisionDelay			: float;
	editable var disableCollisionOnAnim			: bool;
	editable var disableCollisionOnAnimDelay	: float;
	editable var destroyAfterAnimDelay 			: float;
	editable var disableRagdollAfter 			: float;
	
	default destroyAfterAnimDelay 		= -1;
	default createReactionEvent			= 'NPCDeath';
	default fxName 						= 'death';
	default setAppearanceTo 			= '';
	default changeAppearanceAfter 		= 0;
	default disableAgony 				= false;
	default disableCollision			= true;
	default disableCollisionDelay		= 1.0;
	default disableCollisionOnAnim		= true;
	default disableCollisionOnAnimDelay = 0.5;
};


class CAINpcBruxaDeathParams extends CAINpcDeathParams
{
	editable var spawnEntityOnDeathName : name;
};




class CAINpcUnconsciousTree extends CAIDeathTree
{
	default aiTreeName = "resdef:ai\death/unconscious";

	editable inlined var params : CAINpcUnconsciousParams;
	function Init()
	{
		params = new CAINpcUnconsciousParams in this;
		params.OnCreated();
	}
};

class CAINpcUnconsciousParams extends CAIDeathParameters
{
	editable var unconsciousDuration : float;
	editable var unconsciousGetUpDist : float;
	
	default unconsciousDuration = 20.0;
	default unconsciousGetUpDist = 30.0;
};



class CAIDefeated extends CAIDeathTree
{
	default aiTreeName = "resdef:ai\death/defeated";

	editable inlined var params 			: CAIDefeatedParams;
	function Init()
	{
		params = new CAIDefeatedParams in this;
		params.OnCreated();
	}
};

class CAIDefeatedParams extends CAIDeathParameters
{
	editable inlined var localDeathTree 	: CAIDeathTree;
	editable inlined var unconsciousTree 	: CAINpcUnconsciousTree;	
	function Init()
	{
		localDeathTree = new CAINpcDeath in this;
		localDeathTree.OnCreated();
		unconsciousTree = new CAINpcUnconsciousTree in this;
		unconsciousTree.OnCreated();
	}
};



class CAIBruxaNpcDeath extends CAIDeathTree
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\death_bruxa_spawn.w2behtree";

	editable inlined var params : CAINpcBruxaDeathParams;
	
	function Init()
	{
		params = new CAINpcBruxaDeathParams in this;
		params.OnCreated();
	}
};







class CAINpcStyleHjalmarParams extends CAINpcStyleOneHandedSwordParams
{
};


class CAINpcStyleMountedParams extends CAINpcCombatStyleParams
{
};





class CAINpcCriticalState extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\npc_critical_state";

	editable inlined var params : CAINpcCriticalStateParams;
	
	function Init()
	{
		params = new CAINpcCriticalStateParams in this;
		params.OnCreated();
	}
};

class CAINpcCriticalStateParams extends CAICombatActionParameters
{
	editable var FinisherAnim : name;
};


class CAINpcCriticalStateFlying extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\npc_critical_state_flying";

	editable inlined var params : CAINpcCriticalStateParams;
	
	function Init()
	{
		params = new CAINpcCriticalStateParams in this;
		params.OnCreated();
	}
};





class CAIMountHorse extends CAIRidingSubTree
{
	default aiTreeName = "resdef:ai\horse_riding/mount_horse";
};



class CAIDismountHorse extends CAIRidingSubTree
{
	default aiTreeName = "resdef:ai\horse_riding/dismount_horse";
};






class CAIGenericFlee extends CAIFleeTree
{
	default aiTreeName = "resdef:ai\reactions\generic_flee";
};




class CGoatDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 30.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}



class CCatDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 5.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}



class CRoosterDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 5.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}

class CRamDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 20.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}



class CGooseDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 5.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}



class CSheepDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 10.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 2.0;
		dynamicWanderMoveChance 	= 0.2;
		wanderMoveType				= MT_Walk;
	}
}



class CPigDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 10.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 4.0;
		dynamicWanderMoveChance 	= 0.2;
		wanderMoveType				= MT_Walk;

	}
}



class CCowDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 60.0;
		dynamicWanderIdleChance 	= 1.0;
		dynamicWanderMoveDuration 	= 3.0;
		dynamicWanderMoveChance 	= 1.0;
		wanderMoveType				= MT_Walk;
	}
}



class CDogDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 10.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}



class CDeerDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 10.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;

	}
}




class CHareDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 5.0;
		dynamicWanderIdleChance 	= 0.5;
		dynamicWanderMoveDuration 	= 5.0;
		dynamicWanderMoveChance 	= 0.5;
		wanderMoveType				= MT_Walk;
	}
}


class CTamedHorseDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		wanderMoveType				= MT_Walk;
	}
}


class CWildHorseDynamicWander extends CAIDynamicWander
{	
	function Init()
	{
		super.Init();
		dynamicWanderIdleDuration 	= 4.0;
		dynamicWanderIdleChance 	= 0.25;
		wanderMoveType				= MT_Run;

	}
}
