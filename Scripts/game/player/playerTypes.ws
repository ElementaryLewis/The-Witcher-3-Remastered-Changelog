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
	S_Sword_s22,			
	S_Sword_s23,			
	S_Sword_s24,			
	S_Sword_s25,			
	S_Sword_s26,			
	S_Sword_s27,			
	S_Sword_s28,			
	S_Sword_s29,			
	S_Sword_s30,			
	S_Sword_s31,			
	S_Sword_s32,			
	S_Sword_s33,			
	S_Sword_s34,			
	S_Sword_s35,			
	S_Sword_s36,			
	
	
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
	S_Magic_s21,			
	S_Magic_s22,			
	S_Magic_s23,			
	S_Magic_s24,			
	S_Magic_s25,			
	S_Magic_s26,			
	S_Magic_s27,			
	S_Magic_s28,			
	S_Magic_s29,			
	S_Magic_s30,			
	S_Magic_s31,			
	S_Magic_s32,			
	S_Magic_s33,			
	S_Magic_s34,			
	S_Magic_s35,			
	S_Magic_s36,			
	S_Magic_s37,			
	S_Magic_s38,			
	S_Magic_s39,			
	S_Magic_s40,			
	S_Magic_s41,			
	S_Magic_s42,			

	S_Alchemy_s22,			
	S_Alchemy_s23,			
	S_Alchemy_s24,			
	S_Alchemy_s25,			
	S_Alchemy_s26,			
	S_Alchemy_s27,			

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

	
	S_Perk_23,				
	S_Perk_24,				
	S_Perk_25,				
	S_Perk_26,				
	S_Perk_27,				
	S_Perk_28,				

	
	S_Perk_29,				
	S_Perk_30,				
	S_Perk_31,				
	S_Perk_32,				
	S_Perk_33,				
	S_Perk_34,				
	S_Perk_35,				
	S_Perk_36,				
	S_Perk_37,				
	S_Perk_38,				
	S_Perk_39,				
	S_Perk_40,				
	S_Perk_41,				
	S_Perk_42,				
	S_Perk_43,				
	S_Perk_44,				


	S_Perk_MAX,


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
		case 'sword_s22' :						return S_Sword_s22;
		case 'sword_s23' :						return S_Sword_s23;
		case 'sword_s24' :						return S_Sword_s24;
		case 'sword_s25' :						return S_Sword_s25;
		case 'sword_s26' :						return S_Sword_s26;
		case 'sword_s27' :						return S_Sword_s27;
		case 'sword_s28' :						return S_Sword_s28;
		case 'sword_s29' :						return S_Sword_s29;
		case 'sword_s30' :						return S_Sword_s30;
		case 'sword_s31' :						return S_Sword_s31;
		case 'sword_s32' :						return S_Sword_s32;
		case 'sword_s33' :						return S_Sword_s33;
		case 'sword_s34' :						return S_Sword_s34;
		case 'sword_s35' :						return S_Sword_s35;
		case 'sword_s36' :						return S_Sword_s36;
		
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
		case 'magic_s21' :						return S_Magic_s21;
		case 'magic_s22' :						return S_Magic_s22;
		case 'magic_s23' :						return S_Magic_s23;
		case 'magic_s24' :						return S_Magic_s24;
		case 'magic_s25' :						return S_Magic_s25;
		case 'magic_s26' :						return S_Magic_s26;
		case 'magic_s27' :						return S_Magic_s27;
		case 'magic_s28' :						return S_Magic_s28;
		case 'magic_s29' :						return S_Magic_s29;
		case 'magic_s30' :						return S_Magic_s30;
		case 'magic_s31' :						return S_Magic_s31;
		case 'magic_s32' :						return S_Magic_s32;
		case 'magic_s33' :						return S_Magic_s33;
		case 'magic_s34' :						return S_Magic_s34;
		case 'magic_s35' :						return S_Magic_s35;
		case 'magic_s36' :						return S_Magic_s36;
		case 'magic_s37' :						return S_Magic_s37;
		case 'magic_s38' :						return S_Magic_s38;
		case 'magic_s39' :						return S_Magic_s39;
		case 'magic_s40' :						return S_Magic_s40;
		case 'magic_s41' :						return S_Magic_s41;
		case 'magic_s42' :						return S_Magic_s42;
		
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
		case 'alchemy_s22' :					return S_Alchemy_s22;
		case 'alchemy_s23' :					return S_Alchemy_s23;
		case 'alchemy_s24' :					return S_Alchemy_s24;
		case 'alchemy_s25' :					return S_Alchemy_s25;
		case 'alchemy_s26' :					return S_Alchemy_s26;
		case 'alchemy_s27' :					return S_Alchemy_s27;
		
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
		case 'perk_23' :						return S_Perk_23;
		case 'perk_24' :						return S_Perk_24;
		case 'perk_25' :						return S_Perk_25;
		case 'perk_26' :						return S_Perk_26;
		case 'perk_27' :						return S_Perk_27;
		case 'perk_28' :						return S_Perk_28;
		case 'perk_29' :						return S_Perk_29;
		case 'perk_30' :						return S_Perk_30;
		case 'perk_31' :						return S_Perk_31;
		case 'perk_32' :						return S_Perk_32;
		case 'perk_33' :						return S_Perk_33;
		case 'perk_34' :						return S_Perk_34;
		case 'perk_35' :						return S_Perk_35;
		case 'perk_36' :						return S_Perk_36;
		case 'perk_37' :						return S_Perk_37;
		case 'perk_38' :						return S_Perk_38;
		case 'perk_39' :						return S_Perk_39;
		case 'perk_40' :						return S_Perk_40;
		case 'perk_41' :						return S_Perk_41;
		case 'perk_42' :						return S_Perk_42;
		case 'perk_43' :						return S_Perk_43;
		case 'perk_44' :						return S_Perk_44;


	
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
		case S_Sword_s22 :						return 'sword_s22';
		case S_Sword_s23 :						return 'sword_s23';
		case S_Sword_s24 :						return 'sword_s24';
		case S_Sword_s25 :						return 'sword_s25';
		case S_Sword_s26 :						return 'sword_s26';
		case S_Sword_s27 :						return 'sword_s27';
		case S_Sword_s28 :						return 'sword_s28';
		case S_Sword_s29 :						return 'sword_s29';
		case S_Sword_s30 :						return 'sword_s30';
		case S_Sword_s31 :						return 'sword_s31';
		case S_Sword_s32 :						return 'sword_s32';
		case S_Sword_s33 :						return 'sword_s33';
		case S_Sword_s34 :						return 'sword_s34';
		case S_Sword_s35 :						return 'sword_s35';
		case S_Sword_s36 :						return 'sword_s36';
		
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
		case S_Magic_s21 :						return 'magic_s21';
		case S_Magic_s22 :						return 'magic_s22';
		case S_Magic_s23 :						return 'magic_s23';
		case S_Magic_s24 :						return 'magic_s24';
		case S_Magic_s25 :						return 'magic_s25';
		case S_Magic_s26 :						return 'magic_s26';
		case S_Magic_s27 :						return 'magic_s27';
		case S_Magic_s28 :						return 'magic_s28';
		case S_Magic_s29 :						return 'magic_s29';
		case S_Magic_s30 :						return 'magic_s30';
		case S_Magic_s31 :						return 'magic_s31';
		case S_Magic_s32 :						return 'magic_s32';
		case S_Magic_s33 :						return 'magic_s33';
		case S_Magic_s34 :						return 'magic_s34';
		case S_Magic_s35 :						return 'magic_s35';
		case S_Magic_s36 :						return 'magic_s36';
		case S_Magic_s37 :						return 'magic_s37';
		case S_Magic_s38 :						return 'magic_s38';
		case S_Magic_s39 :						return 'magic_s39';
		case S_Magic_s40 :						return 'magic_s40';
		case S_Magic_s41 :						return 'magic_s41';
		case S_Magic_s42 :						return 'magic_s42';
		
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
		case S_Alchemy_s22 :					return 'alchemy_s22';
		case S_Alchemy_s23 :					return 'alchemy_s23';
		case S_Alchemy_s24 :					return 'alchemy_s24';
		case S_Alchemy_s25 :					return 'alchemy_s25';
		case S_Alchemy_s26 :					return 'alchemy_s26';
		case S_Alchemy_s27 :					return 'alchemy_s27';
		
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
		case S_Perk_23 :						return 'perk_23';
		case S_Perk_24 :						return 'perk_24';
		case S_Perk_25 :						return 'perk_25';
		case S_Perk_26 :						return 'perk_26';
		case S_Perk_27 :						return 'perk_27';
		case S_Perk_28 :						return 'perk_28';
		case S_Perk_29 :						return 'perk_29';
		case S_Perk_30 :						return 'perk_30';
		case S_Perk_31 :						return 'perk_31';
		case S_Perk_32 :						return 'perk_32';
		case S_Perk_33 :						return 'perk_33';
		case S_Perk_34 :						return 'perk_34';
		case S_Perk_35 :						return 'perk_35';
		case S_Perk_36 :						return 'perk_36';
		case S_Perk_37 :						return 'perk_37';
		case S_Perk_38 :						return 'perk_38';
		case S_Perk_39 :						return 'perk_39';
		case S_Perk_40 :						return 'perk_40';
		case S_Perk_41 :						return 'perk_41';
		case S_Perk_42 :						return 'perk_42';
		case S_Perk_43 :						return 'perk_43';
		case S_Perk_44 :						return 'perk_44';

		
		default:								return '';
	}
}

