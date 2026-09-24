/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_FullMoon extends W3ChangeMaxStatEffect
{
	default effectType = EET_FullMoon;
	default stat = BCS_Vitality;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() == 3)
		{
			thePlayer.GainStat(BCS_Vitality, thePlayer.GetStat(BCS_Toxicity));
		}
	}
}