/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAIMonsterIdle extends CAIIdleTree
{
	editable inlined var params : CAIMonsterIdleParams;
};


class CAIMonsterIdleParams extends CAIIdleParameters
{
};


class CAIMonsterIdleDefault extends CAIMonsterIdle
{
	default aiTreeName = "resdef:ai\monster_idle";

	function Init()
	{
		params = new CAIMonsterIdleParams in this;
		params.OnCreated();
	}
};


class CAIMonsterSearchFoodTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\idle/monster_search_food_idle";
	
	editable inlined var params : CAIMonsterSearchFoodIdleParams;
	
	function Init()
	{
		super.Init();
		
		this.params = new CAIMonsterSearchFoodIdleParams in this;
		this.params.OnCreated();		
	}
};


class CAIMonsterSearchFoodIdleParams extends CAISubTreeParameters
{
	editable var loopTime		: float;
	editable var corpse 		: bool;
	editable var meat 			: bool;
	editable var vegetable 		: bool;
	editable var water 			: bool;
	editable var monster		: bool;
	editable var landHeight		: float;
	editable var flyHeight		: float;
	
	default loopTime	= 5;
	
	function Init() 
	{
		super.Init();
	}
};


class CAILessogIdle extends CAIMonsterIdle
{
	default aiTreeName = "resdef:ai\monster_lessog_idle";

	function Init()
	{
		params = new CAIMonsterIdleParams in this;
		params.OnCreated();
	}
};


class CAIMonsterIdleDecorator extends CAIIdleDecoratorTree
{
	default aiTreeName = "resdef:ai\idle\monster_idle_decorator";
	
	editable inlined var params : CAIMonsterIdleDecoratorParams;	
	
	function Init()
	{		
		params = new CAIMonsterIdleDecoratorParams in this;
		params.OnCreated();
		params.reactionTree = new CAIMonsterReactionsTree in this;
		params.reactionTree.OnCreated();		
	}
}


class CAIScolopendromorphIdleDecorator extends CAIMonsterIdleDecorator
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_scolopendromorph_idle_logic.w2behtree";
}


class CAIEchinopsIdleDecorator extends CAIMonsterIdleDecorator
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_echinops_idle_logic.w2behtree";
}


class CAIMonsterIdleDecoratorParams extends CAIIdleParameters
{
	editable inlined var reactionTree 		: CAIMonsterReactionsTree;
	editable inlined var searchFoodTree 	: CAIMonsterSearchFoodTree;
	editable inlined var actions 			: array<CAIMonsterIdleAction>;
	editable inlined var nightActions 		: array<CAIMonsterIdleAction>;
	
	editable var actionCooldown				: float;
	editable var chanceToHuntAtNight		: float;
	
	default actionCooldown 		= 5.0;
	default chanceToHuntAtNight = 20.0;
	
	function Init()
	{
		super.Init();		
	}
};


class CAIMonsterIdleDecoratorArachas extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var dig : CAIMonsterIdleDig = new CAIMonsterIdleDig in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		dig.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.meat = true;

		params.searchFoodTree = eat;
		params.actions.PushBack( dig );
	}
};



class CAIMonsterIdleDecoratorPanther extends CAIMonsterIdleDecorator
{
function Init()
{

var eat : CAIMonsterIdleEat = new CAIMonsterIdleEat in this;

super.Init();

eat.OnCreated();

eat.params.cooldown = 4.0;
eat.params.loopTime = 10.0;

params.actions.PushBack( eat );
}
};


class CAIMonsterIdleDecoratorBoar extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		

		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse 	= true;
		eatParams.monster 	= true;
		
		params.searchFoodTree = eat;

	}
};




class CAIMonsterIdleDecoratorKatakan extends CAIMonsterIdleDecorator
{
	function Init()
	{
		super.Init();
	}
};


class CAIMonsterIdleDecoratorBear extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat 				: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var onGroundAndClean 	: CAIMonsterIdleOnGroundAndClean = new CAIMonsterIdleOnGroundAndClean in this;
		var sleep 				: CAIMonsterIdleSleep = new CAIMonsterIdleSleep in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		onGroundAndClean.OnCreated();
		sleep.OnCreated();
		
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse 	= true;
		eatParams.meat 		= true;
		
		params.searchFoodTree = eat;
		
		params.actions.PushBack( onGroundAndClean );
		params.actions.PushBack( sleep );
		
		params.nightActions.PushBack( sleep );
	}
};


class CAIMonsterIdleDecoratorBies extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var howl : CAIMonsterIdleHowl = new CAIMonsterIdleHowl in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		howl.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.vegetable = true;
		
		params.searchFoodTree = eat;
		
		params.actions.PushBack( howl );
	}
};


class CAIMonsterIdleDecoratorTroll extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var stretch : CAIMonsterIdleStretch = new CAIMonsterIdleStretch in this;		
		super.Init();		
		stretch.OnCreated();
		params.actions.PushBack( stretch );
	}
};


