/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SBaseStat
{
	import saved var current	: float;			
	import saved var max		: float;			
	import saved var type 		: EBaseCharacterStats;
};


import struct SBlockedAbility
{
	import editable saved var abilityName : name;
	import editable saved var timeWhenEnabledd : float;		
	import saved var count : int;							
};


enum ESkillColor
{
	SC_None,
	SC_Blue,
	SC_Green,
	SC_Red,
	SC_RedBlue,
	SC_RedGreen,
	SC_BlueGreen,
	SC_RedWhite,
	SC_GreenWhite,
	SC_BlueWhite,
	SC_Yellow		
}

function SkillColorStringToType( str : string ) : ESkillColor
{
	switch( StrLower( str ) )
	{
		case "blue" : 		return SC_Blue;
		case "green" : 		return SC_Green;
		case "red" :		return SC_Red;
		case "yellow" :     return SC_Yellow;
		case "redblue" :	return SC_RedBlue;
		case "redgreen" :	return SC_RedGreen;
		case "bluegreen" :	return SC_BlueGreen;
		case "redwhite" :   return SC_RedWhite;
		case "bluewhite" :   return SC_BlueWhite;
		case "greenwhite" :   return SC_GreenWhite;
		default :			return SC_None;
	}
}

struct SMutagenSlot
{
	saved var item : SItemUniqueId;				
	saved var unlockedAtLevel : int;			
	saved var skillGroupID : int;				
	saved var equipmentSlot : EEquipmentSlots;	
};

struct SSkillSlot
{
	saved var id : int;							
	saved var unlockedOnLevel : int;
	saved var socketedSkill : ESkill;			
	saved var unlocked : bool;					
	saved var groupID : int;					
}


struct SSkill
{
	
	
	
	

	saved var skillType : ESkill;									
		  var skillPath : ESkillPath;								
		  var skillSubPath : ESkillSubPath;							
	saved var level : int;											
		  var maxLevel : int;										

		  default level = -1;
		  default maxLevel = -1;

	  	  var requiredSkills : array<ESkill>;						
		  var requiredSkillsIsAlternative : bool;					
		  var requiredPointsSpent : int;							
		  var priority : int;										
		  var cost : int;											
	saved var isTemporary : bool;									

		  var abilityName : name;									
		  var modifierTags : array<name>;							
																	

		  var localisationNameKey : string;							
		  var localisationDescriptionKey : string;					
		  var localisationDescriptionLevel2Key : string;			
		  var localisationDescriptionLevel3Key : string;			

		  var iconPath : string;									
		  var iconPathTest : string;								
		  var positionID : int;										
	saved var isNew : bool;											
		  var isCoreSkill : bool;									
		  
		  
		  var isReworked : bool;									
		  var isUnchangedLegacy : bool;								
		  var gridRow : int;
		  var gridColumn : int;
		  

		  var wasEquippedOnUIEnter : bool;							

	saved var remainingBlockedTime : float;							

			var precachedModifierSkills : array< ESkill >;
};


struct SRestoredSkill
{
	var level : int;
	var skillType : ESkill;
	var isNew : bool;
	var remainingBlockedTime : float;
};

struct SSimpleSkill
{
	var level : int;
	var skillType : ESkill;
};

struct STutorialSavedSkill
{
	var skillSlotID : int;
	var skillType : ESkill;
};


struct STutorialTemporarySkill
{
	var wasLearned : bool;
	var skillType : ESkill;
};

struct SMutagenBonusAlchemy19
{
	var abilityName : name;
	var count : int;
}

enum ESkillPath
{
	ESP_NotSet,
	ESP_Sword,
	ESP_Signs,
	ESP_Alchemy,
	ESP_Perks
}

function SkillPathNameToType(n : name) : ESkillPath
{
	switch(n)
	{
		case 'Sword' :		return ESP_Sword;
		case 'Signs' : 		return ESP_Signs;
		case 'Alchemy' : 	return ESP_Alchemy;
		case 'Perks' :	 	return ESP_Perks;
		default :			return ESP_NotSet;
	}
}

function SkillPathTypeToName(s : ESkillPath) : name 
{
	switch(s)
	{
		case ESP_Sword :		return 'Sword';
		case ESP_Signs : 		return 'Signs';
		case ESP_Alchemy : 		return 'Alchemy';
		case ESP_Perks : 		return 'Perks';
		default :				return '';
	}
}

function SkillPathTypeToLocalisationKey(s : ESkillPath) : name 
{
	switch(s)
	{
		case ESP_Sword :		return 'panel_character_skill_sword';
		case ESP_Signs : 		return 'panel_character_skill_signs';
		case ESP_Alchemy : 		return 'panel_character_skill_alchemy';
		case ESP_Perks : 		return 'skill_tree_name_survival';
		default :				return '';
	}
}

