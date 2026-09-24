/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAICombatSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_combat";
};


class CAICommonerSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_commoner";
};


class CAIGuardSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_guard";
};


class CAIQuestSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_quest";
};


class CAIMainQuestSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_quest_main";
};


class CAIChildSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_child";
};






class CAINpcReactionsTree extends CAIReactionTree
{
	default aiTreeName = "resdef:ai\reactions/npc_base_reactions";

	
	
	
	editable inlined var reactions : array< CAINpcActionSubtree >;
	
	protected function OverriderReactionsPriority( priority : int, optional priorityWhileActive : int )
	{
		var i : int;
		
		for ( i=0 ; i < reactions.Size() ; i+=1 )
		{
			reactions[i].reactionPriority = priority;
			if ( priorityWhileActive > 0 )
			{
				reactions[i].changePriorityWhileActive = true;
				reactions[i].reactionPriorityWhileActive = priorityWhileActive;
			}
		}
	}
};








class CAICommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var rain			: CAIActionRain 			= new CAIActionRain in this;
		var taunt			: CAIActionTaunt 			= new CAIActionTaunt in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;	
		var gossip		 	: CAIActionGossip 			= new CAIActionGossip in this;
		var question 		: CAIActionQuestion 		= new CAIActionQuestion in this;
		
		var barter 			: CAIActionBarter			= new CAIActionBarter in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;

		beingHit		.OnCreated();
		bump			.OnCreated();
		rain			.OnCreated();
		taunt			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		gossip			.OnCreated();
		question		.OnCreated();
		
		barter			.OnCreated();
		jump			.OnCreated();
		
		taunt.forwardAvailabilityToReactionTree = true;
		attack.forwardAvailabilityToReactionTree = true;
		castSign.forwardAvailabilityToReactionTree = true;
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		combatNearby.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );
		reactions.PushBack( bump );
		reactions.PushBack( rain );
		reactions.PushBack( drawSword );
		reactions.PushBack( taunt );
		reactions.PushBack( attack );
		reactions.PushBack( castSign );
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
		reactions.PushBack( combatNearby );
		reactions.PushBack( gossip );
		reactions.PushBack( question );
		
		reactions.PushBack( barter );
		reactions.PushBack( jump );
	}
}


class CAIChildReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var rain			: CAIActionRain 			= new CAIActionRain in this;
		var taunt			: CAIActionTaunt 			= new CAIActionTaunt in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		rain			.OnCreated();
		taunt			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		
		reactions.PushBack( beingHit );			
		reactions.PushBack( bump );				
		reactions.PushBack( rain );				
		reactions.PushBack( drawSword );		
		reactions.PushBack( taunt );			
		reactions.PushBack( attack );			
		reactions.PushBack( castSign );			
		reactions.PushBack( crossbowShot );		
		reactions.PushBack( bombExplosion );	
		reactions.PushBack( combatNearby );		
		
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[5];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[6];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[7];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[8];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[9];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
	}
}


class CAIDrunkCommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;

		beingHit		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );;
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
	}
}


class CAIGuardReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		var looting		 	: CAIActionLooting 			= new CAIActionLooting in this;
		var taunt		 	: CAIActionTaunt 			= new CAIActionTaunt in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;
		var gossip		 	: CAIActionGossip 			= new CAIActionGossip in this;
		var question 		: CAIActionQuestion 		= new CAIActionQuestion in this;
		
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		looting			.OnCreated();
		taunt			.OnCreated();
		jump			.OnCreated();
		gossip			.OnCreated();
		question		.OnCreated();
		
		
		reactions.PushBack( beingHit );			
		reactions.PushBack( combatNearby );		
		reactions.PushBack( bump );				
		reactions.PushBack( drawSword );		
		reactions.PushBack( attack );			
		reactions.PushBack( castSign );			
		reactions.PushBack( crossbowShot );		
		reactions.PushBack( bombExplosion );	
		reactions.PushBack( taunt );			
		reactions.PushBack( looting );			
		
		
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionTurnHostile)tempOverride.reactionLogicTree).SetParams('BeingHitAction');
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.reactionLogicTree = new CAINpcReactionJoinFight in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.reactionLogicTree = new CAINpcReactionBump in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[5];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[6];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[7];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[8];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[9];
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		
		OverriderReactionsPriority( 60, 59 );
		
		
		reactions.PushBack( jump );
		
		
		
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 62;
		
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 61;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 58;
		
		
		reactions.PushBack( gossip );			
		reactions.PushBack( question );
		

	}
};


class CAICombatNPCReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		var taunt		 	: CAIActionTaunt 			= new CAIActionTaunt in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatStarted 	: CAIActionCombatStarted 	= new CAIActionCombatStarted in this;
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		combatNearby	.OnCreated();
		taunt			.OnCreated();
		jump			.OnCreated();
		bombExplosion	.OnCreated();
		combatStarted	.OnCreated();
		
		reactions.PushBack( beingHit );			
		reactions.PushBack( combatNearby );		
		reactions.PushBack( bump );				
		reactions.PushBack( taunt );			
		reactions.PushBack( bombExplosion );	
		reactions.PushBack( combatStarted );	
		
		
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionTurnHostile)tempOverride.reactionLogicTree).SetParams('BeingHitAction');
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.reactionLogicTree = new CAINpcReactionJoinFight in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionJoinFight)tempOverride.reactionLogicTree).SetParams(true);
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.reactionLogicTree = new CAINpcReactionBump in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionStopAndComment in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(7.f,false,true);
		
		
		OverriderReactionsPriority( 60, 59 );
		
		
		reactions.PushBack( jump ); 
		
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.changePriorityWhileActive = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.changePriorityWhileActive = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 24; 
	}
};


class CAIQuestNPCReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		
		
		bombExplosion	.OnCreated();
		
		
		reactions.PushBack( bombExplosion );
		
	}
};






class CAIPhilippaReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var bombExplosion : CAIActionBombExplosion = new CAIActionBombExplosion in this;
		
		bombExplosion.OnCreated();
		bombExplosion.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( bombExplosion );
	}
};


class CAIBruxaCommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBruxaBeingHit				= new CAIActionBruxaBeingHit in this;
		var drawSword		: CAIActionBruxaDrawSword 				= new CAIActionBruxaDrawSword in this;
		var attack			: CAIActionBruxaAttack 					= new CAIActionBruxaAttack in this;
		var friendlyAttack	: CAIActionBruxaFriendlyAttackAction 	= new CAIActionBruxaFriendlyAttackAction in this;
		var castSign		: CAIActionBruxaCastSign 				= new CAIActionBruxaCastSign in this;
		var crossbowShot 	: CAIActionBruxaCrossbowShot 			= new CAIActionBruxaCrossbowShot in this;
		var bombExplosion 	: CAIActionBruxaBombExplosion 			= new CAIActionBruxaBombExplosion in this;
		var playerPresence 	: CAIActionBruxaPlayerPresence 			= new CAIActionBruxaPlayerPresence in this;
		var forcedSpawn 	: CAIActionBruxaPlayerPresenceForced 	= new CAIActionBruxaPlayerPresenceForced in this;
		
		
		beingHit			.OnCreated();
		drawSword			.OnCreated();
		attack				.OnCreated();
		friendlyAttack		.OnCreated();
		castSign			.OnCreated();
		crossbowShot		.OnCreated();
		bombExplosion		.OnCreated();
		playerPresence 		.OnCreated();
		forcedSpawn 		.OnCreated();
		
		beingHit.forwardAvailabilityToReactionTree = true;
		drawSword.forwardAvailabilityToReactionTree = true;
		attack.forwardAvailabilityToReactionTree = true;
		friendlyAttack.forwardAvailabilityToReactionTree = true;
		castSign.forwardAvailabilityToReactionTree = true;
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		playerPresence.forwardAvailabilityToReactionTree = true;
		forcedSpawn.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );
		reactions.PushBack( drawSword );
		reactions.PushBack( attack );
		reactions.PushBack( friendlyAttack );
		reactions.PushBack( castSign );
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
		reactions.PushBack( playerPresence );
		reactions.PushBack( forcedSpawn );
	}
}



















