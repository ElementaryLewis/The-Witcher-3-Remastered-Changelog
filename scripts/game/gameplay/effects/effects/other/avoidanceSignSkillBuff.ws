/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Avoidance extends CBaseGameplayEffect
{
	default effectType = EET_Avoidance;
	default isPositive = true;

	event OnEffectRemoved()
	{
		GetWitcherPlayer().RemoveBuff( EET_Avoidance, false, "AvoidanceEffect" );
	}
};