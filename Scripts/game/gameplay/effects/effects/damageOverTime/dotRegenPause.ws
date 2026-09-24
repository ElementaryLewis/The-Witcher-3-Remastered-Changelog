/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_DoTHPRegenReduce extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_DoTHPRegenReduce;
	default attributeName = '';
	
	public function GetEffectValue() : SAbilityAttributeValue
	{
		return effectValue;
	}
}