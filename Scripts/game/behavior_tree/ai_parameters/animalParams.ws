/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAIAnimalBase extends CAIBaseTree
{
	default aiTreeName = "resdef:ai\animal_base";

	editable inlined var params : CAIAnimalDefaults;
	
	function Init()
	{
		params = new CAIAnimalDefaults in this;
		params.OnCreated();
	}
};






class CAIAnimalDefaults extends CAIDefaults
{
	editable inlined 	var combatTree 			: CAIAnimalCombat;
	editable inlined 	var idleTree 			: CAIIdleTree;
	editable inlined 	var idleDecoratorTree	: CAIMonsterIdleDecorator;
	editable inlined 	var charmedTree			: CAIAnimalCharmed;
	editable inlined 	var deathTree			: CAIAnimalDeath;
	
	editable var isAnimal	: bool; default isAnimal = true;
	
	function Init()
	{
		var moveOut : CAIActionMoveOut;
		
		combatTree = new CAIAnimalCombat in this;
		combatTree.OnCreated();
		idleDecoratorTree = new CAIMonsterIdleDecorator in this;
		idleDecoratorTree.OnCreated();
		charmedTree = new CAIAnimalCharmed in this;
		charmedTree.OnCreated();
		deathTree = new CAIAnimalDeath in this;
		deathTree.OnCreated();
		
		moveOut = new CAIActionMoveOut in this;
		moveOut.OnCreated();
		idleDecoratorTree.params.reactionTree.params.reactions.PushBack( moveOut );
		
	}
};

class CAIAnimalQuestDefaults extends CAIDefaults
{
	editable inlined var combatTree 		: CAICombatTree;
	editable inlined var idleTree 			: CAIIdleTree;
	editable inlined var deathTree			: CAIDeathTree;
		
	function Init()
	{
		combatTree = new CAIAnimalQuestCombat in this;
		combatTree.OnCreated();
		idleTree = new CAIIdleTree in this;
		idleTree.OnCreated();
		deathTree = new CAIAnimalDeath in this;
		deathTree.OnCreated();
	}
};


class CAIHorseDefaults extends CAIAnimalDefaults
{
	editable var isMount 			: Bool;
	editable var canMoveOutOfAWay 	: Bool;
	
	default isMount 				= true;
	default canMoveOutOfAWay 		= true;
	
	function Init()
	{		
		super.Init();
		combatTree 	= new CAIAnimalCombatHorse in this;
		combatTree.OnCreated();	
		idleDecoratorTree = new CHorseIdleDecoratorTree in this;
		idleDecoratorTree.OnCreated();
		charmedTree = new CAIHorseCharmed in this;
		charmedTree.OnCreated();
	}
};


class CAIRaceHorseDefaults extends CAIHorseDefaults
{
	default isMount 				= true;
	default canMoveOutOfAWay 		= false;
	
	function Init()
	{		
		super.Init();
		idleDecoratorTree.params.reactionTree.params.reactions.Clear();
	}
};


class CAIWildHorseDefaults extends CAIHorseDefaults
{
	editable var isWildHorse	: bool;
	
	default isWildHorse 		= true;


	function Init()
	{
		var i 					: int;
		var moveInPack			: CAIActionMoveInPack;
		var runWildInPack		: CAIActionRunWildInPack;
		var leadPack 			: CAILeadPackWander;
		var runWild				: CAIAnimalRunWild;
		
		super.Init();
		
		idleTree = new CAIAnimalRunWild in this;
		idleTree.OnCreated();
		
		
		runWild = (CAIAnimalRunWild) idleTree;
		runWild.packRegroupEvent 	= 'HorsePackRunsWild';
		runWild.leaderRegroupEvent 	= 'HorseMoves';
		
		combatTree.neutralIsDanger = true;
		
		
		for( i = 0; i < idleDecoratorTree.params.reactionTree.params.reactions.Size(); i += 1 )
		{
			moveInPack = (CAIActionMoveInPack) idleDecoratorTree.params.reactionTree.params.reactions[i];
			if( moveInPack )
			{
				moveInPack.actionEventName = 'HorseMoves';
				moveInPack.chanceToFollowPack = 80;
			}
			runWildInPack = (CAIActionRunWildInPack) idleDecoratorTree.params.reactionTree.params.reactions[i];
			if( runWildInPack )
			{
				runWildInPack.actionEventName = 'HorsePackRunsWild';
			}
		}
		
		
	}
};


