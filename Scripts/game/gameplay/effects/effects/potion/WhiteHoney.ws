/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_WhiteHoney extends CBaseGameplayEffect
{
	default effectType = EET_WhiteHoney;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var exceptions : array<CBaseGameplayEffect>;
		var wolf : CBaseGameplayEffect;
		
		super.OnEffectAdded(customParams);
		
		
		target.ForceSetStat(BCS_Toxicity, 0);
		
		
		exceptions.PushBack(this);
		wolf = thePlayer.GetBuff(EET_WolfHour);
		if(wolf)
			exceptions.PushBack(wolf);
			
		thePlayer.RemoveAllPotionEffects(exceptions);
		
		
		((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager).SetToxicityOffset(0.f);
	}
}