function SkillSubPathToLocalisationKey(s : ESkillSubPath) : string
{
	switch(s)
	{
		case ESSP_Sword_StyleFast    : return "skill_name_sword_1";
		case ESSP_Sword_StyleStrong  : return "skill_name_sword_2";
		case ESSP_Sword_Utility 	 : return "skill_name_sword_3";
		case ESSP_Sword_Crossbow 	 : return "skill_name_sword_4";
		case ESSP_Sword_BattleTrance : return "skill_name_sword_5";

		case ESSP_Signs_Aard   : return "skill_name_magic_1";
		case ESSP_Signs_Igni   : return "skill_name_magic_2";
		case ESSP_Signs_Yrden  : return "skill_name_magic_3";
		case ESSP_Signs_Quen   : return "skill_name_magic_4";
		case ESSP_Signs_Axi    : return "skill_name_magic_5";

		case ESSP_Alchemy_Potions  : return "skill_name_alchemy_1";
		case ESSP_Alchemy_Oils 	   : return "skill_name_alchemy_2";
		case ESSP_Alchemy_Bombs    : return "skill_name_alchemy_3";
		case ESSP_Alchemy_Mutagens : return "skill_name_alchemy_4";
		case ESSP_Alchemy_Grasses  : return "skill_name_alchemy_5";

		default : return "";
	}
}

enum ESkillSubPath
{
	ESSP_NotSet,
	ESSP_Sword_StyleStrong,
	ESSP_Sword_StyleFast,
	ESSP_Sword_Crossbow,
	ESSP_Sword_Utility,
	ESSP_Sword_BattleTrance,
	ESSP_Sword_Offense,
	ESSP_Sword_Defence,
	ESSP_Sword_General,

	ESSP_Signs_Aard,
	ESSP_Signs_Igni,
	ESSP_Signs_Yrden,
	ESSP_Signs_Quen,
	ESSP_Signs_Axi,
	ESSP_Signs_Offense,
	ESSP_Signs_Defence,
	ESSP_Signs_General,

	ESSP_Alchemy_Potions,
	ESSP_Alchemy_Oils,
	ESSP_Alchemy_Bombs,
	ESSP_Alchemy_Mutagens,
	ESSP_Alchemy_Grasses,
	ESSP_Alchemy_Offense,
	ESSP_Alchemy_Defence,
	ESSP_Alchemy_General,

	ESSP_Perks,
	ESSP_Perks_col1,
	ESSP_Perks_col2,
	ESSP_Perks_col3,
	ESSP_Perks_col4,
	ESSP_Perks_col5,

	ESSP_Core
}

function SkillSubPathNameToType(n : name) : ESkillSubPath
{
	switch(n)
	{
		case 'Sword_StyleStrong' :		return ESSP_Sword_StyleStrong;
		case 'Sword_StyleFast' :		return ESSP_Sword_StyleFast;
		case 'Sword_Crossbow' :			return ESSP_Sword_Crossbow;
		case 'Sword_Utility' :			return ESSP_Sword_Utility;
		case 'Sword_BattleTrance' :		return ESSP_Sword_BattleTrance;
		case 'Sword_Offense' :			return ESSP_Sword_Offense;
		case 'Sword_Defence' :			return ESSP_Sword_Defence;
		case 'Sword_General' :			return ESSP_Sword_General;

		case 'Signs_Aard' :				return ESSP_Signs_Aard;
		case 'Signs_Igni' :				return ESSP_Signs_Igni;
		case 'Signs_Yrden' :			return ESSP_Signs_Yrden;
		case 'Signs_Quen' :				return ESSP_Signs_Quen;
		case 'Signs_Axi' :				return ESSP_Signs_Axi;
		case 'Signs_Offense' :			return ESSP_Signs_Offense;
		case 'Signs_Defence' :			return ESSP_Signs_Defence;
		case 'Signs_General' :			return ESSP_Signs_General;

		case 'Alchemy_Potions' :		return ESSP_Alchemy_Potions;
		case 'Alchemy_Oils' :			return ESSP_Alchemy_Oils;
		case 'Alchemy_Bombs' :			return ESSP_Alchemy_Bombs;
		case 'Alchemy_Mutagens' :		return ESSP_Alchemy_Mutagens;
		case 'Alchemy_Grasses' :		return ESSP_Alchemy_Grasses;
		case 'Alchemy_Offense' :		return ESSP_Alchemy_Offense;
		case 'Alchemy_Defence' :		return ESSP_Alchemy_Defence;
		case 'Alchemy_General' :		return ESSP_Alchemy_General;

		case 'Perks' : 					return ESSP_Perks;
		case 'Perks_col1' : 			return ESSP_Perks_col1;
		case 'Perks_col2' : 			return ESSP_Perks_col2;
		case 'Perks_col3' : 			return ESSP_Perks_col3;
		case 'Perks_col4' : 			return ESSP_Perks_col4;
		case 'Perks_col5' : 			return ESSP_Perks_col5;

		case 'Core' :					return ESSP_Core;

		default :						return ESSP_NotSet;
	}
}

