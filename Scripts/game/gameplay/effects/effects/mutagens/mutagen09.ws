/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen09_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen09;
	default dontAddAbilityOnTarget = true;
	
	private var hasAbility : bool;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		if(GetCurWeather() == EWE_Clear)
		{
			if(hasAbility)
			{
				target.RemoveAbility(abilityName);
				hasAbility = false;
			}
		}
		else
		{
			if(!hasAbility)
			{
				target.AddAbility(abilityName, false);
				hasAbility = true;
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		hasAbility = target.HasAbility(abilityName);
	}
}