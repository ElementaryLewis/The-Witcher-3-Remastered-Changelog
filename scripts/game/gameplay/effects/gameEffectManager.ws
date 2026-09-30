/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GameEffectManager
{
	private var effects : array< CBaseGameplayEffect >;			
	private var effectNames : array<name>;						
	private var isReady : bool;									
	private var effectIconTypes : array<SEffectIconType>;		
	
		default isReady = false;
	
	
	function Initialize()
	{
		var i,size : int;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var effectName, iconTypeName : name;
		var iconType : SEffectIconType;
		var path : string;
		
		
		isReady = false;
		effects.Clear();
		effectNames.Clear();
		effectIconTypes.Clear();
		
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', effectName))
			{
				if(IsNameValid(effectName))
					effectNames.PushBack(effectName);
				else
					LogAssert(false, "W3GameEffectManager.Initialize(): not valid effect name <<" + effectName + ">> read from XML file");
			}
		}
		
		
		main = dm.GetCustomDefinition('effect_icons');
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', iconTypeName) && dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'path', path) )
			{
				iconType.typeName = iconTypeName;
				iconType.path = path;
				effectIconTypes.PushBack(iconType);
			}
		}
		
		effects.Grow( (int)EET_EffectTypesSize );
		
		
		for(i=0; i<effectNames.Size(); i+=1)
			if(IsBuffAutoBuff(i))
				CacheEffect(i);	
		
		isReady = true;
	}
	
	
	public function GetPathForEffectIconTypeName(type : name) : string
	{
		var i : int;
	
		if(!isReady)
			return "";
			
		for(i=0; i<effectIconTypes.Size(); i+=1)
			if(effectIconTypes[i].typeName == type)
				return effectIconTypes[i].path;
		
		return "";
	}
	
	
	public function GetEffectNameLocalisationKey( effect : EEffectType ) : string
	{
		if( !effects[effect] )
			CacheEffect( effect );
			
		return effects[effect].GetEffectNameLocalisationKey();
	}
	
	
	public function GetEffectDescriptionLocalisationKey( effect : EEffectType ) : string
	{
		if( !effects[effect] )
			CacheEffect( effect );
			
		return effects[effect].GetEffectDescriptionLocalisationKey();
	}

	
	public function GetEffectIconPath( effect : EEffectType ) : string
	{
		if( !effects[effect] )
			CacheEffect( effect );
			
		return effects[effect].GetIcon();
	}

	public function IsReady() : bool {return isReady;}
	
	
	public function GetEffectTypeFlags(effect : EEffectType, out potion, positive, neutral, negative, immobilize, confuse, damage : bool)
	{
		if( !effects[effect] )
			CacheEffect( effect );
			
		potion = effects[effect].IsPotionEffect();		
		positive = effects[effect].IsPositive();
		negative = effects[effect].IsNegative();
		neutral = effects[effect].IsNeutral();
		
		if( (W3ImmobilizeEffect)effects[effect] )
			immobilize = true;
		else
			immobilize = false;
		
		if( (W3ConfuseEffect)effects[effect] || (W3BlindnessEffect)effects[effect] )
			confuse = true;
		else
			confuse = false;
		
		if( (W3DamageOverTimeEffect)effects[effect] )
			damage = true;
		else
			damage = false;
	}
	
	
	public function MakeNewEffect(effect : EEffectType, ownr : CGameplayEntity, target : CActor, effectManager : W3EffectManager, inDuration : float, srcName : string, optional powerStatValue : SAbilityAttributeValue, optional customVal : SAbilityAttributeValue, optional customAbilityName : name, optional customFXName : name, optional signEffect : bool, optional vibratePadLowFreq : float, optional vibratePadHighFreq : float) : CBaseGameplayEffect
	{
		var e : CBaseGameplayEffect;
		var params : SEffectInitInfo;
	
		
		if(effect == EET_Undefined || effect == EET_Unused1)
			return NULL;
		
		
		if(!effects[effect])
			CacheEffect(effect);
			
		if(!effects[effect])
			return NULL;
			
		e = (CBaseGameplayEffect)(effects[effect].Clone(target));

		params.owner = ownr;
		params.target = target;
		params.duration = inDuration;
		params.sourceName = srcName;
		params.powerStatValue = powerStatValue;
		params.customEffectValue = customVal;
		params.customAbilityName = customAbilityName;
		params.customFXName = customFXName;
		params.isSignEffect = signEffect;
		params.targetEffectManager = effectManager;
		params.vibratePadLowFreq = vibratePadLowFreq;
		params.vibratePadHighFreq = vibratePadHighFreq;
		
		e.Init(params);
	
		return e;
	}		

	
	private function CacheEffect(effect : EEffectType)
	{
		var ret : bool;
		
		
		if(effect == EET_Undefined || effect == EET_Unused1)
			return;
			
		ret = HACK_NO_MEMORY_TO_COMPILE_CacheEffect_Part1(effect);
		
		if(!ret)
			ret = HACK_NO_MEMORY_TO_COMPILE_CacheEffect_Part2(effect);
			
		if(ret)
		{
			effects[effect].CacheSettings();
		}
		else
		{
			LogAssert(false,"W3GameEffectManager.CacheEffect: cannot cache effect of type <<" + effect + ">> unknown type!");
		}
	}		
	
	private function HACK_NO_MEMORY_TO_COMPILE_CacheEffect_Part1(effect : EEffectType) : bool
	{
		var found : bool;
		
		if(effects[effect])
		{
			LogAssert(false, "W3GameEffectManager.CacheEffect: Tries to cache already cached effect!");
			return false;
		}
		
		found = true;
	
		switch(effect)
		{
			
			case EET_AutoEssenceRegen :			effects[effect] = new W3Effect_AutoEssenceRegen in this; 			break;
			case EET_AutoMoraleRegen :			effects[effect] = new W3Effect_AutoMoraleRegen in this; 			break;
			case EET_AutoStaminaRegen :			effects[effect] = new W3Effect_AutoStaminaRegen in this; 			break;
			case EET_AutoVitalityRegen : 		effects[effect] = new W3Effect_AutoVitalityRegen in this; 			break;
			case EET_AutoAirRegen : 			effects[effect] = new W3Effect_AutoAirRegen in this; 				break;
			case EET_AutoPanicRegen :			effects[effect] = new W3Effect_AutoPanicRegen in this;				break;
			case EET_AutoSwimmingStaminaRegen :	effects[effect] = new W3Effect_AutoSwimmingStaminaRegen in this;				break;
			case EET_DoppelgangerEssenceRegen :	effects[effect] = new W3Effect_DoppelgangerEssenceRegen in this;	break;
			case EET_AdrenalineDrain :			effects[effect] = new W3Effect_AdrenalineDrain in this;				break;
			
			
			case EET_Blindness : 				effects[effect] = new W3BlindnessEffect in this; 					break;
			case EET_WraithBlindness : 			effects[effect] = new W3WraithBlindnessEffect in this; 				break;
			case EET_Confusion :				effects[effect] = new W3ConfuseEffect in this; 						break;
			case EET_HeavyKnockdown :			effects[effect] = new W3Effect_HeavyKnockdown in this; 				break;
			case EET_Hypnotized :				effects[effect] = new W3Effect_Hypnotized in this; 					break;
			case EET_WitchHypnotized :			effects[effect] = new W3Effect_WitchHypnotized in this; 			break;
			case EET_Immobilized :				effects[effect] = new W3ImmobilizeEffect in this; 					break;
			case EET_Knockdown :				effects[effect] = new W3Effect_Knockdown in this; 					break;				
			case EET_KnockdownTypeApplicator :	effects[effect] = new W3Effect_KnockdownTypeApplicator in this;		break;
			case EET_Paralyzed :				effects[effect] = new W3Effect_Paralyzed in this; 					break;
			case EET_LongStagger :				effects[effect] = new W3Effect_LongStagger in this; 				break;
			case EET_Stagger :					effects[effect] = new W3Effect_Stagger in this; 					break;
			case EET_Swarm :					effects[effect] = new W3Effect_Swarm in this; 						break;
			case EET_SnowstormQ403:				effects[effect] = new W3Effect_SnowstormQ403 in this; 				break;
			case EET_Snowstorm :				effects[effect] = new W3Effect_Snowstorm in this; 					break;
			case EET_Pull :						effects[effect] = new W3Effect_Pull in this; 						break;
			case EET_Tangled :					effects[effect] = new W3Effect_Tangled in this; 					break;
			case EET_CounterStrikeHit :			effects[effect] = new W3Effect_CounterStrikeHit in this; 			break;
			case EET_Ragdoll :					effects[effect] = new W3Effect_Ragdoll in this; 					break;
			case EET_Frozen :					effects[effect] = new W3Effect_Frozen in this; 						break;
			case EET_Tornado : 					effects[effect] = new W3Effect_Tornado in this; 					break;
			case EET_Trap : 					effects[effect] = new W3Effect_Trap in this; 						break;
			
			
			case EET_Bleeding :					effects[effect] = new W3Effect_Bleeding in this; 					break;
			case EET_BleedingTracking :			effects[effect] = new W3Effect_BleedingTracking in this;			break;
			case EET_Burning :					effects[effect] = new W3Effect_Burning in this; 					break;
			case EET_Poison :					effects[effect] = new W3Effect_Poison in this; 						break;
			case EET_PoisonCritical :			effects[effect] = new W3Effect_PoisonCritical in this; 				break;
			case EET_DoTHPRegenReduce : 		effects[effect] = new W3Effect_DoTHPRegenReduce in this; 			break;
			
			
			case EET_Toxicity :					effects[effect] = new W3Effect_Toxicity in this; 					break;
			case EET_VitalityDrain :			effects[effect] = new W3Effect_VitalityDrain in this; 				break;
			case EET_AirDrain :					effects[effect] = new W3Effect_AirDrain in this; 					break;
			case EET_AirDrainDive :				effects[effect] = new W3Effect_AirDrainDive in this;				break;
			case EET_StaminaDrainSwimming :		effects[effect] = new W3Effect_StaminaDrainSwimming in this;		break;
			case EET_StaminaDrain :				effects[effect] = new W3Effect_StaminaDrain in this;				break;
			
			
			case EET_BlackBlood :				effects[effect] = new W3Potion_BlackBlood in this; 					break;
			case EET_Blizzard :					effects[effect] = new W3Potion_Blizzard in this; 					break;
			case EET_Cat :						effects[effect] = new W3Potion_Cat in this; 						break;
			case EET_FullMoon :					effects[effect] = new W3Potion_FullMoon in this; 					break;
			case EET_GoldenOriole :				effects[effect] = new W3Potion_GoldenOriole in this; 				break;
			case EET_KillerWhale : 				effects[effect] = new W3Potion_KillerWhale in this;					break;
			case EET_MariborForest :			effects[effect] = new W3Potion_MariborForest in this; 				break;
			case EET_PetriPhiltre :				effects[effect] = new W3Potion_PetriPhiltre in this; 				break;
			case EET_Swallow :					effects[effect] = new W3Potion_Swallow in this; 					break;
			case EET_TawnyOwl :					effects[effect] = new W3Potion_TawnyOwl in this; 					break;
			
			case EET_ReinaldPhiltre :			effects[effect] = new W3Potion_ReinaldPhiltre in this; 				break;		
			
			case EET_Thunderbolt :				effects[effect] = new W3Potion_Thunderbolt in this; 				break;
			case EET_WhiteHoney :				effects[effect] = new W3Potion_WhiteHoney in this; 					break;
			case EET_WhiteRaffardDecoction :	effects[effect] = new W3Potion_WhiteRaffardDecoction in this; 		break;
			case EET_PheromoneNekker :			effects[effect] = new W3Potion_PheromoneNekker in this; 			break;
			case EET_PheromoneDrowner :			effects[effect] = new W3Potion_PheromoneDrowner in this; 			break;
			case EET_PheromoneBear :			effects[effect] = new W3Potion_PheromoneBear in this; 				break;
			
			
			case EET_AxiiGuardMe :				effects[effect] = new W3Effect_AxiiGuardMe in this; 				break;
			case EET_BattleTrance :				effects[effect] = new W3Effect_BattleTrance in this;				break;
			case EET_YrdenHealthDrain :			effects[effect] = new W3Effect_YrdenHealthDrain in this;			break;
			case EET_IgnorePain :				effects[effect] = new W3Effect_IgnorePain in this;					break;
			
			
			case EET_ShrineAard :				effects[effect] = new W3Effect_ShrineAard in this; 					break;
			case EET_ShrineAxii :				effects[effect] = new W3Effect_ShrineAxii in this; 					break;
			case EET_ShrineIgni :				effects[effect] = new W3Effect_ShrineIgni in this; 					break;
			case EET_ShrineQuen :				effects[effect] = new W3Effect_ShrineQuen in this; 					break;
			case EET_ShrineYrden:				effects[effect] = new W3Effect_ShrineYrden in this; 				break;
			case EET_EnhancedArmor:				effects[effect] = new W3Effect_EnhancedArmor in this; 				break;
			case EET_EnhancedWeapon:			effects[effect] = new W3Effect_EnhancedWeapon in this; 				break;
			
			
			case EET_AirBoost :					effects[effect] = new W3Effect_AirBoost in this;					break;
			case EET_Edible :					effects[effect] = new W3Effect_Edible in this; 						break;
			case EET_LowHealth :				effects[effect] = new W3Effect_LowHealth in this; 					break;
			case EET_Slowdown :					effects[effect] = new W3Effect_Slowdown in this; 					break;
			case EET_SlowdownFrost :			effects[effect] = new W3Effect_SlowdownFrost in this; 				break;
			case EET_SlowdownAxii :				effects[effect] = new W3Effect_SlowdownAxii in this; 				break;
			case EET_AbilityOnLowHealth: 		effects[effect] = new W3Effect_AbilityOnLowHP in this; 				break;
			case EET_Drowning: 					effects[effect] = new W3Effect_Drowning in this; 					break;
			case EET_Choking:					effects[effect] = new W3Effect_Choking in this;						break;
			case EET_OverEncumbered: 			effects[effect] = new W3Effect_OverEncumbered in this; 				break;
			case EET_SilverDust:				effects[effect] = new W3Effect_SilverDust in this; 					break;
			case EET_WeatherBonus: 				effects[effect] = new W3Effect_WeatherBonus in this; 				break;
			case EET_BoostedEssenceRegen :		effects[effect] = new W3Effect_BoostedEssenceRegen in this; 		break;
			case EET_BoostedStaminaRegen :		effects[effect] = new W3Effect_BoostedStaminaRegen in this; 		break;
			case EET_WellFed : 					effects[effect] = new W3Effect_WellFed in this;			 			break;
			case EET_WellHydrated :				effects[effect] = new W3Effect_WellHydrated in this;			 	break;
			case EET_Drunkenness :				effects[effect] = new W3Effect_Drunkenness in this;			 		break;
			case EET_WolfHour : 				effects[effect] = new W3Effect_WolfHour in this;			 		break;
			case EET_Weaken : 					effects[effect] = new W3Effect_Weaken in this;				 		break;
			case EET_Runeword8 : 				effects[effect] = new W3Effect_Runeword8 in this;			 		break;
			case EET_Oil :						effects[effect] = new W3Effect_Oil in this;			 				break;
			case EET_LynxSetBonus :				effects[effect] = new W3Effect_LynxSetBonus in this;				break;
			case EET_GryphonSetBonus :			effects[effect] = new W3Effect_GryphonSetBonus in this;				break;
			case EET_GryphonSetBonusYrden :		effects[effect] = new W3Effect_GryphonSetBonusYrden in this;		break;
			case EET_Mutation7Buff :			effects[effect] = new W3Effect_Mutation7Buff in this;				break;
			case EET_Mutation7Debuff :			effects[effect] = new W3Effect_Mutation7Debuff in this;				break;
			case EET_Mutation10 :				effects[effect] = new W3Effect_Mutation10 in this;					break;
			case EET_Mutation11Buff :			effects[effect] = new W3Effect_Mutation11Buff in this;				break;
			case EET_Mutation11Debuff :			effects[effect] = new W3Effect_Mutation11Debuff in this;			break;
			case EET_Perk21InternalCooldown :	effects[effect] = new W3Effect_Perk21InternalCooldown in this;		break;
			case EET_Mutation11Immortal :		effects[effect] = new W3Effect_Mutation11Immortal in this;			break;
			case EET_POIGorA10 :				effects[effect] = new W3Effect_POIGorA10Effect in this;				break;
			case EET_Mutation3 :				effects[effect] = new W3Effect_Mutation3 in this;					break;
			case EET_Mutation4 :				effects[effect] = new W3Effect_Mutation4 in this;					break;
			case EET_Mutation5 :				effects[effect] = new W3Effect_Mutation5 in this;					break;
			case EET_ToxicityVenom :			effects[effect] = new W3Effect_ToxicityVenom in this;				break;
			case EET_BasicQuen :				effects[effect] = new W3Effect_BasicQuen in this;					break;
			
			
			case EET_Fact : 					effects[effect] = new W3Potion_Fact in this;						break;
			
			
			case EET_StaggerAura :				effects[effect] = new W3StaggerAura in this;						break;
			case EET_FireAura :					effects[effect] = new W3FireAura in this;							break;
			case EET_WeakeningAura : 			effects[effect] = new W3WeakeningAura in this;						break;
			
			
			case EET_Bleeding1 :				effects[effect] = new W3Effect_Bleeding1 in this; 					break;
			case EET_Bleeding2 :				effects[effect] = new W3Effect_Bleeding2 in this; 					break;
			case EET_Bleeding3 :				effects[effect] = new W3Effect_Bleeding3 in this; 					break;
			
			
			default :
				found = false;
				break;
		}
		
		return found;
	}
	
	private function HACK_NO_MEMORY_TO_COMPILE_CacheEffect_Part2(effect : EEffectType) : bool
	{
		var found : bool;
		
		if(effects[effect])
		{
			LogAssert(false, "W3GameEffectManager.CacheEffect: Tries to cache already cached effect!");
			return false;
		}
		
		found = true;
	
		switch(effect)
		{
			
			case EET_Mutagen01 : 				effects[effect] = new W3Mutagen01_Effect in this;					break;
			case EET_Mutagen02 : 				effects[effect] = new W3Mutagen02_Effect in this;					break;
			case EET_Mutagen03 : 				effects[effect] = new W3Mutagen03_Effect in this;					break;
			case EET_Mutagen04 : 				effects[effect] = new W3Mutagen04_Effect in this;					break;
			case EET_Mutagen05 : 				effects[effect] = new W3Mutagen05_Effect in this;					break;
			case EET_Mutagen06 : 				effects[effect] = new W3Mutagen06_Effect in this;					break;
			case EET_Mutagen07 : 				effects[effect] = new W3Mutagen07_Effect in this;					break;
			case EET_Mutagen08 : 				effects[effect] = new W3Mutagen08_Effect in this;					break;
			case EET_Mutagen09 : 				effects[effect] = new W3Mutagen09_Effect in this;					break;
			case EET_Mutagen10 : 				effects[effect] = new W3Mutagen10_Effect in this;					break;
			case EET_Mutagen11 : 				effects[effect] = new W3Mutagen11_Effect in this;					break;
			case EET_Mutagen12 : 				effects[effect] = new W3Mutagen12_Effect in this;					break;
			case EET_Mutagen13 : 				effects[effect] = new W3Mutagen13_Effect in this;					break;
			case EET_Mutagen14 : 				effects[effect] = new W3Mutagen14_Effect in this;					break;
			case EET_Mutagen15 : 				effects[effect] = new W3Mutagen15_Effect in this;					break;
			case EET_Mutagen16 : 				effects[effect] = new W3Mutagen16_Effect in this;					break;
			case EET_Mutagen17 : 				effects[effect] = new W3Mutagen17_Effect in this;					break;
			case EET_Mutagen18 : 				effects[effect] = new W3Mutagen18_Effect in this;					break;
			case EET_Mutagen19 : 				effects[effect] = new W3Mutagen19_Effect in this;					break;
			case EET_Mutagen20 : 				effects[effect] = new W3Mutagen20_Effect in this;					break;
			case EET_Mutagen21 : 				effects[effect] = new W3Mutagen21_Effect in this;					break;
			case EET_Mutagen22 : 				effects[effect] = new W3Mutagen22_Effect in this;					break;
			case EET_Mutagen23 : 				effects[effect] = new W3Mutagen23_Effect in this;					break;
			case EET_Mutagen24 : 				effects[effect] = new W3Mutagen24_Effect in this;					break;
			case EET_Mutagen25 : 				effects[effect] = new W3Mutagen25_Effect in this;					break;
			case EET_Mutagen26 : 				effects[effect] = new W3Mutagen26_Effect in this;					break;
			case EET_Mutagen27 : 				effects[effect] = new W3Mutagen27_Effect in this;					break;
			case EET_Mutagen28 : 				effects[effect] = new W3Mutagen28_Effect in this;					break;
			
			
			case EET_Acid :						effects[effect] = new W3Effect_Acid in this;						break;
			case EET_WellRested :				effects[effect] = new W3Effect_WellRested in this;					break;
			case EET_HorseStableBuff :			effects[effect] = new W3Effect_HorseStableBuff in this;				break;
			case EET_BookshelfBuff :			effects[effect] = new W3Effect_BookshelfBuff in this;				break;
			case EET_PolishedGenitals :			effects[effect] = new W3Effect_PolishedGenitals in this;			break;
			case EET_Mutation12Cat :			effects[effect] = new W3Effect_Mutation12Cat in this;				break;
			case EET_Aerondight :				effects[effect] = new W3Effect_Aerondight in this;					break;
			
			default :
				found = false;
				break;
		}
		
		return found;
	}
	
	public function GetBuffResistStat(effect : EEffectType) : ECharacterDefenseStats
	{
		if(!effects[effect])
			CacheEffect(effect);
			
		if(!effects[effect])
			return CDS_None;
			
		return effects[effect].GetResistStat();
	}
	
	
	public function IsBuffNegative(effectType : EEffectType) : bool
	{
		if(!effects[effectType])
			CacheEffect(effectType);
			
		if(!effects[effectType])
			return false;
			
		return effects[effectType].IsNegative();
	}
		
	
	public function IsEffectNameValid( effectName : name ) : bool
	{
		var i,size : int;
		var effectType, tmp : string;
		
		if(!IsNameValid(effectName))
			return false;
			
		size = effectNames.Size();
		for(i=0; i<size; i+=1)
		{
			if(effectNames[i] == effectName)
			{
				return true;
			}
			else
			{
				
				StrSplitFirst(NameToString(effectName),"_",effectType,tmp);
				if(NameToString(effectNames[i]) == effectType)
					return true;
			}
		}
				
		return false;
	}	
		
	
	public function CheckInteractionWith(effectManager : W3EffectManager, effect : CBaseGameplayEffect, interactionEffects : array<CBaseGameplayEffect>, out overridenEffectsIdxs : array<int>, out cumulateIdx : int) : bool
	{
		var i, size, tmpCumulate : int;		
		var interactNew, interactOld : EEffectInteract;
		
		overridenEffectsIdxs.Clear();
		size = interactionEffects.Size();		
		cumulateIdx = -1;
		tmpCumulate = -1;
		for(i=size-1; i>=0; i-=1)
		{
			
			interactNew = effect.GetInteraction(interactionEffects[i]);
			interactOld = interactionEffects[i].GetInteraction(effect);
						
			
			if(interactOld == EI_Cumulate)
			{
				tmpCumulate = i ;
				continue;
			}
			
			
			if(interactNew == EI_Cumulate)
			{
				LogEffects("EffectManager.CheckInteraction: new effect <<" + interactionEffects[i] + ">> should be cumulated by old effect <<" + effect + ">> - older is better - DENY");
				return false;
			}
			
			
			if(interactNew == EI_Override)
				overridenEffectsIdxs.PushBack(i);	
			
			
			if(interactNew == EI_Deny)
			{
				LogEffects("EffectManager.CheckInteraction: new effect <<" + effect + ">> denies old effect <<" + interactionEffects[i] + ">> - old is removed");
				effectManager.RemoveEffect(interactionEffects[i], true);
				interactionEffects.Erase(i);
				return true;
			}
				
			
			if(interactOld == EI_Deny)
			{
				LogEffects("EffectManager.CheckInteraction: old effect <<" + interactionEffects[i] + ">> denies new effect <<" + effect + ">> - DENY");
				return false;
			}
			
			
			if(interactOld == EI_Override && interactNew == EI_Pass)
			{
				LogEffects("EffectManager.CheckInteraction: old effect <<" + interactionEffects[i] + ">> overrides new effect <<" + effect + ">> - DENY");
				return false;
			}					
		}
		
		cumulateIdx = tmpCumulate;		
		return true;
	}
}