function SkillSubPathTypeToName(s : ESkillSubPath) : name 
{
	switch(s)
	{
		case ESSP_Sword_StyleStrong :		return 'Sword_StyleStrong';
		case ESSP_Sword_StyleFast :			return 'Sword_StyleFast' ;
		case ESSP_Sword_Crossbow :			return 'Sword_Crossbow';
		case ESSP_Sword_Utility :			return 'Sword_Utility';
		case ESSP_Sword_BattleTrance :		return 'Sword_BattleTrance';
		case ESSP_Sword_Offense :			return 'Sword_Offense';
		case ESSP_Sword_Defence :			return 'Sword_Defence';
		case ESSP_Sword_General :			return 'Sword_General';

		case ESSP_Signs_Igni :				return 'Signs_Igni';
		case ESSP_Signs_Aard :				return 'Signs_Aard';
		case ESSP_Signs_Yrden :				return 'Signs_Yrden';
		case ESSP_Signs_Axi :				return 'Signs_Axi';
		case ESSP_Signs_Quen :				return 'Signs_Quen';
		case ESSP_Signs_Offense :			return 'Signs_Offense';
		case ESSP_Signs_Defence :			return 'Signs_Defence';
		case ESSP_Signs_General :			return 'Signs_General';

		case ESSP_Alchemy_Potions :			return 'Alchemy_Potions';
		case ESSP_Alchemy_Oils :			return 'Alchemy_Oils';
		case ESSP_Alchemy_Bombs :			return 'Alchemy_Bombs';
		case ESSP_Alchemy_Mutagens :		return 'Alchemy_Mutagens';
		case ESSP_Alchemy_Grasses :			return 'Alchemy_Grasses';
		case ESSP_Alchemy_Offense :			return 'Alchemy_Offense';
		case ESSP_Alchemy_Defence :			return 'Alchemy_Defence';
		case ESSP_Alchemy_General :			return 'Alchemy_General';

		case ESSP_Perks :					return 'Perks';
		case ESSP_Perks_col1 :				return 'Perks_col1';
		case ESSP_Perks_col2 :				return 'Perks_col2';
		case ESSP_Perks_col3 :				return 'Perks_col3';
		case ESSP_Perks_col4 :				return 'Perks_col4';
		case ESSP_Perks_col5 :				return 'Perks_col5';

		case ESSP_Core :					return 'Core';

		default :							return '';
	}
}

import struct SResistanceValue
{
	import saved var points 	: SAbilityAttributeValue;
	import saved var percents 	: SAbilityAttributeValue;
	import saved var type 		: ECharacterDefenseStats;
};


function IsSkillSign(skill : ESkill) : bool
{
	switch(skill)
	{
		case S_Magic_1:
		case S_Magic_2:
		case S_Magic_3:
		case S_Magic_4:
		case S_Magic_5:
		case S_Magic_s01:
		case S_Magic_s02:
		case S_Magic_s03:
		case S_Magic_s04:
		case S_Magic_s05:
		case S_Magic_s28:
			return true;
		default:
			return false;
	}
}

enum EPlayerMutationType
{
	EPMT_None,
	EPMT_Mutation1,
	EPMT_Mutation2,
	EPMT_Mutation3,
	EPMT_Mutation4,
	EPMT_Mutation5,
	EPMT_Mutation6,
	EPMT_Mutation7,
	EPMT_Mutation8,
	EPMT_Mutation9,
	EPMT_Mutation10,
	EPMT_Mutation11,
	EPMT_Mutation12,
	EPMT_MutationMaster
}

function MutationNameToType( mutName : name ) : EPlayerMutationType
{
	switch( mutName )
	{
		case 'mutation1' : 			return EPMT_Mutation1;
		case 'mutation2' : 			return EPMT_Mutation2;
		case 'mutation3' :			return EPMT_Mutation3;
		case 'mutation4' : 			return EPMT_Mutation4;
		case 'mutation5' :			return EPMT_Mutation5;
		case 'mutation6' : 			return EPMT_Mutation6;
		case 'mutation7' : 			return EPMT_Mutation7;
		case 'mutation8' : 			return EPMT_Mutation8;
		case 'mutation9' : 			return EPMT_Mutation9;
		case 'mutation10' : 		return EPMT_Mutation10;
		case 'mutation11' : 		return EPMT_Mutation11;
		case 'mutation12' : 		return EPMT_Mutation12;
		case 'mutationMaster' : 	return EPMT_MutationMaster;

		default : 					return EPMT_None;
	}

	return EPMT_None;
}

struct SMutationProgress
{
	var redUsed : int;					
	var redRequired : int;				
	var blueUsed : int;					
	var blueRequired : int;				
	var greenUsed : int;				
	var greenRequired : int;			
	var skillpointsUsed : int;			
	var skillpointsRequired : int;		
	var overallProgress : int;			
}

struct SMutation
{
	var type : EPlayerMutationType;								
	var colors : array< ESkillColor >;							
	var progress : SMutationProgress;							
	var requiredMutations : array< EPlayerMutationType >;		
	var localizationNameKey : name;								
	var localizationDescriptionKey : name;						
	var iconPath : name;										
	var soundbank : string;										
}