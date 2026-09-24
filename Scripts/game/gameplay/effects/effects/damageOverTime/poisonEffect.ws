/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Poison extends W3DamageOverTimeEffect
{
	default effectType = EET_Poison;
	default resistStat = CDS_PoisonRes;
}