function IsEffectNameValid( effectName : name ) : bool
{
	if(theGame.IsEffectManagerInitialized())
		return theGame.effectMgr.IsEffectNameValid( effectName );
	
	LogAssert(false, "IsEffectNameValid(): Game Effect Manager is not ready to handle this request!");
	return false;
}


function DecoctionEffectTypeToItemName( effectType : EEffectType ) : name
{
	var itemName : name;
	
	switch( effectType )
	{
		case EET_Mutagen01 : itemName = 'Mutagen 1';  break;
		case EET_Mutagen02 : itemName = 'Mutagen 2';  break;
		case EET_Mutagen03 : itemName = 'Mutagen 3';  break;
		case EET_Mutagen04 : itemName = 'Mutagen 4';  break;
		case EET_Mutagen05 : itemName = 'Mutagen 5';  break;
		case EET_Mutagen06 : itemName = 'Mutagen 6';  break;
		case EET_Mutagen07 : itemName = 'Mutagen 7';  break;
		case EET_Mutagen08 : itemName = 'Mutagen 8';  break;
		case EET_Mutagen09 : itemName = 'Mutagen 9';  break;
		case EET_Mutagen10 : itemName = 'Mutagen 10'; break;
		case EET_Mutagen11 : itemName = 'Mutagen 11'; break;
		case EET_Mutagen12 : itemName = 'Mutagen 12'; break;
		case EET_Mutagen13 : itemName = 'Mutagen 13'; break;
		case EET_Mutagen14 : itemName = 'Mutagen 14'; break;
		case EET_Mutagen15 : itemName = 'Mutagen 15'; break;
		case EET_Mutagen16 : itemName = 'Mutagen 16'; break;
		case EET_Mutagen17 : itemName = 'Mutagen 17'; break;
		case EET_Mutagen18 : itemName = 'Mutagen 18'; break;
		case EET_Mutagen19 : itemName = 'Mutagen 19'; break;
		case EET_Mutagen20 : itemName = 'Mutagen 20'; break;
		case EET_Mutagen21 : itemName = 'Mutagen 21'; break;
		case EET_Mutagen22 : itemName = 'Mutagen 22'; break;
		case EET_Mutagen23 : itemName = 'Mutagen 23'; break;
		case EET_Mutagen24 : itemName = 'Mutagen 24'; break;
		case EET_Mutagen25 : itemName = 'Mutagen 25'; break;
		case EET_Mutagen26 : itemName = 'Mutagen 26'; break;
		case EET_Mutagen27 : itemName = 'Mutagen 27'; break;
		case EET_Mutagen28 : itemName = 'Mutagen 28'; break;
		default			   : itemName = '';
	}
	
	return itemName;
}



