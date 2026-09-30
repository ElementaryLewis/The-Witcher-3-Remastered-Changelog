/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3BuffCustomParams {}


struct SCustomEffectParams
{
	var effectType 				: EEffectType;				
	var creator 				: CGameplayEntity;			
	var sourceName				: string;					
	var duration				: float;					
	var effectValue				: SAbilityAttributeValue;	
	var customAbilityName		: name;						
	var customFXName			: name;						
	var isSignEffect			: bool;						
	var customPowerStatValue	: SAbilityAttributeValue;	
	var buffSpecificParams		: W3BuffCustomParams;		
	var vibratePadLowFreq 		: float;					
	var vibratePadHighFreq 		: float;					
};

struct SCurrentBuffFX
{
	var fx : name;
	var sources : array<string>;
};

class W3PotionParams extends W3BuffCustomParams
{
	var potionItemName : name;
}


struct SEffectInitInfo
{
	var owner : CGameplayEntity;
	var target : CActor;
	var duration : float;
	var sourceName : string;
	var targetEffectManager : W3EffectManager;

	
	var powerStatValue : SAbilityAttributeValue;
	var customEffectValue : SAbilityAttributeValue;
	var customAbilityName : name;
	var customFXName : name;
	var isSignEffect : bool;
	var vibratePadLowFreq 		: float;					
	var vibratePadHighFreq 		: float;					
};


struct SEffectInfo
{
	editable var effectType : EEffectType;
	editable var effectDuration : float;
	editable var effectAbilityName : name;						
	editable var customFXName : name;
	editable var effectCustomValue : SAbilityAttributeValue;	
	editable var effectCustomParam : W3BuffCustomParams;
	editable var applyChance : float;							
	
		hint effectDutation = "Set -1 for infinite";
};


struct SEffectCachedDamage
{
	saved var dmgType : name;	
	saved var attacker : EntityHandle;					
	saved var carrier : CBaseGameplayEffect;			
	saved var dmgVal	: float;
	saved var dt : float;								
	saved var dontShowHitParticle : bool;
	saved var powerStatType : ECharacterPowerStats;		
	saved var isEnvironment : bool;						
	saved var sourceName : string;						
};


struct SDoTDamage
{
	saved var damageTypeName : name;					
	saved var hitsVitality  : bool;						
	saved var hitsEssence  : bool;						
	saved var resistance : ECharacterDefenseStats;		
};


struct SEffectIconType
{
	var typeName : name;
	var path : string;
};


enum EEffectInteract
{
	EI_Undefined,			
	EI_Deny,				
	EI_Override,			
	EI_Pass,				
	EI_Cumulate				
}

function EffectInteractionSuccessfull( e : EEffectInteract ) : bool
{
	if( e == EI_Undefined || e == EI_Deny )
	{
		return false;
	}
	
	return true;
}






enum EEffectType
{
	EET_Undefined,		

	
	EET_AutoVitalityRegen,
	EET_AutoStaminaRegen,
	EET_AutoEssenceRegen,
	EET_AutoMoraleRegen,
		
	
	EET_Confusion,
	EET_HeavyKnockdown,
	EET_Hypnotized,
	EET_Immobilized,
	EET_Knockdown,	
	EET_KnockdownTypeApplicator,
	EET_Frozen,
	EET_Paralyzed,
	EET_Stagger,
	EET_Blindness,
	EET_PoisonCritical,
				
	
	EET_Bleeding,
	EET_BleedingTracking,
	EET_Burning,
	EET_Poison,
	EET_DoTHPRegenReduce,
		
	
	EET_Toxicity,
		
	
	EET_BlackBlood,
	EET_Blizzard,
	EET_Cat,
	EET_FullMoon,
	EET_GoldenOriole,
	EET_MariborForest,
	EET_PetriPhiltre,
	EET_Swallow,
	EET_TawnyOwl,

