/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen14_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen14;
	default dontAddAbilityOnTarget = true;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(target.IsInCombat())
			target.AddTimer('Mutagen14Timer', 2, true);
	}

	event OnEffectRemoved()
	{
		GetWitcherPlayer().RemoveTimer('Mutagen14Timer');
		
		super.OnEffectRemoved();
	}
}