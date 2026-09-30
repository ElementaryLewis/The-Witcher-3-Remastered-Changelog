/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Catalyst extends CBaseGameplayEffect
{
	default effectType = EET_Catalyst;
	default isPositive = true;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var skillLevel, i : int;
		var player : CR4Player;

		super.OnEffectAdded(customParams);
		
		player = (CR4Player)target;
		if(player && player.CanUseSkill(S_Magic_s35))
		{
			skillLevel = player.GetSkillLevel(S_Magic_s35);

			
			for(i = 1; i < skillLevel; i+=1)
			{
				player.AddAbility( abilityName, true );
			}
		} 
		else
		{
			timeLeft = 0;
		}
	}

	event OnEffectRemoved()
	{
		var player : CR4Player;

		super.OnEffectRemoved();

		player = (CR4Player)target;
		if(player)
		{
			player.RemoveAbilityAll('CatalystEffect');
			player.RemoveBuff( EET_Catalyst, false, "CatalystEffect" );
		}
	}
};