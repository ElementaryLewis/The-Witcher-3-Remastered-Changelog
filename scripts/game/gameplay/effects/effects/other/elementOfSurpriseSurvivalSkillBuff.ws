/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_ElementOfSurprise extends CBaseGameplayEffect
{
	default effectType = EET_ElementOfSurprise;
	default isPositive = true;

	event OnEffectRemoved()
	{
		GetWitcherPlayer().RemoveBuff( EET_ElementOfSurprise, false, "ElementOfSurpriseEffect" );
	}
};