function EffectNameToType(effectName : name, out type : EEffectType, out abilityName : name)
{
	var ret : bool;
	
	ret = HACK_NO_MEMORY_TO_COMPILE_EffectNameToType_Part1(effectName, type, abilityName);
	
	if(!ret)
		HACK_NO_MEMORY_TO_COMPILE_EffectNameToType_Part2(effectName, type, abilityName);
}

function HACK_NO_MEMORY_TO_COMPILE_EffectNameToType_Part1(effectName : name, out type : EEffectType, out abilityName : name) : bool
{
	var effectType, abilityNameStr : string;
	var found : bool;
	
	found = true;

	if(StrSplitFirst(NameToString(effectName),"_",effectType,abilityNameStr))
	{
		abilityName = effectName;	
	}
	else
	{
		effectType = effectName;	
		abilityName = '';
	}
	
	switch(effectType)
	{
		case "AutoEssenceRegen" : 							type = EET_AutoEssenceRegen; 			break;
		case "AutoMoraleRegen" : 							type = EET_AutoMoraleRegen;				break;
		case "AutoStaminaRegen" : 							type = EET_AutoStaminaRegen;			break;
		case "AutoVitalityRegen" : 							type = EET_AutoVitalityRegen; 			break;
		case "AutoAirRegen" : 								type = EET_AutoAirRegen; 				break;
		case "AutoSwimmingStaminaRegen" : 					type = EET_AutoSwimmingStaminaRegen; 	break;
		case "AutoPanicRegen" : 							type = EET_AutoPanicRegen; 				break;
		case "DoppelgangerEssenceRegen" : 					type = EET_DoppelgangerEssenceRegen; 	break;
		case "BoostedEssenceRegen" 	: 						type = EET_BoostedEssenceRegen; 		break;
		case "BoostedStaminaRegen" 	: 						type = EET_BoostedStaminaRegen; 		break;
		
		case "BlindnessEffect" : 							type = EET_Blindness; 					break;
		case "WraithBlindnessEffect" : 						type = EET_WraithBlindness; 			break;
		case "ConfusionEffect" : 							type = EET_Confusion; 					break;
		case "FrozenEffect" : 								type = EET_Frozen; 						break;
		case "TornadoEffect" : 								type = EET_Tornado; 					break;
		case "TrapEffect" : 								type = EET_Trap; 						break;
		case "HeavyKnockdownEffect" : 						type = EET_HeavyKnockdown; 				break;
		case "HypnotizedEffect" : 							type = EET_Hypnotized; 					break;
		case "WitchHypnotizedEffect" : 						type = EET_WitchHypnotized; 			break;
		case "ImmobilizedEffect" :						 	type = EET_Immobilized; 				break;
		case "KnockdownEffect" : 							type = EET_Knockdown; 					break;
		case "KnockdownTypeApplicator" : 					type = EET_KnockdownTypeApplicator; 	break;
		case "LongStaggerEffect" : 							type = EET_LongStagger; 				break;
		case "ParalyzedEffect" : 							type = EET_Paralyzed; 					break;
		case "PullEffect" : 								type = EET_Pull; 						break;
		case "TangledEffect" :								type = EET_Tangled; 					break;
		case "StaggerEffect" : 								type = EET_Stagger; 					break;
		case "SwarmEffect" :	 							type = EET_Swarm; 						break;
		case "SnowstormEffect" : 							type = EET_Snowstorm; 					break;
		case "SnowstormEffectQ403" : 						type = EET_SnowstormQ403; 				break;
		case "CounterStrikeHitEffect" : 					type = EET_CounterStrikeHit; 			break;
		case "RagdollEffect" : 								type = EET_Ragdoll; 					break;
		
		case "BleedingEffect" : 							type = EET_Bleeding; 					break;
		
		case "BleedingEffect1" : 							type = EET_Bleeding1; 					break;
		case "BleedingEffect2" : 							type = EET_Bleeding2; 					break;
		case "BleedingEffect3" : 							type = EET_Bleeding3; 					break;
		
		
		case "BleedingTrackingEffect" : 					type = EET_BleedingTracking; 			break;
		case "BurningEffect" : 								type = EET_Burning; 					break;
		case "PoisonEffect" : 								type = EET_Poison; 						break;
		case "PoisonCriticalEffect" : 						type = EET_PoisonCritical; 				break;
		case "DoTHPRegenReduceEffect" : 					type = EET_DoTHPRegenReduce; 			break;
		
		case "ToxicityEffect" : 							type = EET_Toxicity; 					break;
		case "VitalityDrainEffect" :						type = EET_VitalityDrain; 				break;
		case "AdrenalineDrainEffect" : 						type = EET_AdrenalineDrain; 			break;
		case "AirDrainEffect" : 							type = EET_AirDrain; 					break;
		case "AirDrainDiveEffect" : 						type = EET_AirDrainDive; 				break;
		case "StaminaDrainSwimmingEffect" : 				type = EET_StaminaDrainSwimming; 		break;
		case "StaminaDrainEffect" : 						type = EET_StaminaDrain; 				break;
		
		case "FactPotion" : 								type = EET_Fact; 						break;
		
		case "BlackBloodEffect" : 							type = EET_BlackBlood; 					break;
		case "BlizzardEffect" : 							type = EET_Blizzard; 					break;
		case "CatEffect" : 									type = EET_Cat; 						break;
		case "FullMoonEffect" : 							type = EET_FullMoon; 					break;
		case "GoldenOrioleEffect" : 						type = EET_GoldenOriole; 				break;
		case "KillerWhaleEffect" : 							type = EET_KillerWhale; 				break;
		case "MariborForestEffect" : 						type = EET_MariborForest; 				break;
		case "PetriPhiltreEffect" : 						type = EET_PetriPhiltre; 				break;
		case "SwallowEffect" : 								type = EET_Swallow; 					break;
		case "TawnyOwlEffect" : 							type = EET_TawnyOwl; 					break;
		
		
		case "ReinaldPhiltreEffect" : 						type = EET_ReinaldPhiltre; 				break;
		
		case "ThunderboltEffect" : 							type = EET_Thunderbolt; 				break;
		case "WhiteHoneyEffect" :							type = EET_WhiteHoney; 					break;
		case "WhiteRaffardDecoctionEffect" :				type = EET_WhiteRaffardDecoction; 		break;
		case "PheromoneEffectDrowner" : 					type = EET_PheromoneDrowner; 			break;
		case "PheromoneEffectNekker" : 						type = EET_PheromoneNekker; 			break;
		case "PheromoneEffectBear" : 						type = EET_PheromoneBear; 				break;
		
		case "AxiiGuardMeEffect" : 							type = EET_AxiiGuardMe; 				break;
		case "BattleTranceEffect" : 						type = EET_BattleTrance; 				break;
		case "YrdenHealthDrainEffect" : 					type = EET_YrdenHealthDrain; 			break;
		case "IgnorePainEffect" : 							type = EET_IgnorePain; 					break;
		
		case "ShrineAardEffect" : 							type = EET_ShrineAard; 					break;
		case "ShrineAxiiEffect" : 							type = EET_ShrineAxii; 					break;
		case "ShrineIgniEffect" : 							type = EET_ShrineIgni; 					break;
		case "ShrineQuenEffect" : 							type = EET_ShrineQuen; 					break;
		case "ShrineYrdenEffect" : 							type = EET_ShrineYrden; 				break;
		
		case "LowHealthEffect" : 							type = EET_LowHealth; 					break;
		case "SlowdownEffect" : 							type = EET_Slowdown; 					break;
		case "SlowdownFrostEffect"  :					 	type = EET_SlowdownFrost; 				break;
		case "SlowdownAxiiEffect" : 						type = EET_SlowdownAxii; 				break;
		case "EdibleEffect" : 								type = EET_Edible; 						break;
		case "AbilityOnLowHPEffect" :						type = EET_AbilityOnLowHealth;			break;
		case "DrowningEffect" :								type = EET_Drowning; 					break;
		case "ChokingEffect" : 								type = EET_Choking; 					break;
		case "WeatherBonusEffect" : 						type = EET_WeatherBonus; 				break;
		case "OverEncumberedEffect" : 						type = EET_OverEncumbered; 				break;
		case "SilverDustEffect" : 							type = EET_SilverDust; 					break;
		case "WellFedEffect" : 								type = EET_WellFed; 					break;
		case "WellHydratedEffect" : 						type = EET_WellHydrated; 				break;
		case "AirBoostEffect" : 							type = EET_AirBoost; 					break;
		case "DrunkennessEffect" :							type = EET_Drunkenness; 				break;
		case "EnhancedArmorEffect" : 						type = EET_EnhancedArmor; 				break;
		case "EnhancedWeaponEffect" : 						type = EET_EnhancedWeapon; 				break;
		case "WolfHourEffect" : 							type = EET_WolfHour; 					break;
		case "WeakenEffect" : 								type = EET_Weaken; 						break;
		case "Runeword8Effect" : 							type = EET_Runeword8; 					break;
		case "OilEffect" : 									type = EET_Oil; 						break;
		case "LynxSetBonusEffect" : 						type = EET_LynxSetBonus; 				break;
		case "GryphonSetBonusEffect" :						type = EET_GryphonSetBonus;				break;
		case "GryphonSetBonusYrdenEffect" : 				type = EET_GryphonSetBonusYrden; 		break;
		case "Mutation7BuffEffect" : 						type = EET_Mutation7Buff; 				break;
		case "Mutation7DebuffEffect" : 						type = EET_Mutation7Debuff; 			break;
		case "Mutation10Effect" :							type = EET_Mutation10;					break;
		case "Mutation11BuffEffect" :						type = EET_Mutation11Buff;				break;
		case "Mutation11DebuffEffect" :						type = EET_Mutation11Debuff;			break;
		case "Perk21InternalCooldownEffect" :				type = EET_Perk21InternalCooldown;		break;
		case "Mutation11ImmortalEffect" :					type = EET_Mutation11Immortal;			break;
		case "Mutation3Effect" :							type = EET_Mutation3; 					break;
		case "Mutation4Effect" :							type = EET_Mutation4; 					break;
		case "Mutation5Effect" :							type = EET_Mutation5; 					break;
		case "ToxicityVenomEffect" :						type = EET_ToxicityVenom;				break;
		case "BasicQuenEffect" : 							type = EET_BasicQuen;					break;
		
		
		case "StaggerAuraEffect" : 							type = EET_StaggerAura; 				break;
		case "FireAuraEffect" : 							type = EET_FireAura; 					break;
		case "WeakeningAuraEffect" : 						type = EET_WeakeningAura; 				break;		
		
		default :
			found = false;
			break;
	}
	
	return found;
}
		
