/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAINpcCombatStyle extends CAISubTree
{
	default aiTreeName = "resdef:ai\combat/npc_combatstyle";

	editable inlined var params : CAINpcCombatStyleParams;
	
	var highPriority : bool;
	
	function Init()
	{
		params = new CAINpcCombatStyleParams in this;
		params.OnCreated();
	}
};


class CAINpcCombatStyleParams extends CAISubTreeParameters
{
	
	editable var LeftItemType 				: name;
	editable var RightItemType 				: name;
	editable var chooseSilverIfPossible 	: bool;
	editable var behGraph 					: EBehaviorGraph;
	editable var minCombatStyleDistance 	: float;
	
	default minCombatStyleDistance = 0.f;
	
	
	editable inlined var defenseActions 		: array<CAINpcDefenseAction>;
	
	
	editable inlined var combatTacticTree 		: CAINpcTacticTree;
	
	
	editable inlined var attackBehavior 		: CAIAttackBehaviorTree;
	
	
	editable var potentialFollower				: bool;
	
	
	editable var tryToUseFormation				: bool;
	editable inlined var formationTacticTree 	: CAINpcFormationTacticTree;
	
	default tryToUseFormation = false;
	
	function Init()
	{
		var i : int;
		var defenseAction : CAINpcDefenseAction;
		
		defenseAction = new CAINpcParryAction in this;
		defenseAction.OnCreated();
		defenseActions.PushBack(defenseAction);
		
		defenseAction = new CAINpcDodgeAction in this;
		defenseAction.OnCreated();
		defenseActions.PushBack(defenseAction);
		
		defenseAction = new CAINpcCounterAction in this;
		defenseAction.OnCreated();
		defenseActions.PushBack(defenseAction);
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		attackBehavior = new CAIAttackBehaviorTree in this;
		attackBehavior.OnCreated();
		
		if ( tryToUseFormation )
		{
			formationTacticTree = new CAINpcFormationTacticTree in this;
			formationTacticTree.OnCreated();
		}
	}
};




class CAINpcOneHandedSwordCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleOneHandedSwordParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleOneHandedSwordParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'sword1h';
	default behGraph = EBG_Combat_1Handed_Sword;
	
	function Init()
	{
		super.Init();
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		attackBehavior.params.chargeAction = true;
	}
};




class CAINpcOneHandedAxeCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleOneHandedAxeParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleOneHandedAxeParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'axe1h';
	default behGraph = EBG_Combat_1Handed_Axe;
	
	function Init()
	{
		super.Init();
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		attackBehavior.params.chargeAction = true;
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcDodgeAction in this );
	}
};




class CAINpcOneHandedBluntCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleOneHandedBluntParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleOneHandedBluntParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'blunt1h';
	default behGraph = EBG_Combat_1Handed_Blunt;
	
	function Init()
	{
		super.Init();
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		attackBehavior.params.chargeAction = true;
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcDodgeAction in this );
	}
};




class CAINpcOneHandedAnyCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleOneHandedAnyParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleOneHandedAnyParams extends CAINpcCombatStyleParams
{
	default RightItemType = '1handedWeapon';
	default behGraph = EBG_Combat_1Handed_Any;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		attackBehavior.params.chargeAction = true;
		
		
		defenseActions.Clear();
	}
};



class CAINpcTwoHandedAnyCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedAnyParams in this;
		params.OnCreated();
	}	
};
class CAINpcStyleTwoHandedAnyParams extends CAINpcCombatStyleParams
{
	default RightItemType = '2handedWeapon';
	default behGraph = EBG_Combat_2Handed_Any;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		
		
		defenseActions.Clear();
	}
};




abstract class CAINpcFistsCombatStyleBaseParams extends CAINpcCombatStyleParams
{
	editable var canBeScared : bool;
	