class CAIDeerLeaderDefaults extends CAIDeerDefaults
{
	function Init()
	{
		var leadPack : CAILeadPackWander;
		super.Init();		
		idleTree = new CAILeadPackWander in this;
		idleTree.OnCreated();
		leadPack = (CAILeadPackWander) idleTree;
		leadPack.leaderRegroupEvent = 'DeerMoves';
	}
};



class CAIDeerDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var i 					: int;
		var moveInPack			: CAIActionMoveInPack;
		var eatAction 			: CAIMonsterIdleEat;
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		combatTree = new CAIAnimalCombatDeer in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;		
		eatAction.OnCreated();
		eatAction.params.cooldown = 10.0;
		eatAction.params.loopTime = 3.0;
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable 	= true;
		searchFoodParams.water 		= true;
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
		
		idleDecoratorTree.params.actions.PushBack( eatAction );
		
		for( i = 0; i < idleDecoratorTree.params.reactionTree.params.reactions.Size(); i += 1 )
		{
			moveInPack = (CAIActionMoveInPack) idleDecoratorTree.params.reactionTree.params.reactions[i];
			if( moveInPack )
			{
				moveInPack.actionEventName = 'DeerMoves';
				moveInPack.chanceToFollowPack = 100;
			}
		}
	}
};



class CAIHareDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var eatAction 			: CAIMonsterIdleEat; 
		
		super.Init();
		combatTree = new CAIAnimalCombatHare in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;		
		eatAction.OnCreated();
		eatAction.params.cooldown = 10.0;
		eatAction.params.loopTime = 3.0;		
		
		idleDecoratorTree.params.actions.PushBack( eatAction );
	}
};


class CAIDogDefaults extends CAIAnimalDefaults
{
	function Init()
	{		
		var eatAction 			: CAIMonsterIdleEat; 
		var lieAction 			: CAIMonsterIdleLie;
		var sitAction 			: CAIMonsterIdleSit;
		var cleanAction			: CAIMonsterIdleClean;
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		combatTree = new CAIAnimalCombatDog in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		
		
		lieAction = new CAIMonsterIdleLie in this;
		lieAction.OnCreated();
		lieAction.params.cooldown = 40.0;
		lieAction.params.loopTime = 15.0;
		
		sitAction = new CAIMonsterIdleSit in this;
		sitAction.OnCreated();
		sitAction.params.cooldown = 40.0;
		sitAction.params.loopTime = 15.0;
		
		cleanAction = new CAIMonsterIdleClean in this;
		cleanAction.OnCreated();
		cleanAction.params.cooldown = 40.0;
		cleanAction.params.loopTime = 15.0;
		
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.meat 		= true;
		searchFoodParams.water 		= true;		
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
		
		idleDecoratorTree.params.actions.PushBack( eatAction );  
		idleDecoratorTree.params.actions.PushBack( lieAction );
		idleDecoratorTree.params.actions.PushBack( sitAction );
		idleDecoratorTree.params.actions.PushBack( cleanAction );
		
	}
};


class CAIGoatDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var i 					: int;
		var moveInPack			: CAIActionMoveInPack;
		var leadPack 			: CAILeadPackWander;
		
		var eatAction 			: CAIMonsterIdleEat; 
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		combatTree = new CAIAnimalCombatGoat in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 10.0;
		eatAction.params.loopTime = 10.0;
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable = true;
		
		idleTree = new CAILeadPackWander in this;
		idleTree.OnCreated();
		leadPack = ((CAILeadPackWander) idleTree);
		leadPack.leaderRegroupEvent = 'GoatMoves';
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
		idleDecoratorTree.params.actions.PushBack( eatAction );
		
		
		for( i = 0; i < idleDecoratorTree.params.reactionTree.params.reactions.Size(); i += 1 )
		{
			moveInPack = (CAIActionMoveInPack) idleDecoratorTree.params.reactionTree.params.reactions[i];
			if( moveInPack )
			{
				moveInPack.actionEventName = 'GoatMoves';
				moveInPack.chanceToFollowPack = 50;
			}
		}
	}
};


class CAIGoatQuestDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		combatTree = new CAIAnimalQuestCombat in this;
		combatTree.OnCreated();
	}
};




class CAIPigDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var i 					: int;
		var moveInPack			: CAIActionMoveInPack;
		var leadPack 			: CAILeadPackWander;
		
		var eatAction 			: CAIMonsterIdleEat; 
		var lieAction 			: CAIMonsterIdleLie;
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		combatTree = new CAIAnimalCombatPig in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		
		
		lieAction = new CAIMonsterIdleLie in this;
		lieAction.OnCreated();
		lieAction.params.cooldown = 10.0;
		lieAction.params.loopTime = 15.0;
		
		idleTree = new CAILeadPackWander in this;
		idleTree.OnCreated();
		leadPack = (CAILeadPackWander) idleTree;
		leadPack.leaderRegroupEvent = 'PigMoves';
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.meat 		= true;
		searchFoodParams.vegetable 	= true;
		searchFoodParams.water 		= true;		
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
		
		idleDecoratorTree.params.actions.PushBack( eatAction );  
		idleDecoratorTree.params.actions.PushBack( lieAction );
		
		for( i = 0; i < idleDecoratorTree.params.reactionTree.params.reactions.Size(); i += 1 )
		{
			moveInPack = (CAIActionMoveInPack) idleDecoratorTree.params.reactionTree.params.reactions[i];
			if( moveInPack )
			{
				moveInPack.actionEventName = 'PigMoves';
				moveInPack.chanceToFollowPack = 30;
			}
		}
	}
};


class CAISheepDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var eatAction 			: CAIMonsterIdleEat; 
		var lieAction 			: CAIMonsterIdleLie; 
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		
		combatTree = new CAIAnimalCombatSheep in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		idleDecoratorTree.params.actions.PushBack( eatAction ); 
		
		lieAction = new CAIMonsterIdleLie in this;
		lieAction.OnCreated();
		lieAction.params.cooldown = 10.0;
		lieAction.params.loopTime = 15.0;
		idleDecoratorTree.params.actions.PushBack( lieAction ); 
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable 	= true;
		searchFoodParams.water 		= true;
		idleDecoratorTree.params.searchFoodTree = searchFood;
		
	}
};


class CAIGooseDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var eatAction 			: CAIMonsterIdleEat; 
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		combatTree = new CAIAnimalCombatGoose in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		idleDecoratorTree.params.actions.PushBack( eatAction ); 
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable 	= true;
		searchFoodParams.water 		= true;
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
	}
};



class CAICowDefaults extends CAIAnimalDefaults
{
	function Init()
	{	
		var eatAction 			: CAIMonsterIdleEat; 
		var lieAction 			: CAIMonsterIdleLie; 
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		combatTree = new CAIAnimalCombatCow in this;
		combatTree.OnCreated();
		charmedTree = new CAICowCharmed in this;
		charmedTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 10.0;
		eatAction.params.loopTime = 30.0;
		idleDecoratorTree.params.actions.PushBack( eatAction ); 
		
		lieAction = new CAIMonsterIdleLie in this;
		lieAction.OnCreated();
		lieAction.params.cooldown = 10.0;
		lieAction.params.loopTime = 30.0;
		idleDecoratorTree.params.actions.PushBack( lieAction ); 
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable 	= true;
		searchFoodParams.water 		= true;		
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
		
		
	}
};


class CAIChickenDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var eatAction 			: CAIMonsterIdleEat;
		
		super.Init();
		
		combatTree = new CAIAnimalCombatRooster in this;
		combatTree.OnCreated();	
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();		
		
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		
		idleDecoratorTree.params.actions.PushBack( eatAction );		
	}
}


class CAIRoosterDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var eatAction 			: CAIMonsterIdleEat; 
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		
		super.Init();
		combatTree = new CAIAnimalCombatRooster in this;
		combatTree.OnCreated();	
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		idleDecoratorTree.params.actions.PushBack( eatAction );
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.vegetable 	= true;
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
	}
};


class CAICatDefaults extends CAIAnimalDefaults
{
	function Init()
	{
		var searchFood			: CAIMonsterSearchFoodTree = new CAIMonsterSearchFoodTree in this;
		var searchFoodParams 	: CAIMonsterSearchFoodIdleParams;
		var eatAction 			: CAIMonsterIdleEat; 
		
		super.Init();
		combatTree = new CAIAnimalCombatCat in this;
		combatTree.OnCreated();
		
		eatAction = new CAIMonsterIdleEat in this;
		eatAction.OnCreated();
		eatAction.params.cooldown = 4.0;
		eatAction.params.loopTime = 10.0;
		idleDecoratorTree.params.actions.PushBack( eatAction );
		
		searchFood.OnCreated();
		
		searchFoodParams = (CAIMonsterSearchFoodIdleParams) searchFood.params;
		searchFoodParams.corpse		= true;
		searchFoodParams.meat 		= true;
		searchFoodParams.water 		= true;
		
		idleDecoratorTree.params.searchFoodTree = searchFood;
	}
};