function HACK_NO_MEMORY_TO_COMPILE_EffectNameToType_Part2(effectName : name, out type : EEffectType, out abilityName : name)
{
	var effectType, abilityNameStr : string;

	if(StrSplitFirst(NameToString(effectName),"_",effectType,abilityNameStr))
	{
		abilityName = effectName;	
	}
	else
	{
		effectType = effectName;	
		abilityName = '';
	}
	
	switch(effectType)
	{
		
		case "Mutagen01Effect" : type = EET_Mutagen01; break;
		case "Mutagen02Effect" : type = EET_Mutagen02; break;
		case "Mutagen03Effect" : type = EET_Mutagen03; break;
		case "Mutagen04Effect" : type = EET_Mutagen04; break;
		case "Mutagen05Effect" : type = EET_Mutagen05; break;
		case "Mutagen06Effect" : type = EET_Mutagen06; break;
		case "Mutagen07Effect" : type = EET_Mutagen07; break;
		case "Mutagen08Effect" : type = EET_Mutagen08; break;
		case "Mutagen09Effect" : type = EET_Mutagen09; break;
		case "Mutagen10Effect" : type = EET_Mutagen10; break;
		case "Mutagen11Effect" : type = EET_Mutagen11; break;
		case "Mutagen12Effect" : type = EET_Mutagen12; break;
		case "Mutagen13Effect" : type = EET_Mutagen13; break;
		case "Mutagen14Effect" : type = EET_Mutagen14; break;
		case "Mutagen15Effect" : type = EET_Mutagen15; break;
		case "Mutagen16Effect" : type = EET_Mutagen16; break;
		case "Mutagen17Effect" : type = EET_Mutagen17; break;
		case "Mutagen18Effect" : type = EET_Mutagen18; break;
		case "Mutagen19Effect" : type = EET_Mutagen19; break;
		case "Mutagen20Effect" : type = EET_Mutagen20; break;
		case "Mutagen21Effect" : type = EET_Mutagen21; break;
		case "Mutagen22Effect" : type = EET_Mutagen22; break;
		case "Mutagen23Effect" : type = EET_Mutagen23; break;
		case "Mutagen24Effect" : type = EET_Mutagen24; break;
		case "Mutagen25Effect" : type = EET_Mutagen25; break;
		case "Mutagen26Effect" : type = EET_Mutagen26; break;
		case "Mutagen27Effect" : type = EET_Mutagen27; break;
		case "Mutagen28Effect" : type = EET_Mutagen28; break;
		
		
		case "AcidEffect" :									type = EET_Acid;						break;
		case "WellRestedEffect" :							type = EET_WellRested;					break;
		case "HorseStableBuffEffect" :						type = EET_HorseStableBuff;				break;
		case "BookshelfBuffEffect" :						type = EET_BookshelfBuff;				break;
		case "PolishedGenitalsEffect" :						type = EET_PolishedGenitals;			break;		
		case "Mutation12CatEffect" :						type = EET_Mutation12Cat;				break;
		case "AerondightEffect" :							type = EET_Aerondight;					break;
		case "POIGorA10Effect" :							type = EET_POIGorA10;					break;
			
		default : 
			LogAssert(false, "EffectNameToType: Effect with name <<"+effectName+">> is not defined!");
			type = EET_Undefined;
			break;
	}
}



