/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Resonance extends CBaseGameplayEffect
{
	default effectType = EET_Resonance;
	default isPositive = true;
    default duration = 15;

	event OnEffectRemoved()
	{
		if(GetWitcherPlayer())
		{
			GetWitcherPlayer().StopEffect('resonance_sword');
		}
	}
};