/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EGeneralEnum
{
	GE_0,
	GE_1,
	GE_2,
	GE_3,
	GE_4,
	GE_5,
	GE_6,
	GE_7,
	GE_8,
	GE_9,
	GE_10,
}

enum EPlayerExplorationAction 
{
	PEA_None,
	PEA_SlotAnimation,
	PEA_Meditation,
	PEA_ExamineGround,
	PEA_ExamineEyeLevel,
	PEA_SmellHigh,
	PEA_SmellMid,
	PEA_SmellLow,
	PEA_InspectHigh,
	PEA_InspectMid,
	PEA_InspectLow,
	PEA_IgniLight,
	PEA_AardLight,
	PEA_SetBomb,
	PEA_PourPotion,
	PEA_DispelIllusion,
	PEA_GoToSleep
}

enum EPlayerBoatMountFacing
{
	EPBMD_NotSet,
	EPBMD_Front,
	EPBMD_Back,
	EPBMD_Left,
	EPBMD_Right
}


enum EPlayerAttackType
{
	PAT_Light,
	PAT_Heavy
};



enum ESkill
{
	S_SUndefined,
	
	S_Sword_1,				
	S_Sword_2,				
	S_Sword_3,				
	S_Sword_4,				
	S_Sword_5,				
	
	S_Magic_1,				
	S_Magic_2,				
	S_Magic_3,				
	S_Magic_4,				
	S_Magic_5,				
	
	S_Alchemy_1,			
	S_Alchemy_2,			
	S_Alchemy_3,			
	S_Alchemy_4,			
	S_Alchemy_5,			
	
	
	S_Sword_s01,			
	S_Sword_s02,			
	S_Sword_s03,			
	S_Sword_s04,			
	S_Sword_s05,			
	S_Sword_s06,			
	S_Sword_s07,			
	S_Sword_s08,			
	S_Sword_s09,			
	S_Sword_s10,			
	S_Sword_s11,			
	S_Sword_s12,			
	S_Sword_s13,			
S_UNUSED1,
	S_Sword_s15,			
	S_Sword_s16,			
	S_Sword_s17,			
	S_Sword_s18,			
	S_Sword_s19,			
	S_Sword_s20,			
	S_Sword_s21,			
	
	
	S_Magic_s01,			
	S_Magic_s02,			
	S_Magic_s03,			
	S_Magic_s04,			
	S_Magic_s05,			
	S_Magic_s06,			
	S_Magic_s07,			
	S_Magic_s08,			
	S_Magic_s09,			
	S_Magic_s10,			
	S_Magic_s11,			
	S_Magic_s12,			
	S_Magic_s13,			
	S_Magic_s14,			
	S_Magic_s15,			
	S_Magic_s16,			
	S_Magic_s17,			
	S_Magic_s18,			
	S_Magic_s19,			
	S_Magic_s20,			
S_UNUSED2,
	
	
	S_Alchemy_s01,			
	S_Alchemy_s02,			
	S_Alchemy_s03,			
	S_Alchemy_s04,			
	S_Alchemy_s05,			
	S_Alchemy_s06,			
	S_Alchemy_s07,			
	S_Alchemy_s08,			
	S_Alchemy_s09,			
	S_Alchemy_s10,			
	S_Alchemy_s11,			
	S_Alchemy_s12,			
	S_Alchemy_s13,			
	S_Alchemy_s14,			
	S_Alchemy_s15,			
	S_Alchemy_s16,			
	S_Alchemy_s17,			
	S_Alchemy_s18,			
	S_Alchemy_s19,			
	S_Alchemy_s20,			
	S_Skill_MAX,

	S_Perk_MIN,
	S_Perk_01,				
	S_Perk_02,				
	S_Perk_03,				
	S_Perk_04,				
	S_Perk_05,				
	S_Perk_06,				
	S_Perk_07,				
	S_Perk_08,				
	S_Perk_09,				
	S_Perk_10,				
	S_Perk_11,				
	S_Perk_12,				
	
	
	S_Perk_13,				
	S_Perk_14,				
	S_Perk_15,				
	S_Perk_16,				
	S_Perk_17,				
	S_Perk_18,				
	S_Perk_19,				
	S_Perk_20,				
	S_Perk_21,				
	S_Perk_22,				
	S_Perk_MAX
}

