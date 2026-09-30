/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AbilityOnLowHP extends CBaseGameplayEffect
{
	private var lowHPAbilityName : name;				

	default effectType = EET_AbilityOnLowHealth;
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;

	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		var attributes : array<name>;
	
		super.CacheSettings();
		
		attributeName = 'healthPercents';
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, attributes);
		for(i=0; i<attributes.Size(); i+=1)
		{
			if(dm.IsAbilityDefined(attributes[i]))
			{
				lowHPAbilityName = attributes[i];
				break;
			}
		}
	}

	event OnUpdate(deltaTime : float)
	{
		super.OnUpdate(deltaTime);
		
		if(target.GetHealthPercents() * 100 <= effectValue.valueAdditive)
			target.AddAbility(lowHPAbilityName, false);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.RemoveAbility(lowHPAbilityName);		
	}
	
	
	
	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		
		if(lowHPAbilityName != ((W3Effect_AbilityOnLowHP)e).lowHPAbilityName)
			return EI_Pass;
			
		
		return super.GetSelfInteraction(e);
	}
}