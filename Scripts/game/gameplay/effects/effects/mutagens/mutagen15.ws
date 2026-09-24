/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen15_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen15;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(target.IsInCombat() && !target.HasAbility(abilityName))
			target.AddAbility(abilityName, false);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if(target.HasAbility(abilityName))
			target.RemoveAbility(abilityName);
	}
}