enum EItemSetBonus
{
	EISB_Undefined,
	EISB_Lynx_1,			
	EISB_Lynx_2,			
	EISB_Gryphon_1,			
	EISB_Gryphon_2,			
	EISB_Bear_1,			
	EISB_Bear_2,			
	EISB_Wolf_1,			
	EISB_Wolf_2,			
	EISB_RedWolf_1,			
	EISB_RedWolf_2,			
	EISB_Vampire,			
	EISB_Netflix_1,
	EISB_Netflix_2
}

enum EItemSetType
{
	EIST_Undefined,
	EIST_Lynx,
	EIST_Gryphon,
	EIST_Bear,
	EIST_Wolf,
	EIST_RedWolf,
	EIST_Vampire,
	EIST_Viper,
	EIST_Netflix
}

function SetItemNameToType( nam : name ) : EItemSetType
{
	switch( nam )
	{
		case theGame.params.ITEM_SET_TAG_LYNX : 			return EIST_Lynx ;
		case theGame.params.ITEM_SET_TAG_GRYPHON : 			return EIST_Gryphon ;
		case theGame.params.ITEM_SET_TAG_BEAR : 			return EIST_Bear ;
		case theGame.params.ITEM_SET_TAG_WOLF : 			return EIST_Wolf ;
		case theGame.params.ITEM_SET_TAG_RED_WOLF : 		return EIST_RedWolf ;
		case theGame.params.ITEM_SET_TAG_VAMPIRE :			return EIST_Vampire ;
		case theGame.params.ITEM_SET_TAG_VIPER : 			return EIST_Viper;
		case theGame.params.ITEM_SET_TAG_NETFLIX : 			return EIST_Netflix;
		default: 											return EIST_Undefined;
	}
}

function GetSetBonusAbility( setBonus : EItemSetBonus ) : name
{
	switch( setBonus )
	{
		case EISB_Lynx_2:				return 'setBonusAbilityLynx_2';
		case EISB_Bear_1:				return 'setBonusAbilityBear_1';
		case EISB_Bear_2:				return 'setBonusAbilityBear_2';
		case EISB_RedWolf_2:			return 'setBonusAbilityRedWolf_2';
		case EISB_Wolf_1:				return 'SetBonusAbilityWolf_1';
		case EISB_Netflix_1:			return 'SetBonusAbilityNetflix_1';
		default: 						return '';
	}
}


