/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EMonsterCluesTypes
{
	MCT_MonsterSize,
	MCT_MonsterSound,
	MCT_DamageMarks,
	MCT_VictimState,
	MCT_MonsterApperance, 	
	MCT_SkinFacture,		
	MCT_MonsterMovement,	
	MCT_MonsterBehaviour,	
	MCT_MonsterAttitude,	
	MCT_AttackTime,			
	MCT_MonsterHideout		
}

enum EMonsterSize
{
	MS_Human,
	MS_Giant,
	MS_SmallHuman,
	MS_BigHuman,
	MS_Child,
	MS_GiantSnake,
	MS_Dog,
	MS_Cart,
	MS_Horse
}

enum EMonsterEmittedSound
{
	MES_Growling,
	MES_Mumbling,
	MES_Hissing,
	MES_Roaring,
	MES_Shrieking,
	MES_Yelling,
	MES_Clattering,	
	MES_Murmuring,
	MES_Sneering,
	MES_Silent
}

enum EMonsterDamageMarks
{
	DM_PoisonousBite,
	DM_Bruises,
	DM_FleshRips,
	DM_SharpBites,
	DM_BluntClaws,
	DM_BluntBites,
	DM_Claws,
	DM_Crippled,
	DM_Scaldings,
	DM_RazorSharpCuts,
	DM_BleachedHair,
	DM_Frozen,
	DM_BrokenBones,
	DM_PiercedWounds,
	DM_StrangleGrip,
	DM_BlueTongue,
	DM_StickyMucus,
	DM_Drained
}

enum EMonsterVictimState
{
	VS_PartiallyEaten,
	VS_Drained,
	VS_Drowned,
	VS_TornApart,
	VS_Swollen,
	VS_Hemorrhaged,
	VS_Beaten,
	VS_Paralyzed,
	VS_Buldgeoned,
	VS_Burned,
	VS_Suffocated,
}


enum EMonsterApperance 
{	
	MAE_Muscular,
    MAE_GlowingEyes,
    MAE_Skinny,
    MAE_Stocky,
    MAE_Beautiful,
    MAE_Mandibles,
    MAE_SkinWings,
    MAE_Trinkets,
    MAE_Pieces_of_Armor,
    MAE_PowerfulJaws,
    MAE_Massive,
    MAE_Terrifying,
    MAE_Tentacles,
    MAE_BigMandibles,
    MAE_Hungering,
    MAE_LongTail,
    MAE_Owl_like
}

enum EMonsterSkinFacture 
{
	MSF_Callous,
    MSF_VeinySmooth,
    MSF_DirtyDecomposed,
    MSF_PaleOily,
    MSF_AlabasterPale,
    MSF_ScorchedEarth_like,
    MSF_Feathers,
    MSF_RuggedSkin,
    MSF_ShellSegments,
    MSF_Ethereal,
    MSF_Scales,
    MSF_Fur
}

enum EMonsterMovement 
{
	MM_FastWalk,
    MM_VeryFastRun,
    MM_SluggishWalk,
    MM_LightningFastRun,
    MM_Walk,
    MM_Flight,
    MM_Swim,
    MM_Crawl,
    MM_Float,
    MM_Jump,
    MM_Roll,
    MM_NoMovement
}

enum EMonsterBehaviour 
{	
	MB_Lurking,
	MB_Ambushing,
	MB_Attracting,
	MB_Wandering,
	MB_Stalking
}

enum EMonsterAttitude 
{
	MA_Aggressive,
	MA_Cunning,
	MA_Careful,
	MA_Vicious
}

enum EMonsterAttackTime 
{
	AT_AllDay,
	AT_Day,
	AT_AfterDark,
	AT_Night
}

enum EMonsterHideout
{
	MH_Crypt,
	MH_Cave,
	MH_UnderwaterCave,
	MH_MountainCave,
	MH_MountainCliff,
	MH_RuinedBuilding,
	MH_Forest,
	MH_Underground,
	MH_Catacombs,
	MH_Ravine,
	MH_Basement,
	MH_Swamp,
	MH_Glade
}