class CAIMonsterIdleDecoratorDrowner extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var cough : CAIMonsterIdleCough = new CAIMonsterIdleCough in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		cough.OnCreated();

		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse 	= true;
		eatParams.monster 	= true;
		
		params.searchFoodTree = eat;
		params.actions.PushBack( cough );
	}
};


class CAIMonsterIdleDecoratorGhoul extends CAIMonsterIdleDecorator
{
	function Init()
	{
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		
		super.Init();
		
		eat.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse 	= true;
		eatParams.monster 	= true;
		
		params.searchFoodTree = eat;
	}
};


class CAIMonsterIdleDecoratorGolem extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var strikeFists : CAIMonsterIdleStrikeFists = new CAIMonsterIdleStrikeFists in this;
		var growl : CAIMonsterIdleGrowl = new CAIMonsterIdleGrowl in this;
		var lookAround : CAIMonsterIdleLookAround = new CAIMonsterIdleLookAround in this;
		
		super.Init();
		
		strikeFists.OnCreated();
		growl.OnCreated();
		lookAround.OnCreated();
		
		params.actions.PushBack( strikeFists );
		params.actions.PushBack( growl );		
		params.actions.PushBack( lookAround );		
	}
};


class CAIMonsterIdleDecoratorGryphon extends CAIMonsterIdleDecorator
{
	editable var arrivalDistance : float;
	
	
	default arrivalDistance = 2.5f;
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var growl : CAIMonsterIdleGrowl = new CAIMonsterIdleGrowl in this;
		var wings : CAIMonsterIdleWings = new CAIMonsterIdleWings in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		growl.OnCreated();
		wings.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.meat 		 = true;
		eatParams.landHeight = 7;
		eatParams.landHeight = 6;
		
		params.searchFoodTree = eat;
		
		params.actions.PushBack( growl );
		params.actions.PushBack( wings );
	}
};


class CAIDynamicFlyingWanderGryphon extends CAIDynamicFlyingWander
{	
	default landingGroundOffset		= 7;
}



class CAIMonsterIdleDecoratorHarpy extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var dig : CAIMonsterIdleDig = new CAIMonsterIdleDig in this;
		var lookAround : CAIMonsterIdleLookAround = new CAIMonsterIdleLookAround in this;		
		
		super.Init();
		
		dig.OnCreated();
		lookAround.OnCreated();

		params.actions.PushBack( dig );
		params.actions.PushBack( lookAround );			
	}	
};



class CAIDynamicFlyingWanderHarpy extends CAIDynamicFlyingWander
{	
	default landingGroundOffset			= 1;
	default onSpotLanding				= true;
	default minFlyDistance				= 10;
	default maxFlyDistance				= 60;
	default minHeight					= 10;
	default maxHeight					= 20;
	default proximityToAllowTakeOff		= 70;
	default proximityToForceTakeOff		= 60;
	default distanceFromPlayerToLand	= 80;
}


class CAIMonsterIdleDecoratorWraith extends CAIMonsterIdleDecorator
{
	function Init()
	{
		super.Init();
	}
};


class CAIMonsterIdleDecoratorNoonWraith extends CAIMonsterIdleDecorator
{
	function Init()
	{
		super.Init();
	}
};


class CAIMonsterIdleDecoratorSiren extends CAIMonsterIdleDecorator
{
	function Init()
	{		
		var flyBarrel 	: CAIMonsterIdleFlyBarrel 	= new CAIMonsterIdleFlyBarrel in this;
		var flyAirDive 	: CAIMonsterIdleFlyAirDive 	= new CAIMonsterIdleFlyAirDive in this;
		var wings		: CAIMonsterIdleWings		= new CAIMonsterIdleWings in this;
		
		super.Init();
		
		flyBarrel.OnCreated();
		flyAirDive.OnCreated();
		wings.OnCreated();
		
		params.actions.PushBack( flyBarrel );
		params.actions.PushBack( flyAirDive );	
		params.actions.PushBack( wings );	
	}
};


class CAIMonsterIdleDecoratorGiant extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var sit 	: CAIMonsterIdleSit = new CAIMonsterIdleSit in this;
		var yawn 	: CAIMonsterIdleYawn = new CAIMonsterIdleYawn in this;
		var sleep 	: CAIMonsterIdleSleep = new CAIMonsterIdleSleep in this;
	
		super.Init();
		
		sit.OnCreated();
		yawn.OnCreated();
		sleep.OnCreated();

		params.actions.PushBack( sit );
		params.actions.PushBack( yawn );
		params.actions.PushBack( sleep );
		
		params.nightActions.PushBack( sleep );
	}
};


class CAIMonsterIdleDecoratorNekker extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var growl 		: CAIMonsterIdleGrowl = new CAIMonsterIdleGrowl in this;
		var dig 		: CAIMonsterIdleDig = new CAIMonsterIdleDig in this;
		var lookAround	: CAIMonsterIdleLookAround = new CAIMonsterIdleLookAround in this;
			
		super.Init();
		
		growl.OnCreated();
		dig.OnCreated();
		lookAround.OnCreated();
		
		params.actions.PushBack( growl );
		params.actions.PushBack( dig );
		params.actions.PushBack( lookAround );
	}
};