	default RightItemType 	= 'fist';
	default behGraph 		= EBG_Combat_Fists;
	default canBeScared 	= true;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		combatTacticTree = new CAINpcSurroundTacticCloseTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcParryAction in this );
		defenseActions.PushBack( new CAINpcDodgeAction in this );
		defenseActions.PushBack( new CAINpcCounterFistFightAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcFistsCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleFistsParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleFistsParams extends CAINpcFistsCombatStyleBaseParams
{
	function Init()
	{
		super.Init();
		
		attackBehavior.params.attackAction = new CAIFistAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.farAttackAction = new CAISimpleAttackActionTree in this;
		attackBehavior.params.farAttackAction.OnCreated();
	}
};





class CAINpcFistsEasyCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleFistsEasyParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleFistsEasyParams extends CAINpcFistsCombatStyleBaseParams
{
	function Init()
	{
		super.Init();
		
		attackBehavior.params.attackAction = new CAIFistAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
	}
};




class CAINpcFistsHardCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleFistsHardParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleFistsHardParams extends CAINpcFistsCombatStyleBaseParams
{
	function Init()
	{
		super.Init();
		attackBehavior.params.attackAction = new CAIComboFistAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.farAttackAction = new CAISimpleAttackActionTree in this;
		attackBehavior.params.farAttackAction.OnCreated();
	}
};




class CAINpcShieldCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleShieldParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleShieldParams extends CAINpcCombatStyleParams
{
	default RightItemType = '1handedWeapon';
	default LeftItemType = 'shield';
	default behGraph = EBG_Combat_Shield;
	
	function Init()
	{
		super.Init();
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		combatTacticTree.params.allowChangingGuard 		= false;
	}
};




class CAINpcSorceressCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleSorceressParams in this;
		params.OnCreated();
	}	
};

class CAINpcYenneferCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();
		
		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'magic_attack_lightning';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAICastLightningSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAICastRipApartSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcKeiraCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();
		
		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'magic_attack_lightning';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAICastLightningSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAICastRipApartSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIShootProjectilesFromGroundSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcTrissCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();
		
		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'magic_attack_fire';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAICastRipApartSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAICastFireballSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcPhilippaCustomCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();
		
		params = new CAINpcStylePhilippaParams in this;
		params.OnCreated();
		
		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'magic_attack_arcane';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcPhilippaCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();

		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'magic_attack_arcane';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAICastArcaneMissileSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAICastArcaneExplosionSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcLynxWitchCombatStyle extends CAINpcSorceressCombatStyle
{
	function Init()
	{
		var i : int;
		var sorceressParams : CAINpcStyleSorceressParams;
		
		super.Init();
		
		sorceressParams = (CAINpcStyleSorceressParams)params;
		sorceressParams.magicAttackResourceName = 'ep2_magic_attack_lightning';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAILynxWitchCastLightningSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAICastRipApartSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAILynxWitchShootProjectilesFromGroundSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}


class CAINpcStyleSorceressParams extends CAINpcCombatStyleParams
{
	default behGraph = EBG_Combat_Sorceress;
	default RightItemType = 'fist';

	editable var magicAttackResourceName : name;
	
	default magicAttackResourceName = 'magic_attack_lightning';
	
	function Init()
	{
		var i : int;
		super.Init();
		
		combatTacticTree = new CAINpcSorceressTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterPushAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};

class CAINpcStylePhilippaParams extends CAINpcCombatStyleParams
{
	default behGraph = EBG_Combat_Sorceress;
	default RightItemType = 'fist';

	editable var magicAttackResourceName : name;
	
	default magicAttackResourceName = 'magic_attack_lightning';
	
	function Init()
	{
		var i : int;
		super.Init();
		
		combatTacticTree = new CAINpcPhilippaTacticTree in this;
		combatTacticTree.OnCreated();
		
		defenseActions.Clear();
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcSorcererCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		
		params = new CAINpcStyleSorcererParams in this;
		params.OnCreated();
	}	
};

class CAINpcDruidCombatStyle extends CAINpcSorcererCombatStyle
{
	function Init()
	{
		var i : int;
		var sorcererParams : CAINpcStyleSorcererParams;
		
		super.Init();
		
		sorcererParams = (CAINpcStyleSorcererParams)params;
		sorcererParams.magicAttackResourceName = 'magic_attack_lightning';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicGroundBlastSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicPushSpecialAction in params.combatTacticTree.params );
		
		
		
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcWindMageCombatStyle extends CAINpcSorcererCombatStyle
{
	function Init()
	{
		var i : int;
		var sorcererParams : CAINpcStyleSorcererParams;
		
		super.Init();
		
		sorcererParams = (CAINpcStyleSorcererParams)params;
		sorcererParams.magicAttackResourceName = 'magic_attack_sand';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandGroundBlastSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandPushSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicTornadoSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWindCoilSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWindGustSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandCageSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicShieldSpecialAction in params.combatTacticTree.params );
		
		
		
		
		
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcWindMageCombatStyleBob extends CAINpcSorcererCombatStyle
{
	function Init()
	{
		var i : int;
		var sorcererParams : CAINpcStyleSorcererParams;
		
		super.Init();
		
		sorcererParams = (CAINpcStyleSorcererParams)params;
		sorcererParams.magicAttackResourceName = 'magic_attack_sand';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandGroundBlastSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandPushSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicTornadoSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWindCoilSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWindGustSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicSandCageSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicShieldSpecialActionBob in params.combatTacticTree.params );
		
		
		
		
		
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}


class CAINpcWaterMageCombatStyleBob extends CAINpcSorcererCombatStyle
{
	function Init()
	{
		var i : int;
		var sorcererParams : CAINpcStyleSorcererParams;
		
		super.Init();
		
		sorcererParams = (CAINpcStyleSorcererParams)params;
		sorcererParams.magicAttackResourceName = 'magic_attack_water';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWaterGroundBlastSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWaterPushSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWaterTornadoSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWaterCoilSpecialActionBob in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWindGustSpecialActionBob in params.combatTacticTree.params ); 
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicWaterCageSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIWaterMagicShieldSpecialActionBob in params.combatTacticTree.params );
		
		
		
		
		
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}

class CAINpcAvallachCombatStyle extends CAINpcSorcererCombatStyle
{
	function Init()
	{
		var i : int;
		var sorcererParams : CAINpcStyleSorcererParams;
		
		super.Init();
		
		sorcererParams = (CAINpcStyleSorcererParams)params;
		sorcererParams.magicAttackResourceName = 'magic_attack_lightning';
		
		params.combatTacticTree.params.specialActions.Clear();
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicGroundBlastSpecialAction in params.combatTacticTree.params );
		params.combatTacticTree.params.specialActions.PushBack( new CAIMagicPushSpecialAction in params.combatTacticTree.params );
		
		
		
		params.combatTacticTree.params.InitializeSpecialActions();
	}
}


class CAINpcStyleSorcererParams extends CAINpcCombatStyleParams
{
	default behGraph = EBG_Combat_2Handed_Staff;
	default RightItemType = 'staff2h';

	editable var magicAttackResourceName : name;
	
	default magicAttackResourceName = 'magic_attack_fire';
	
	function Init()
	{
		var i : int;
		super.Init();
		
		
		combatTacticTree = new CAINpcSorcererTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.attackActionRange 	= 'thrust250';
		attackBehavior.params.farAttackActionRange 	= 'thrust320';
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterPushAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};






class CAINpcBowCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleBowParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleBowParams extends CAINpcCombatStyleParams
{
	default LeftItemType = 'bow';
	default behGraph = EBG_Combat_Bow;
	default minCombatStyleDistance = 6.0;
	
	function Init()
	{
		super.Init();
		
		minCombatStyleDistance = 6.0;
		
		combatTacticTree = new CAINpcSurroundRangedTacticTree in this;
		combatTacticTree.OnCreated();
	}
};




class CAINpcBowmanMeleeCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		var i : int;
		
		super.Init();
		params = new CAINpcStyleBowmanMeleeParams in this;
		params.OnCreated();
	}	
};


class CAINpcStyleBowmanMeleeParams extends CAINpcCombatStyleParams
{
	default RightItemType = '1handedWeapon';
	default behGraph = EBG_Combat_1Handed_Any;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		combatTacticTree = new CAINpcSurroundTacticFarTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcParryAction in this );
		defenseActions.PushBack( new CAINpcDodgeAction in this );
		defenseActions.PushBack( new CAINpcCounterAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcCrossbowCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleCrossbowParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleCrossbowParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'crossbow';
	default behGraph = EBG_Combat_Crossbow;
	default minCombatStyleDistance = 6.0;
	
	function Init()
	{
		super.Init();
		
		minCombatStyleDistance = 6.0;
		
		combatTacticTree = new CAINpcSurroundRangedTacticTree in this;
		combatTacticTree.OnCreated();
	}
};



class CAINpcTwoHandedHammerCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedHammerParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleTwoHandedHammerParams extends CAINpcCombatStyleParams
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
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcTwoHandedAxeCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedAxeParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleTwoHandedAxeParams extends CAINpcCombatStyleParams
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
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcTwoHandedHalberdCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedHalberdParams in this;
		params.OnCreated();
	}
};

