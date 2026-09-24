/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAINpcCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\npc_basecombat";

	editable inlined var params : CAINpcCombatParams;
	
	function Init()
	{
		params = new CAINpcCombatParams in this;
		params.OnCreated();
	}
}


class CAINpcCombatParams extends CAICombatParameters
{
	editable var scaredCombat : bool;
	editable inlined var scaredBranch  : CAIScaredSubTree;
	editable inlined var combatStyles : array<CAINpcCombatStyle>;
	editable inlined var criticalState : CAINpcCriticalState;
	
	editable var preferedCombatStyle : EBehaviorGraph;
	editable var increaseHitCounterOnlyOnMelee : bool;
	
	default increaseHitCounterOnlyOnMelee = true;
	
	
	
	
	editable var reachabilityTolerance : float;
	editable var targetOnlyPlayer : bool;
	editable var hostileActorWeight : float;
	editable var currentTargetWeight : float;
	editable var rememberedHits : int;
	editable var hitterWeight : float;
	editable var maxWeightedDistance : float;
	editable var distanceWeight : float;
	editable var playerWeightProbability : int;
	editable var playerWeight : float;
	editable var skipVehicle : ECombatTargetSelectionSkipTarget;
	editable var skipVehicleProbability : int;
	editable var skipUnreachable : ECombatTargetSelectionSkipTarget;
	editable var skipUnreachableProbability : int;
	editable var monsterWeight : float;
	
	
	default	hostileActorWeight 	= 10.0f;
	
	default reachabilityTolerance = 2.0f;
	
	default	hitterWeight 		= 20.0f; 
	default	currentTargetWeight = 9.0f;  
	default	playerWeight		= 100.0f; 
	
	
	
	
	default	distanceWeight 		= 30.0f;
	default maxWeightedDistance = 30.0f;
	
	default monsterWeight		= 101.0f;
		
	
	default	targetOnlyPlayer = false;
	default	playerWeightProbability = 100;
	default rememberedHits = 2;

	
	default skipVehicle 		   = CTSST_SKIP_ALWAYS;
	default	skipVehicleProbability = 100;		
	
	
	default skipUnreachable 		   	= CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS;
	default	skipUnreachableProbability	= 100;
	
	function Init()
	{		
		SetupCombatStyles();
		
		scaredBranch = new CAIScaredTree in this;
		scaredBranch.OnCreated();
		
		criticalState = new CAINpcCriticalState in this;
		criticalState.OnCreated();
		criticalState.params.FinisherAnim 		= 'HumanKnockDownFinisher';
	}
	
	protected function SetupCombatStyles()
	{
		combatStyles.Clear();
	}
	
	protected function SetupCSFinisherAnims()
	{
		
	}
	
	protected function ClearCSFinisherAnims()
	{
		criticalState.params.FinisherAnim = '';		
	}
	
	public function InitializeCombatStyles()
	{
		var i : int;
		
		for ( i = 0; i < combatStyles.Size(); i+=1 )
		{
			combatStyles[ i ].OnCreated();
		}
	}
}




class CAINpcFistsDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
};

class CAINpcFistsCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcFistsCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcFistsEasyDefaults extends CAINpcFistsDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsEasyCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
}

class CAINpcFistsEasyCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsEasyCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcFistsEasyCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsEasyCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcFistsHardDefaults extends CAINpcFistsDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsHardCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
}

class CAINpcFistsHardCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsHardCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcFistsHardCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsHardCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcGuardDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcGuardCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcGuardCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcGuardCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcGuardCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAnyCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcOneHandedAnyCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcOneHandedDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcOneHandedCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcOneHandedCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcOneHandedAxeDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedAxeCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcOneHandedAxeCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedAxeCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcOneHandedAxeCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedAxeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcOneHandedBluntDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedBluntCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcOneHandedBluntCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedBluntCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcOneHandedBluntCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedBluntCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcTwoHandedHammerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedHammerCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcTwoHandedHammerCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedHammerCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcTwoHandedHammerCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedHammerCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcTwoHandedAxeDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedAxeCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcTwoHandedAxeCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedAxeCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcTwoHandedAxeCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAxeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcTwoHandedHalberdDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedHalberdCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcTwoHandedHalberdCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedHalberdCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcTwoHandedHalberdCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedHalberdCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcTwoHandedSpearDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedSpearCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcTwoHandedSpearCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedSpearCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcTwoHandedSpearCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedSpearCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcPitchforkDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcPitchforkCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcPitchforkCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcPitchforkCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcPitchforkCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcPitchforkCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcShieldDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcShieldCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcShieldCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcShieldCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcShieldCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcShieldCombatStyle in this );
		combatStyles.PushBack( new CAINpcOneHandedAnyCombatStyle in this );
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this );
		
		InitializeCombatStyles();
	}
}




class CAINpcBowDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBowCombat in this;
		combatTree.Init();
	}
};

class CAINpcBowCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBowCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcBowCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcBowCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcBowmanMeleeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_Bow;
	}
}




class CAINpcCrossbowDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCrossbowCombat in this;
		combatTree.Init();
	}
};

class CAINpcCrossbowCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCrossbowCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcCrossbowCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCrossbowCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcBowmanMeleeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_Crossbow;
	}
}




class CAINpcTwoHandedSwordDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedSwordCombat in this;
		combatTree.Init();
	}
};

class CAINpcTwoHandedSwordCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedSwordCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcTwoHandedSwordCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedSwordCombatStyle in this );  
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_2Handed_Sword;
	}
}




class CAINpcGregoireDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcGregoireCombat in this;
		combatTree.Init();
	}
};

class CAINpcGregoireCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcGregoireCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcGregoireCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcGregoireCombatStyle in this );  	
		
		InitializeCombatStyles();
	}
}




class CAIHjalmarDefaults extends CAINpcDefaults
{
	function Init()
	{
		var hjalmarStyle : CAINpcCombatStyle;
		super.OnCreated();
		combatTree.params.combatStyles.Clear();
		hjalmarStyle = new CAINpcCombatStyle in this;
		hjalmarStyle.OnCreated();
		hjalmarStyle.params = new CAINpcStyleHjalmarParams in this;
		hjalmarStyle.params.OnCreated();
		combatTree.params.combatStyles.PushBack(hjalmarStyle);
		hjalmarStyle = new CAINpcCombatStyle in this;
		hjalmarStyle.OnCreated();
		hjalmarStyle.params = new CAINpcStyleFistsHardParams in this;
		hjalmarStyle.params.OnCreated();
		combatTree.params.combatStyles.PushBack(hjalmarStyle);
	}
};




class CAINpcWitcherDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWitcherCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcWitcherCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWitcherCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcWitcherCombatParams extends CAINpcCombatParams
{
	protected function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWitcherCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}




class CAINpcEredinDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcEredinCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcEredinCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcEredinCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcEredinCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcEredinCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}




class CAINpcImlerithDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcImlerithCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcImlerithCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcImlerithCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcImlerithCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcImlerithCombatStyle in this ); 		
		combatStyles.PushBack( new CAINpcImlerithSecondStageCombatStyle in this );
		
		InitializeCombatStyles();
		
	}
}





class CAINpcCaranthirDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCaranthirCombat in this;
		combatTree.OnCreated();
		
	}
};

class CAINpcCaranthirCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCaranthirCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcCaranthirCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCaranthirCombatStyle in this ); 
		increaseHitCounterOnlyOnMelee = false;
		LogEffects( "increaseHitCounterOnlyOnMelee " + increaseHitCounterOnlyOnMelee);
		
		InitializeCombatStyles();
		
	}
}




class CAINpcCaretakerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCaretakerCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcCaretakerCombat extends CAINpcCombat
{		
	
	function Init()
	{
		params = new CAINpcCaretakerCombatParams in this;
		params.OnCreated();		
	}
	
}

class CAINpcCaretakerCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCaretakerCombatStyle in this ); 
		increaseHitCounterOnlyOnMelee = false;
		
		InitializeCombatStyles();		
	}
}




class CAINpcWitcherFollowerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWitcherFollowerCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcWitcherFollowerCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWitcherFollowerCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcWitcherFollowerCombatParams extends CAINpcWitcherCombatParams
{
	var i : int;
	
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		super.SetupCombatStyles();
		
		combatStyles[0].params.combatTacticTree.params.specialActions.PushBack( new CAIDwimeritiumBombSpecialAction in combatStyles[0].params.combatTacticTree.params );
		combatStyles[0].params.combatTacticTree.params.InitializeSpecialActions();
		
		for ( i=0 ; i<combatStyles.Size() ; i+=1 )
		{
			combatStyles[i].params.potentialFollower = true;
		}
	}
}




class CAINpcCiriDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCiriCombat in this;
		combatTree.OnCreated();
	}
};

class CAINpcCiriCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCiriCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcCiriCombatParams extends CAINpcCombatParams
{
	var i : int;
	
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCiriCombatStyle in this );		
		
		InitializeCombatStyles();
		
		for ( i=0 ; i<combatStyles.Size() ; i+=1 )
		{
			combatStyles[i].params.potentialFollower = true;
		}
	}
}




abstract class CAINpcSorceressDefaults extends CAINpcDefaults
{
};

class CAINpcYenneferDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcYenneferCombat in this;
		combatTree.Init();
	}
};

class CAINpcTrissDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTrissCombat in this;
		combatTree.Init();
	}
};

class CAINpcKeiraDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcKeiraCombat in this;
		combatTree.Init();
	}
};

class CAINpcPhilippaDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcPhilippaCombat in this;
		combatTree.Init();
		reactionTree = new CAIPhilippaReactionsTree in this;
		reactionTree.Init();
	}
};

class CAINpcLynxWitchDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcLynxWitchCombat in this;
		combatTree.Init();
	}
};



class CAINpcYenneferCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcYenneferCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcTrissCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTrissCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcKeiraCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcKeiraCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcPhilippaCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcPhilippaCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcLynxWitchCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcLynxWitchCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcSorceressCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		var i : int;
		
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcSorceressCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcYenneferCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcYenneferCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcTrissCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTrissCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcKeiraCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcKeiraCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcPhilippaCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcPhilippaCombatStyle in this );
		combatStyles.PushBack( new CAINpcPhilippaCustomCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcLynxWitchCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcLynxWitchCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}




abstract class CAINpcSorcererDefaults extends CAINpcDefaults
{
};

class CAINpcDruidDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcDruidCombat in this;
		combatTree.Init();
	}
};

class CAINpcDruidCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDruidCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcWindMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWindMageCombat in this;
		combatTree.Init();
	}
};

class CAINpcWindMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWindMageCombatParams in this;
		params.OnCreated();
	}
}


class CAINpcBobWindMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBobWindMageCombat in this;
		combatTree.Init();
	}
};

class CAINpcBobWindMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBobWindMageCombatParams in this;
		params.OnCreated();
	}
}


class CAINpcBobWaterMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBobWaterMageCombat in this;
		combatTree.Init();
	}
};

class CAINpcBobWaterMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBobWaterMageCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcAvallachDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcAvallachCombat in this;
		combatTree.Init();
	}
};

class CAINpcAvallachCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcAvallachCombatParams in this;
		params.OnCreated();
	}
}


class CAINpcSorcererCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		var i : int;
		
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcSorcererCombatStyle in this );		
		
		InitializeCombatStyles();
	}
};

class CAINpcDruidCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDruidCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcWindMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWindMageCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcBobWindMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWindMageCombatStyleBob in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcBobWaterMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWaterMageCombatStyleBob in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcAvallachCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcAvallachCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}




abstract class CAINpcMainDefaults extends CAINpcDefaults
{
}



class CAINpcIorwvethDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBowCombat in this;
		combatTree.Init();
		combatTree.params.preferedCombatStyle = EBG_Combat_1Handed_Any;
	}
};



class CAINpcZoltanDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcZoltanCombat in this;
		combatTree.Init();
		combatTree.params.preferedCombatStyle = EBG_Combat_2Handed_Axe;
	}
};

class CAINpcZoltanCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcZoltanCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcZoltanCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAxeCombatStyle in this );		
		combatStyles.PushBack( new CAINpcOneHandedBluntCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}



class CAINpcVesDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcVesCombat in this;
		combatTree.Init();
	}
};

class CAINpcVesCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcVesCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcVesCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this );		
		combatStyles.PushBack( new CAINpcBowCombatStyle in this );		
		
		InitializeCombatStyles();
		
		combatStyles[1].params.combatTacticTree.params.specialActions.PushBack( new CAIShootBarrelsSpecialAction in combatStyles[1].params.combatTacticTree.params );
		combatStyles[1].params.combatTacticTree.params.InitializeSpecialActions();
		
		preferedCombatStyle = EBG_Combat_1Handed_Sword;
	}
}




class CAINpcRocheDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcRocheCombat in this;
		combatTree.Init();
	}
};

class CAINpcRocheCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcRocheCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcRocheCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this );		
		combatStyles.PushBack( new CAINpcCrossbowCombatStyle in this );
		
		InitializeCombatStyles();
		
		combatStyles[1].params.combatTacticTree.params.specialActions.PushBack( new CAIShootBarrelsSpecialAction in combatStyles[1].params.combatTacticTree.params );
		combatStyles[1].params.combatTacticTree.params.InitializeSpecialActions();
		
		preferedCombatStyle = EBG_Combat_1Handed_Sword;
	}
}




class CAINpcOlgierdCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOlgierdCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcOlgierdCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOlgierdCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}




class CAINpcDettlaffVampireCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDettlaffVampireCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcDettlaffVampireCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDettlaffVampireCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}



class CAINpcDettlaffMinion extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcDettlaffMinionCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDettlaffMinionDeath in this;
		deathTree.OnCreated();
	}
};
class CAIDettlaffMinionDeath extends CAIDeathTree
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_dettlaff_minion_death.w2behtree";

	editable inlined var params : CAINpcDeathParams;
	
	function Init()
	{
		params = new CAINpcDeathParams in this;
		params.OnCreated();
	}
};
class CAINpcDettlaffMinionCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDettlaffMinionCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcDettlaffMinionCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDettlaffMinionCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}