function SkillNameToEnum(n : name) : ESkill
{
	switch(n)
	{
		case 'sword_1' :						return S_Sword_1;
		case 'sword_2' :						return S_Sword_2;
		case 'sword_3' :						return S_Sword_3;
		case 'sword_4' :						return S_Sword_4;
		case 'sword_5' :						return S_Sword_5;
		
		case 'magic_1' :						return S_Magic_1;
		case 'magic_2' :						return S_Magic_2;
		case 'magic_3' :						return S_Magic_3;
		case 'magic_4' :						return S_Magic_4;
		case 'magic_5' :						return S_Magic_5;
		
		case 'alchemy_1' :						return S_Alchemy_1;
		case 'alchemy_2' :						return S_Alchemy_2;
		case 'alchemy_3' :						return S_Alchemy_3;
		case 'alchemy_4' :						return S_Alchemy_4;
		case 'alchemy_5' :						return S_Alchemy_5;
		
		case 'sword_s1' :						return S_Sword_s01;
		case 'sword_s2' :						return S_Sword_s02;
		case 'sword_s3' :						return S_Sword_s03;
		case 'sword_s4' :						return S_Sword_s04;
		case 'sword_s5' :						return S_Sword_s05;
		case 'sword_s6' :						return S_Sword_s06;
		case 'sword_s7' :						return S_Sword_s07;
		case 'sword_s8' :						return S_Sword_s08;
		case 'sword_s9' :						return S_Sword_s09;
		case 'sword_s10' :						return S_Sword_s10;
		case 'sword_s11' :						return S_Sword_s11;
		case 'sword_s12' :						return S_Sword_s12;
		case 'sword_s13' :						return S_Sword_s13;
		case 'sword_s15' :						return S_Sword_s15;
		case 'sword_s16' :						return S_Sword_s16;
		case 'sword_s17' :						return S_Sword_s17;
		case 'sword_s18' :						return S_Sword_s18;
		case 'sword_s19' :						return S_Sword_s19;
		case 'sword_s20' :						return S_Sword_s20;
		case 'sword_s21' :						return S_Sword_s21;
		
		case 'magic_s1' :						return S_Magic_s01;
		case 'magic_s2' :						return S_Magic_s02;
		case 'magic_s3' :						return S_Magic_s03;
		case 'magic_s4' :						return S_Magic_s04;
		case 'magic_s5' :						return S_Magic_s05;
		case 'magic_s6' :						return S_Magic_s06;
		case 'magic_s7' :						return S_Magic_s07;
		case 'magic_s8' :						return S_Magic_s08;
		case 'magic_s9' :						return S_Magic_s09;
		case 'magic_s10' :						return S_Magic_s10;
		case 'magic_s11' :						return S_Magic_s11;
		case 'magic_s12' :						return S_Magic_s12;
		case 'magic_s13' :						return S_Magic_s13;
		case 'magic_s14' :						return S_Magic_s14;
		case 'magic_s15' :						return S_Magic_s15;
		case 'magic_s16' :						return S_Magic_s16;
		case 'magic_s17' :						return S_Magic_s17;
		case 'magic_s18' :						return S_Magic_s18;
		case 'magic_s19' :						return S_Magic_s19;
		case 'magic_s20' :						return S_Magic_s20;
		
		case 'alchemy_s1' :						return S_Alchemy_s01;
		case 'alchemy_s2' :						return S_Alchemy_s02;
		case 'alchemy_s3' :						return S_Alchemy_s03;
		case 'alchemy_s4' :						return S_Alchemy_s04;
		case 'alchemy_s5' :						return S_Alchemy_s05;
		case 'alchemy_s6' :						return S_Alchemy_s06;
		case 'alchemy_s7' :						return S_Alchemy_s07;
		case 'alchemy_s8' :						return S_Alchemy_s08;
		case 'alchemy_s9' :						return S_Alchemy_s09;
		case 'alchemy_s10' :					return S_Alchemy_s10;
		case 'alchemy_s11' :					return S_Alchemy_s11;
		case 'alchemy_s12' :					return S_Alchemy_s12;
		case 'alchemy_s13' :					return S_Alchemy_s13;
		case 'alchemy_s14' :					return S_Alchemy_s14;
		case 'alchemy_s15' :					return S_Alchemy_s15;
		case 'alchemy_s16' :					return S_Alchemy_s16;
		case 'alchemy_s17' :					return S_Alchemy_s17;
		case 'alchemy_s18' :					return S_Alchemy_s18;
		case 'alchemy_s19' :					return S_Alchemy_s19;
		case 'alchemy_s20' :					return S_Alchemy_s20;
		
		case 'perk_1' :							return S_Perk_01;
		case 'perk_2' :							return S_Perk_02;
		case 'perk_3' :							return S_Perk_03;
		case 'perk_4' :							return S_Perk_04;
		case 'perk_5' :							return S_Perk_05;
		case 'perk_6' :							return S_Perk_06;
		case 'perk_7' :							return S_Perk_07;
		case 'perk_8' :							return S_Perk_08;
		case 'perk_9' :							return S_Perk_09;
		case 'perk_10' :						return S_Perk_10;
		case 'perk_11' :						return S_Perk_11;
		case 'perk_12' :						return S_Perk_12;
		case 'perk_13' :						return S_Perk_13;
		case 'perk_14' :						return S_Perk_14;
		case 'perk_15' :						return S_Perk_15;
		case 'perk_16' :						return S_Perk_16;
		case 'perk_17' :						return S_Perk_17;
		case 'perk_18' :						return S_Perk_18;
		case 'perk_19' :						return S_Perk_19;
		case 'perk_20' :						return S_Perk_20;
		case 'perk_21' :						return S_Perk_21;
		case 'perk_22' :						return S_Perk_22;
	
		default:								return S_SUndefined;
	}
}