class CAINpcStyleTwoHandedHalberdParams extends CAINpcCombatStyleParams
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
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
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




class CAINpcTwoHandedSpearCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedSpearParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleTwoHandedSpearParams extends CAINpcCombatStyleParams
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
		
		
		attackBehavior.params.attackAction = new CAITwoHandedAttackActionTree in attackBehavior.params;
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




class CAINpcPitchforkCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStylePitchforkParams in this;
		params.OnCreated();
	}	
};

class CAINpcStylePitchforkParams extends CAINpcCombatStyleParams
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
		
		
		attackBehavior.params.attackAction = new CAIPitchforkAttackActionTree in attackBehavior.params;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.attackActionRange = 'thrust250';
				
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcCounterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcWitcherCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcWitcherCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcWitcherCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_Witcher;
	default chooseSilverIfPossible = true;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		attackBehavior.params.attackAction = new CAIWitcherAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.approachAction 	= true;
		attackBehavior.params.throwBomb 		= true;
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcWitcherCounterAction in this );
		defenseActions.PushBack( new CAINpcParryAction in this );
		defenseActions.PushBack( new CAINpcDodgeAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcEredinCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcEredinCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcEredinCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_WildHunt_Eredin;
	
	function Init()
	{
		var parryAction : CAINpcEredinParryAction;
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcEredinTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		
		parryAction = new CAINpcEredinParryAction in this;
		parryAction.activationTimeLimitBonusHeavy = 3.0;
		parryAction.activationTimeLimitBonusLight = 2.0;
		
		defenseActions.PushBack( parryAction );
		defenseActions.PushBack( new CAINpcEredinCounterAction in this ); 
		defenseActions.PushBack( new CAINpcEredinRaiseGuardAction in this );
		defenseActions.PushBack( new CAINpcEredinSignsBlockAction in this ); 
		defenseActions.PushBack( new CAINpcEredinDodgeAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};



class CAINpcCaranthirCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcCaranthirCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcCaranthirCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'hammer2h';
	default behGraph = EBG_Combat_WildHunt_Caranthir;
		
	function Init()
	{
		var i : int;
		super.Init();
		
		
		
		combatTacticTree = new CAINpcCaranthirTacticTree in this;
		combatTacticTree.OnCreated();
		combatTacticTree.params.dontUseRunWhileStrafing = true;
		
		
		
		
		defenseActions.Clear();					
		defenseActions.PushBack( new CAINpcCaranthirCounterAction in this );
		defenseActions.PushBack( new CAINpcCaranthirIceArmorAction in this );
		
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
		
	}
};





class CAINpcImlerithCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcImlerithCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcImlerithCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = '1handedWeapon';
	default LeftItemType = 'shield';
	default behGraph = EBG_Combat_WildHunt_Imlerith;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcImlerithTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		
		defenseActions.PushBack( new CAINpcImlerithParry in this );
		defenseActions.PushBack( new CAINpcImlerithCounterAction in this );
		defenseActions.PushBack( new CAINpcImlerithGuardAction in this );
		defenseActions.PushBack( new CAINpcImlerithSignsBlockAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcImlerithSecondStageCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcImlerithSecondStageCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcImlerithSecondStageCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = '1handedWeapon';
	default LeftItemType = 'None';
	default behGraph = EBG_Combat_WildHunt_Imlerith_Second_Stage;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcImlerithSecondStageTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcImlerithCounterActionSecondStage in this );
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};





class CAINpcCaretakerCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcCaretakerCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcCaretakerCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'axe2h';
	default behGraph = EBG_Combat_Caretaker;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcCaretakerTacticTree in this;
		combatTacticTree.OnCreated();
	}
};




class CAINpcCiriCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcCiriCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcCiriCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_Witcher;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		attackBehavior.params.attackAction = new CAICiriAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
		attackBehavior.params.teleportAction 	= true;
		
		
		defenseActions.Clear();
	}
};




class CAINpcTwoHandedSwordCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleTwoHandedSwordParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleTwoHandedSwordParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_2Handed_Sword;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcSurroundTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		attackBehavior.params.attackAction = new CAISword2hAttackActionTree in this;
		attackBehavior.params.attackAction.OnCreated();
	}
};




class CAINpcGregoireCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcGregoireCombatStyleParams in this;
		params.OnCreated();
	}	
};

class CAINpcGregoireCombatStyleParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';

	default behGraph = EBG_Combat_Gregoire;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		
		combatTacticTree = new CAINpcGregoireTacticTree in this;
		combatTacticTree.OnCreated();
		
		
		defenseActions.Clear();
		
		defenseActions.PushBack( new CAINpcGregoireCounterAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};





class CAINpcVesemirTutorialCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleVesemirTutorialParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleVesemirTutorialParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_Witcher;
	
	function Init()
	{
		super.Init();
		
		
		combatTacticTree = new CAINpcVesemirTutorialTacticTree in this;
		combatTacticTree.OnCreated();
		
	}
};






class CAINpcOlgierdCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleOlgierdParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleOlgierdParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'steelsword';
	default behGraph = EBG_Combat_Olgierd;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		combatTacticTree = new CAINpcOlgierdTacticTree in this;
		combatTacticTree.OnCreated();
		
		defenseActions.Clear();

		defenseActions.PushBack( new CAINpcOlgierdParryAction in this ); 
		defenseActions.PushBack( new CAINpcOlgierdCounterAction in this ); 
		defenseActions.PushBack( new CAINpcOlgierdDodgeAction in this );
		defenseActions.PushBack( new CAINpcOlgierdCounterAfterHitAction in this );
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};




class CAINpcDettlaffVampireCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleDettlaffVampireParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleDettlaffVampireParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'monster_weapon';
	default behGraph = EBG_Combat_Dettlaff_Vampire;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		combatTacticTree = new CAINpcDettlaffVampireTacticTree in this;
		combatTacticTree.OnCreated();
		
		defenseActions.Clear();

		defenseActions.PushBack( new CAINpcDettlaffVampireParryAction in this ); 
		defenseActions.PushBack( new CAINpcDettlaffVampireCounterAction in this ); 
		defenseActions.PushBack( new CAINpcDettlaffVampireCounterAfterHitAction in this ); 
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};



class CAINpcDettlaffMinionCombatStyle extends CAINpcCombatStyle
{
	function Init()
	{
		super.Init();
		params = new CAINpcStyleDettlaffMinionParams in this;
		params.OnCreated();
	}	
};

class CAINpcStyleDettlaffMinionParams extends CAINpcCombatStyleParams
{
	default RightItemType = 'monster_weapon';
	default behGraph = EBG_Combat_Dettlaff_Minion;
	
	function Init()
	{
		var i : int;
		
		super.Init();
		
		combatTacticTree = new CAINpcDettlaffMinionTacticTree in this;
		combatTacticTree.OnCreated();
		
		defenseActions.Clear();
		defenseActions.PushBack( new CAINpcDettlaffMinionParryAction in this ); 
		defenseActions.PushBack( new CAINpcDettlaffMinionCounterAction in this ); 
		
		for ( i = 0; i < defenseActions.Size(); i+=1 )
		{
			defenseActions[ i ].OnCreated();
		}
	}
};