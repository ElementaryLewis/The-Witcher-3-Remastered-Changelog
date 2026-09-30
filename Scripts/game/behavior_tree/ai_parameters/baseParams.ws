/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CAIMainTree extends CAITree 
{
};





class CAIIdleTree extends CAIMainTree
{
	default aiTreeName = "resdef:ai\idle/npc_idle";
};

abstract class CAIWanderTree extends CAIIdleTree
{
	editable var wanderMoveSpeed 	: float;
	editable var wanderMoveType 	: EMoveType;
	editable var wanderMaxDistance 	: float;
	
	default wanderMaxDistance = 1.0;
};

class CAIIdleDecoratorTree extends CAISubTree
{	
}

abstract class CAICombatTree extends CAIMainTree
{
};

abstract class CAIAxiiTree extends CAIMainTree
{
};

abstract class CAITauntTree extends CAIMainTree
{
};

abstract class CAICombatQuestTree extends CAIMainTree
{
};

abstract class CAICombatDecoratorTree extends CAIMainTree
{
};

abstract class CAIDeathTree extends CAIMainTree
{
	
};

abstract class CAICustomMainTree extends CAIMainTree
{
};

abstract class CAIReactionTree extends CAIMainTree
{
};

abstract class CAISoftReactionTree extends CAIMainTree
{
};

abstract class CAIFleeTree extends CAISubTree
{
};

abstract class CAISubTree extends CAITree
{
};


abstract class CAIActionTree extends CAISubTree
{
};

abstract class CAICombatActionTree extends CAIActionTree
{
};

abstract class CAIRidingSubTree extends CAISubTree
{
};

class CAIRetreatTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\npc_simple_retreat";
};


class CAIKeepDistanceTree extends CAISubTree
{
	editable var moveType 		: EMoveType;
	
	default moveType = MT_Sprint;
	
	default aiTreeName = "resdef:ai\npc_keep_distance";
};

class CAIRunToGAKnockdown extends CAIKeepDistanceTree
{
	default aiTreeName = "resdef:ai\monster_run_to_ga_knockdown";
}





abstract class CAIMainParameters extends CAIParameters
{
};

abstract class CAIIdleParameters extends CAIMainParameters
{

};
abstract class CAICombatDecoratorParameters extends CAIMainParameters
{
};
abstract class CAICombatParameters extends CAIMainParameters
{
};
abstract class CAIAxiiParameters extends CAIMainParameters
{
};
abstract class CAITauntParameters extends CAIMainParameters
{
};
abstract class CAIDeathParameters extends CAIMainParameters
{
};
abstract class CAIReactionsParameters extends CAIMainParameters
{
};
abstract class CAISoftReactionsParameters extends CAIMainParameters
{
};
abstract class CAICustomMainParameters extends CAIMainParameters             
{
};
abstract class CAISubTreeParameters extends CAIParameters
{
};
abstract class CAIActionTreeParameters extends CAISubTreeParameters
{
};
abstract class CAICombatActionParameters extends CAIActionTreeParameters
{
};
abstract class CAIWanderParameters extends CAIIdleParameters
{
};
abstract class CAIRidingSubTreeParameters extends CAISubTreeParameters
{
};
abstract class CAIFleeParameters extends CAISubTreeParameters
{
};



import abstract class IAIActionTree extends CAITree 
{
};
import abstract class IRiderActionTree extends CAITree
{
};



import abstract class IAIActionParameters extends CAIParameters
{
};
import abstract class IRiderActionParameters extends CAIParameters
{
};





import abstract class CAIRedefinitionParameters extends IAIParameters
{
	
};

class CAIMultiRedefinitionParameters extends CAIRedefinitionParameters
{
	editable inlined var subParams : array< CAIRedefinitionParameters >;
};

class CAIIdleRedefinitionParameters extends CAIRedefinitionParameters
{
	editable inlined var idleTree : CAIIdleTree;
};

class CAIRiderIdleRedefinitionParameters extends CAIRedefinitionParameters
{
	editable inlined var riderIdleTree : CAIRiderIdle;
	
	function Init()
	{
		riderIdleTree = new CAINpcIdleHorseRider in this;
		riderIdleTree.OnCreated();
	}
};

class CAIStartingBehaviorParameters extends CAIRedefinitionParameters
{
	editable inlined var startingBehavior : IAIActionTree;
	editable var startingBehaviorPriority : int;
	
	default startingBehaviorPriority = 100;
	
	function SetPriority( p : int )
	{
		startingBehaviorPriority = p;
	}
};

class CAIRiderStartingBehaviorParameters extends CAIRedefinitionParameters
{
	editable inlined var startingBehavior : IRiderActionTree;
	editable var startingBehaviorPriority : int;
	
	default startingBehaviorPriority = 100;
	
	function SetPriority( p : int )
	{
		startingBehaviorPriority = p;
	}
};

class CAICombatDecoratorRedefinitionParameters extends CAIRedefinitionParameters
{
	editable inlined var combatDecorator : CAICombatDecoratorTree;
};

class CAINPCGroupTypeRedefinition extends CAIRedefinitionParameters
{
	editable var npcGroupType : ENPCGroupType;
};