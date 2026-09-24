/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutagen26_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen26;
	
	public final function GetReturnedDamage(out points : float, out percents : float)
	{
		var min, max, dmg : SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'returned_damage', min, max);
		dmg = GetAttributeRandomizedValue(min, max);
		
		points = dmg.valueAdditive;
		percents = dmg.valueMultiplicative;
	}
}