class CAIAnimalDeath extends CAINpcDeath
{
	function Init()
	{
		params = new CAIAnimalDeathParams in this;
		params.OnCreated();
	}
};


class CAIAnimalDeathParams extends CAINpcDeathParams
{	
	default createReactionEvent			= 'AnimalDeath';
	default fxName 						= 'death';
	default setAppearanceTo 			= '';
	default changeAppearanceAfter 		= 0;
	default disableAgony 				= true;
	default disableCollision			= true;
	default disableCollisionDelay		= 1.0;
	default disableCollisionOnAnim		= false;
	default disableCollisionOnAnimDelay = 0.5;
	default destroyAfterAnimDelay		= -1;
		
};






class CAIAnimalCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\combat/animal_combat";

	editable var chanceOfBeingScared 			: float;
	editable var chanceOfBeingScaredRerollTime 	: float;
	editable var scaredIfTargetRuns				: bool;
	editable var maxTolerableTargetDistance 	: float;
	editable var maxFleeRunDistance				: float;
	editable var maxFleeWalkDistance			: float;
	editable var stopFleeingDistance			: float;
	editable var fleeInGroup					: bool;
	editable var neutralIsDanger				: bool;
	
	default chanceOfBeingScared 			= 0.8;
	default chanceOfBeingScaredRerollTime 	= 3.0f;
	default scaredIfTargetRuns 				= true;
	default maxTolerableTargetDistance 		= 3.0;
	default maxFleeRunDistance				= 10.0;
	default maxFleeWalkDistance				= 15.0f;
	default stopFleeingDistance				= 15.0f;
	default fleeInGroup						= true;
	default neutralIsDanger					= true;
};



class CAIAnimalCombatFlee extends CAICombatTree
{
	default aiTreeName = "resdef:ai\combat/animal_flee";
};


class CAIAnimalCombatCurious extends CAICombatTree
{
	default aiTreeName = "resdef:ai\combat/animal_curious";
};

class CAIHorseShakeRider extends CAICombatTree
{
	default aiTreeName = "resdef:ai\combat/horse_shake_rider";
};


class CAIAnimalQuestCombatParams extends CAICombatParameters
{
};


class CAIAnimalQuestCombat extends CAIAnimalCombat
{
	default aiTreeName = "resdef:ai\combat/animal_combat_quest";
};

class CAIAnimalQuestScaredBehaviour extends CAICombatQuestTree
{

}


class CAIAnimalCombatDog extends CAIAnimalCombat
{	
	default	scaredIfTargetRuns				= false;
	default	chanceOfBeingScared 			= 0.05;
	default	chanceOfBeingScaredRerollTime	= 5;
	default	maxTolerableTargetDistance		= 2.0;
	default	maxFleeRunDistance				= 6.0f;
	default	maxFleeWalkDistance				= 10.0f;
	default neutralIsDanger					= false;
};


class CAIAnimalCombatPig extends CAIAnimalCombat
{		
	default scaredIfTargetRuns				= true;
	default chanceOfBeingScared 			= 0.90;
	default chanceOfBeingScaredRerollTime	= 5;
	default neutralIsDanger					= false;
};


class CAIAnimalCombatRooster extends CAIAnimalCombat
{		
	default scaredIfTargetRuns				= true;
	default chanceOfBeingScared 			= 0.5;
	default chanceOfBeingScaredRerollTime	= 10;
	default maxTolerableTargetDistance		= 3.0;
	default maxFleeRunDistance				= 4.0f;
	default maxFleeWalkDistance				= 5.0;
	default stopFleeingDistance 			= 6.0f;
};


class CAIAnimalCombatGoose extends CAIAnimalCombat
{		
	default scaredIfTargetRuns				= true;
	default chanceOfBeingScared 			= 1.0;
	default chanceOfBeingScaredRerollTime	= 2;
	default maxTolerableTargetDistance		= 4.0;
	default maxFleeRunDistance				= 10.0f;
	default maxFleeWalkDistance				= 20.0;
	default stopFleeingDistance 			= 25.0f;
};