abstract class CAINpcActionSubtree extends CAISubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_reaction";

	editable inlined var reactionLogicTree : CAINpcReaction;
	
	editable var reactionPriority 					: int;
	editable var actionEventName 					: CName;
	editable var actionCooldownDistance 			: float;
	editable var actionCooldownTimeout 				: float;
	editable var actionFailedCooldown 				: float;
	editable var dontSetActionTarget 				: bool;
	editable var changePriorityWhileActive 			: bool;
	editable var reactionPriorityWhileActive 		: int;
	editable var disallowOutsideOfGuardArea 		: bool;
	editable var forwardAvailabilityToReactionTree 	: bool;
	editable var disableTalkInteraction			 	: bool;
	editable var disallowWhileOnHorse			 	: bool;
	
	default actionCooldownTimeout 	= -1;
	default actionFailedCooldown 	= -1;
	default disableTalkInteraction 	= true;
	default disallowWhileOnHorse 	= true;
};














class CAIActionBeingHit extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGetScared in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)reactionLogicTree).SetParams(10.f,false);
		reactionPriority = 60;
		actionEventName = 'BeingHitAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		disallowWhileOnHorse = false;
	}
};


class CAIActionBumpTree extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBump in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "bump";

		reactionPriority = 60;
		actionEventName = 'BumpAction';
		actionCooldownDistance = 1;
		actionCooldownTimeout = 1;
		dontSetActionTarget = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 51;
		forwardAvailabilityToReactionTree = true;
	}
};


class CAIActionCombatNearby extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionObserveFight in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CombatNearbyAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};


class CAIActionDrawSword extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'DrawSwordAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
	}
};


class CAIActionAttack extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'AttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};


class CAIActionCastSign extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CastSignAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};


class CAIActionCrossbowShot extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'CrossbowShotAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
	}
};


class CAIActionBombExplosion extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGetScared in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)reactionLogicTree).SetParams(7.f,false);
		reactionPriority = 56;
		actionEventName = 'BombExplosionAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
	}
};


class CAIActionLooting extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionGuardWarnGeneral)reactionLogicTree).SetParams(true);
		
		reactionPriority = 50;
		actionEventName = 'LootingAction';
		actionCooldownDistance = 0.5;
		actionFailedCooldown = 2.f;
		actionCooldownTimeout = 0.1;
	}
};


class CAIActionTaunt extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'TauntAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		dontSetActionTarget = false;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};


class CAIActionRain extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionRain in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "rain";
		
		reactionPriority = 45;
		actionEventName = 'RainReactionEvent';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		actionFailedCooldown = 300; 
		
		disableTalkInteraction = false;
		forwardAvailabilityToReactionTree = true;
	}
};


class CAIActionJump extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionSurprise in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'PlayerJumpAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
		forwardAvailabilityToReactionTree = true;
	}
};


class CAIActionCombatStarted extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionSurprise in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionSurprise)reactionLogicTree).SetParams(true);
		
		reactionPriority = 45;
		actionEventName = 'CombatStarted';
		actionCooldownDistance = 0.5;
		actionFailedCooldown = 2.f;
		actionCooldownTimeout = 0.1;
		forwardAvailabilityToReactionTree = true;
	}
};






class CAIActionGossip extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_gossip_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'GossipAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;
	}
};


class CAIActionQuestion extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_question_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'QuestionAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;	
	}
};


class CAIActionGreeting extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_greeting_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'GreetingAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;
	}
};


class CAIActionBarter extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_scene_barter";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'BarterAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;		
		
		disableTalkInteraction = false;
	}
};


class CAIActionPlayerPresence extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "reaction_to_geralt";
		
		reactionPriority = 20; 
		actionEventName = 'PlayerPresenceAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 10;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 22;
		
		disableTalkInteraction = false;
	}
};


class CAIQuestActionPlayerPresence extends CAIActionPlayerPresence
{
	function Init()
	{
		super.Init();
		((CAINpcReactionStopAndComment)reactionLogicTree).SetParams(100,-1);
		actionCooldownTimeout = 0;
	}
};






class CAIActionBruxaBeingHit extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 60;
		actionEventName = 'BeingHitAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		disallowWhileOnHorse = false;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

class CAIActionBruxaDrawSword extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 24;
		actionEventName = 'DrawSwordAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaAttack extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'AttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaFriendlyAttackAction extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'FriendlyAttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaCastSign extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CastSignActionFar';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaCrossbowShot extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 24;
		actionEventName = 'CrossbowShotAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaBombExplosion extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 56;
		actionEventName = 'BombExplosionAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};


