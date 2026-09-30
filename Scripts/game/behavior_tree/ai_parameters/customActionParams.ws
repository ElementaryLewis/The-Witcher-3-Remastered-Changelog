/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class IAICustomActionTree extends IAIActionTree
{
}

class CAICarryMiscreantActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/custom/custom_action_carry_miscreant";

	editable var attachmentBone		: name;		default	attachmentBone	= 'r_weapon';
	editable var miscreantName		: name;		default	miscreantName	= 'Miscreant';
	editable var behaviorGraph		: name;		default	behaviorGraph	= 'Miscreant';
	editable var cryStartEventName	: name;
	editable var cryStopEventName	: name;
	editable inlined var carrySubAction : IAIActionTree;
};


class CAIMiscreantAttachActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/custom/custom_action_miscreant_attach";

	var attachmentBone		: name;		default	attachmentBone	= 'r_weapon';
	var miscreantName		: name;		default	miscreantName	= 'Miscreant';
	var behaviorGraph		: name;		default	behaviorGraph	= 'Miscreant';
};


class CAIMiscreantCryActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/custom/custom_action_miscreant_cry";

	var miscreantName		: name;		default	miscreantName	= 'Miscreant';
};

class CAISorceressAttacksBoidActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_sorceress_attacks_boid";

	editable var animName : name;

	default animName = 'woman_cowering01_idle03';

	
};

class CAISorceressMagicBubbleActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_sorceress_magic_bubble";

	editable var magicBubbleResourceName		: name; default magicBubbleResourceName = 'magicBubble';

	editable var deactivate : bool;
	editable var playAnim : bool;
};

class CAISorceressFireballCastActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_sorceress_fireball_cast";

	editable var targetTag			: name;
};

class CAISorceressLightningCastActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_sorceress_lightning_cast";

	editable var targetTag			: name;
};

class CAISorceressTeleportActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_sorceress_teleport";

	editable var targetTag			: name;
};

class CAIVampireTeleportActionTree extends IAICustomActionTree
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\scripted_actions\custom_action_vampire_teleport.w2behtree";

	editable var targetTag			: name;
};

class CAISwarmTeleportAttackActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_swarm_teleport_attack";

	editable var targetTag			: name;
};

class CAIFrostAttackActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_frost_attack";

	editable var targetTag							: name;
	editable var duration							: float;
	editable var clampDurationWhenTargetReached		: float;

	default clampDurationWhenTargetReached 	= 2;
};

class CAIForceJumpAttackActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_force_jump_attack";

	editable var targetTag							: name;
};

class CAIGryphonCrashActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_gryphon_crash";
};

class CAIShootActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_shoot";

	editable var targetTag							: name;
	editable inlined var multipleTargetsTags		: W3BehTreeValNameArray;
	editable var numberOfActions 					: int;			default numberOfActions = 1;
	editable var setProjectileOnFire 				: bool; 		default setProjectileOnFire = false;
	editable var afterActionIdleDuration 			: float; 		default afterActionIdleDuration = 0.01;
	editable var afterActionIdleDurationChance 		: float; 		default afterActionIdleDurationChance = 1.01;
	editable var useRayCastBeforeShooting 			: bool; 		default useRayCastBeforeShooting = true;

	hint multipleTargetsTags = "if any name is in array it will randomly select one and treat it as targetTag";
	hint numberOfActions = "for BOW numberOfActions = numberOfShots; for XBOW numberOfAction = numberOfShots*2 -1;";
	hint afterActionIdleDurationChance = "range form 0 to 1; chance to end idle after duration time expires";

	function Init()
	{
		super.Init();
		multipleTargetsTags = new W3BehTreeValNameArray in this;
	}
};


class CAILambertTrainingActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_lambert_training";

	editable var holdPositionTag 					: name;
	editable var maxDistanceToHoldGroundPosition 	: float;

	function Init()
	{
		super.Init();
		maxDistanceToHoldGroundPosition = 2;
	}
};


class CAICiriSnowballFightActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_ciri_snowball_fight";

	editable var minDistFromTargetToPerformTeleport : float;
	editable var delayBetweenThrows : float;
	editable var teleportPointTag : name;

	default minDistFromTargetToPerformTeleport = 10.0f;
	default delayBetweenThrows = 1.0f;

	function Init()
	{
		super.Init();
	}
};



class CAIMageBossFightActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions\custom\custom_action_wh_mage_bossfight";

	editable var minDistFromTargetToPerformTeleport : float;

	default minDistFromTargetToPerformTeleport = 10.0f;

	function Init()
	{
		super.Init();
	}
};


class CAIWitcherCastOffensiveSignActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/custom/custom_action_witcher_cast_sign";

	editable var targetTag : name;
	editable var castIgniInsteadOfAard : bool;
};


class CAIKickActionTree extends IAICustomActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/custom/custom_action_kick";

	editable var targetTag 					: name;		default targetTag = 'PLAYER';
	editable var distanceToForceStopAciton 	: float;	default distanceToForceStopAciton = 10.f;
};



exec function TestCustomAction( optional actorTag : name)
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAIHandsBehindBackOverlayActionTree;

	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );

	l_aiTree = new CAIHandsBehindBackOverlayActionTree in l_actor;
	l_aiTree.OnCreated();

	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.ForceAIBehavior( l_aiTree, BTAP_AboveCombat);
	}
}