class CAIAnimalCombatCat extends CAIAnimalCombat
{	
	default scaredIfTargetRuns				= false;
	default chanceOfBeingScared 			= 0.05;
	default chanceOfBeingScaredRerollTime	= 5;
	default maxTolerableTargetDistance		= 2.0;
	default maxFleeRunDistance				= 6.0f;
	default maxFleeWalkDistance				= 10.0;
	default stopFleeingDistance 			= 25.0f;
	default neutralIsDanger					= false;
};

class CAIAnimalCombatCow extends CAIAnimalCombat
{	
	default scaredIfTargetRuns				= false;
	default chanceOfBeingScared 			= 0.05;
	default chanceOfBeingScaredRerollTime	= 1;
	default neutralIsDanger					= false;
};


class CAIAnimalCombatGoat extends CAIAnimalCombat
{
	default scaredIfTargetRuns			= true;
	default chanceOfBeingScared 		= 0.3;
	default maxTolerableTargetDistance	= 5.0;
	default maxFleeRunDistance			= 15;
	default maxFleeWalkDistance			= 30;
	default stopFleeingDistance 		= 40.0f;
};

class CAIAnimalCombatSheep extends CAIAnimalCombat
{	
	default scaredIfTargetRuns				= true;
	default chanceOfBeingScared 			= 0.6f;
	default maxTolerableTargetDistance		= 5.0;
	default maxFleeRunDistance				= 10.0f;
	default maxFleeWalkDistance				= 15.0;
	default stopFleeingDistance 			= 20.0f;
};


class CAIAnimalCombatHare extends CAIAnimalCombat
{	
	default chanceOfBeingScared 		= 0.90;
	default maxTolerableTargetDistance	= 8.0;
	default maxFleeRunDistance			= 10.0f;
	default maxFleeWalkDistance			= 20.0;
	default stopFleeingDistance 		= 50;
	default fleeInGroup 				= false;
};



class CAIAnimalCombatDeer extends CAIAnimalCombat
{	
	default chanceOfBeingScared 			= 0.8f;
	default chanceOfBeingScaredRerollTime 	= 1.0f;
	default maxTolerableTargetDistance		= 10.0f;
	default maxFleeRunDistance				= 20.0f;
	default maxFleeWalkDistance				= 30.0;
	default stopFleeingDistance 			= 50;
};
   

class CAIAnimalCombatHorse extends CAIAnimalCombat
{ 
	default aiTreeName = "resdef:ai\combat/horse_combat";
	editable inlined var shakeRiderTree	: CAIHorseShakeRider;	

	default chanceOfBeingScared 			= 0.1f;
	default chanceOfBeingScaredRerollTime 	= 8.0f;
	default scaredIfTargetRuns 				= true;
	default maxTolerableTargetDistance 		= 5.0;
	default maxFleeRunDistance				= 10.0;
	default maxFleeWalkDistance				= 15.0f;
	default stopFleeingDistance				= 50.0f;
	default neutralIsDanger					= false;
	
	function Init()
	{
		shakeRiderTree = new CAIHorseShakeRider in this;
		shakeRiderTree.OnCreated();
	}
};


class CAIAnimalCharmed extends CAIIdleTree
{
	default aiTreeName = "resdef:ai\idle/animal_charmed_idle";
	editable var charmedGotoDistance 		: float;
	default charmedGotoDistance 			= 3.0f;
};

class CAIHorseCharmed extends CAIAnimalCharmed
{	
	function Init()
	{
		super.Init();
		charmedGotoDistance = 5.0f;
	}
};

class CAICowCharmed extends CAIAnimalCharmed
{
	function Init()
	{
		super.Init();
		charmedGotoDistance = 5.0f;
	}
};



class CAnimalIdleDecoratorTree extends CAIMainTree
{
	default aiTreeName = "resdef:ai\idle/animal_idle_decorator";
	
	function Init()
	{
		
	}
};



class CHorseIdleDecoratorTree extends CAIMonsterIdleDecorator
{
	default aiTreeName 								= "resdef:ai\idle/horse_idle_decorator";
	
	editable inlined var actionPointSelector : CHorseParkingActionPointSelector;
	
	editable var packName : name;
	
	default packName = 'HorsePack';
	
	function Init()
	{
		super.Init();
		actionPointSelector = new CHorseParkingActionPointSelector in this;
		actionPointSelector.radius = 20.0f;
	}
};