class CAIActionBruxaPlayerPresence extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 20; 
		actionEventName = 'PlayerPresenceAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
		
		disableTalkInteraction = false;
	}
};


class CAIActionBruxaPlayerPresenceForced extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 100;
		actionEventName = 'ForceBruxaSpawn';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
		
		disableTalkInteraction = false;
	}
};













class CAINpcReaction extends CAISubTree
{
	editable var voiceSet : string;
};




class CAINpcReactionGetScared extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_get_scared";
	
	editable var scaredTime : float;
	editable var scaredTimeMax : float;
	editable var checkLineOfSight : bool;
	editable var tryToBeHostileFirst : bool;
	
	default scaredTime = 8.f;
	default scaredTimeMax = 11.f;
	default checkLineOfSight = false;
	
	function SetParams( _scaredTime : float, _checkLineOfSight : bool, optional _tryToBeHostileFirst : bool )
	{
		scaredTime = _scaredTime - 2;
		scaredTimeMax = _scaredTime + 1;
		checkLineOfSight = _checkLineOfSight;
		tryToBeHostileFirst = _tryToBeHostileFirst;
	}
};


class CAINpcReactionTaunt extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_taunt";
};


class CAINpcReactionStopAndComment extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_stop_and_comment";
	
	editable var stopDuration 			: float;	default stopDuration = 6.f;
	editable var activationChance 		: int;		default activationChance = 20;
	editable var distanceToInterrupt	: int;		default distanceToInterrupt = 10.f;
	
	function SetParams( _activationChance : int, _stopDuration : float )
	{
		activationChance = _activationChance;
		stopDuration = _stopDuration;
	}
};


class CAINpcReactionSurprise extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_surprise";
	
	editable var rotateToActionTargetsTarget : bool;
	
	function SetParams( _rotateToActionTargetsTarget : bool )
	{
		rotateToActionTargetsTarget = _rotateToActionTargetsTarget;
	}
};
 

class CAINpcReactionJoinFight extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_join_fight";
	editable var onlyHelpActorsFromTheSameAttidueGroup : bool;
	
	function SetParams( _onlyHelpActorsFromTheSameAttidueGroup : bool )
	{
		onlyHelpActorsFromTheSameAttidueGroup = _onlyHelpActorsFromTheSameAttidueGroup;
	}
};


class CAINpcReactionObserveFight extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_observe_fight";
	
	editable var doNotCheckLineOfSight : bool;
	
	function SetParams( _doNotCheckLineOfSight : bool )
	{
		doNotCheckLineOfSight = _doNotCheckLineOfSight;
	}
};


class CAINpcReactionTurnHostile extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_turn_hostile";
	editable var setAttitudeGameplayEventName : name;
	
	function SetParams( gameplayEventName : name )
	{
		setAttitudeGameplayEventName = gameplayEventName;
	}
};


class CAINpcReactionGuardWarnSword extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_guard_warn_sword";
};


class CAINpcReactionGuardWarnGeneral extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_guard_warn_general";
	
	editable var lootingReaction : bool;
	
	function SetParams( _lootingReaction : bool )
	{
		lootingReaction = _lootingReaction;
	}
};


class CAINpcReactionBump extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_bump";
};



class CAINpcReactionRain extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_rain";
	
	editable inlined var actionPointSelector 	: CRainActionPointSelector;
	
	function Init()
	{
		actionPointSelector = new CRainActionPointSelector in this;
		
		actionPointSelector.radius 			= 30;
		actionPointSelector.chooseClosestAP = true;
	}
};


class CAINpcReactionBruxaSpawn extends CAINpcReaction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\reaction_bruxa_spawn.w2behtree";
	
	editable var activationChance 		: int;		default activationChance = 100;
	editable var distanceToInterrupt	: int;		default distanceToInterrupt = 15.f;
	
	function SetParams( _activationChance : int, _stopDuration : float )
	{
		activationChance = _activationChance;
	}
};





abstract class CAIScaredSubTree extends CAISubTree
{

};

class CAIScaredTree extends CAIScaredSubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_scared_reaction";
};

class CAIRunOnlyScaredTree extends CAIScaredSubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_scared_run_only_reaction";
};


