function SignEnumToSkillEnum( s : ESignType ) : ESkill
{
	switch( s )
	{
		case ST_Aard: 	return S_Magic_1;
		case ST_Igni: 	return S_Magic_2;
		case ST_Yrden: 	return S_Magic_3;
		case ST_Quen: 	return S_Magic_4;
		case ST_Axii: 	return S_Magic_5;
		
		default:		return S_SUndefined;
	}
}


function SkillEnumToName(s : ESkill) : name
{
	switch(s)
	{
		case S_Sword_1 :						return 'sword_1';
		case S_Sword_2 :						return 'sword_2';
		case S_Sword_3 :						return 'sword_3';
		case S_Sword_4 :						return 'sword_4';
		case S_Sword_5 :						return 'sword_5';
		
		case S_Magic_1 :						return 'magic_1';
		case S_Magic_2 :						return 'magic_2';
		case S_Magic_3 :						return 'magic_3';
		case S_Magic_4 :						return 'magic_4';
		case S_Magic_5 :						return 'magic_5';
		
		case S_Alchemy_1 :						return 'alchemy_1';
		case S_Alchemy_2 :						return 'alchemy_2';
		case S_Alchemy_3 :						return 'alchemy_3';
		case S_Alchemy_4 :						return 'alchemy_4';
		case S_Alchemy_5 :						return 'alchemy_5';
		
		case S_Sword_s01 :						return 'sword_s1';
		case S_Sword_s02 :						return 'sword_s2';
		case S_Sword_s03 :						return 'sword_s3';
		case S_Sword_s04 :						return 'sword_s4';
		case S_Sword_s05 :						return 'sword_s5';
		case S_Sword_s06 :						return 'sword_s6';
		case S_Sword_s07 :						return 'sword_s7';
		case S_Sword_s08 :						return 'sword_s8';
		case S_Sword_s09 :						return 'sword_s9';
		case S_Sword_s10 :						return 'sword_s10';
		case S_Sword_s11 :						return 'sword_s11';
		case S_Sword_s12 :						return 'sword_s12';
		case S_Sword_s13 :						return 'sword_s13';
		case S_Sword_s15 :						return 'sword_s15';
		case S_Sword_s16 :						return 'sword_s16';
		case S_Sword_s17 :						return 'sword_s17';
		case S_Sword_s18 :						return 'sword_s18';
		case S_Sword_s19 :						return 'sword_s19';
		case S_Sword_s20 :						return 'sword_s20';
		case S_Sword_s21 :						return 'sword_s21';
		
		case S_Magic_s01 :						return 'magic_s1';
		case S_Magic_s02 :						return 'magic_s2';
		case S_Magic_s03 :						return 'magic_s3';
		case S_Magic_s04 :						return 'magic_s4';
		case S_Magic_s05 :						return 'magic_s5';
		case S_Magic_s06 :						return 'magic_s6';
		case S_Magic_s07 :						return 'magic_s7';
		case S_Magic_s08 :						return 'magic_s8';
		case S_Magic_s09 :						return 'magic_s9';
		case S_Magic_s10 :						return 'magic_s10';
		case S_Magic_s11 :						return 'magic_s11';
		case S_Magic_s12 :						return 'magic_s12';
		case S_Magic_s13 :						return 'magic_s13';
		case S_Magic_s14 :						return 'magic_s14';
		case S_Magic_s15 :						return 'magic_s15';
		case S_Magic_s16 :						return 'magic_s16';
		case S_Magic_s17 :						return 'magic_s17';
		case S_Magic_s18 :						return 'magic_s18';
		case S_Magic_s19 :						return 'magic_s19';
		case S_Magic_s20 :						return 'magic_s20';
		
		case S_Alchemy_s01 :					return 'alchemy_s1';
		case S_Alchemy_s02 :					return 'alchemy_s2';
		case S_Alchemy_s03 :					return 'alchemy_s3';
		case S_Alchemy_s04 :					return 'alchemy_s4';
		case S_Alchemy_s05 :					return 'alchemy_s5';
		case S_Alchemy_s06 :					return 'alchemy_s6';
		case S_Alchemy_s07 :					return 'alchemy_s7';
		case S_Alchemy_s08 :					return 'alchemy_s8';
		case S_Alchemy_s09 :					return 'alchemy_s9';
		case S_Alchemy_s10 :					return 'alchemy_s10';
		case S_Alchemy_s11 :					return 'alchemy_s11';
		case S_Alchemy_s12 :					return 'alchemy_s12';
		case S_Alchemy_s13 :					return 'alchemy_s13';
		case S_Alchemy_s14 :					return 'alchemy_s14';
		case S_Alchemy_s15 :					return 'alchemy_s15';
		case S_Alchemy_s16 :					return 'alchemy_s16';
		case S_Alchemy_s17 :					return 'alchemy_s17';
		case S_Alchemy_s18 :					return 'alchemy_s18';
		case S_Alchemy_s19 :					return 'alchemy_s19';
		case S_Alchemy_s20 :					return 'alchemy_s20';
		
		case S_Perk_01 :						return 'perk_1';
		case S_Perk_02 :						return 'perk_2';
		case S_Perk_03 :						return 'perk_3';
		case S_Perk_04 :						return 'perk_4';
		case S_Perk_05 :						return 'perk_5';
		case S_Perk_06 :						return 'perk_6';
		case S_Perk_07 :						return 'perk_7';
		case S_Perk_08 :						return 'perk_8';
		case S_Perk_09 :						return 'perk_9';
		case S_Perk_10 :						return 'perk_10';
		case S_Perk_11 :						return 'perk_11';
		case S_Perk_12 :						return 'perk_12';
		case S_Perk_13 :						return 'perk_13';
		case S_Perk_14 :						return 'perk_14';
		case S_Perk_15 :						return 'perk_15';
		case S_Perk_16 :						return 'perk_16';
		case S_Perk_17 :						return 'perk_17';
		case S_Perk_18 :						return 'perk_18';
		case S_Perk_19 :						return 'perk_19';
		case S_Perk_20 :						return 'perk_20';
		case S_Perk_21 :						return 'perk_21';
		case S_Perk_22 :						return 'perk_22';
		
		default:								return '';
	}
}


