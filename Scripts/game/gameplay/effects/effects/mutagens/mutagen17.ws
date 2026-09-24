/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen17_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen17;
	default dontAddAbilityOnTarget = true;
	
	private var hasBoost : bool;
	
	event OnUpdate(dt : float)
	{
		var cnt : int;
		
		super.OnUpdate(dt);
		
		if(!hasBoost)
		{
			cnt = 0;
			
			
			
			if(FactsQuerySum("ach_attack_light") > 0)	cnt += 1;
			if(FactsQuerySum("ach_attack_heavy") > 0)	cnt += 1;
			
			if(FactsQuerySum("ach_counter") > 0)		cnt += 1;			
			if(FactsQuerySum("ach_sign") > 0)			cnt += 1;
			if(FactsQuerySum("ach_bomb") >0)			cnt += 1;
			if(FactsQuerySum("ach_crossbow") >0)		cnt += 1;
			
			if(cnt >= 3)
			{
				target.AddAbility(abilityName, false);
				hasBoost = true;
			}
		}
	}
	
	public function HasBoost() : bool
	{
		return hasBoost;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		target.RemoveAbility(abilityName);	
	}
	
	public function ClearBoost()
	{
		hasBoost = false;
		target.RemoveAbility(abilityName);
	}
}