	EET_Thunderbolt,
EET_Unused1,
	EET_WhiteHoney,
	EET_WhiteRaffardDecoction,
	EET_KillerWhale,
	
	
	EET_AxiiGuardMe,
	EET_IgnorePain,
	
	
	EET_StaggerAura,
	EET_OverEncumbered,
	EET_Edible,	
	EET_LowHealth,
	EET_Slowdown,
	EET_Fact,
	EET_WellFed,
	EET_SlowdownFrost,
	
	
	EET_LongStagger,				
	EET_WellHydrated,
	EET_BattleTrance,				
	EET_YrdenHealthDrain,
	EET_AdrenalineDrain,
	EET_WeatherBonus,
	EET_Swarm,						
	EET_Pull,						
	EET_AbilityOnLowHealth,			
	EET_Oil,
	EET_CounterStrikeHit,	
	EET_Drowning,
	EET_Snowstorm,	
	EET_AutoAirRegen,
	
	
	EET_ShrineAard,
	EET_ShrineAxii,
	EET_ShrineIgni,
	EET_ShrineQuen,
	EET_ShrineYrden,
	
	
	EET_Ragdoll,	
	EET_AutoPanicRegen,	
	EET_VitalityDrain,
	EET_DoppelgangerEssenceRegen,	
	EET_FireAura,	
	EET_BoostedEssenceRegen,
	EET_AirDrain,
	EET_SilverDust,

	
	EET_Mutagen01,
	EET_Mutagen02,
	EET_Mutagen03,
	EET_Mutagen04,
	EET_Mutagen05,
	EET_Mutagen06,
	EET_Mutagen07,
	EET_Mutagen08,
	EET_Mutagen09,
	EET_Mutagen10,
	EET_Mutagen11,
	EET_Mutagen12,
	EET_Mutagen13,
	EET_Mutagen14,
	EET_Mutagen15,
	EET_Mutagen16,
	EET_Mutagen17,
	EET_Mutagen18,
	EET_Mutagen19,
	EET_Mutagen20,
	EET_Mutagen21,
	EET_Mutagen22,
	EET_Mutagen23,
	EET_Mutagen24,
	EET_Mutagen25,
	EET_Mutagen26,
	EET_Mutagen27,
	EET_Mutagen28,
	
	
	EET_AirDrainDive,
	EET_BoostedStaminaRegen,
	EET_WitchHypnotized,
	EET_AirBoost,
	EET_StaminaDrainSwimming,
	EET_AutoSwimmingStaminaRegen,
	EET_Drunkenness,
	EET_WraithBlindness,
	EET_Choking,
	EET_StaminaDrain,
	EET_EnhancedArmor,
	EET_EnhancedWeapon,
	EET_SnowstormQ403,
	EET_SlowdownAxii,
	EET_PheromoneNekker,
	EET_PheromoneDrowner,
	EET_PheromoneBear,
	EET_Tornado,
	EET_WolfHour,
	EET_WeakeningAura,
	EET_Weaken,
	
	EET_Tangled,					
	EET_Runeword8,
	EET_LynxSetBonus,
	EET_GryphonSetBonus,
	EET_GryphonSetBonusYrden,
	EET_POIGorA10,
	EET_Mutation7Buff,
	EET_Mutation7Debuff,
	EET_Mutation10,
	EET_Perk21InternalCooldown,
	EET_Mutation11Buff,
	EET_Mutation11Debuff,	
	EET_Acid,						
	EET_WellRested,
	EET_HorseStableBuff,
	EET_BookshelfBuff,
	EET_PolishedGenitals,
	EET_Mutation12Cat,
	EET_Mutation11Immortal,
	EET_Aerondight,
	EET_Trap,
	EET_Mutation3,
	EET_Mutation4,
	EET_Mutation5,
	EET_ToxicityVenom,
	EET_BasicQuen,
	
	
	EET_ReinaldPhiltre,
	
	
	EET_Bleeding1,
	EET_Bleeding2,
	EET_Bleeding3,
	
	
	
	
EET_EffectTypesSize,
EET_ForceEnumTo16Bit = 10000
}


function GetMinorShrineBuffs() : array<EEffectType>
{
	var ret : array<EEffectType>;
	
	ret.PushBack(EET_ShrineAard);
	ret.PushBack(EET_ShrineAxii);
	ret.PushBack(EET_ShrineIgni);
	ret.PushBack(EET_ShrineQuen);
	ret.PushBack(EET_ShrineYrden);
	
	return ret;
}


import struct CBuffImmunity
{
	
	import var  potion : Bool ;
	import var  positive  : Bool ;
	import var 	neutral : bool;
	import var  negative : Bool ;
	import var  immobilize : Bool ;
	import var  confuse : Bool ;
	import var  damage : Bool ;
	
	
	import var  immunityTo : array<int>;		
}


struct SApplicatorSpawnEffect
{		
	saved var spawnAbilityName : name;											
	saved var spawnType : EEffectType;											
	saved var spawnFlagsHostile, spawnFlagsNeutral, spawnFlagsFriendly : bool;	
	saved var spawnSourceName : string;											
};

struct SPausedAutoEffect
{
	saved var effectType		: EEffectType;
	saved var duration 			: float;
	saved var sourceName 		: name;
	saved var singleLock 		: bool;
	saved var useMaxDuration 	: bool;
	saved var timeLeft 			: float;
};

struct STemporarilyPausedEffect
{
	saved var buff			: CBaseGameplayEffect;
	saved var timeLeft 		: float;
	saved var source 		: name;
	saved var singleLock 	: bool;
	saved var useMaxDuration 	: bool;
	saved var duration 			: float;
};

struct SBuffPauseLock
{
	saved var sourceName 	: name;
	saved var counter 		: int;
};