enum EPlayerCommentary
{
	PC_MedalionWarning,
	PC_MonsterReaction,
	PC_NCFMClueCommentTrace,
	PC_NCFMClueCommentRemainings,
	PC_NCFMClueSoundDetected,
	PC_ColdWaterComment,
}

enum EPlayerWeapon
{
	PW_None,
	PW_Steel,
	PW_Silver,
	PW_Fists
}

enum EPlayerRangedWeapon
{
	PRW_None	,
	PRW_Crossbow
}

enum EPlayerCombatStance
{
	PCS_Normal,
	PCS_AlertNear,
	PCS_AlertFar,
	PCS_Guarded
}

enum ESignType
{
	ST_Aard,
	ST_Yrden,
	ST_Igni,
	ST_Quen,
	ST_Axii,
	ST_None
}

function SignNameToEnum( signName : name ) : ESignType
{
	switch(signName)
	{
		case 'Aard':			return ST_Aard;
		case 'Axii':			return ST_Axii;
		case 'Quen':			return ST_Quen;
		case 'Igni':			return ST_Igni;
		case 'Yrden':			return ST_Yrden;
		default:				return ST_None;
	}
}

function SignStringToEnum( signString : string ) : ESignType
{
	switch(signString)
	{
		case "Aard":			return ST_Aard;
		case "Axii":			return ST_Axii;
		case "Quen":			return ST_Quen;
		case "Igni":			return ST_Igni;
		case "Yrden":			return ST_Yrden;
		default:				return ST_None;
	}
}

function SignEnumToString( signType : ESignType ) : string	
{
	switch( signType )
	{
		case ST_Aard:		return "Aard";
		case ST_Yrden:		return "Yrden";
		case ST_Igni:		return "Igni";
		case ST_Quen:		return "Quen";
		case ST_Axii:		return "Axii";
		default : return "";
	}
}

enum EMoveSwitchDirection
{
	MSD_SlowForwardLeft,
	MSD_SlowForwardRight,
	MSD_SlowBackLeft,
	MSD_SlowBackRight,	
	MSD_FastForwardLeft,
	MSD_FastForwardRight,
	MSD_FastBackLeft,
	MSD_FastBackRight,
	MSD_None,
}

enum EPlayerEvadeType
{
	PET_Roll,
	PET_Dodge,
	PET_Pirouette,
}

