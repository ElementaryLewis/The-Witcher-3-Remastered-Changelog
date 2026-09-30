/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CAIScaredCombatTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\combat\npc_scared_combat";
};





abstract class CAINpcDefenseAction extends CAICombatActionTree
{
};



class CAINpcParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};



class CAINpcDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_dodge";
};



class CAINpcCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter";
};



class CAINpcCounterFistFightAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter_fistfight";
};



class CAINpcCounterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counterhit";
};



class CAIWildHuntCounterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_wildhunt_counterhit";
};



class CAINpcCounterPushAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter_push";
};



class CAINpcWitcherCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_witcher_counter";
};



class CAINpcCiriCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_ciri_counter";
};



class CAINpcImlerithCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_counter";
};



class CAINpcImlerithCounterActionSecondStage extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_counter_second_stage";
};



class CAINpcImlerithParry extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};



class CAINpcImlerithGuardAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_guard";
};



class CAINpcImlerithSignsBlockAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_signs_block";
};



class CAINpcGregoireCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_gregoire_counter";
};



class CAINpcEredinCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_counter";
};



class CAINpcEredinRaiseGuardAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_raise_guard";
};



class CAINpcEredinSignsBlockAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_signs_block";
};



class CAINpcEredinDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_dodge";
};



class CAINpcEredinParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};



class CAINpcOlgierdCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_counter";
};



class CAINpcOlgierdDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_dodge";
};



class CAINpcOlgierdCounterAfterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_counter_after_hit";
};



class CAINpcOlgierdParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};



class CAINpcDettlaffVampireCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_counter";
};


class CAINpcDettlaffVampireCounterAfterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_counter_after_hit";
};


class CAINpcDettlaffVampireParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};



class CAINpcDettlaffMinionParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};


class CAINpcDettlaffMinionCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_counter";
};



class CAINpcSummonGuardsAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_summon_guards";
};



class CAINpcCaranthirCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_caranthir_counter";
};



class CAINpcCaranthirIceArmorAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_caranthir_ice_armor";
};





abstract class CAINpcTacticTree extends CAISubTree
{
	editable inlined var params : CAINpcTacticTreeParams;
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};



abstract class CAINpcMeleeTacticTree extends CAINpcTacticTree
{
};



abstract class CAINpcRangedTacticTree extends CAINpcTacticTree
{
};



abstract class CAINpcCustomTacticTree extends CAINpcTacticTree
{
};


class CAINpcTacticTreeParams extends CAISubTreeParameters
{
	
	
	editable inlined var specialActions : array<CAISpecialAction>;
	
	
	
	
	editable var dontUseRunWhileStrafing	: bool;
	editable var allowChangingGuard			: bool;
	
	default dontUseRunWhileStrafing = false;
	default allowChangingGuard 		= true;
	
	function Init()
	{
		
		
	}
	
	function InitializeSpecialActions()
	{
		var i : int;
		
		for ( i = 0; i < specialActions.Size(); i+=1 )
		{
			specialActions[ i ].OnCreated();
		}
	}
};



class CAINpcSimpleTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_simple";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};



class CAINpcSurroundTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcSurroundTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};


class CAINpcSurroundTacticCloseTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_close";
	
	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcSurroundTacticFarTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_far";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcSurroundRangedTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_ranged";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};



class CAINpcHoldGroundTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_holdground";
	
	function Init()
	{
		params = new CAINpcHoldGroundTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcHoldGroundTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var holdPositionTag 					: name;
	editable var engageDist 						: float;
	editable var maxDistanceToHoldGroundPosition 	: float;
	
	function Init()
	{
		super.Init();
		engageDist = 8;
		maxDistanceToHoldGroundPosition = 8;
	}
};


class CAINpcHoldGroundRangedTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_holdground_ranged";
	
	
	function Init()
	{
		params = new CAINpcHoldGroundRangedTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcHoldGroundRangedTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var holdPositionTag 					: name;
	editable var maxDistanceToHoldGroundPosition 	: float;
	
	function Init()
	{
		super.Init();
		maxDistanceToHoldGroundPosition = 0.f;
	}
};


class CAINpcVesemirTutorialTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_vesemir_tutorial";
	
	function Init()
	{
		params = new CAINpcVesemirTutorialTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcVesemirTutorialTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var backgroundTraining	: bool;
	editable var onlyBlock 			: bool;
	editable var onlyBlocksWithQuen : bool;
	editable var useAttacks 		: bool;
	editable var useCombos 			: bool;
	editable var forceIdle		 	: bool;
	editable var attacksInterval 	: float;
	
	editable var maxDistFromTarget  : float;
	
	default maxDistFromTarget = 5.f;
	
	function Init()
	{
		attacksInterval = 3.f;
		super.Init();
	}
};


class CAINpcSorceressTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_sorceress";
	
	function Init()
	{
		params = new CAINpcSorceressTacticTreeParams in this;
		params.OnCreated();
	}
};

class CAINpcSorceressTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};


class CAINpcSorcererTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_sorcerer";
	
	function Init()
	{
		params = new CAINpcSorcererTacticTreeParams in this;
		params.OnCreated();
	}
};

class CAINpcSorcererTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};


class CAINpcEredinTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_eredin";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcEredinTESTTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_eredin_test";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcImlerithTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_imlerith";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcImlerithSecondStageTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_imlerith_second_stage";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcCaranthirTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_caranthir";
	
	editable var Phase1 			: bool;
	editable var Phase2 			: bool;

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcCaretakerTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_caretaker_logic";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcPhilippaTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_philippa";
	
	function Init()
	{
		params = new CAINpcSorceressTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcOlgierdTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_olgierd";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcDettlaffVampireTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_logic";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

class CAINpcDettlaffMinionTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_logic";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcGregoireTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/npc_tactic_gregoire";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};


class CAINpcCombatRetreatActionTree extends CAICombatActionTree 
{
	default aiTreeName = "resdef:ai\combat\npc_combataction_retreat";
}




class CAINpcPreCombatWarningActionTree extends CAICombatActionTree 
{
	default aiTreeName = "resdef:ai\combat\npc_combataction_precombatwarning";
}





class CAINpcFormationTacticTree extends CAISubTree 
{
	default aiTreeName = "resdef:ai\combat\npc_formation_tactic_base";
	
	editable inlined var params : CAINpcFormationTacticTreeParams;
	
	
	function Init()
	{
		params = new CAINpcFormationTacticTreeParams in this;
		params.OnCreated();
	}
};

class CAINpcFormationTacticTreeParams extends CAISubTreeParameters
{
	editable inlined var formationFollowerAttackAction 	: CAIAttackActionTree;
	editable inlined var formationLeaderAttackBehavior 	: CAIAttackBehaviorTree;
	
	function Init()
	{
		formationFollowerAttackAction = new CAIBasicAttackActionTree in this;
		formationFollowerAttackAction.OnCreated();
		
		formationLeaderAttackBehavior = new CAIAttackBehaviorTree in this;
		formationLeaderAttackBehavior.OnCreated();
	}
};





class CAIAttackBehaviorTree extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackbehavior";

	editable inlined var params : CAIAttackBehaviorTreeParams;
	
	function Init()
	{
		params = new CAIAttackBehaviorTreeParams in this;
		params.OnCreated();
	}
};

class CAIAttackBehaviorTreeParams extends CAICombatActionParameters
{
	editable inlined var chargeAction 	: bool;
	editable inlined var approachAction : bool;
	editable inlined var throwBomb 		: bool;
	editable inlined var teleportAction : bool;
	
	editable inlined var attackAction : CAIAttackActionTree;
	editable inlined var attackActionRange : name;
	editable inlined var farAttackAction : CAIAttackActionTree;
	editable inlined var farAttackActionRange : name;
	
	function Init()
	{
		attackAction = new CAIBasicAttackActionTree in this;
		attackAction.OnCreated();
		
		attackActionRange = 'rangeNormal';
		farAttackActionRange = 'rangeFar';
	}
};





abstract class CAISpecialAction extends CAISubTree
{
	var params : CAISpecialActionParams;
	
	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAISpecialActionParams extends CAISubTreeParameters
{
	
};

class CAIDwimeritiumBombSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_throw_dwimeritium";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIAttachEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_attach_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIDisperseAttachedEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_disperse_attached_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicGroundBlastSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_magic_ground_blast";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicPushSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_magic_push";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandGroundBlastSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_mage_ground_blast";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandGroundBlastSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_mage_ground_blast_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWaterGroundBlastSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_water_mage_ground_blast_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandPushSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_mage_push";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandPushSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_mage_push_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWaterPushSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_water_mage_push_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicRootAttackSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_root";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicTornadoSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_tornado";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicTornadoSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_tornado_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWaterTornadoSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_tornado_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindCoilSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_wind_coil";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindCoilSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_wind_coil_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWaterCoilSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_coil_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindGustSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_wind_gust";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindGustSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_wind_gust_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandCageSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_sand_cage";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWaterCageSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_cage_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandCageSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_sand_cage_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicShieldSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_magic_shield";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicShieldSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_magic_shield_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIWaterMagicShieldSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_magic_shield_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootAttachedEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_attached_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootProjectilesFromGroundSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_projectiles_from_ground";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAILynxWitchShootProjectilesFromGroundSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_shoot_projectiles_from_ground_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};


class CAICastRipApartSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_rip_apart";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastFireballSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_fireball";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastLightningSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_lightning";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAILynxWitchCastLightningSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_lightning_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootBarrelsSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_barrels";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastArcaneMissileSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_arcane_missile";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastArcaneExplosionSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_arcane_explosion";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShadowDashSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shadow_dash";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};





abstract class CAIAttackActionTree extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_basic";
	editable inlined var params : CAIAttackActionTreeParams;
	function Init()
	{
		params = new CAIAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIAttackActionTreeParams extends CAICombatActionParameters
{
	function Init()
	{
	}
};



class CAISimpleAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_simple";
	function Init()
	{
		super.Init();
		params = new CAISimpleAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAISimpleAttackActionTreeParams extends CAIAttackActionTreeParams
{
};



class CAIBasicAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_basic";
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIBasicAttackActionTreeParams extends CAIAttackActionTreeParams
{
};





class CAIFistAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_fists";
	
	var easyVersion : bool;
	
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
		easyVersion = true;
	}
};

class CAIComboFistAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_fists_combos";
	
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAISword2hAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_sword2h";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};



class CAITwoHandedAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_twohanded";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIPitchforkAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_pitchfork";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIWitcherAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_witcher";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAICiriAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_ciri";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};