function EffectTypeToName(effectType : EEffectType) : name
{
	switch(effectType)
	{
		case EET_AutoEssenceRegen : 					return 'AutoEssenceRegen';
		case EET_AutoMoraleRegen : 						return 'AutoMoraleRegen';
		case EET_AutoStaminaRegen : 					return 'AutoStaminaRegen';
		case EET_AutoVitalityRegen : 					return 'AutoVitalityRegen';
		case EET_AutoAirRegen : 						return 'AutoAirRegen';
		case EET_AutoPanicRegen : 						return 'AutoPanicRegen';
		case EET_AutoSwimmingStaminaRegen : 			return 'AutoSwimmingStaminaRegen';
		case EET_BoostedEssenceRegen : 					return 'BoostedEssenceRegen';
		case EET_BoostedStaminaRegen : 					return 'BoostedStaminaRegen';
		
		case EET_Blindness : 							return 'BlindnessEffect';
		case EET_WraithBlindness : 						return 'WraithBlindnessEffect';
		case EET_Confusion : 							return 'ConfusionEffect';
		case EET_Frozen : 								return 'FrozenEffect';
		case EET_Tornado : 								return 'TornadoEffect';
		case EET_Trap : 								return 'TrapEffect';
		case EET_HeavyKnockdown : 						return 'HeavyKnockdownEffect';
		case EET_Hypnotized : 							return 'HypnotizedEffect';
		case EET_WitchHypnotized : 						return 'WitchHypnotizedEffect';
		case EET_Immobilized : 							return 'ImmobilizedEffect';
		case EET_Knockdown : 							return 'KnockdownEffect';
		case EET_KnockdownTypeApplicator : 				return 'KnockdownTypeApplicator';
		case EET_LongStagger : 							return 'LongStaggerEffect';
		case EET_Paralyzed : 							return 'ParalyzedEffect';
		case EET_Stagger : 								return 'StaggerEffect';
		case EET_Swarm : 								return 'SwarmEffect';
		case EET_Snowstorm : 							return 'SnowstormEffect';
		case EET_SnowstormQ403 : 						return 'SnowstormEffectQ403';
		case EET_CounterStrikeHit : 					return 'CounterStrikeHitEffect';
		case EET_Ragdoll : 								return 'RagdollEffect';
		
		case EET_Bleeding : 							return 'BleedingEffect';
		
		
		case EET_Bleeding1 : 							return 'BleedingEffect1';
		case EET_Bleeding2 : 							return 'BleedingEffect2';
		case EET_Bleeding3 : 							return 'BleedingEffect3';
		
		
		case EET_BleedingTracking :						return 'BleedingTrackingEffect';
		case EET_Burning : 								return 'BurningEffect';
		case EET_Poison : 								return 'PoisonEffect';
		case EET_PoisonCritical : 						return 'PoisonCriticalEffect';
		case EET_DoTHPRegenReduce : 					return 'DoTHPRegenReduceEffect';
		case EET_Acid :									return 'AcidEffect';
		
		case EET_Toxicity : 							return 'ToxicityEffect';
		case EET_AdrenalineDrain : 						return 'AdrenalineDrainEffect';
		case EET_AirDrain : 							return 'AirDrainEffect';
		case EET_AirDrainDive : 						return 'AirDrainDiveEffect';
		case EET_StaminaDrainSwimming : 				return 'StaminaDrainSwimmingEffect';
		case EET_StaminaDrain : 						return 'StaminaDrainEffect';
		case EET_VitalityDrain : 						return 'VitalityDrainEffect';
		
		case EET_Fact : 								return 'FactPotion';
		
		case EET_BlackBlood : 							return 'BlackBloodEffect';
		case EET_Blizzard : 							return 'BlizzardEffect';
		case EET_Cat : 									return 'CatEffect';
		case EET_Pull : 								return 'PullEffect';
		case EET_Tangled : 								return 'TangledEffect';
		case EET_FullMoon : 							return 'FullMoonEffect';
		case EET_GoldenOriole : 						return 'GoldenOrioleEffect';
		case EET_KillerWhale : 							return 'KillerWhaleEffect';
		case EET_MariborForest : 						return 'MariborForestEffect';
		case EET_PetriPhiltre : 						return 'PetriPhiltreEffect';
		case EET_Swallow : 								return 'SwallowEffect';
		case EET_TawnyOwl : 							return 'TawnyOwlEffect';
		
		
		case EET_ReinaldPhiltre : 						return 'ReinaldPhiltreEffect';
		
		case EET_Thunderbolt : 							return 'ThunderboltEffect';
		case EET_WhiteHoney : 							return 'WhiteHoneyEffect';
		case EET_WhiteRaffardDecoction : 				return 'WhiteRaffardDecoctionEffect';
		case EET_PheromoneNekker : 						return 'PheromoneEffectNekker';
		case EET_PheromoneDrowner : 					return 'PheromoneEffectDrowner';
		case EET_PheromoneBear : 						return 'PheromoneEffectBear';
		
		case EET_AxiiGuardMe : 							return 'AxiiGuardMeEffect';
		case EET_BattleTrance : 						return 'BattleTranceEffect';
		case EET_YrdenHealthDrain : 					return 'YrdenHealthDrainEffect';
		case EET_IgnorePain : 							return 'IgnorePainEffect';
		
		case EET_ShrineAard : 							return 'ShrineAardEffect';
		case EET_ShrineAxii : 							return 'ShrineAxiiEffect';
		case EET_ShrineIgni : 							return 'ShrineIgniEffect';
		case EET_ShrineQuen : 							return 'ShrineQuenEffect';
		case EET_ShrineYrden : 							return 'ShrineYrdenEffect';
		
		case EET_LowHealth : 							return 'LowHealthEffect';
		case EET_Slowdown : 							return 'SlowdownEffect';
		case EET_SlowdownFrost : 						return 'SlowdownFrostEffect';
		case EET_SlowdownAxii : 						return 'SlowdownAxiiEffect';
		case EET_Edible : 								return 'EdibleEffect';
		case EET_AbilityOnLowHealth : 					return 'AbilityOnLowHPEffect';
		case EET_Drowning : 							return 'DrowningEffect';
		case EET_Choking : 								return 'ChokingEffect';
		case EET_OverEncumbered : 						return 'OverEncumberedEffect';
		case EET_SilverDust : 							return 'SilverDustEffect';
		case EET_WeatherBonus : 						return 'WeatherBonusEffect';
		case EET_WellFed : 								return 'WellFedEffect';
		case EET_WellHydrated : 						return 'WellHydratedEffect';
		case EET_AirBoost : 							return 'AirBoostEffect';
		case EET_Drunkenness : 							return 'DrunkennessEffect';
		case EET_EnhancedArmor : 						return 'EnhancedArmorEffect';
		case EET_EnhancedWeapon : 						return 'EnhancedWeaponEffect';
		case EET_WolfHour : 							return 'WolfHourEffect';
		case EET_Weaken : 								return 'WeakenEffect';
		case EET_Runeword8 : 							return 'Runeword8Effect';
		case EET_Oil : 									return 'OilEffect';
		case EET_LynxSetBonus : 						return 'LynxSetBonusEffect';
		case EET_GryphonSetBonus: 						return 'GryphonSetBonusEffect';
		case EET_GryphonSetBonusYrden : 				return 'GryphonSetBonusYrdenEffect';
		case EET_Mutation7Buff : 						return 'Mutation7BuffEffect';
		case EET_Mutation7Debuff : 						return 'Mutation7DebuffEffect';
		case EET_Mutation10 :							return 'Mutation10Effect';
		case EET_Mutation11Buff :						return 'Mutation11BuffEffect';
		case EET_Mutation11Debuff :						return 'Mutation11DebuffEffect';
		case EET_Perk21InternalCooldown :				return 'Perk21InternalCooldownEffect';
		case EET_HorseStableBuff :						return 'HorseStableBuff';
		case EET_Mutation12Cat :						return 'Mutation12CatEffect';
		case EET_Mutation11Immortal :					return 'Mutation11ImmortalEffect';
		case EET_ToxicityVenom :						return 'ToxicityVenomEffect';
		case EET_BasicQuen :							return 'BasicQuenEffect';
		
		
		case EET_StaggerAura : 							return 'StaggerAuraEffect';
		case EET_FireAura : 							return 'FireAuraEffect';
		case EET_WeakeningAura :						return 'WeakeningAuraEffect';
		
		
		case EET_Mutagen01 : 							return 'Mutagen01Effect';
		case EET_Mutagen02 : 							return 'Mutagen02Effect';
		case EET_Mutagen03 : 							return 'Mutagen03Effect';
		case EET_Mutagen04 : 							return 'Mutagen04Effect';
		case EET_Mutagen05 : 							return 'Mutagen05Effect';
		case EET_Mutagen06 : 							return 'Mutagen06Effect';
		case EET_Mutagen07 : 							return 'Mutagen07Effect';
		case EET_Mutagen08 : 							return 'Mutagen08Effect';
		case EET_Mutagen09 : 							return 'Mutagen09Effect';
		case EET_Mutagen10 : 							return 'Mutagen10Effect';
		case EET_Mutagen11 : 							return 'Mutagen11Effect';
		case EET_Mutagen12 : 							return 'Mutagen12Effect';
		case EET_Mutagen13 : 							return 'Mutagen13Effect';
		case EET_Mutagen14 : 							return 'Mutagen14Effect';
		case EET_Mutagen15 : 							return 'Mutagen15Effect';
		case EET_Mutagen16 : 							return 'Mutagen16Effect';
		case EET_Mutagen17 : 							return 'Mutagen17Effect';
		case EET_Mutagen18 : 							return 'Mutagen18Effect';
		case EET_Mutagen19 : 							return 'Mutagen19Effect';
		case EET_Mutagen20 : 							return 'Mutagen20Effect';
		case EET_Mutagen21 : 							return 'Mutagen21Effect';
		case EET_Mutagen22 : 							return 'Mutagen22Effect';
		case EET_Mutagen23 : 							return 'Mutagen23Effect';
		case EET_Mutagen24 : 							return 'Mutagen24Effect';
		case EET_Mutagen25 : 							return 'Mutagen25Effect';
		case EET_Mutagen26 : 							return 'Mutagen26Effect';
		case EET_Mutagen27 : 							return 'Mutagen27Effect';
		case EET_Mutagen28 : 							return 'Mutagen28Effect';
		case EET_WellRested :							return 'WellRestedEffect';
		case EET_BookshelfBuff :						return 'BookshelfBuffEffect';
		case EET_PolishedGenitals :						return 'PolishedGenitalsEffect';
		case EET_Aerondight :							return 'AerondightEffect';
		case EET_POIGorA10 :							return 'POIGorA10Effect';
		case EET_Mutation3 :							return 'Mutation3Effect';
		case EET_Mutation4 :							return 'Mutation4Effect';
		case EET_Mutation5 :							return 'Mutation5Effect';
			
		default : 
			LogAssert(false, "EffectTypeToName: Effect type <<" + effectType + ">> is undefined!");
			return '';
	}
}


function IsBuffAutoBuff(effectType : EEffectType) : bool
{
	switch(effectType)
	{
		case EET_AutoVitalityRegen:
		case EET_AutoStaminaRegen:
		case EET_AutoEssenceRegen:
		case EET_AutoMoraleRegen :
		case EET_AutoAirRegen :
		case EET_AutoPanicRegen :
		case EET_AutoSwimmingStaminaRegen :
			return true;
		
		default:
			return false;
	}
}

function IsBuffShrine(effectType : EEffectType) : bool
{
	switch(effectType)
	{
		case EET_ShrineAard:
		case EET_ShrineAxii:
		case EET_ShrineIgni:
		case EET_ShrineQuen:
		case EET_ShrineYrden:
			return true;
			
		default:
			return false;
	}
	
	return false;
}