/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_ConvergenceTheory extends CBaseGameplayEffect
{
	protected var maxStacks : int;
	protected var currentStacks : int;

	default effectType = EET_ConvergenceTheory;
	default isPositive = true;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var skillLevel, i : int;

		skillLevel = thePlayer.GetSkillLevel(S_Magic_s37);
		
		super.OnEffectAdded(customParams);
		currentStacks = 1;
		maxStacks = 5;
		for (i=1; i<skillLevel; i+=1)
		{
			target.AddAbility( abilityName, true );
		}
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();

		GetWitcherPlayer().RemoveAbilityAll('ConvergenceTheoryEffect');
		GetWitcherPlayer().RemoveBuff( EET_ConvergenceTheory, false, "ConvergenceTheoryEffect" );
	}

	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		var skillLevel, i : int;

		skillLevel = thePlayer.GetSkillLevel(S_Magic_s37);

		if(abilityName == effect.abilityName && !dontAddAbilityOnTarget)
		{
			if( currentStacks < maxStacks )
			{
				currentStacks += 1;
				for (i=0; i<skillLevel; i+=1)
				{
					target.AddAbility( abilityName, true );
				}
			}
		}
			
		super.CumulateWith(effect);
	}
	
	public function GetStacks() : int
	{
		return currentStacks;
	}
};