enum EPlayerEvadeDirection
{
	PED_Forward,
	PED_ForwardLeft,
	PED_Left,
	PED_LeftBack,
	PED_Back,
	PED_BackRight,
	PED_Right,
	PED_RightForward,
}

enum EPlayerParryDirection
{
	PPD_Forward,
	PPD_Left,
	PPD_Back,
	PPD_Right,	
}

enum EPlayerRepelType
{
	PRT_Random,
	PRT_Bash,
	PRT_Kick,
	PRT_Slash,
	PRT_SideStepSlash,
	PRT_RepelToFinisher
}

enum ERotationRate
{
	RR_0 		= 0,
	RR_30 		= 30,
	RR_60 		= 60,
	RR_90 		= 90,
	RR_180 		= 180,
	RR_360 		= 360,
	RR_1080 	= 1080,
	RR_2160 	= 2160,
}

enum EItemType
{
	IT_Petard,
	IT_Bolt,
}


enum ESpecialAbilityInput
{
	SAI_Up,
	SAI_Down,
	SAI_Left,
	SAI_Right,
}

enum EThrowStage
{
	TS_Start,
	TS_Loop,
	TS_End,
	TS_Stop,
};

enum EParryStage
{
	PS_Start,
	PS_Loop,
	PS_End,
	PS_Stop,
};

enum EParryType 
{
	PT_Up,
	PT_UpLeft,
	PT_Left,
	PT_LeftDown,
	PT_Down,
	PT_DownRight,
	PT_Right,
	PT_RightUp,
	PT_Jab,
	PT_None,
}

enum EAttackSwingRange
{
	ASR_Short,
	ASR_Normal,
	ASR_Long,
}

function IsBufferActionAttackAction(a : EBufferActionType) : bool
{
	switch(a)
	{
		case EBAT_LightAttack:
		case EBAT_HeavyAttack:
		case EBAT_SpecialAttack_Light:
		case EBAT_SpecialAttack_Heavy:
		case EBAT_Ciri_SpecialAttack:
		case EBAT_Ciri_SpecialAttack_Heavy:
			return true;
			
		default:
			return false;
	}
}



struct SParryInfo
{
	var attacker					: CActor;
	var target						: CActor;
	var targetToAttackerAngleAbs	: float;
	var targetToAttackerDist		: float;
	var attackSwingType				: EAttackSwingType;
	var attackSwingDir				: EAttackSwingDirection;
	var attackActionName			: name;						
	var attackerWeaponId			: SItemUniqueId;			
	var canBeParried				: bool;						
};

import struct STargetSelectionWeights
{
	import var angleWeight			: float;
	import var distanceWeight		: float;
	import var distanceRingWeight	: float;
};

struct SDrunkMutagen
{
	var slot : int;
	var mutagenName : name;
	var toxicityOffset : float;				
	var effectType : EEffectType;
};

struct SWitcherSign
{
	editable	var template	: CEntityTemplate;
				var entity		: W3SignEntity;
};

struct SRadialSlotDef
{
	var slotName 		  : name;
	var disabledBySources : array < name >;
}









enum EInputActionBlock
{
	EIAB_Signs,
	EIAB_DrawWeapon,
	EIAB_OpenInventory,
	EIAB_RadialMenu,
	EIAB_CallHorse,
	EIAB_FastTravel,
	EIAB_Movement,
	EIAB_HighlightObjective,
	EIAB_Fists,
	EIAB_OpenPreparation,
	EIAB_Jump,
	EIAB_Roll,
	EIAB_InteractionAction,
	EIAB_ThrowBomb,
	EIAB_RunAndSprint,
	EIAB_OpenMap,
	EIAB_OpenCharacterPanel,
	EIAB_OpenJournal,
	EIAB_OpenAlchemy,
	EIAB_ExplorationFocus,	
	EIAB_Dive,
	EIAB_Interactions,
	EIAB_DismountVehicle,
	EIAB_Dodge,
	EIAB_SwordAttack,
	EIAB_Parry,
	EIAB_Sprint,
	EIAB_Explorations,
	EIAB_Undefined,
	EIAB_Counter,
	EIAB_LightAttacks,
	EIAB_HeavyAttacks,
	EIAB_QuickSlots,
	EIAB_Crossbow,
	EIAB_UsableItem,
	EIAB_OpenFastMenu,
	EIAB_OpenGlossary,
	EIAB_HardLock,
	EIAB_Climb,
	EIAB_Slide,
	EIAB_OpenGwint,
	EIAB_MeditationWaiting,
	EIAB_MountVehicle,
	EIAB_InteractionContainers,	
	EIAB_SpecialAttackLight,
	EIAB_SpecialAttackHeavy,
	EIAB_OpenMeditation,
	EIAB_Noticeboards,
	EIAB_FastTravelGlobal,
	EIAB_CameraLock
}