function ModifyHitSeverityBuff(target : CActor, type : EEffectType) : EEffectType
{
	var severityReduction, severity : int;
	var npc : CNewNPC;
	var witcher : W3PlayerWitcher;
	var quenEntity : W3QuenEntity;

	severityReduction = RoundMath(CalculateAttributeValue(target.GetAttributeValue('hit_severity')));
		
	
	switch(type)
	{
		case EET_HeavyKnockdown : 	severity = 4; break;
		case EET_Knockdown :		severity = 3; break;
		case EET_LongStagger : 		severity = 2; break;
		case EET_Stagger :			severity = 1; break;
		default :					severity = 0; break;
	}
	
	
	severity -= severityReduction;
	
	
	if(target.HasAlternateQuen())		
	{
		if( (CNewNPC)target )
		{
			
			severity -= 1;
		}
		else
		{
			
			witcher = (W3PlayerWitcher)target;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					severity -= 1;
				}
			}
		}
	}
	
	
	if(severity == 4 && target.IsImmuneToBuff(EET_HeavyKnockdown))		severity = 3;
	if(severity == 3 && target.IsImmuneToBuff(EET_Knockdown))			severity = 2;
	if(severity == 2 && target.IsImmuneToBuff(EET_LongStagger))			severity = 1;
	if(severity == 1 && target.IsImmuneToBuff(EET_Stagger))				severity = 0;
			
	
	if(severity >= 4)
		return EET_HeavyKnockdown;
	else if(severity == 3)
		return EET_Knockdown;
	else if(severity == 2)
		return EET_LongStagger;
	else if(severity == 1)
		return EET_Stagger;
	else
		return EET_Undefined;
}

function IsKnockdownEffectType(type : EEffectType) : bool
{
	switch (type)
	{
		case EET_HeavyKnockdown :
		case EET_Knockdown :
		case EET_LongStagger :
		case EET_Stagger :
			return true;
		default: 
			return false;
	}
}

function IsCriticalEffectType(type : EEffectType) : bool
{
	switch (type)
	{
		case EET_Immobilized :
		case EET_Burning :
		case EET_Knockdown :
		case EET_HeavyKnockdown :
		case EET_Blindness :
		case EET_WraithBlindness :
		case EET_Confusion :
		case EET_Paralyzed :
		case EET_Hypnotized :
		case EET_WitchHypnotized :
		case EET_Stagger :
		case EET_CounterStrikeHit :
		case EET_LongStagger :
		case EET_Pull :
		case EET_Tangled :
		case EET_Ragdoll :
		case EET_PoisonCritical :
		case EET_Frozen :
		case EET_Tornado :
		case EET_Trap :
		case EET_Swarm :
		case EET_Snowstorm :
		case EET_SnowstormQ403 :
		case EET_KnockdownTypeApplicator :
			return true;
		default: 
			return false;
	}
}

function IsNegativeEffectType(type : EEffectType) : bool
{
	if ( IsCriticalEffectType( type ) )
		return true;
		
	switch (type)
	{
		case EET_DoTHPRegenReduce :
		case EET_AirDrain :
		case EET_AirDrainDive :
		case EET_StaminaDrain :
		case EET_StaminaDrainSwimming :
		case EET_VitalityDrain :
		case EET_Drunkenness :
		case EET_OverEncumbered :
		case EET_SilverDust :
		case EET_Slowdown :
		case EET_SlowdownFrost :
		case EET_AxiiGuardMe :
		case EET_YrdenHealthDrain :
			return true;
		default: 
			return false;
	}
}

function GetBuffCriticalType(buff : CBaseGameplayEffect) : ECriticalStateType
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return ECST_None;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.GetCriticalStateType();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.GetCriticalStateType();
	}
	
	return ECST_None;
}

function CriticalBuffIsDestroyedOnInterrupt(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.IsDestroyedOnInterrupt();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.IsDestroyedOnInterrupt();
	}
	
	return false;
}


function CriticalBuffIsHitAllowed(buff : CBaseGameplayEffect, hit : EHitReactionType) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return true;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.IsHitAllowed(hit);
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.IsHitAllowed(hit);
	}
	
	return true;
}

function IsCriticalEffect(e : CBaseGameplayEffect) : bool
{
	if(!e)
		return false;
		
	return ((W3CriticalEffect)e) || ((W3CriticalDOTEffect)e) || e.GetEffectType() == EET_KnockdownTypeApplicator;
}

function IsDoTEffect(e : CBaseGameplayEffect) : bool
{
	if(!e)
		return false;
		
	return ((W3DamageOverTimeEffect)e) || ((W3CriticalDOTEffect)e);
}

function CriticalEffectCanPlayAnimation(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.CanPlayAnimation();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.CanPlayAnimation();
	}
	
	return false;
}

function CriticalBuffDisallowPlayAnimation(buff : CBaseGameplayEffect)
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.DisallowPlayAnimation();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.DisallowPlayAnimation();
	}
	
	return;
}

function CriticalBuffUsesFullBodyAnim(buff : CBaseGameplayEffect) : bool
{
	var crit : W3CriticalEffect;
	var critDOT : W3CriticalDOTEffect;
	
	if(!buff)
		return false;
		
	crit = (W3CriticalEffect)buff;
	if(crit)
	{
		return crit.UsesFullBodyAnim();
	}
	else
	{
		critDOT = (W3CriticalDOTEffect)buff;
		if(critDOT)
			return critDOT.UsesFullBodyAnim();
	}
	
	return false;
}



enum ECriticalHandling
{
	ECH_HandleNow,			
	ECH_Postpone,			
	ECH_Abort				
}

struct SBuffImmunity
{
	saved var buffType : EEffectType;
	saved var sources : array<name>;
};