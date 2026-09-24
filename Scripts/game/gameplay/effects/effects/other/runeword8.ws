/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Runeword8 extends CBaseGameplayEffect
{
	private saved var focusDrainPerSec : float;
	default effectType = EET_Runeword8;
	default isPositive = true;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var val : SAbilityAttributeValue;
		var toxicity : W3Effect_Toxicity;
		
		target.AddAbility('Runeword 8 Regen');
		target.AddEffectDefault(EET_AdrenalineDrain, NULL, "runeword8");

		val = target.GetAttributeValue('focus_drain');
		focusDrainPerSec = val.valueMultiplicative;
		
		CalculateDuration();
		
		toxicity = (W3Effect_Toxicity)target.GetBuff(EET_Toxicity);
		if(toxicity)
			toxicity.RecalcEffectValue();
		
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		timeLeft = target.GetStatPercents(BCS_Focus) * initialDuration;
	}
	
	event OnEffectRemoved()
	{
		var toxicity : W3Effect_Toxicity;
		
		target.RemoveAbility('Runeword 8 Regen');
		
		toxicity = (W3Effect_Toxicity)target.GetBuff(EET_Toxicity);
		if(toxicity)
			toxicity.RecalcEffectValue();
			
		target.RemoveBuff(EET_AdrenalineDrain, , "runeword8");
			
		super.OnEffectRemoved();
	}
		
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		duration = target.GetStat(BCS_Focus) / focusDrainPerSec;
		initialDuration = duration;
		timeLeft = duration;
	}
}