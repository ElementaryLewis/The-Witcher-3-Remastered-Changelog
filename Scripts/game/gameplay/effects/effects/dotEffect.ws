/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3DamageOverTimeEffect extends CBaseGameplayEffect
{	
	protected saved var damages : array<SDoTDamage>;
	protected saved var powerStatType : ECharacterPowerStats;				
	protected saved var isEnvironment : bool;
	protected saved var hpRegenPauseStrength : SAbilityAttributeValue;		
	protected saved var hpRegenPauseExtraDuration : float;					
	
		default isEnvironment = false;
		default powerStatType = CPS_Undefined;		
		default isNegative = true;
		
	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		var attribs : array<name>;
		var min, max : SAbilityAttributeValue;
		var dot : SDoTDamage;
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, attribs);
		
		for(i=0; i<attribs.Size(); i+=1)
		{
			if(IsDamageTypeNameValid(attribs[i]))
			{
				dm.GetAbilityAttributeValue(abilityName, attribs[i], min, max);
			
				dot.damageTypeName = attribs[i];
				dot.hitsVitality = DamageHitsVitality(attribs[i]);		
				dot.hitsEssence = DamageHitsEssence(attribs[i]);
				dot.resistance = GetResistForDamage(dot.damageTypeName, true);
				
				damages.PushBack(dot);
				
				attributeName = attribs[i];
			}
			else
			{
				if(attribs[i] == 'hp_regen_reduction_strength')
				{
					dm.GetAbilityAttributeValue(abilityName, attribs[i], min, max);
					hpRegenPauseStrength = GetAttributeRandomizedValue(min, max);
				}
				else if(attribs[i] == 'hp_regen_reduction_duration')
				{
					dm.GetAbilityAttributeValue(abilityName, attribs[i], min, max);
					hpRegenPauseExtraDuration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				}
			}
		}
		
		if(damages.Size() == 0 && !((W3CriticalDOTEffect)this) )
		{
			LogAssert(false, "W3DamageOverTimeEffect.CacheSettings: effect <<" + this + ">> has no damage type defined!");
			return;
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3BuffDoTParams;
		var perk20Bonus :SAbilityAttributeValue;
		
		var skillPassiveMod : float; 
		
		params = (W3BuffDoTParams)customParams;
		if(params)
		{
			isEnvironment = params.isEnvironment;
		}
		
		
		if( params.isFromBomb )
		{
			skillPassiveMod = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('potion_duration'));
			effectValue.valueAdditive *= ( 1 + skillPassiveMod );
		}
		
		
		
		if( params.isPerk20Active )
		{
			perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
			effectValue = effectValue * ( 1 + perk20Bonus.valueMultiplicative );
		}
			
		AddHealthRegenReductionBuff();		
		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectAddedPost()
	{
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		
		super.OnEffectAddedPost();
	}
	
	
	private function AddHealthRegenReductionBuff()
	{
		var regenParams : SCustomEffectParams;
		
		if(hpRegenPauseExtraDuration > 0 && (hpRegenPauseStrength.valueAdditive > 0 || hpRegenPauseStrength.valueBase > 0 || hpRegenPauseStrength.valueMultiplicative > 0) )
		{
			regenParams.effectType = EET_DoTHPRegenReduce;
			regenParams.creator = GetCreator();
			regenParams.sourceName = sourceName;
			regenParams.duration = duration + hpRegenPauseExtraDuration;
			regenParams.effectValue = hpRegenPauseStrength;
			
			target.AddEffectCustom(regenParams);
		}
	}
	
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		AddHealthRegenReductionBuff();
	}
	
	
	event OnUpdate(dt : float)
	{	
		var dmg, maxVit, maxEss : float;
		var i : int;
		
		super.OnUpdate(dt);	
		
		if(!target.IsAlive())
			return true;
		
		
		maxVit = target.GetStatMax( BCS_Vitality);
		maxEss = target.GetStatMax( BCS_Essence);
		
		for(i=0; i<damages.Size(); i+=1)
		{
			dmg = CalculateDamage(i, maxVit, maxEss, dt);
				
			if( (!damages[i].hitsVitality && !damages[i].hitsEssence) || dmg <= 0)
			{
				LogAssert(false, "W3DamageOverTimeEffect: effect " + this + " on " + target.GetReadableName() + " is dealing no damage");
			}
			else
			{
				effectManager.CacheDamage(damages[i].damageTypeName, dmg, GetCreator(), this, dt, true, powerStatType, isEnvironment);		
			}
			
			
			if(effectValue.valueBase != 0)
				LogAssert(false, "W3DamageOverTimeEffect.OnUpdate: effect <<" + this + ">> has baseValue set which makes no sense!!!!");				
			else if(effectValue.valueMultiplicative == 1)
				LogAssert(false, "W3DamageOverTimeEffect.OnUpdate: effect <<" + this + ">> has valueMultiplicative set to 1 which results in 100% MAX HP damage /sec!!!!!");
		}
	}
	
	protected function CalculateDamage(arrayIndex : int, maxVit : float, maxEss : float, dt : float) : float
	{
		var dmg, dmgV, dmgE : float;
		
		if(damages[arrayIndex].hitsVitality)
		{
			dmgV = MaxF(0, dt * (effectValue.valueAdditive + (effectValue.valueMultiplicative * maxVit) ));
		}
		if(damages[arrayIndex].hitsEssence)
		{
			dmgE = MaxF(0, dt * (effectValue.valueAdditive + (effectValue.valueMultiplicative * maxEss) ));
		}
		
		dmg = MaxF(dmgE, dmgV);	
		return dmg;
	}
	
	protected function IsImmuneToAllDamage(dt : float) : bool
	{
		var i : int;
		var maxVit, maxEss : float;
		var immune : bool;
		var points, percents : float;
	
		maxVit = target.GetStatMax( BCS_Vitality);
		maxEss = target.GetStatMax( BCS_Essence);
				
		for(i=0; i<damages.Size(); i+=1)
		{
			target.GetResistValue(damages[i].resistance, points, percents);
			if(points < CalculateDamage(i, maxVit, maxEss, dt) && percents < 1)
				return false;
		}
		
		return true;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		
		if(duration >= 0.f && duration < 0.1f)
		{
			duration = 0.f;
			LogEffects("W3DamageOverTimeEffect.CalculateDuration(): final duration is below 0.1, setting to 0");
		}
	}
	
	public final function GetDamages() : array<SRawDamage>
	{
		var raw : SRawDamage;
		var i : int;
		var maxVit, maxEss : float;
		var ret : array<SRawDamage>;
		
		maxVit = target.GetStatMax( BCS_Vitality);
		maxEss = target.GetStatMax( BCS_Essence);
		
		for(i=0; i<damages.Size(); i+=1)
		{			
			raw.dmgType = damages[i].damageTypeName;
			raw.dmgVal = CalculateDamage(i, maxVit, maxEss, 0.1f);
			
			ret.PushBack(raw);
		}
		
		return ret;
	}
}

class W3BuffDoTParams extends W3BuffCustomParams
{
	var isEnvironment : bool;			
	var isPerk20Active : bool;			
	var isFromBomb 		: bool; 
}