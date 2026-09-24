/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAIWildHuntTwoHandedSwordDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAIWildHuntTwoHandedSwordCombat in this;
		combatTree.Init();
	}
};

class CAIWildHuntTwoHandedSwordCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAIWildHuntTwoHandedSwordCombatParams in this;
		params.OnCreated();
	}
};

class CAIWildHuntTwoHandedSwordCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAIWildHuntTwoHandedSwordCombatStyle in this );  	
		
		InitializeCombatStyles();
	}
};

class CAIWildHuntTwoHandedSwordCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAIWildHuntStyleTwoHandedSwordParams in this;
		params.OnCreated();
	}	
};

class CAIWildHuntStyleTwoHandedSwordParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_2Handed_Sword;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		attackBehavior.params.attackAction = new CAIWildHuntTwoHandedSwordAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.attackActionRange = 'basic_strike';
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAIWildHuntCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAIWildHuntTwoHandedAxeDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAIWildHuntTwoHandedAxeCombat in this;
		combatTree.OnCreated();
	}
};

class CAIWildHuntTwoHandedAxeCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAIWildHuntTwoHandedAxeCombatParams in this;
		params.OnCreated();
	}
};

class CAIWildHuntTwoHandedAxeCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAIWildHuntTwoHandedAxeCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
};

class CAIWildHuntTwoHandedAxeCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAIWildHuntStyleTwoHandedAxeParams in this;
		params.OnCreated();
	}	
};

class CAIWildHuntStyleTwoHandedAxeParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'axe2h';
	default behGraph = EBG_Combat_2Handed_Axe;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAIWildHuntTwoHandedPolearmAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAIWildHuntTwoHandedHalberdDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAIWildHuntTwoHandedHalberdCombat in this;
		combatTree.OnCreated();
	}
};

class CAIWildHuntTwoHandedHalberdCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAIWildHuntTwoHandedHalberdCombatParams in this;
		params.OnCreated();
	}
};

class CAIWildHuntTwoHandedHalberdCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAIWildHuntTwoHandedHalberdCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
};

class CAIWildHuntTwoHandedHalberdCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAIWildHuntStyleTwoHandedHalberdParams in this;
		params.OnCreated();
	}	
};

class CAIWildHuntStyleTwoHandedHalberdParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'halberd2h';
	default behGraph = EBG_Combat_2Handed_Halberd;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAIWildHuntTwoHandedPolearmAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.attackActionRange 	= 'thrust250';
		attackBehavior.params.farAttackActionRange 	= 'thrust320';
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAIWildHuntTwoHandedHammerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAIWildHuntTwoHandedHammerCombat in this;
		combatTree.OnCreated();
	}
};

class CAIWildHuntTwoHandedHammerCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAIWildHuntTwoHandedHammerCombatParams in this;
		params.OnCreated();
	}
};

class CAIWildHuntTwoHandedHammerCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAIWildHuntTwoHandedHammerCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
};

class CAIWildHuntTwoHandedHammerCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAIWildHuntStyleTwoHandedHammerParams in this;
		params.OnCreated();
	}	
};

class CAIWildHuntStyleTwoHandedHammerParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'hammer2h';
	default behGraph = EBG_Combat_2Handed_Hammer;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAIWildHuntTwoHandedPolearmAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAIWildHuntTwoHandedSpearDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAIWildHuntTwoHandedSpearCombat in this;
		combatTree.OnCreated();
	}
};

class CAIWildHuntTwoHandedSpearCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAIWildHuntTwoHandedSpearCombatParams in this;
		params.OnCreated();
	}
};

class CAIWildHuntTwoHandedSpearCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAIWildHuntTwoHandedSpearCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
};

class CAIWildHuntTwoHandedSpearCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAIWildHuntStyleTwoHandedSpearParams in this;
		params.OnCreated();
	}	
};

class CAIWildHuntStyleTwoHandedSpearParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'spear2h';
	default behGraph = EBG_Combat_2Handed_Spear;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAIWildHuntTwoHandedPolearmAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.attackActionRange = 'thrust250';
		attackBehavior.params.farAttackAction = new CAISimpleAttackActionTree in attackBehavior.params;
		attackBehavior.params.farAttackAction.OnCreated();
		attackBehavior.params.farAttackActionRange = 'thrust320';
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAIWildHuntTwoHandedSwordAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\wildhunt_attackaction_sword2h";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};
class CAIWildHuntTwoHandedPolearmAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\wildhunt_attackaction_twohanded";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};