class CAIMonsterIdleDecoratorWerewolf extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var howl : CAIMonsterIdleHowl = new CAIMonsterIdleHowl in this;
		var sniff : CAIMonsterIdleSniff = new CAIMonsterIdleSniff in this;
	
		super.Init();
		
		howl.OnCreated();
		sniff.OnCreated();

		params.actions.PushBack( howl );
		params.actions.PushBack( sniff );
	}
};


class CAIMonsterIdleDecoratorWolfAlpha extends CAIMonsterIdleDecorator
{
	function Init()
	{	
	
		
		var eat 		 		: CAIMonsterSearchFoodTree 			= new CAIMonsterSearchFoodTree in this;
		var sit 				: CAIMonsterIdleSit 				= new CAIMonsterIdleSit in this;
		var howl 				: CAIMonsterIdleHowl 				= new CAIMonsterIdleHowl in this;
		
		var eatParams 			: CAIMonsterSearchFoodIdleParams;
		
		
		var searchForTarget : CAIActionSearchForTarget 		= new CAIActionSearchForTarget in this;
		var joinSearch 		: CAIActionAllySearchesTarget 	= new CAIActionAllySearchesTarget in this;
		
		super.Init();
		
		
		eat.OnCreated();
		sit.OnCreated();
		howl.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse = true;
		
		params.searchFoodTree = eat;
				
		params.actions.PushBack( sit );
		params.actions.PushBack( howl );
		
		
		searchForTarget	.OnCreated();
		joinSearch		.OnCreated();
		
		params.reactionTree.params.reactions.Clear();
		params.reactionTree.params.reactions.PushBack( searchForTarget );
		params.reactionTree.params.reactions.PushBack( joinSearch );
	}
}

class CAIMonsterIdleDecoratorWolf extends CAIMonsterIdleDecorator
{
	function Init()
	{
		var i 					: int;
		var moveInPack			: CAIActionMoveInPack;
		
		var eat 		 		: CAIMonsterSearchFoodTree 			= new CAIMonsterSearchFoodTree in this;
		var sit 				: CAIMonsterIdleSit 				= new CAIMonsterIdleSit in this;
		var onGroundAndClean 	: CAIMonsterIdleOnGroundAndClean 	= new CAIMonsterIdleOnGroundAndClean in this;
		var howl 				: CAIMonsterIdleHowl 				= new CAIMonsterIdleHowl in this;
		var sleep 				: CAIMonsterIdleSleep 				= new CAIMonsterIdleSleep in this;
		var roll 				: CAIMonsterIdleRoll 				= new CAIMonsterIdleRoll in this;
		var playAround			: CAIMonsterIdlePlayAround 			= new CAIMonsterIdlePlayAround in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		roll.OnCreated();
		sit.OnCreated();
		onGroundAndClean.OnCreated();
		howl.OnCreated();
		sleep.OnCreated();
		playAround.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse = true;
		
		params.searchFoodTree = eat;
		
		params.actions.PushBack( roll );		
		params.actions.PushBack( sit );
		params.actions.PushBack( onGroundAndClean );
		params.actions.PushBack( howl );
		params.actions.PushBack( sleep );
		params.actions.PushBack( playAround );
		
		params.nightActions.PushBack( sleep );
		params.nightActions.PushBack( howl );		
		
		
		for( i = 0; i < params.reactionTree.params.reactions.Size(); i += 1 )
		{
			moveInPack = (CAIActionMoveInPack) params.reactionTree.params.reactions[i];
			if( moveInPack )
			{
				moveInPack.actionEventName = 'WolfMoves';
				moveInPack.chanceToFollowPack = 100;
			}
		}
	}
};


class CAIMonsterIdleDecoratorWyvern extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var wings : CAIMonsterIdleWings = new CAIMonsterIdleWings in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		wings.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse = true;
		eatParams.monster 	= true;
		eatParams.landHeight = 2;
		eatParams.flyHeight = 2;

		params.searchFoodTree = eat;
		params.actions.PushBack( wings );		
	}
};



class CAIDynamicFlyingWanderWyvern extends CAIDynamicFlyingWander
{	
	default landingGroundOffset		= 2;
}



class CAIMonsterIdleDecoratorGravehag extends CAIMonsterIdleDecorator
{
	function Init()
	{
		
		var eat : CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		
		var eatParams : CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		eat.OnCreated();
		
		eatParams = (CAIMonsterSearchFoodIdleParams) eat.params;
		eatParams.corpse 	= true;
		eatParams.monster 	= true;

		params.searchFoodTree = eat;
	}
};




class CAIFrogIdleDecorator extends CAIMonsterIdleDecorator
{
	default aiTreeName = "resdef:ai\idle\frog_idle_decorator";
	
	
	
	function Init()
	{		
		params = new CAIMonsterIdleDecoratorParams in this;
		params.OnCreated();
		params.reactionTree = new CAIMonsterReactionsTree in this;
		params.reactionTree.OnCreated();		
	}
}