function IsActionCombat(action : EInputActionBlock) : bool
{
	switch(action)
	{
		case EIAB_Signs :
		case EIAB_DrawWeapon :
		case EIAB_Fists :
		case EIAB_Roll :
		case EIAB_ThrowBomb :
		case EIAB_Dodge :
		case EIAB_SwordAttack :
		case EIAB_Parry :
		case EIAB_Counter :
		case EIAB_LightAttacks :
		case EIAB_HeavyAttacks :
		case EIAB_Crossbow :
		case EIAB_SpecialAttackLight :
		case EIAB_SpecialAttackHeavy :
			return true;
		
		default :
			return false;
	}
	
	return false;
}

enum EPlayerMoveType
{
	PMT_Idle,
	PMT_Walk,
	PMT_Run,
	PMT_Sprint,
}

struct SHighlightMappin
{
	var MappinName : name;
	var MappinState : bool;
}

struct SInputActionLock
{
	saved var sourceName : name;
	saved var removedOnSpawn : bool;
	saved var isFromQuest : bool;
	saved var isFromPlace : bool;
}

struct SInteriorAreaInfo
{
	var areaName			: string;
	var isSmallInterior		: bool;
	var modifyPlayerSpeed	: bool;
}

struct SCustomOrientationInfo
{
	var orientationTarget	: EOrientationTarget;
	var sourceName 			: name;
	var customHeading		: float;
}

struct SSelectedQuickslotItem
{
	saved var sourceName : name;
	saved var itemID : SItemUniqueId;
}

enum EPlayerActionToRestore
{
	PATR_Default,
	PATR_Crossbow,
	PATR_CastSign,
	PATR_ThrowBomb,
	PATR_CallHorse,
	PATR_None
	
}

enum EPlayerInteractionLock
{
	PIL_Cutscene = 1,			
	PIL_Default = 2,
	PIL_CombatAction = 4,
	PIL_Dialog = 8,
	PIL_RadialMenu = 16,
	PIL_Vehicle = 32
	
};

enum EPlayerPreviewInventory
{
	PPI_default,
	PPI_Bear_1,
	PPI_Bear_4,
	PPI_Lynx_1,
	PPI_Lynx_4,
	PPI_Gryphon_1,
	PPI_Gryphon_4,
	PPI_Common_1,	
	PPI_Naked,
	PPI_Viper,
	PPI_Red_Wolf_1
}

enum EDismembermentWoundTypes
{
	DWT_Head,
	DWT_Torso,
	DWT_TorsoLeft,
	DWT_TorsoRight,
	DWT_ArmLeft,
	DWT_ArmRight,
	DWT_LegLeft,
	DWT_LegRight,
	DWT_Morph_Head,
	DWT_Morph_Torso,
	DWT_Morph_TorsoLeft,
	DWT_Morph_TorsoRight,
	DWT_Morph_ArmLeft,
	DWT_Morph_ArmRight,
	DWT_Morph_LegLeft,
	DWT_Morph_LegRight,
	DWT_DLC_Defined
}

enum ERecoilLevel
{
	RL_1,
	RL_2,
	RL_3
}

enum EPlayerMovementLockType
{
	PMLT_Free		,
	PMLT_NoSprint	,
	PMLT_NoRun		,
}
	
struct SRewardMultiplier
{
	var rewardName : name;
	var rewardMultiplier : float;
	var isItemMultiplier : bool;
};	

enum EHorseMode
{
	EHM_NotSet,
	EHM_Normal,
	EHM_Devil,
	EHM_Unicorn
}


 