function SkillEnumToRemasterName(s : ESkill) : name
{
	switch(s)
	{
		case S_Sword_s02 :						return 'Rend';
		case S_Sword_s16 :						return 'Resolve';
		case S_Sword_s18 :						return 'Undying';
		case S_Sword_s19 :						return 'Flood of Anger';
		case S_Sword_s20 :						return 'Razor Focus';
		case S_Sword_s22 :						return 'Muscle Memory';
		case S_Sword_s23 :						return 'Strength Training';
		case S_Sword_s24 :						return 'Precise Blows';
		case S_Sword_s25 :						return 'Crushing Blows';
		case S_Sword_s26 :						return 'Anatomical Knowledge';
		case S_Sword_s27 :						return 'Crippling Shot';
		case S_Sword_s28 :						return 'Sunder Armor';
		case S_Sword_s29 :						return 'Crippling Strikes';
		case S_Sword_s30 :						return 'Deadly Precision';
		case S_Sword_s31 :						return 'Counter Attack';
		case S_Sword_s32 :						return 'Lightning Reflexes';
		case S_Sword_s33 :						return 'Arrow Deflection';
		case S_Sword_s34 :						return 'Cold Blood';
		case S_Sword_s35 :						return 'Whirl';
		case S_Sword_s36 :						return 'Fleet Footed';
		
		case S_Magic_s01 :						return 'Aard Sweep';
		case S_Magic_s03 :						return 'Magic Trap';
		case S_Magic_s08 :						return 'Melt Armor';
		case S_Magic_s11 :						return 'Supercharged Glyphs';
		case S_Magic_s13 :						return 'Exploding Shield';
		case S_Magic_s14 :						return 'Active Shield';
		case S_Magic_s17 :						return 'Delusion';
		case S_Magic_s19 :						return 'Domination';
		case S_Magic_s20 :						return 'Far Reaching Aard';
		case S_Magic_s28 :						return 'Firestream';
		case S_Magic_s31 :						return 'Puppet';
		case S_Magic_s33 :						return 'Shock Wave';
		case S_Magic_s35 :						return 'Catalyst';
		case S_Magic_s36 :						return 'Fortified Signs';
		case S_Magic_s37 :						return 'Convergence Theory';
		case S_Magic_s38 :						return 'Focus';
		case S_Magic_s39 :						return 'Avoidance';
		case S_Magic_s40 :						return 'Overload';
		case S_Magic_s41 :						return 'Resonance';
		case S_Magic_s42 :						return 'Sustained Glyphs';
		
		case S_Alchemy_s02 :					return 'Refreshment';
		case S_Alchemy_s03 :					return 'Delayed Recovery';
		case S_Alchemy_s04 :					return 'Side Effects';
		case S_Alchemy_s05 :					return 'Protective Coating';
		case S_Alchemy_s08 :					return 'Efficiency';
		case S_Alchemy_s10 :					return 'Pyrotechnics';
		case S_Alchemy_s11 :					return 'Cluster Bombs';
		case S_Alchemy_s12 :					return 'Poisoned Blades';
		case S_Alchemy_s13 :					return 'Tissue Transformation';
		case S_Alchemy_s14 :					return 'Adaptation';
		case S_Alchemy_s15 :					return 'Fast Metabolism';
		case S_Alchemy_s16 :					return 'Frenzy';
		case S_Alchemy_s18 :					return 'Acquired Tolerance';
		case S_Alchemy_s20 :					return 'Endure Pain';
		case S_Alchemy_s22 :					return 'Debilitating Poison';
		case S_Alchemy_s23 :					return 'Toxic Shock';
		case S_Alchemy_s24 :					return 'Heightened Tolerance';
		case S_Alchemy_s25 :					return 'Volatile Concoction';
		case S_Alchemy_s26 :					return 'Wyvern Sting';
		case S_Alchemy_s27 :					return 'Hunter Instinct';
		
		case S_Perk_23 :						return 'Cat School Technique';
		case S_Perk_24 :						return 'Griffin School Technique';
		case S_Perk_25 :						return 'Bear School Technique';
		case S_Perk_26 :						return 'Wolven School Technique';
		case S_Perk_27 :						return 'Manticore School Technique';
		case S_Perk_28 :						return 'Viper School Technique';
		case S_Perk_30 :						return 'Survival Instinct';
		case S_Perk_31 :						return 'Attack is the Best Defense';
		case S_Perk_32 :						return 'Metabolism Boost';
		case S_Perk_33 :						return 'Metabolic Control';
		case S_Perk_34 :						return 'Rage Management';
		case S_Perk_35 :						return 'Strong Back';
		case S_Perk_37 :						return 'Conjunction';
		case S_Perk_38 :						return 'Sun and Stars';
		case S_Perk_39 :						return 'Advanced Pyrotechnics';
		case S_Perk_40 :						return 'Battle Frenzy';
		case S_Perk_41 :						return 'Gourmet';
		case S_Perk_42 :						return 'Adrenaline Burst';
		case S_Perk_43 :						return 'Synergy';
		case S_Perk_44 :						return 'Element of Surprise';
		
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
	RR_5		= 5,
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
	EIAB_CameraLock,
	EIAB_NonPatternAlternatives,	

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
	PATR_None,

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

enum EPreciseBlowsCounterId
{
	PreciseBlowsCounterId_Fast,
	PreciseBlowsCounterId_Strong
};

enum ECrushingBlowsCounterId
{
	CrushingBlowsCounterId_SimpleAttack,
	CrushingBlowsCounterId_BuffedAttack
};